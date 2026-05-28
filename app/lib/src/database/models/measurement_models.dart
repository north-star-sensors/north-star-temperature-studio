// Plain, storage-agnostic domain models.
//
// These deliberately carry no Isar annotations so they compile on every
// target (Isar 3 cannot compile to web). The native Database backend maps
// them to/from Isar collections; the web backend keeps them in memory.

class RecordingSession {
  int id = 0;
  late DateTime startTime;
  String? note;
}

class TemperatureReading {
  int id = 0;
  late int sessionId;
  late DateTime timestamp;
  late double value;
}

/// A user-dropped marker annotating a moment during a recording session
/// (e.g. "touched", "ice", "breath"). Exports attach it to the timeline.
class SessionMarker {
  int id = 0;
  late int sessionId;
  late DateTime timestamp;
  late String label;
}
