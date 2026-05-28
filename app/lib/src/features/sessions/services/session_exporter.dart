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
  'marker',
];

const List<String> _markerHeaders = [
  'timestamp_iso',
  'elapsed_seconds',
  'label',
];

class SessionExportData {
  final RecordingSession session;
  final List<TemperatureReading> readings;
  final List<SessionMarker> markers;
  const SessionExportData(
    this.session,
    this.readings, [
    this.markers = const [],
  ]);
}

String suggestedFileName(RecordingSession session, String extension) {
  final t = session.startTime;
  String pad(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${t.year}-${pad(t.month)}-${pad(t.day)}_${pad(t.hour)}-${pad(t.minute)}-${pad(t.second)}';
  return 'temp_session_${session.id}_$stamp.$extension';
}

double _elapsedSeconds(DateTime ts, DateTime start) =>
    ts.difference(start).inMicroseconds / 1e6;

/// Maps each marker to the reading whose timestamp is nearest, so annotations
/// land on the timeline. Returns reading-index → joined labels (markers that
/// collapse onto the same reading are joined with "; "). Empty if no readings.
Map<int, String> _markersByReadingIndex(
  List<TemperatureReading> readings,
  List<SessionMarker> markers,
) {
  if (readings.isEmpty || markers.isEmpty) return const {};
  final byIndex = <int, List<String>>{};
  for (final marker in markers) {
    var bestIndex = 0;
    var bestDelta = readings[0]
        .timestamp
        .difference(marker.timestamp)
        .inMicroseconds
        .abs();
    for (var i = 1; i < readings.length; i++) {
      final delta = readings[i]
          .timestamp
          .difference(marker.timestamp)
          .inMicroseconds
          .abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        bestIndex = i;
      }
    }
    (byIndex[bestIndex] ??= <String>[]).add(marker.label);
  }
  return {for (final entry in byIndex.entries) entry.key: entry.value.join('; ')};
}

Uint8List buildSessionCsv(SessionExportData data) {
  final session = data.session;
  final readings = data.readings;
  final markerLabels = _markersByReadingIndex(readings, data.markers);

  final rows = <List<dynamic>>[_readingHeaders];
  for (var i = 0; i < readings.length; i++) {
    final r = readings[i];
    rows.add([
      r.timestamp.toIso8601String(),
      _elapsedSeconds(r.timestamp, session.startTime).toStringAsFixed(3),
      r.value,
      markerLabels[i] ?? '',
    ]);
  }

  final csvText = Csv(lineDelimiter: '\n').encode(rows);
  return Uint8List.fromList(utf8.encode('$_utf8Bom$csvText\n'));
}

Uint8List buildSessionXlsx(SessionExportData data) {
  final session = data.session;
  final readings = data.readings;
  final markers = data.markers;
  final markerLabels = _markersByReadingIndex(readings, markers);

  final excel = Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null && defaultSheet != 'Metadata') {
    excel.rename(defaultSheet, 'Metadata');
  }

  final meta = excel['Metadata'];
  final endTime = readings.isEmpty ? session.startTime : readings.last.timestamp;
  meta.appendRow([TextCellValue('key'), TextCellValue('value')]);
  meta.appendRow([TextCellValue('session_id'), IntCellValue(session.id)]);
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
    TextCellValue('marker_count'),
    IntCellValue(markers.length),
  ]);
  meta.appendRow([TextCellValue('note'), TextCellValue(session.note ?? '')]);

  final readingsSheet = excel['Readings'];
  readingsSheet.appendRow(
    [for (final h in _readingHeaders) TextCellValue(h)],
  );
  for (var i = 0; i < readings.length; i++) {
    final r = readings[i];
    readingsSheet.appendRow([
      TextCellValue(r.timestamp.toIso8601String()),
      DoubleCellValue(_elapsedSeconds(r.timestamp, session.startTime)),
      DoubleCellValue(r.value),
      TextCellValue(markerLabels[i] ?? ''),
    ]);
  }

  final markersSheet = excel['Markers'];
  markersSheet.appendRow([for (final h in _markerHeaders) TextCellValue(h)]);
  for (final m in markers) {
    markersSheet.appendRow([
      TextCellValue(m.timestamp.toIso8601String()),
      DoubleCellValue(_elapsedSeconds(m.timestamp, session.startTime)),
      TextCellValue(m.label),
    ]);
  }

  final bytes = excel.save();
  if (bytes == null) {
    throw StateError('Failed to encode XLSX bytes');
  }
  return Uint8List.fromList(bytes);
}
