import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_studio/src/features/theremin/audio/scale_quantizer.dart';

void main() {
  group('quantizeHz', () {
    test('continuous returns the input unchanged', () {
      expect(quantizeHz(437.3, ThereminScale.continuous), 437.3);
    });

    test('non-positive input is returned unchanged', () {
      expect(quantizeHz(0, ThereminScale.major), 0);
      expect(quantizeHz(-10, ThereminScale.chromatic), -10);
    });

    test('chromatic snaps to the nearest semitone', () {
      // 445 Hz and 433 Hz both round to A4 (440 Hz).
      expect(quantizeHz(445, ThereminScale.chromatic), closeTo(440.0, 0.01));
      expect(quantizeHz(433, ThereminScale.chromatic), closeTo(440.0, 0.01));
    });

    test('a note already in the scale is preserved', () {
      // A4 (440) is in C major and C major pentatonic.
      expect(quantizeHz(440, ThereminScale.major), closeTo(440.0, 0.01));
      expect(
        quantizeHz(440, ThereminScale.majorPentatonic),
        closeTo(440.0, 0.01),
      );
    });

    test('major pentatonic skips an excluded note', () {
      // B4 (~493.9 Hz, pitch class 11) is not in C major pentatonic;
      // the nearest allowed note is C5 (523.25 Hz).
      expect(
        quantizeHz(493.9, ThereminScale.majorPentatonic),
        closeTo(523.25, 0.5),
      );
    });

    test('quantizing is idempotent on an already-quantized value', () {
      final once = quantizeHz(500, ThereminScale.majorPentatonic);
      final twice = quantizeHz(once, ThereminScale.majorPentatonic);
      expect(twice, closeTo(once, 0.001));
    });

    test('every scale exposes a non-empty label', () {
      for (final scale in ThereminScale.values) {
        expect(scale.label, isNotEmpty);
      }
    });
  });
}
