import ContactsUI
import Flutter
import PDFKit
import UIKit
import UserNotifications
import VisionKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var contactPickerHandler: DeviceContactPickerHandler?
  private var receiptScannerHandler: ReceiptDocumentScannerHandler?
  private var storageCapacityHandler: StorageCapacityHandler?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    guard excludeApplicationSupportFromBackup() else { return false }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()
    contactPickerHandler = DeviceContactPickerHandler(
      messenger: messenger,
      presenter: { [weak self] in self?.topViewController() }
    )
    receiptScannerHandler = ReceiptDocumentScannerHandler(
      messenger: messenger,
      presenter: { [weak self] in self?.topViewController() }
    )
    storageCapacityHandler = StorageCapacityHandler(messenger: messenger)
  }

  private func topViewController() -> UIViewController? {
    let windows = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
    var controller = windows.first(where: { $0.isKeyWindow })?.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    return controller
  }

  private func excludeApplicationSupportFromBackup() -> Bool {
    guard var supportURL = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first else { return false }
    do {
      try FileManager.default.createDirectory(
        at: supportURL,
        withIntermediateDirectories: true
      )
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try supportURL.setResourceValues(values)
      return true
    } catch {
      return false
    }
  }
}

private final class DeviceContactPickerHandler: NSObject, CNContactPickerDelegate {
  private var pendingResult: FlutterResult?
  private let presenter: () -> UIViewController?

  init(messenger: FlutterBinaryMessenger, presenter: @escaping () -> UIViewController?) {
    self.presenter = presenter
    super.init()
    FlutterMethodChannel(
      name: "pl.budowapro/device_contacts",
      binaryMessenger: messenger
    ).setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      guard call.method == "pickPhoneContact" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard self.pendingResult == nil else {
        result(FlutterError(
          code: "contact_picker_busy",
          message: "A contact selection is already active",
          details: nil
        ))
        return
      }
      guard let presenter = self.presenter() else {
        result(FlutterError(
          code: "contact_picker_unavailable",
          message: "No view controller is available",
          details: nil
        ))
        return
      }
      let picker = CNContactPickerViewController()
      picker.delegate = self
      self.pendingResult = result
      presenter.present(picker, animated: true)
    }
  }

  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    finish(with: contact, picker: picker)
  }

  func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    let result = pendingResult
    pendingResult = nil
    picker.dismiss(animated: true) { result?(nil) }
  }

  private func finish(with contact: CNContact, picker: CNContactPickerViewController) {
    let result = pendingResult
    pendingResult = nil
    let name = CNContactFormatter.string(from: contact, style: .fullName)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let phone = contact.phoneNumbers.first?.value.stringValue
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let payload: [String: String]?
    if let name, !name.isEmpty, let phone, !phone.isEmpty {
      payload = ["displayName": name, "phone": phone]
    } else {
      payload = nil
    }
    picker.dismiss(animated: true) {
      if let payload {
        result?(payload)
      } else {
        result?(FlutterError(
          code: "contact_read_failed",
          message: "The selected contact has no phone number",
          details: nil
        ))
      }
    }
  }
}

private final class ReceiptDocumentScannerHandler: NSObject, VNDocumentCameraViewControllerDelegate {
  private var pendingResult: FlutterResult?
  private let presenter: () -> UIViewController?

  init(messenger: FlutterBinaryMessenger, presenter: @escaping () -> UIViewController?) {
    self.presenter = presenter
    super.init()
    FlutterMethodChannel(
      name: "pl.budowapro/receipt_scanner",
      binaryMessenger: messenger
    ).setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      guard call.method == "scan" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard self.pendingResult == nil else {
        result(FlutterError(
          code: "scanner_busy",
          message: "A scan is already active",
          details: nil
        ))
        return
      }
      guard VNDocumentCameraViewController.isSupported, let presenter = self.presenter() else {
        result(FlutterError(
          code: "scanner_unavailable",
          message: "Document scanning is not available",
          details: nil
        ))
        return
      }
      let scanner = VNDocumentCameraViewController()
      scanner.delegate = self
      self.pendingResult = result
      presenter.present(scanner, animated: true)
    }
  }

  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    let result = pendingResult
    pendingResult = nil
    controller.dismiss(animated: true) { result?(nil) }
  }

  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFailWithError error: Error
  ) {
    let result = pendingResult
    pendingResult = nil
    controller.dismiss(animated: true) {
      result?(FlutterError(
        code: "scanner_failed",
        message: error.localizedDescription,
        details: nil
      ))
    }
  }

  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFinishWith scan: VNDocumentCameraScan
  ) {
    let result = pendingResult
    pendingResult = nil
    let pageCount = min(scan.pageCount, 20)
    let fileURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("budowapro-receipt-\(UUID().uuidString).pdf")
    do {
      guard pageCount > 0 else {
        throw NSError(
          domain: "BudowaPRO",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "The scan has no pages"]
        )
      }
      let document = PDFDocument()
      for index in 0..<pageCount {
        guard let page = PDFPage(image: scan.imageOfPage(at: index)) else {
          throw NSError(
            domain: "BudowaPRO",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Could not encode a scanned page"]
          )
        }
        document.insert(page, at: index)
      }
      guard document.write(to: fileURL) else {
        throw NSError(
          domain: "BudowaPRO",
          code: 3,
          userInfo: [NSLocalizedDescriptionKey: "Could not save the scanned document"]
        )
      }
      controller.dismiss(animated: true) { result?(fileURL.path) }
    } catch {
      controller.dismiss(animated: true) {
        result?(FlutterError(
          code: "scanner_failed",
          message: error.localizedDescription,
          details: nil
        ))
      }
    }
  }
}

private final class StorageCapacityHandler {
  init(messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(
      name: "pl.budowapro/storage",
      binaryMessenger: messenger
    ).setMethodCallHandler { call, result in
      guard call.method == "availableBytes" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let arguments = call.arguments as? [String: Any]
      let path = arguments?["path"] as? String ?? NSHomeDirectory()
      do {
        let attributes = try FileManager.default.attributesOfFileSystem(forPath: path)
        if let free = attributes[.systemFreeSize] as? NSNumber {
          result(free.int64Value)
        } else {
          result(FlutterError(
            code: "storage_unavailable",
            message: "Available storage could not be read",
            details: nil
          ))
        }
      } catch {
        result(FlutterError(
          code: "storage_unavailable",
          message: error.localizedDescription,
          details: nil
        ))
      }
    }
  }
}
