import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temperature_studio/src/database/models/measurement_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/ui/algorithm_lab_page.dart';
import 'package:temperature_studio/src/features/kona_game/ui/kona_game_page.dart';
import 'package:temperature_studio/src/features/lunar_lander/ui/lunar_lander_page.dart';
import 'package:temperature_studio/src/features/recording/recording_service.dart';
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
  List<String> _devices = [];
  String? _selectedDevice;
  bool _isLoadingDevices = false;

  @override
  void initState() {
    super.initState();
    _scanDevices();
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

  Future<void> _scanDevices() async {
    setState(() => _isLoadingDevices = true);
    try {
      final hardware = ref.read(serialHardwareProvider);
      final devices = await hardware.getDevices();
      setState(() {
        _devices = devices;
        if (devices.isNotEmpty && _selectedDevice == null) {
          _selectedDevice = devices.first;
        }
      });
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
          IconButton(
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
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedDevice,
                    hint: const Text('Select Device'),
                    isExpanded: true,
                    items: _devices.map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: (isConnected)
                        ? null
                        : (val) => setState(() => _selectedDevice = val),
                  ),
                ),
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
                    onPressed: _selectedDevice == null
                        ? null
                        : () {
                            ref
                                .read(recordingServiceProvider.notifier)
                                .connect(_selectedDevice!);
                          },
                    icon: const Icon(Icons.link),
                    label: const Text('Connect'),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Session: ${recordingData?.session?.id}'),
            ),
          ] else ...[
            const Expanded(child: Center(child: Text('Ready to record.'))),
          ],
        ],
      ),
    );
  }
}
