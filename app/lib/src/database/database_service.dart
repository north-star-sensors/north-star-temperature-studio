import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'models/measurement_models.dart';
// Storage backend, chosen at compile time: Isar on native, in-memory on web
// (Isar 3 cannot compile to web).
import 'database_factory_native.dart'
    if (dart.library.js_interop) 'database_factory_web.dart';

part 'database_service.g.dart';

/// Storage-agnostic persistence contract. Implemented by `IsarDatabase`
/// (native) and `MemoryDatabase` (web).
abstract interface class Database {
  Future<int> createSession(RecordingSession session);
  Future<RecordingSession?> getSession(int id);
  Future<List<RecordingSession>> getAllSessions();
  Future<List<RecordingSession>> getAllSessionsNewestFirst();

  Future<void> saveReadings(List<TemperatureReading> readings);
  Future<List<TemperatureReading>> getReadingsForSession(int sessionId);
  Future<int> countReadingsForSession(int sessionId);
  Future<List<TemperatureReading>> getReadingsInRange(
    int sessionId,
    DateTime start,
    DateTime end,
  );

  Future<int> saveMarker(SessionMarker marker);
  Future<List<SessionMarker>> getMarkersForSession(int sessionId);
  Future<int> countMarkersForSession(int sessionId);
}

@Riverpod(keepAlive: true)
Future<Database> databaseService(DatabaseServiceRef ref) async {
  // For testing, override this provider with a mock or an in-memory instance.
  return openDatabase();
}
