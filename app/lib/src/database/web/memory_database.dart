import '../database_service.dart';
import '../models/measurement_models.dart';

/// In-memory [Database] used on the web target (Isar 3 cannot compile to web).
/// Data lives for the session only — it is not persisted across reloads.
class MemoryDatabase implements Database {
  int _nextSessionId = 1;
  int _nextReadingId = 1;
  int _nextMarkerId = 1;

  final Map<int, RecordingSession> _sessions = {};
  final List<TemperatureReading> _readings = [];
  final List<SessionMarker> _markers = [];

  @override
  Future<int> createSession(RecordingSession session) async {
    if (session.id == 0) session.id = _nextSessionId++;
    _sessions[session.id] = session;
    return session.id;
  }

  @override
  Future<RecordingSession?> getSession(int id) async => _sessions[id];

  @override
  Future<List<RecordingSession>> getAllSessions() async =>
      _sessions.values.toList();

  @override
  Future<List<RecordingSession>> getAllSessionsNewestFirst() async {
    return _sessions.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<void> saveReadings(List<TemperatureReading> readings) async {
    for (final r in readings) {
      if (r.id == 0) r.id = _nextReadingId++;
      _readings.add(r);
    }
  }

  @override
  Future<List<TemperatureReading>> getReadingsForSession(int sessionId) async {
    return _readings.where((r) => r.sessionId == sessionId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<int> countReadingsForSession(int sessionId) async =>
      _readings.where((r) => r.sessionId == sessionId).length;

  @override
  Future<List<TemperatureReading>> getReadingsInRange(
    int sessionId,
    DateTime start,
    DateTime end,
  ) async {
    return _readings
        .where(
          (r) =>
              r.sessionId == sessionId &&
              !r.timestamp.isBefore(start) &&
              !r.timestamp.isAfter(end),
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<int> saveMarker(SessionMarker marker) async {
    if (marker.id == 0) marker.id = _nextMarkerId++;
    _markers.add(marker);
    return marker.id;
  }

  @override
  Future<List<SessionMarker>> getMarkersForSession(int sessionId) async {
    return _markers.where((m) => m.sessionId == sessionId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<int> countMarkersForSession(int sessionId) async =>
      _markers.where((m) => m.sessionId == sessionId).length;
}
