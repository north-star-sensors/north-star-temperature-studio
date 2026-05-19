import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:temperature_studio/src/database/database_service.dart';
import 'package:temperature_studio/src/database/models/measurement_models.dart';
import 'package:temperature_studio/src/hardware/hardware_provider.dart';

part 'recording_service.g.dart';

class RecordingData {
  final bool isConnected;
  final RecordingSession? session;
  const RecordingData({this.isConnected = false, this.session});

  bool get isRecording => session != null;
}

@Riverpod(keepAlive: true)
class RecordingService extends _$RecordingService {
  StreamSubscription? _subscription;
  RecordingSession? _currentSession;
  final List<TemperatureReading> _buffer = [];
  Timer? _flushTimer;

  final _readingsController = StreamController<TemperatureReading>.broadcast();
  Stream<TemperatureReading> get readingsStream => _readingsController.stream;

  static const int _bufferSize = 50;
  static const Duration _maxBufferTime = Duration(seconds: 5);

  @override
  FutureOr<RecordingData> build() {
    ref.onDispose(() {
      _readingsController.close();
    });
    return const RecordingData();
  }

  Future<void> connect(String deviceId) async {
    if (state.value?.isConnected == true) return;

    final hardware = ref.read(serialHardwareProvider);
    final stream = await hardware.connect(deviceId);

    _subscription = stream
        .map((data) => utf8.decode(data))
        .transform(const LineSplitter())
        .listen(
          (line) {
            _handleLine(line);
          },
          onError: (e) {
            debugPrint('Error in recording stream: $e');
            disconnect();
          },
        );

    state = AsyncData(
      RecordingData(isConnected: true, session: _currentSession),
    );
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await stopRecording();

    final hardware = ref.read(serialHardwareProvider);
    await hardware.disconnect();

    state = const AsyncData(RecordingData(isConnected: false, session: null));
  }

  Future<void> startRecording({String? note}) async {
    if (state.value?.isRecording == true) return;
    if (state.value?.isConnected != true) throw Exception('Not connected');

    final db = await ref.read(databaseServiceProvider.future);

    // Create session
    final session = RecordingSession()
      ..startTime = DateTime.now()
      ..note = note;

    // Save session to get ID
    final sessionId = await db.createSession(session);
    session.id = sessionId;
    _currentSession = session;

    // Set timer
    _startFlushTimer(db);

    // Update state
    state = AsyncData(RecordingData(isConnected: true, session: session));
  }

  Future<void> stopRecording() async {
    if (_currentSession == null) return;

    _flushTimer?.cancel();
    _flushTimer = null;

    final db = await ref.read(databaseServiceProvider.future);
    await _flushBuffer(db);

    _currentSession = null;
    // Keep connected, but clear session
    state = AsyncData(RecordingData(isConnected: true, session: null));
  }

  void _handleLine(String line) {
    if (line.trim().isEmpty) return;

    try {
      final value = double.parse(line.trim());
      // Create reading object but don't set IDs yet
      final reading = TemperatureReading()
        ..timestamp = DateTime.now()
        ..value = value;

      // Always emit to stream for UI
      _readingsController.add(reading);

      // Only buffer if recording
      if (_currentSession != null) {
        reading.sessionId = _currentSession!.id;
        _buffer.add(reading);
        if (_buffer.length >= _bufferSize) {
          // We need db reference. It's async to get it.
          // Better pattern might be to store db ref in build or property if accessed frequently,
          // but Ref reading is fine.
          ref
              .read(databaseServiceProvider.future)
              .then((db) => _flushBuffer(db));
        }
      }
    } catch (e) {
      // Ignore parse errors (garbage data)
    }
  }

  void _startFlushTimer(DatabaseService db) {
    _flushTimer = Timer.periodic(_maxBufferTime, (_) {
      _flushBuffer(db);
    });
  }

  Future<void> _flushBuffer(DatabaseService db) async {
    if (_buffer.isEmpty) return;
    final readingsToSave = List<TemperatureReading>.from(_buffer);
    _buffer.clear();
    await db.saveReadings(readingsToSave);
  }
}
