import 'serial_hardware_interface.dart';
import 'serial_web_impl.dart';

/// Web backend: the browser's Web Serial API. Only compiled when
/// `dart:js_interop` is available (i.e. when targeting the web).
SerialHardwareInterface createSerialHardware() => SerialWebImpl();
