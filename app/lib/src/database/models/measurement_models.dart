import 'package:isar/isar.dart';

part 'measurement_models.g.dart';

@collection
class RecordingSession {
  Id id = Isar.autoIncrement;

  late DateTime startTime;

  String? note;
}

@collection
class TemperatureReading {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('timestamp')])
  late int sessionId;

  late DateTime timestamp;

  late double value;
}
