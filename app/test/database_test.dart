import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:temperature_studio/src/database/native/isar_database.dart';
import 'package:temperature_studio/src/database/models/measurement_models.dart';

void main() {
  late Directory tempDir;
  late IsarDatabase databaseService;
  late Isar isar;

  setUp(() async {
    // Ensure Isar core is initialized
    await Isar.initializeIsarCore(download: true);

    // Create a temporary directory for the Isar database
    tempDir = await Directory.systemTemp.createTemp('isar_test_');

    // Initialize Isar
    // We use the static method we created, passing the temp path
    isar = await IsarDatabase.openIsar(tempDir.path);
    databaseService = IsarDatabase(isar);
  });

  tearDown(() async {
    // Close Isar and delete the database files
    await isar.close(deleteFromDisk: true);
  });

  group('DatabaseService Tests', () {
    test('Create and retrieve RecordingSession', () async {
      final session = RecordingSession()
        ..startTime = DateTime.now()
        ..note = 'Test Session';

      final id = await databaseService.createSession(session);

      expect(id, isNotNull);

      final retrievedSession = await databaseService.getSession(id);
      expect(retrievedSession, isNotNull);
      expect(retrievedSession!.note, 'Test Session');
      expect(retrievedSession.startTime, session.startTime);
    });

    test('Batch write and retrieve TemperatureReadings', () async {
      final session = RecordingSession()
        ..startTime = DateTime.now()
        ..note = 'Batch Test';
      final sessionId = await databaseService.createSession(session);

      final readings = List.generate(100, (index) {
        return TemperatureReading()
          ..sessionId = sessionId
          ..timestamp = DateTime.now().add(Duration(seconds: index))
          ..value = 20.0 + (index * 0.1);
      });

      await databaseService.saveReadings(readings);

      final retrievedReadings = await databaseService.getReadingsForSession(
        sessionId,
      );
      expect(retrievedReadings.length, 100);
      expect(retrievedReadings.first.value, 20.0);
      expect(retrievedReadings.last.value, 29.9);

      // Verify ordering
      expect(
        retrievedReadings.first.timestamp.isBefore(
          retrievedReadings.last.timestamp,
        ),
        true,
      );
    });

    test('Retrieve Readings in Range', () async {
      final session = RecordingSession()..startTime = DateTime.now();
      final sessionId = await databaseService.createSession(session);

      final baseTime = DateTime(2023, 1, 1, 10, 0, 0);

      final readings = [
        TemperatureReading()
          ..sessionId = sessionId
          ..timestamp = baseTime
          ..value = 1.0,
        TemperatureReading()
          ..sessionId = sessionId
          ..timestamp = baseTime.add(Duration(minutes: 10))
          ..value = 2.0,
        TemperatureReading()
          ..sessionId = sessionId
          ..timestamp = baseTime.add(Duration(minutes: 20))
          ..value = 3.0,
      ];

      await databaseService.saveReadings(readings);

      // Query covering only the middle reading
      final rangeReadings = await databaseService.getReadingsInRange(
        sessionId,
        baseTime.add(Duration(minutes: 5)),
        baseTime.add(Duration(minutes: 15)),
      );

      expect(rangeReadings.length, 1);
      expect(rangeReadings.first.value, 2.0);
    });
  });
}
