import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

typedef ProtocolPdfFontLoader = Future<ByteData> Function();
typedef ProtocolPdfDirectoryProvider = Future<Directory> Function();
typedef ProtocolPdfShareFile = Future<void> Function(File file, String title);

final class ProtocolPdfLabels {
  const ProtocolPdfLabels({
    required this.documentTitle,
    required this.project,
    required this.date,
    required this.status,
    required this.stage,
    required this.room,
    required this.contractor,
    required this.notes,
    required this.defects,
    required this.defectTitle,
    required this.severity,
    required this.deadline,
    required this.noDefects,
    required this.signatures,
    required this.investorSignature,
    required this.contractorSignature,
    required this.generatedNotice,
  });

  final String documentTitle;
  final String project;
  final String date;
  final String status;
  final String stage;
  final String room;
  final String contractor;
  final String notes;
  final String defects;
  final String defectTitle;
  final String severity;
  final String deadline;
  final String noDefects;
  final String signatures;
  final String investorSignature;
  final String contractorSignature;
  final String generatedNotice;
}

final class ProtocolPdfDefectRow {
  const ProtocolPdfDefectRow({
    required this.title,
    required this.severity,
    required this.status,
    this.deadline,
  });

  final String title;
  final String severity;
  final String status;
  final String? deadline;
}

final class ProtocolPdfRequest {
  ProtocolPdfRequest({
    required this.projectName,
    required this.protocolTitle,
    required this.inspectedAt,
    required this.status,
    required this.labels,
    required Iterable<ProtocolPdfDefectRow> defects,
    this.stage,
    this.room,
    this.contractor,
    this.notes,
  }) : defects = List<ProtocolPdfDefectRow>.unmodifiable(defects);

  final String projectName;
  final String protocolTitle;
  final String inspectedAt;
  final String status;
  final ProtocolPdfLabels labels;
  final List<ProtocolPdfDefectRow> defects;
  final String? stage;
  final String? room;
  final String? contractor;
  final String? notes;
}

abstract interface class ProtocolPdfGateway {
  Future<void> share({
    required ProtocolPdfRequest request,
    required String fileStem,
  });
}

final class LocalProtocolPdfGateway implements ProtocolPdfGateway {
  factory LocalProtocolPdfGateway.forDevice() => LocalProtocolPdfGateway(
    fontLoader: () => rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    outputDirectoryProvider: () async {
      final temporary = await getTemporaryDirectory();
      return Directory(p.join(temporary.path, 'budowapro-exports'));
    },
    shareFile: (file, title) => SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: 'application/pdf')],
        title: title,
      ),
    ),
  );

  factory LocalProtocolPdfGateway({
    required ProtocolPdfFontLoader fontLoader,
    required ProtocolPdfDirectoryProvider outputDirectoryProvider,
    required ProtocolPdfShareFile shareFile,
  }) =>
      LocalProtocolPdfGateway._(fontLoader, outputDirectoryProvider, shareFile);

  const LocalProtocolPdfGateway._(
    this._fontLoader,
    this._outputDirectoryProvider,
    this._shareFile,
  );

  final ProtocolPdfFontLoader _fontLoader;
  final ProtocolPdfDirectoryProvider _outputDirectoryProvider;
  final ProtocolPdfShareFile _shareFile;

  @override
  Future<void> share({
    required ProtocolPdfRequest request,
    required String fileStem,
  }) async {
    final directory = await _outputDirectoryProvider();
    await directory.create(recursive: true);
    final safeStem = fileStem.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
    final file = File(p.join(directory.path, '$safeStem.pdf'));
    try {
      final font = await _fontLoader();
      final bytes = await ProtocolPdfBuilder.build(
        request,
        fontBytes: font.buffer.asUint8List(
          font.offsetInBytes,
          font.lengthInBytes,
        ),
      );
      await file.writeAsBytes(bytes, flush: true);
      await _shareFile(file, request.labels.documentTitle);
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // The next private-cache cleanup retries app-owned export deletion.
      }
    }
  }
}

abstract final class ProtocolPdfBuilder {
  static Future<Uint8List> build(
    ProtocolPdfRequest request, {
    required Uint8List fontBytes,
  }) async {
    final font = pw.Font.ttf(ByteData.sublistView(fontBytes));
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );
    final labels = request.labels;
    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.fromLTRB(36, 40, 36, 36),
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blue700, width: 1.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'BudowaPRO',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                labels.documentTitle,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 18),
          pw.Text(
            labels.documentTitle,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            request.protocolTitle,
            style: const pw.TextStyle(fontSize: 14, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 18),
          _metadata(request),
          if (request.notes != null) ...[
            pw.SizedBox(height: 16),
            _sectionTitle(labels.notes),
            pw.SizedBox(height: 5),
            pw.Text(request.notes!),
          ],
          pw.SizedBox(height: 20),
          _sectionTitle(labels.defects),
          pw.SizedBox(height: 8),
          if (request.defects.isEmpty)
            pw.Text(labels.noDefects)
          else
            pw.TableHelper.fromTextArray(
              headers: <String>[
                labels.defectTitle,
                labels.severity,
                labels.status,
                labels.deadline,
              ],
              data: request.defects
                  .map(
                    (defect) => <String>[
                      defect.title,
                      defect.severity,
                      defect.status,
                      defect.deadline ?? '-',
                    ],
                  )
                  .toList(growable: false),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellPadding: const pw.EdgeInsets.all(6),
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: const <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(3.5),
                1: pw.FlexColumnWidth(1.2),
                2: pw.FlexColumnWidth(1.4),
                3: pw.FlexColumnWidth(1.2),
              },
            ),
          pw.SizedBox(height: 28),
          _sectionTitle(labels.signatures),
          pw.SizedBox(height: 34),
          pw.Row(
            children: [
              pw.Expanded(child: _signature(labels.investorSignature)),
              pw.SizedBox(width: 36),
              pw.Expanded(child: _signature(labels.contractorSignature)),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(9),
            decoration: pw.BoxDecoration(
              color: PdfColors.amber50,
              border: pw.Border.all(color: PdfColors.amber700, width: 0.6),
            ),
            child: pw.Text(
              labels.generatedNotice,
              style: const pw.TextStyle(fontSize: 8.5),
            ),
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _metadata(ProtocolPdfRequest request) {
    final labels = request.labels;
    final rows = <(String, String)>[
      (labels.project, request.projectName),
      (labels.date, request.inspectedAt),
      (labels.status, request.status),
      if (request.stage != null) (labels.stage, request.stage!),
      if (request.room != null) (labels.room, request.room!),
      if (request.contractor != null) (labels.contractor, request.contractor!),
    ];
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
      ),
      child: pw.Column(
        children: rows
            .map(
              (row) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 100,
                      child: pw.Text(
                        row.$1,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(child: pw.Text(row.$2)),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  static pw.Widget _sectionTitle(String text) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey900,
    ),
  );

  static pw.Widget _signature(String label) => pw.Column(
    children: [
      pw.Container(height: 1, color: PdfColors.grey700),
      pw.SizedBox(height: 5),
      pw.Text(label, style: const pw.TextStyle(fontSize: 8.5)),
    ],
  );
}
