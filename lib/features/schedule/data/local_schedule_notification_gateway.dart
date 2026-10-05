import 'package:budowapro/features/schedule/data/schedule_notification_payload.dart';
import 'package:budowapro/features/schedule/data/schedule_reminder_time.dart';
import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/features/schedule/domain/schedule_notification_gateway.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _scheduleChannelId = 'budowapro_schedule_reminders';
const _scheduleChannelName = 'Terminy budowy';
const _scheduleChannelDescription =
    'Przypomnienia o zadaniach, wizytach, dostawach, odbiorach i platnosciach.';

const scheduleNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    _scheduleChannelId,
    _scheduleChannelName,
    channelDescription: _scheduleChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
    visibility: NotificationVisibility.secret,
  ),
  iOS: DarwinNotificationDetails(
    presentAlert: true,
    presentBanner: true,
    presentList: true,
    presentSound: true,
  ),
);

final class LocalScheduleNotificationGateway
    implements ScheduleNotificationGateway {
  LocalScheduleNotificationGateway({
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? utcNow,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _utcNow = utcNow ?? DateTime.now;

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _utcNow;
  bool _initialized = false;
  bool _timeZonesInitialized = false;
  String? _currentTimeZoneId;
  void Function(ScheduleNotificationTarget target)? _onOpen;

  @override
  Future<void> initialize(
    void Function(ScheduleNotificationTarget target) onOpen,
  ) async {
    _onOpen = onOpen;
    if (_initialized) return;
    await _initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        // A bare name is looked up as a drawable only; the launcher icon is a
        // mipmap, so 'ic_launcher' failed with invalid_icon and no reminder
        // could ever be scheduled. Kept from shrinking by res/raw/keep.xml.
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        _openPayload(response.payload);
      },
    );
    _initialized = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _openPayload(launch?.notificationResponse?.payload);
    }
  }

  @override
  Future<NotificationPermissionState> permissionState() async {
    await _ensureInitialized();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final enabled = await android.areNotificationsEnabled();
      return enabled == true
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final permissions = await ios.checkPermissions();
      return permissions?.isEnabled == true
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }
    return NotificationPermissionState.unavailable;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    await _ensureInitialized();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted == true
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted == true
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }
    return NotificationPermissionState.unavailable;
  }

  @override
  Future<void> schedule(ScheduleNotificationRequest request) async {
    await _ensureInitialized();
    final event = request.event;
    if (!event.reminderEnabled ||
        event.isResolved ||
        !request.preferences.isEnabledFor(event.kind)) {
      await cancel(event);
      return;
    }
    if (await permissionState() != NotificationPermissionState.granted) return;
    final location = _location(event.timeZoneId);
    final scheduledAt = ScheduleReminderTime.resolve(
      event: event,
      preferences: request.preferences,
      location: location,
    );
    if (!scheduledAt.toUtc().isAfter(_utcNow().toUtc())) {
      await cancel(event);
      return;
    }
    await _plugin.zonedSchedule(
      id: scheduleNotificationId(event.projectId, event.id),
      title: request.title,
      body: request.body,
      scheduledDate: scheduledAt,
      notificationDetails: scheduleNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: ScheduleNotificationPayload.encode(
        ScheduleNotificationTarget(
          projectId: event.projectId,
          eventId: event.id,
        ),
      ),
    );
  }

  @override
  Future<void> cancel(ScheduleEvent event) {
    return _plugin.cancel(
      id: scheduleNotificationId(event.projectId, event.id),
    );
  }

  @override
  Future<String> currentTimeZoneId() async {
    await _initializeTimeZones();
    return _currentTimeZoneId!;
  }

  @override
  DateTime toTimeZone(DateTime instant, String timeZoneId) {
    return tz.TZDateTime.from(instant.toUtc(), _location(timeZoneId));
  }

  @override
  DateTime fromWallTime(DateTime wallTime, String timeZoneId) {
    final location = _location(timeZoneId);
    return tz.TZDateTime(
      location,
      wallTime.year,
      wallTime.month,
      wallTime.day,
      wallTime.hour,
      wallTime.minute,
    ).toUtc();
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize(_onOpen ?? (_) {});
    }
  }

  Future<void> _initializeTimeZones() async {
    if (_timeZonesInitialized) return;
    tz_data.initializeTimeZones();
    var identifier = 'Etc/UTC';
    try {
      identifier = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(identifier));
    } on Object {
      tz.setLocalLocation(tz.UTC);
      identifier = 'Etc/UTC';
    }
    _currentTimeZoneId = identifier;
    _timeZonesInitialized = true;
  }

  tz.Location _location(String identifier) {
    try {
      return tz.getLocation(identifier);
    } on tz.LocationNotFoundException {
      return tz.local;
    }
  }

  void _openPayload(String? payload) {
    final target = ScheduleNotificationPayload.decode(payload);
    if (target != null) _onOpen?.call(target);
  }
}

int scheduleNotificationId(String projectId, String eventId) {
  var hash = 0x811c9dc5;
  for (final unit in '$projectId:$eventId'.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}
