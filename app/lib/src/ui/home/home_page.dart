import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temperature_studio/src/database/models/measurement_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/ui/algorithm_lab_page.dart';
import 'package:temperature_studio/src/features/kona_game/ui/kona_game_page.dart';
import 'package:temperature_studio/src/features/lunar_lander/ui/lunar_lander_page.dart';
import 'package:temperature_studio/src/features/recording/recording_service.dart';
import 'package:temperature_studio/src/features/secret_knock/ui/secret_knock_page.dart';
import 'package:temperature_studio/src/features/sessions/state/sessions_list_provider.dart';
import 'package:temperature_studio/src/features/sessions/ui/session_export_actions.dart';
import 'package:temperature_studio/src/features/sessions/ui/sessions_page.dart';
import 'package:temperature_studio/src/features/theremin/ui/theremin_page.dart';
import 'package:temperature_studio/src/hardware/hardware_provider.dart';
import 'package:temperature_studio/src/ui/chart/live_chart_widget.dart';
import 'package:temperature_studio/src/ui/home/current_temperature_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const Duration _autoScanInterval = Duration(seconds: 2);
  // On web, any not-yet-granted device id makes the backend open the browser's
  // port picker; the exact value is irrelevant.
  static const String _webConnectRequest = 'web-serial-picker';

  List<String> _devices = [];
  String? _selectedDevice;
  bool _isLoadingDevices = false;
  Timer? _autoScanTimer;

  @override
  void initState() {
    super.initState();
    // On the web there is no silent port enumeration — connection goes through
    // the browser's port picker on demand, so scanning/auto-scan don't apply.
    if (!kIsWeb) {
      _scanDevices();
      _autoScanTimer = Timer.periodic(_autoScanInterval, (_) => _autoScan());
    }
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    super.dispose();
  }

  Future<void> _autoScan() async {
    if (!mounted || _isLoadingDevices) return;
    final recordingData = ref.read(recordingServiceProvider).value;
    if ((recordingData?.isConnected ?? false)) return;
    try {
      final hardware = ref.read(serialHardwareProvider);
      final devices = await hardware.getDevices();
      if (!mounted) return;
      if (_devicesEqual(devices, _devices)) return;
      setState(() => _applyDeviceList(devices));
    } catch (_) {
      // Silent — manual refresh still surfaces errors.
    }
  }

  void _applyDeviceList(List<String> devices) {
    _devices = devices;
    if (_selectedDevice != null && !devices.contains(_selectedDevice)) {
      _selectedDevice = devices.isNotEmpty ? devices.first : null;
    } else if (_selectedDevice == null && devices.isNotEmpty) {
      _selectedDevice = devices.first;
    }
  }

  bool _devicesEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _stopAndOfferExport(RecordingSession? session) async {
    await ref.read(recordingServiceProvider.notifier).stopRecording();
    if (!mounted) return;
    ref.invalidate(sessionsListProvider);
    if (session == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recording stopped.'),
        action: SnackBarAction(
          label: 'Export',
          onPressed: () => pickFormatAndExport(context, ref, session),
        ),
      ),
    );
  }

  static const List<String> _quickMarkerLabels = ['Touch', 'Ice', 'Breath'];

  Future<void> _addMarker(String label) async {
    await ref.read(recordingServiceProvider.notifier).addMarker(label);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marker: $label'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _addCustomMarker() async {
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add marker'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. door opened'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (label != null && label.trim().isNotEmpty) {
      await _addMarker(label.trim());
    }
  }

  Future<void> _scanDevices() async {
    setState(() => _isLoadingDevices = true);
    try {
      final hardware = ref.read(serialHardwareProvider);
      final devices = await hardware.getDevices();
      if (!mounted) return;
      setState(() => _applyDeviceList(devices));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error scanning devices: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDevices = false);
      }
    }
  }

  Future<void> _connect() async {
    final notifier = ref.read(recordingServiceProvider.notifier);
    try {
      if (kIsWeb) {
        await notifier.connect(_webConnectRequest);
      } else if (_selectedDevice != null) {
        await notifier.connect(_selectedDevice!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not connect: $e')));
    }
  }

  /// The device area left of the Connect button: a port dropdown on native,
  /// or a short explanation of the browser-picker flow on web.
  Widget _buildDeviceArea(BuildContext context, bool isConnected) {
    final theme = Theme.of(context);
    if (!kIsWeb) {
      return DropdownButton<String>(
        value: _selectedDevice,
        hint: const Text('Select Device'),
        isExpanded: true,
        items: _devices
            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
            .toList(),
        onChanged: isConnected
            ? null
            : (val) => setState(() => _selectedDevice = val),
      );
    }
    if (isConnected) {
      return Row(
        children: [
          Icon(Icons.usb, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('Serial device connected', style: theme.textTheme.bodyMedium),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('USB temperature probe', style: theme.textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(
          'Connect opens your browser’s port chooser (Chrome or Edge).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingServiceProvider);
    final recordingData = recordingState.value;
    final isConnected = recordingData?.isConnected ?? false;
    final isRecording = recordingData?.isRecording ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('North Star Temperature Studio'),
        actions: [
          IconButton(
            tooltip: 'Lunar Lander',
            icon: const Icon(Icons.rocket_launch),
            onPressed: () {
              Navigator.of(context).pushNamed(LunarLanderPage.routeName);
            },
          ),
          IconButton(
            tooltip: 'Play Kona Run!',
            icon: const Icon(Icons.pets),
            onPressed: () {
              Navigator.of(context).pushNamed(KonaGamePage.routeName);
            },
          ),
          IconButton(
            tooltip: 'Theremin',
            icon: const Icon(Icons.music_note),
            onPressed: () {
              Navigator.of(context).pushNamed(ThereminPage.routeName);
            },
          ),
          IconButton(
            tooltip: 'Secret Knock',
            icon: const Icon(Icons.lock_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(SecretKnockPage.routeName);
            },
          ),
          IconButton(
            tooltip: 'Open Algorithm Lab',
            icon: const Icon(Icons.science_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(AlgorithmLabPage.routeName);
            },
          ),
          IconButton(
            tooltip: 'Recordings',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).pushNamed(SessionsPage.routeName);
            },
          ),
          if (!kIsWeb)
            IconButton(
              tooltip: 'Rescan devices',
              icon: _isLoadingDevices
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    )
                  : const Icon(Icons.refresh),
              onPressed: (isConnected || isRecording || _isLoadingDevices)
                  ? null
                  : _scanDevices,
            ),
        ],
      ),
      body: Column(
        children: [
          // Device Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildDeviceArea(context, isConnected)),
                const SizedBox(width: 16),

                if (isConnected)
                  FilledButton.tonalIcon(
                    onPressed: isRecording
                        ? null
                        : () {
                            ref
                                .read(recordingServiceProvider.notifier)
                                .disconnect();
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    icon: const Icon(Icons.link_off),
                    label: const Text('Disconnect'),
                  )
                else
                  FilledButton.icon(
                    onPressed: (kIsWeb || _selectedDevice != null)
                        ? _connect
                        : null,
                    icon: Icon(kIsWeb ? Icons.usb : Icons.link),
                    label: Text(kIsWeb ? 'Connect device' : 'Connect'),
                  ),

                const SizedBox(width: 8),

                if (isRecording)
                  FilledButton.icon(
                    onPressed: () => _stopAndOfferExport(recordingData?.session),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Rec'),
                  )
                else
                  FilledButton.icon(
                    onPressed: isConnected
                        ? () {
                            ref
                                .read(recordingServiceProvider.notifier)
                                .startRecording();
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                    icon: const Icon(Icons.fiber_manual_record),
                    label: const Text('Record'),
                  ),
              ],
            ),
          ),

          if (isConnected) const CurrentTemperatureWidget(),

          if (isRecording) ...[
            const Expanded(child: LiveChartWidget()),
            _MarkerBar(
              sessionId: recordingData?.session?.id,
              markerCount: recordingData?.markerCount ?? 0,
              onMark: _addMarker,
              onCustom: _addCustomMarker,
              quickLabels: _quickMarkerLabels,
            ),
          ] else ...[
            const Expanded(child: Center(child: Text('Ready to record.'))),
          ],
        ],
      ),
    );
  }
}

/// Quick-tap marker controls shown while a recording is active.
class _MarkerBar extends StatelessWidget {
  const _MarkerBar({
    required this.sessionId,
    required this.markerCount,
    required this.onMark,
    required this.onCustom,
    required this.quickLabels,
  });

  final int? sessionId;
  final int markerCount;
  final void Function(String label) onMark;
  final VoidCallback onCustom;
  final List<String> quickLabels;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Session $sessionId', style: textTheme.labelLarge),
              const Spacer(),
              if (markerCount > 0)
                Text(
                  '$markerCount marker${markerCount == 1 ? '' : 's'}',
                  style: textTheme.labelMedium,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final label in quickLabels)
                ActionChip(
                  avatar: const Icon(Icons.label_outline, size: 18),
                  label: Text(label),
                  onPressed: () => onMark(label),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Custom'),
                onPressed: onCustom,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
