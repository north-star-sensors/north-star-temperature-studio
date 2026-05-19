import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/recording/recording_service.dart';
import 'package:temperature_studio/src/hardware/hardware_provider.dart';

abstract class LiveTemperatureGateway {
  Stream<TemperatureSample> get samples;
  Future<List<String>> getDevices();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  bool get isConnected;
}

class RecordingLiveTemperatureGateway implements LiveTemperatureGateway {
  RecordingLiveTemperatureGateway(this._ref);

  final Ref _ref;

  @override
  Stream<TemperatureSample> get samples {
    final service = _ref.read(recordingServiceProvider.notifier);
    return service.readingsStream.map(
      (reading) => TemperatureSample(
        timestamp: reading.timestamp,
        rawCelsius: reading.value,
      ),
    );
  }

  @override
  Future<List<String>> getDevices() async {
    return _ref.read(serialHardwareProvider).getDevices();
  }

  @override
  Future<void> connect(String deviceId) async {
    await _ref.read(recordingServiceProvider.notifier).connect(deviceId);
  }

  @override
  Future<void> disconnect() async {
    await _ref.read(recordingServiceProvider.notifier).disconnect();
  }

  @override
  bool get isConnected {
    return _ref.read(recordingServiceProvider).value?.isConnected ?? false;
  }
}

final liveTemperatureGatewayProvider = Provider<LiveTemperatureGateway>((ref) {
  return RecordingLiveTemperatureGateway(ref);
});
