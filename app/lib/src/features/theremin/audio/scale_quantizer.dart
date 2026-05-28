import 'dart:math';

/// Musical scales the theremin can snap its pitch to. [continuous] disables
/// quantization (the classic gliding theremin sweep).
enum ThereminScale {
  continuous,
  chromatic,
  major,
  majorPentatonic,
  minorPentatonic,
}

const Map<ThereminScale, String> _scaleLabels = {
  ThereminScale.continuous: 'Continuous',
  ThereminScale.chromatic: 'Chromatic',
  ThereminScale.major: 'Major',
  ThereminScale.majorPentatonic: 'Major pentatonic',
  ThereminScale.minorPentatonic: 'Minor pentatonic',
};

extension ThereminScaleLabel on ThereminScale {
  String get label => _scaleLabels[this]!;
}

/// Semitone offsets (relative to the tonic) permitted by each scale.
const Map<ThereminScale, List<int>> _pitchClasses = {
  ThereminScale.chromatic: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
  ThereminScale.major: [0, 2, 4, 5, 7, 9, 11],
  ThereminScale.majorPentatonic: [0, 2, 4, 7, 9],
  ThereminScale.minorPentatonic: [0, 3, 5, 7, 10],
};

const double _a4Hz = 440.0; // MIDI note 69

/// Snaps [hz] to the nearest note of [scale] in 12-tone equal temperament.
///
/// [rootPitchClass] sets the tonic (0 = C, 9 = A, …). Returns [hz] unchanged
/// for [ThereminScale.continuous] or non-positive input.
double quantizeHz(double hz, ThereminScale scale, {int rootPitchClass = 0}) {
  if (scale == ThereminScale.continuous || hz <= 0) return hz;
  final allowed = _pitchClasses[scale]!;

  // Continuous MIDI number, then search nearby semitones for the closest note
  // whose pitch class is in the scale. ±2 semitones always covers the widest
  // gap (3 semitones) in the supported scales.
  final midi = 69 + 12 * (log(hz / _a4Hz) / ln2);
  final base = midi.round();
  var bestNote = base;
  var bestDistance = double.infinity;
  for (var note = base - 2; note <= base + 2; note++) {
    final pitchClass = ((note - rootPitchClass) % 12 + 12) % 12;
    if (!allowed.contains(pitchClass)) continue;
    final distance = (note - midi).abs();
    if (distance < bestDistance) {
      bestDistance = distance;
      bestNote = note;
    }
  }

  return _a4Hz * pow(2, (bestNote - 69) / 12).toDouble();
}
