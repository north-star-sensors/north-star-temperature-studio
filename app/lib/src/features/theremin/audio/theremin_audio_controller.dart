import 'package:flutter_soloud/flutter_soloud.dart';

import 'scale_quantizer.dart';

class ThereminAudioController {
  AudioSource? _source;
  SoundHandle? _handle;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isMuted = false;
  // True only if this controller performed the global SoLoud init, so that
  // dispose() tears down the engine it owns (and never one owned elsewhere).
  bool _ownsEngine = false;

  double _targetPitchHz = 440.0;
  double _targetVolume = 0.0;
  double _smoothedPitchHz = 440.0;
  double _smoothedVolume = 0.0;

  ThereminScale _scale = ThereminScale.majorPentatonic;
  WaveForm _waveform = WaveForm.sin;

  static const double _pitchAlpha = 0.12;
  static const double _volumeAlpha = 0.18;

  bool get isMuted => _isMuted;
  double get currentPitchHz => _smoothedPitchHz;
  double get currentVolume => _smoothedVolume;
  ThereminScale get scale => _scale;
  WaveForm get waveform => _waveform;

  void setScale(ThereminScale scale) => _scale = scale;

  void setWaveform(WaveForm waveform) {
    _waveform = waveform;
    final source = _source;
    if (_isInitialized && source != null) {
      SoLoud.instance.setWaveform(source, waveform);
    }
  }

  Future<void> init() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    try {
      final soloud = SoLoud.instance;
      if (!soloud.isInitialized) {
        await soloud.init();
        _ownsEngine = true;
      }
      _source = await soloud.loadWaveform(WaveForm.sin, false, 1.0, 0.0);
      _handle = await soloud.play(
        _source!,
        volume: 0.0,
        looping: true,
      );
      _isInitialized = true;
    } catch (_) {
      // Audio init may fail on some platforms; feature degrades gracefully.
    } finally {
      _isInitializing = false;
    }
  }

  void setTarget(double pitchHz, double volumeNorm) {
    _targetPitchHz = pitchHz;
    _targetVolume = volumeNorm;
  }

  void tick() {
    if (!_isInitialized) return;

    // Snap to the selected scale, then glide toward it (portamento).
    final targetPitch = quantizeHz(_targetPitchHz, _scale);
    _smoothedPitchHz += (targetPitch - _smoothedPitchHz) * _pitchAlpha;
    _smoothedVolume += (_targetVolume - _smoothedVolume) * _volumeAlpha;

    final soloud = SoLoud.instance;
    final source = _source;
    final handle = _handle;
    if (source == null || handle == null) return;

    soloud.setWaveformFreq(source, _smoothedPitchHz);
    soloud.setVolume(handle, _isMuted ? 0.0 : _smoothedVolume);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted && _isInitialized && _handle != null) {
      SoLoud.instance.setVolume(_handle!, 0.0);
    }
  }

  void dispose() {
    if (!_isInitialized) return;
    final soloud = SoLoud.instance;
    final handle = _handle;
    final source = _source;
    if (handle != null) {
      soloud.stop(handle);
    }
    if (source != null) {
      soloud.disposeSource(source);
    }
    if (_ownsEngine && soloud.isInitialized) {
      soloud.deinit();
    }
    _handle = null;
    _source = null;
    _isInitialized = false;
    _ownsEngine = false;
  }
}
