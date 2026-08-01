import 'dart:io';
import 'dart:typed_data';

import 'package:budowapro/features/punch_list/data/protocol_pdf_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a local PDF with Polish text and defect rows', () async {
    final font = await File('assets/fonts/Roboto-Regular.ttf').readAsBytes();

    final bytes = await ProtocolPdfBuilder.build(_request(), fontBytes: font);

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('shares a temporary PDF and removes it afterwards', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'budowapro_protocol_pdf_test_',
    );
    addTearDown(() async {
      if (temporary.existsSync()) await temporary.delete(recursive: true);
    });
    final font = await File('assets/fonts/Roboto-Regular.ttf').readAsBytes();
    String? sharedPath;
    late Uint8List sharedBytes;
    final gateway = LocalProtocolPdfGateway(
      fontLoader: () async => ByteData.sublistView(font),
      outputDirectoryProvider: () async => temporary,
      shareFile: (file, title) async {
        expect(title, 'Protokół odbioru');
        expect(await file.exists(), isTrue);
        sharedPath = file.path;
        sharedBytes = await file.readAsBytes();
      },
    );

    await gateway.share(request: _request(), fileStem: 'protocol/unsafe');

    expect(String.fromCharCodes(sharedBytes.take(5)), '%PDF-');
    expect(sharedPath, endsWith('protocol_unsafe.pdf'));
    expect(await File(sharedPath!).exists(), isFalse);
  });
}

ProtocolPdfRequest _request() => ProtocolPdfRequest(
  projectName: 'Dom w Sosnowcu',
  protocolTitle: 'Odbiór przejść instalacyjnych',
  inspectedAt: '31.07.2026',
  status: 'Gotowy do podpisu',
  stage: 'Stan zero',
  room: 'Kotłownia',
  contractor: 'Jan Kowalski',
  notes: 'Sprawdzono szczelność i dokumentację zdjęciową.',
  defects: const <ProtocolPdfDefectRow>[
    ProtocolPdfDefectRow(
      title: 'Nieszczelne przejście rury przez fundament',
      severity: 'Krytyczna',
      status: 'Do ponownej kontroli',
      deadline: '05.08.2026',
    ),
  ],
  labels: const ProtocolPdfLabels(
    documentTitle: 'Protokół odbioru',
    project: 'Projekt',
    date: 'Data odbioru',
    status: 'Status protokołu',
    stage: 'Etap',
    room: 'Pomieszczenie lub strefa',
    contractor: 'Wykonawca',
    notes: 'Ustalenia i uwagi z odbioru',
    defects: 'Usterki w protokole',
    defectTitle: 'Usterka',
    severity: 'Ważność',
    deadline: 'Termin',
    noDefects: 'Brak powiązanych usterek',
    signatures: 'Potwierdzenie odbioru',
    investorSignature: 'Podpis inwestora',
    contractorSignature: 'Podpis wykonawcy',
    generatedNotice:
        'Dokument wygenerowany lokalnie. Sam wydruk nie zastępuje podpisanego protokołu.',
  ),
);
