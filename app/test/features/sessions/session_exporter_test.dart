import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_studio/src/database/models/measurement_models.dart';
import 'package:temperature_studio/src/features/sessions/services/session_exporter.dart';

RecordingSession _session({
  int id = 42,
  DateTime? start,
  String? note,
}) {
  return RecordingSession()
    ..id = id
    ..startTime = start ?? DateTime.utc(2026, 5, 13, 14, 23, 1)
    ..note = note;
}

TemperatureReading _reading(int sessionId, DateTime ts, double v) {
  return TemperatureReading()
    ..sessionId = sessionId
    ..timestamp = ts
    ..value = v;
}

SessionMarker _marker(int sessionId, DateTime ts, String label) {
  return SessionMarker()
    ..sessionId = sessionId
    ..timestamp = ts
    ..label = label;
}

void main() {
  group('buildSessionCsv', () {
    test('starts with UTF-8 BOM and has header row', () {
      final s = _session();
      final bytes = buildSessionCsv(SessionExportData(s, const []));
      expect(bytes[0], 0xEF);
      expect(bytes[1], 0xBB);
      expect(bytes[2], 0xBF);
      final text = utf8.decode(bytes.skip(3).toList());
      final firstLine = text.split('\n').first;
      expect(firstLine, 'timestamp_iso,elapsed_seconds,value_celsius,marker');
    });

    test('row count matches reading count', () {
      final start = DateTime.utc(2026, 1, 1);
      final s = _session(start: start);
      final readings = [
        _reading(s.id, start.add(const Duration(milliseconds: 100)), 23.45),
        _reading(s.id, start.add(const Duration(milliseconds: 250)), 23.47),
        _reading(s.id, start.add(const Duration(milliseconds: 999)), 24.10),
      ];
      final bytes = buildSessionCsv(SessionExportData(s, readings));
      final text = utf8.decode(bytes.skip(3).toList());
      final lines = text
          .split('\n')
          .where((l) => l.isNotEmpty)
          .toList();
      expect(lines.length, readings.length + 1); // header + data rows
    });

    test('elapsed_seconds formatted to 3 decimals', () {
      final start = DateTime.utc(2026, 1, 1);
      final s = _session(start: start);
      final readings = [
        _reading(s.id, start.add(const Duration(milliseconds: 333)), 20.0),
      ];
      final bytes = buildSessionCsv(SessionExportData(s, readings));
      final text = utf8.decode(bytes.skip(3).toList());
      final dataLine = text.split('\n').firstWhere((l) =>
          l.isNotEmpty && !l.startsWith('timestamp_iso'));
      final cells = dataLine.split(',');
      expect(cells[1], '0.333');
    });

    test('empty session produces header-only CSV', () {
      final bytes = buildSessionCsv(SessionExportData(_session(), const []));
      final text = utf8.decode(bytes.skip(3).toList());
      final lines = text.split('\n').where((l) => l.isNotEmpty).toList();
      expect(lines.length, 1);
      expect(lines.first, 'timestamp_iso,elapsed_seconds,value_celsius,marker');
    });

    test('attaches a marker to the nearest reading row', () {
      final start = DateTime.utc(2026, 1, 1);
      final s = _session(start: start);
      final readings = [
        _reading(s.id, start.add(const Duration(seconds: 1)), 20.0),
        _reading(s.id, start.add(const Duration(seconds: 2)), 21.0),
        _reading(s.id, start.add(const Duration(seconds: 3)), 22.0),
      ];
      // 2.1s is nearest the second reading (2s).
      final markers = [
        _marker(s.id, start.add(const Duration(milliseconds: 2100)), 'ice'),
      ];
      final bytes = buildSessionCsv(SessionExportData(s, readings, markers));
      final lines = utf8
          .decode(bytes.skip(3).toList())
          .split('\n')
          .where((l) => l.isNotEmpty)
          .toList();
      // header + 3 rows; marker only on the 2nd data row (index 2 overall).
      expect(lines[1].endsWith(','), isTrue); // reading 1: no marker
      expect(lines[2].endsWith(',ice'), isTrue); // reading 2: marker
      expect(lines[3].endsWith(','), isTrue); // reading 3: no marker
    });
  });

  group('buildSessionXlsx', () {
    test('produces decodable workbook with Metadata and Readings sheets', () {
      final start = DateTime.utc(2026, 1, 1, 12);
      final s = _session(start: start, note: 'first try');
      final readings = [
        _reading(s.id, start.add(const Duration(milliseconds: 100)), 21.0),
        _reading(s.id, start.add(const Duration(milliseconds: 200)), 21.5),
      ];
      final bytes = buildSessionXlsx(SessionExportData(s, readings));
      final decoded = Excel.decodeBytes(bytes);
      expect(decoded.sheets.keys, containsAll(['Metadata', 'Readings']));

      final meta = decoded['Metadata'];
      // Header row + 5 metadata rows
      expect(meta.maxRows, greaterThanOrEqualTo(6));

      final readingsSheet = decoded['Readings'];
      expect(readingsSheet.maxRows, readings.length + 1); // header + rows
    });

    test('empty session XLSX has reading_count 0 and header-only Readings', () {
      final bytes = buildSessionXlsx(SessionExportData(_session(), const []));
      final decoded = Excel.decodeBytes(bytes);
      final readingsSheet = decoded['Readings'];
      expect(readingsSheet.maxRows, 1); // header only

      final meta = decoded['Metadata'];
      // Find the reading_count row
      var foundZero = false;
      for (var r = 0; r < meta.maxRows; r++) {
        final keyCell = meta.cell(CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: r,
        ));
        if (keyCell.value is TextCellValue) {
          final txt = (keyCell.value as TextCellValue).value.toString();
          if (txt == 'reading_count') {
            final valueCell = meta.cell(CellIndex.indexByColumnRow(
              columnIndex: 1,
              rowIndex: r,
            ));
            expect(valueCell.value, isA<IntCellValue>());
            expect((valueCell.value as IntCellValue).value, 0);
            foundZero = true;
          }
        }
      }
      expect(foundZero, isTrue);
    });

    test('includes a Markers sheet listing every marker', () {
      final start = DateTime.utc(2026, 1, 1, 12);
      final s = _session(start: start);
      final readings = [
        _reading(s.id, start.add(const Duration(seconds: 1)), 21.0),
      ];
      final markers = [
        _marker(s.id, start.add(const Duration(milliseconds: 900)), 'touched'),
        _marker(s.id, start.add(const Duration(seconds: 1)), 'breath'),
      ];
      final bytes = buildSessionXlsx(SessionExportData(s, readings, markers));
      final decoded = Excel.decodeBytes(bytes);
      expect(decoded.sheets.keys, contains('Markers'));
      final markersSheet = decoded['Markers'];
      expect(markersSheet.maxRows, markers.length + 1); // header + markers
    });
  });

  group('suggestedFileName', () {
    test('formats id and timestamp', () {
      final s = _session(id: 7, start: DateTime(2026, 5, 13, 14, 23, 1));
      expect(
        suggestedFileName(s, 'csv'),
        'temp_session_7_2026-05-13_14-23-01.csv',
      );
    });
  });
}
