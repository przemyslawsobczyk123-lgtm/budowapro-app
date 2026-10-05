import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:budowapro/features/costs/data/cost_spreadsheet_parser.dart';
import 'package:budowapro/features/costs/domain/cost_spreadsheet_import.dart';
import 'package:excel_community/excel_community.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an Excel-compatible CSV and detects its header', () async {
    final table = await const CostSpreadsheetParser().parse(
      fileName: 'kosztorys.csv',
      bytes: Uint8List.fromList(
        utf8.encode('\uFEFFNazwa materiału;Koszt\r\nBeton B20;1 234,56\r\n'),
      ),
    );

    expect(table.headerDetected, isTrue);
    expect(table.columns, <String>['Nazwa materiału', 'Koszt']);
    expect(table.rows.single.sourceRowNumber, 2);
    expect(table.rows.single.cells, <String>['Beton B20', '1 234,56']);
  });

  test('keeps the first row as data when the file has no header', () async {
    final table = await const CostSpreadsheetParser().parse(
      fileName: 'kosztorys.csv',
      bytes: Uint8List.fromList(
        utf8.encode('Beton B20\t1234.56\r\nStal\t800\r\n'),
      ),
    );

    expect(table.headerDetected, isFalse);
    expect(table.columns, <String>['', '']);
    expect(table.rows.map((row) => row.sourceRowNumber), <int>[1, 2]);
  });

  test('parses the first non-empty XLSX worksheet', () async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Kosztorys'];
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Nazwa');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Kwota');
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('Cegła');
    sheet.cell(CellIndex.indexByString('B2')).value = const DoubleCellValue(
      349.9,
    );
    final encoded = workbook.save();

    final table = await const CostSpreadsheetParser().parse(
      fileName: 'kosztorys.xlsx',
      bytes: Uint8List.fromList(encoded!),
    );

    expect(table.sheetName, 'Kosztorys');
    expect(table.headerDetected, isTrue);
    expect(table.rows.single.cells, <String>['Cegła', '349.9']);
  });

  test('rejects an XLSX containing an unsafe archive path', () async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Kosztorys'];
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Nazwa');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Kwota');
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('Beton');
    sheet.cell(CellIndex.indexByString('B2')).value = const IntCellValue(100);
    final archive = ZipDecoder().decodeBytes(workbook.save()!);
    archive.add(ArchiveFile.string('../outside.xml', 'unsafe'));
    final encoded = ZipEncoder().encode(archive);

    await expectLater(
      const CostSpreadsheetParser().parse(
        fileName: 'niebezpieczny.xlsx',
        bytes: Uint8List.fromList(encoded),
      ),
      throwsA(
        isA<CostSpreadsheetImportException>().having(
          (error) => error.code,
          'code',
          CostSpreadsheetImportError.unreadableFile,
        ),
      ),
    );
  });

  test('rejects an XLSX containing duplicate archive paths', () async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Kosztorys'];
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Nazwa');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Kwota');
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('Beton');
    sheet.cell(CellIndex.indexByString('B2')).value = const IntCellValue(100);
    final archive = ZipDecoder().decodeBytes(workbook.save()!);
    const placeholder = 'duplicate_entry.xml';
    const duplicate = '[Content_Types].xml';
    archive.add(ArchiveFile.string(placeholder, 'duplicate'));
    final encoded = ZipEncoder().encode(archive);
    final placeholderBytes = utf8.encode(placeholder);
    final duplicateBytes = utf8.encode(duplicate);
    for (var offset = 0; offset <= encoded.length - placeholderBytes.length;) {
      var matches = true;
      for (var index = 0; index < placeholderBytes.length; index++) {
        if (encoded[offset + index] != placeholderBytes[index]) {
          matches = false;
          break;
        }
      }
      if (!matches) {
        offset++;
        continue;
      }
      encoded.setRange(offset, offset + duplicateBytes.length, duplicateBytes);
      offset += duplicateBytes.length;
    }

    await expectLater(
      const CostSpreadsheetParser().parse(
        fileName: 'duplikat.xlsx',
        bytes: Uint8List.fromList(encoded),
      ),
      throwsA(
        isA<CostSpreadsheetImportException>().having(
          (error) => error.code,
          'code',
          CostSpreadsheetImportError.unreadableFile,
        ),
      ),
    );
  });

  test('rejects more than the supported number of data rows', () async {
    final rows = StringBuffer('Nazwa;Koszt\n');
    for (
      var index = 0;
      index <= CostSpreadsheetParser.maximumDataRows;
      index++
    ) {
      rows.writeln('Pozycja $index;1,00');
    }

    expect(
      () => const CostSpreadsheetParser().parse(
        fileName: 'za-duzy.csv',
        bytes: Uint8List.fromList(utf8.encode(rows.toString())),
      ),
      throwsA(
        isA<CostSpreadsheetImportException>().having(
          (error) => error.code,
          'code',
          CostSpreadsheetImportError.tooManyRows,
        ),
      ),
    );
  });
}
