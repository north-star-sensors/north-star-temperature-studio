import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sources/temperature_source.dart';

class LiveTemperatureSource implements TemperatureSource {
  LiveTemperatureSource(this._sampleStream);

  final Stream<TemperatureSample> _sampleStream;

  @override
  Stream<TemperatureSample> stream() => _sampleStream;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}
