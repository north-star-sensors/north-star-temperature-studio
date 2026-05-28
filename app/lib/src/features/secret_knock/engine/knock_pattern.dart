import 'dart:math';

/// A rhythmic knock pattern: the relative onset time (in seconds) of each tap,
/// starting at 0. Matching is tempo-independent — it compares the *shape* of
/// the rhythm (onsets normalized to the total span), not the absolute speed.
class KnockPattern {
  const KnockPattern(this.name, this.onsets);

  final String name;

  /// Monotonic non-decreasing onset times in seconds; first is 0.
  final List<double> onsets;

  int get tapCount => onsets.length;

  /// Builds a pattern from captured tap timestamps (e.g. when recording a new
  /// secret), re-based so the first onset is 0.
  factory KnockPattern.fromTimestamps(String name, List<Duration> taps) {
    if (taps.isEmpty) return KnockPattern(name, const [0.0]);
    final firstMicros = taps.first.inMicroseconds;
    return KnockPattern(name, [
      for (final t in taps) (t.inMicroseconds - firstMicros) / 1e6,
    ]);
  }

  static List<double> _normalize(List<double> times) {
    if (times.length < 2) return List<double>.filled(times.length, 0.0);
    final span = times.last - times.first;
    if (span <= 0) return List<double>.filled(times.length, 0.0);
    return [for (final t in times) (t - times.first) / span];
  }

  /// Whether [taps] reproduce this pattern within [tolerance] (the maximum
  /// allowed deviation of any normalized onset, default 0.16). The number of
  /// taps must match exactly.
  bool matches(List<Duration> taps, {double tolerance = 0.16}) {
    if (taps.length != onsets.length) return false;
    if (onsets.length < 2) return true; // a single tap trivially matches

    final target = _normalize(onsets);
    final actual = _normalize([
      for (final t in taps) t.inMicroseconds / 1e6,
    ]);
    // A zero span (all taps at once) can't match a multi-onset pattern.
    if (actual.every((v) => v == 0.0)) return false;

    var maxDeviation = 0.0;
    for (var i = 0; i < target.length; i++) {
      maxDeviation = max(maxDeviation, (actual[i] - target[i]).abs());
    }
    return maxDeviation <= tolerance;
  }

  /// Serializes the onsets for persistence (e.g. shared_preferences).
  String encode() => onsets.map((o) => o.toStringAsFixed(4)).join(',');

  static KnockPattern? decode(String name, String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    final parts = encoded.split(',');
    final onsets = <double>[];
    for (final p in parts) {
      final v = double.tryParse(p);
      if (v == null) return null;
      onsets.add(v);
    }
    if (onsets.isEmpty) return null;
    return KnockPattern(name, onsets);
  }

  /// Built-in patterns with deliberately distinctive rhythms.
  static const List<KnockPattern> presets = [
    // "Shave and a haircut": ta · ta-ta-ta · ta.
    KnockPattern('Shave & a Haircut', [0.0, 0.6, 0.9, 1.2, 1.8]),
    // Two slow, then three quick.
    KnockPattern('Slow, slow, flurry', [0.0, 0.8, 1.6, 1.85, 2.1]),
    // Heartbeat: lub-dub … lub-dub.
    KnockPattern('Heartbeat', [0.0, 0.25, 1.1, 1.35]),
  ];
}
