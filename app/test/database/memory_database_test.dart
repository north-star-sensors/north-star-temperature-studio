import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_studio/src/database/models/measurement_models.dart';
import 'package:temperature_studio/src/database/web/memory_database.dart';

RecordingSession _session(DateTime start, {String? note}) => RecordingSession()
  ..startTime = start
  ..note = note;

TemperatureReading _reading(int sessionId, DateTime ts, double v) =>
    TemperatureReading()
      ..sessionId = sessionId
      ..timestamp = ts
      ..value = v;

void main() {
  late MemoryDatabase db;

  setUp(() => db = MemoryDatabase());

  test('assigns ids and round-trips a session', () async {
    final id = await db.createSession(_session(DateTime(2026), note: 'hi'));
    expect(id, greaterThan(0));
    final got = await db.getSession(id);
    expect(got!.note, 'hi');
  });

  test('lists sessions newest first', () async {
    await db.createSession(_session(DateTime(2026, 1, 1)));
    await db.createSession(_session(DateTime(2026, 3, 1)));
    await db.createSession(_session(DateTime(2026, 2, 1)));
    final sessions = await db.getAllSessionsNewestFirst();
    expect(
      sessions.map((s) => s.startTime),
      [DateTime(2026, 3, 1), DateTime(2026, 2, 1), DateTime(2026, 1, 1)],
    );
  });

  test('returns only a session\'s readings, ordered by time', () async {
    final base = DateTime(2026, 1, 1, 10);
    await db.saveReadings([
      _reading(1, base.add(const Duration(seconds: 2)), 2),
      _reading(1, base, 1),
      _reading(2, base, 99), // other session
    ]);
    final readings = await db.getReadingsForSession(1);
    expect(readings.map((r) => r.value), [1, 2]);
    expect(await db.countReadingsForSession(1), 2);
  });

  test('range query is inclusive of both ends', () async {
    final base = DateTime(2026, 1, 1, 10);
    await db.saveReadings([
      _reading(1, base, 1),
      _reading(1, base.add(const Duration(minutes: 10)), 2),
      _reading(1, base.add(const Duration(minutes: 20)), 3),
    ]);
    final inRange = await db.getReadingsInRange(
      1,
      base.add(const Duration(minutes: 5)),
      base.add(const Duration(minutes: 15)),
    );
    expect(inRange.map((r) => r.value), [2]);
  });

  test('stores and retrieves markers ordered by time', () async {
    final base = DateTime(2026, 1, 1, 10);
    await db.saveMarker(
      SessionMarker()
        ..sessionId = 1
        ..timestamp = base.add(const Duration(seconds: 5))
        ..label = 'late',
    );
    await db.saveMarker(
      SessionMarker()
        ..sessionId = 1
        ..timestamp = base
        ..label = 'early',
    );
    final markers = await db.getMarkersForSession(1);
    expect(markers.map((m) => m.label), ['early', 'late']);
    expect(await db.countMarkersForSession(1), 2);
  });
}
