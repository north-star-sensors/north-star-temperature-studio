import 'package:isar/isar.dart';

part 'isar_models.g.dart';

/// Isar storage mirrors of the plain domain models. Native-only — their
/// generated code uses 64-bit hash literals and `dart:ffi`, neither of which
/// compiles to web, so this file is never imported on the web target.

@collection
class IsarRecordingSession {
  Id id = Isar.autoIncrement;

  late DateTime startTime;

  String? note;
}

@collection
class IsarTemperatureReading {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('timestamp')])
  late int sessionId;

  late DateTime timestamp;

  late double value;
}

@collection
class IsarSessionMarker {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('timestamp')])
  late int sessionId;

  late DateTime timestamp;

  late String label;
}
