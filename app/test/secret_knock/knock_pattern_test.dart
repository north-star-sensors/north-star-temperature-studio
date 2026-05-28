import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_studio/src/features/secret_knock/engine/knock_pattern.dart';

List<Duration> _taps(List<double> seconds) => [
  for (final s in seconds) Duration(microseconds: (s * 1e6).round()),
];

void main() {
  const pattern = KnockPattern('test', [0.0, 0.6, 0.9, 1.2, 1.8]);

  group('matches', () {
    test('accepts the exact rhythm', () {
      expect(pattern.matches(_taps([0.0, 0.6, 0.9, 1.2, 1.8])), isTrue);
    });

    test('is tempo-independent (same shape, faster)', () {
      // Half the duration, same proportions.
      expect(pattern.matches(_taps([0.0, 0.3, 0.45, 0.6, 0.9])), isTrue);
    });

    test('is offset-independent (does not need to start at zero)', () {
      expect(pattern.matches(_taps([10.0, 10.6, 10.9, 11.2, 11.8])), isTrue);
    });

    test('rejects a different number of taps', () {
      expect(pattern.matches(_taps([0.0, 0.6, 0.9])), isFalse);
    });

    test('rejects a clearly different rhythm', () {
      // Front-loaded then a long wait — wrong shape.
      expect(pattern.matches(_taps([0.0, 0.1, 0.2, 0.3, 1.8])), isFalse);
    });

    test('rejects all taps at once', () {
      expect(pattern.matches(_taps([0.0, 0.0, 0.0, 0.0, 0.0])), isFalse);
    });

    test('honours the tolerance argument', () {
      final slightlyOff = _taps([0.0, 0.65, 0.9, 1.15, 1.8]);
      expect(pattern.matches(slightlyOff, tolerance: 0.16), isTrue);
      expect(pattern.matches(slightlyOff, tolerance: 0.001), isFalse);
    });
  });

  group('fromTimestamps', () {
    test('re-bases captured taps so the first onset is zero', () {
      final p = KnockPattern.fromTimestamps('captured', _taps([5.0, 5.5, 6.0]));
      expect(p.onsets.first, 0.0);
      expect(p.onsets[1], closeTo(0.5, 1e-6));
      expect(p.onsets[2], closeTo(1.0, 1e-6));
    });
  });

  group('encode/decode', () {
    test('round-trips through a string', () {
      final encoded = pattern.encode();
      final decoded = KnockPattern.decode('test', encoded)!;
      expect(decoded.onsets.length, pattern.onsets.length);
      for (var i = 0; i < pattern.onsets.length; i++) {
        expect(decoded.onsets[i], closeTo(pattern.onsets[i], 1e-4));
      }
    });

    test('decode returns null for empty or malformed input', () {
      expect(KnockPattern.decode('x', null), isNull);
      expect(KnockPattern.decode('x', ''), isNull);
      expect(KnockPattern.decode('x', '0.0,bogus'), isNull);
    });
  });

  group('presets', () {
    test('each preset round-trips its own rhythm', () {
      for (final preset in KnockPattern.presets) {
        final taps = _taps(preset.onsets);
        expect(
          preset.matches(taps),
          isTrue,
          reason: '${preset.name} should match its own onsets',
        );
      }
    });
  });
}
