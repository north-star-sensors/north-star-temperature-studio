import 'serial_hardware_interface.dart';

/// Fallback used only on platforms that match neither `dart:io` (native) nor
/// `dart:js_interop` (web). In practice this is never reached.
SerialHardwareInterface createSerialHardware() => throw UnsupportedError(
  'No serial hardware backend is available for this platform.',
);
