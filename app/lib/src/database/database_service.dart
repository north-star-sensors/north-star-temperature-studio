import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'models/measurement_models.dart';

part 'database_service.g.dart';

/// DatabaseService handles all interactions with the Isar database.
/// It must be initialized with an Isar instance.
class DatabaseService {
  final Isar isar;

  DatabaseService(this.isar);

  /// Opens the Isar database.
  /// If [directory] is provided, it opens the database in that directory.
  /// Otherwise, it uses the application documents directory.
  static Future<Isar> openIsar([String? directory]) async {
    final dir = directory ?? (await getApplicationDocumentsDirectory()).path;
    return Isar.open([
      RecordingSessionSchema,
      TemperatureReadingSchema,
    ], directory: dir);
  }

  // --- Recording Sessions ---

  Future<int> createSession(RecordingSession session) async {
    return isar.writeTxn(() async {
      return await isar.recordingSessions.put(session);
    });
  }

  Future<RecordingSession?> getSession(int id) async {
    return isar.recordingSessions.get(id);
  }

  Future<List<RecordingSession>> getAllSessions() async {
    return isar.recordingSessions.where().findAll();
  }

  Future<List<RecordingSession>> getAllSessionsNewestFirst() async {
    return isar.recordingSessions.where().sortByStartTimeDesc().findAll();
  }

  // --- Temperature Readings ---

  /// Batched write for temperature readings.
  Future<void> saveReadings(List<TemperatureReading> readings) async {
    if (readings.isEmpty) return;
    await isar.writeTxn(() async {
      await isar.temperatureReadings.putAll(readings);
    });
  }

  Future<List<TemperatureReading>> getReadingsForSession(int sessionId) async {
    return isar.temperatureReadings
        .where()
        .sessionIdEqualToAnyTimestamp(sessionId)
        .findAll();
  }

  Future<int> countReadingsForSession(int sessionId) async {
    return isar.temperatureReadings
        .where()
        .sessionIdEqualToAnyTimestamp(sessionId)
        .count();
  }

  /// Get readings for a session within a time range.
  /// This leverages the composite index [sessionId, timestamp].
  Future<List<TemperatureReading>> getReadingsInRange(
    int sessionId,
    DateTime start,
    DateTime end,
  ) async {
    return isar.temperatureReadings
        .where()
        .sessionIdEqualToTimestampBetween(sessionId, start, end)
        .findAll();
  }
}

@Riverpod(keepAlive: true)
Future<DatabaseService> databaseService(DatabaseServiceRef ref) async {
  // We open the database in the default location.
  // For testing, we can override this provider to use a temp path or mock.
  final isar = await DatabaseService.openIsar();
  return DatabaseService(isar);
}
