import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/secret_knock/engine/knock_pattern.dart';

enum _KnockStatus { idle, listening, unlocked, denied, recording }

class SecretKnockPage extends ConsumerStatefulWidget {
  const SecretKnockPage({super.key});

  static const String routeName = '/secret-knock';

  @override
  ConsumerState<SecretKnockPage> createState() => _SecretKnockPageState();
}

class _SecretKnockPageState extends ConsumerState<SecretKnockPage> {
  static const Duration _pauseToEvaluate = Duration(milliseconds: 1300);
  static const String _customPrefsKey = 'secret_knock.custom';
  static const String _customName = 'Your secret';

  final List<KnockPattern> _patterns = List.of(KnockPattern.presets);
  late KnockPattern _target = _patterns.first;
  final List<DateTime> _taps = [];
  Timer? _evalTimer;
  _KnockStatus _status = _KnockStatus.idle;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadCustomPattern();
  }

  @override
  void dispose() {
    _evalTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomPattern() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final custom = KnockPattern.decode(
      _customName,
      prefs.getString(_customPrefsKey),
    );
    if (custom != null && mounted) {
      setState(() {
        _patterns
          ..removeWhere((p) => p.name == _customName)
          ..add(custom);
        _target = custom;
      });
    }
  }

  void _registerTap() {
    _evalTimer?.cancel();
    setState(() {
      if (_status != _KnockStatus.recording) {
        if (_status != _KnockStatus.listening) _taps.clear();
        _status = _KnockStatus.listening;
      }
      _taps.add(DateTime.now());
    });
    _evalTimer = Timer(_pauseToEvaluate, _finish);
  }

  void _finish() {
    if (_taps.isEmpty) return;
    final relative = [
      for (final t in _taps) t.difference(_taps.first),
    ];

    if (_status == _KnockStatus.recording) {
      if (_taps.length < 2) {
        setState(() {}); // keep recording; need at least two knocks
        return;
      }
      final custom = KnockPattern.fromTimestamps(_customName, relative);
      unawaited(_prefs?.setString(_customPrefsKey, custom.encode()));
      setState(() {
        _patterns
          ..removeWhere((p) => p.name == _customName)
          ..add(custom);
        _target = custom;
        _status = _KnockStatus.idle;
        _taps.clear();
      });
      return;
    }

    setState(() {
      _status = _target.matches(relative)
          ? _KnockStatus.unlocked
          : _KnockStatus.denied;
    });
  }

  void _reset() {
    _evalTimer?.cancel();
    setState(() {
      _taps.clear();
      _status = _KnockStatus.idle;
    });
  }

  void _startRecording() {
    _evalTimer?.cancel();
    setState(() {
      _taps.clear();
      _status = _KnockStatus.recording;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Thermal taps from the sensor count as knocks (false→true button edge).
    ref.listen<AlgorithmLabState>(algorithmLabControllerProvider, (
      previous,
      next,
    ) {
      if (previous != null &&
          !previous.buttonIsPressed &&
          next.buttonIsPressed) {
        _registerTap();
      }
    });

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secret Knock'),
        actions: [
          PopupMenuButton<KnockPattern>(
            tooltip: 'Choose secret',
            icon: const Icon(Icons.lock_outline),
            onSelected: (p) => setState(() {
              _target = p;
              _reset();
            }),
            itemBuilder: (context) => [
              for (final p in _patterns)
                PopupMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      if (identical(p, _target))
                        const Icon(Icons.check, size: 18)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text('${p.name} (${p.tapCount})'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _registerTap(),
        child: Column(
          children: [
            Expanded(child: Center(child: _buildStatus(cs))),
            _buildFooter(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(ColorScheme cs) {
    final (IconData icon, Color color, String title) = switch (_status) {
      _KnockStatus.idle => (Icons.lock_outline, cs.onSurfaceVariant, 'Locked'),
      _KnockStatus.listening => (Icons.hearing, cs.primary, 'Listening…'),
      _KnockStatus.recording => (
        Icons.fiber_manual_record,
        cs.error,
        'Recording — knock your secret',
      ),
      _KnockStatus.unlocked => (Icons.lock_open, Colors.green, 'Unlocked!'),
      _KnockStatus.denied => (Icons.gpp_bad, cs.error, 'Wrong knock'),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 96, color: color),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _TapDots(
          captured: _taps.length,
          target: _status == _KnockStatus.recording ? null : _target.tapCount,
          color: color,
        ),
        const SizedBox(height: 24),
        Text(
          _status == _KnockStatus.recording
              ? 'Tap a rhythm below, then pause to save it.'
              : 'Knock “${_target.name}” — tap below or knock on the sensor.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme cs) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
            FilledButton.tonalIcon(
              onPressed: _startRecording,
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Record new secret'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row of dots: filled for each captured tap, hollow for the remaining taps
/// expected by the target (when known).
class _TapDots extends StatelessWidget {
  const _TapDots({
    required this.captured,
    required this.target,
    required this.color,
  });

  final int captured;
  final int? target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final total = target == null ? captured : (target! > captured ? target! : captured);
    if (total == 0) {
      return Text('—', style: TextStyle(color: color));
    }
    return Wrap(
      spacing: 10,
      children: [
        for (var i = 0; i < total; i++)
          Icon(
            i < captured ? Icons.circle : Icons.circle_outlined,
            size: 16,
            color: color,
          ),
      ],
    );
  }
}
