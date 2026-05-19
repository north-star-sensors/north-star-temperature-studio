import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../../../database/models/measurement_models.dart';

const String _utf8Bom = '\u{FEFF}';

const List<String> _readingHeaders = [
  'timestamp_iso',
  'elapsed_seconds',
  'value_celsius',
];

class SessionExportData {
  final RecordingSession session;
  final List<TemperatureReading> readings;
  const SessionExportData(this.session, this.readings);
}

String suggestedFileName(RecordingSession session, String extension) {
  final t = session.startTime;
  String pad(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${t.year}-${pad(t.month)}-${pad(t.day)}_${pad(t.hour)}-${pad(t.minute)}-${pad(t.second)}';
  return 'temp_session_${session.id}_$stamp.$extension';
}

Uint8List buildSessionCsv(SessionExportData data) {
  final session = data.session;
  final readings = data.readings;

  final rows = <List<dynamic>>[_readingHeaders];
  for (final r in readings) {
    final elapsedSec =
        r.timestamp.difference(session.startTime).inMicroseconds / 1e6;
    rows.add([
      r.timestamp.toIso8601String(),
      elapsedSec.toStringAsFixed(3),
      r.value,
    ]);
  }

  final csvText = Csv(lineDelimiter: '\n').encode(rows);
  return Uint8List.fromList(utf8.encode('$_utf8Bom$csvText\n'));
}

Uint8List buildSessionXlsx(SessionExportData data) {
  final session = data.session;
  final readings = data.readings;

  final excel = Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null && defaultSheet != 'Metadata') {
    excel.rename(defaultSheet, 'Metadata');
  }

  final meta = excel['Metadata'];
  final endTime =
      readings.isEmpty ? session.startTime : readings.last.timestamp;
  meta.appendRow([TextCellValue('key'), TextCellValue('value')]);
  meta.appendRow(
    [TextCellValue('session_id'), IntCellValue(session.id)],
  );
  meta.appendRow([
    TextCellValue('start_time'),
    TextCellValue(session.startTime.toIso8601String()),
  ]);
  meta.appendRow([
    TextCellValue('end_time'),
    TextCellValue(endTime.toIso8601String()),
  ]);
  meta.appendRow([
    TextCellValue('reading_count'),
    IntCellValue(readings.length),
  ]);
  meta.appendRow([
    TextCellValue('note'),
    TextCellValue(session.note ?? ''),
  ]);

  final readingsSheet = excel['Readings'];
  readingsSheet.appendRow([
    TextCellValue(_readingHeaders[0]),
    TextCellValue(_readingHeaders[1]),
    TextCellValue(_readingHeaders[2]),
  ]);
  for (final r in readings) {
    final elapsedSec =
        r.timestamp.difference(session.startTime).inMicroseconds / 1e6;
    readingsSheet.appendRow([
      TextCellValue(r.timestamp.toIso8601String()),
      DoubleCellValue(elapsedSec),
      DoubleCellValue(r.value),
    ]);
  }

  final bytes = excel.save();
  if (bytes == null) {
    throw StateError('Failed to encode XLSX bytes');
  }
  return Uint8List.fromList(bytes);
}
