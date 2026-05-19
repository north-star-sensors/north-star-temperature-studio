import '../models/algorithm_lab_models.dart';

abstract class TemperatureSource {
  Stream<TemperatureSample> stream();
  Future<void> start();
  Future<void> stop();
}
