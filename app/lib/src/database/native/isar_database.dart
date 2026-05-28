import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../database_service.dart';
import '../models/measurement_models.dart';
import 'isar_models.dart';

/// Isar-backed [Database] (desktop + Android). Maps the plain domain models
/// to/from Isar collections so the rest of the app never touches Isar types.
class IsarDatabase implements Database {
  IsarDatabase(this.isar);

  final Isar isar;

  /// Opens the Isar database. [directory] is used if given, otherwise the
  /// application documents directory.
  static Future<Isar> openIsar([String? directory]) async {
    final dir = directory ?? (await getApplicationDocumentsDirectory()).path;
    return Isar.open([
      IsarRecordingSessionSchema,
      IsarTemperatureReadingSchema,
      IsarSessionMarkerSchema,
    ], directory: dir);
  }

  // --- Recording Sessions ---

  @override
  Future<int> createSession(RecordingSession session) async {
    final row = IsarRecordingSession()
      ..startTime = session.startTime
      ..note = session.note;
    if (session.id != 0) row.id = session.id;
    final id = await isar.writeTxn(() => isar.isarRecordingSessions.put(row));
    session.id = id;
    return id;
  }

  @override
  Future<RecordingSession?> getSession(int id) async {
    final row = await isar.isarRecordingSessions.get(id);
    return row == null ? null : _toSession(row);
  }

  @override
  Future<List<RecordingSession>> getAllSessions() async {
    final rows = await isar.isarRecordingSessions.where().findAll();
    return rows.map(_toSession).toList();
  }

  @override
  Future<List<RecordingSession>> getAllSessionsNewestFirst() async {
    final rows =
        await isar.isarRecordingSessions.where().sortByStartTimeDesc().findAll();
    return rows.map(_toSession).toList();
  }

  // --- Temperature Readings ---

  @override
  Future<void> saveReadings(List<TemperatureReading> readings) async {
    if (readings.isEmpty) return;
    final rows = readings.map(_fromReading).toList();
    await isar.writeTxn(() => isar.isarTemperatureReadings.putAll(rows));
  }

  @override
  Future<List<TemperatureReading>> getReadingsForSession(int sessionId) async {
    final rows = await isar.isarTemperatureReadings
        .where()
        .sessionIdEqualToAnyTimestamp(sessionId)
        .findAll();
    return rows.map(_toReading).toList();
  }

  @override
  Future<int> countReadingsForSession(int sessionId) async {
    return isar.isarTemperatureReadings
        .where()
        .sessionIdEqualToAnyTimestamp(sessionId)
        .count();
  }

  @override
  Future<List<TemperatureReading>> getReadingsInRange(
    int sessionId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await isar.isarTemperatureReadings
        .where()
        .sessionIdEqualToTimestampBetween(sessionId, start, end)
        .findAll();
    return rows.map(_toReading).toList();
  }

  // --- Session Markers ---

  @override
  Future<int> saveMarker(SessionMarker marker) async {
    final row = IsarSessionMarker()
      ..sessionId = marker.sessionId
      ..timestamp = marker.timestamp
      ..label = marker.label;
    if (marker.id != 0) row.id = marker.id;
    final id = await isar.writeTxn(() => isar.isarSessionMarkers.put(row));
    marker.id = id;
    return id;
  }

  @override
  Future<List<SessionMarker>> getMarkersForSession(int sessionId) async {
    final rows = await isar.isarSessionMarkers
        .where()
        .sessionIdEqualToAnyTimestamp(sessionId)
        .findAll();
    return rows.map(_toMarker).toList();
  }

  @override
  Future<int> countMarkersForSession(int sessionId) async {
    return isar.isarSessionMarkers
        .where()
        .sessionIdEqualToAnyTimestamp(sessionId)
        .count();
  }

  // --- Mapping ---

  RecordingSession _toSession(IsarRecordingSession row) => RecordingSession()
    ..id = row.id
    ..startTime = row.startTime
    ..note = row.note;

  TemperatureReading _toReading(IsarTemperatureReading row) =>
      TemperatureReading()
        ..id = row.id
        ..sessionId = row.sessionId
        ..timestamp = row.timestamp
        ..value = row.value;

  IsarTemperatureReading _fromReading(TemperatureReading reading) {
    final row = IsarTemperatureReading()
      ..sessionId = reading.sessionId
      ..timestamp = reading.timestamp
      ..value = reading.value;
    if (reading.id != 0) row.id = reading.id;
    return row;
  }

  SessionMarker _toMarker(IsarSessionMarker row) => SessionMarker()
    ..id = row.id
    ..sessionId = row.sessionId
    ..timestamp = row.timestamp
    ..label = row.label;
}
