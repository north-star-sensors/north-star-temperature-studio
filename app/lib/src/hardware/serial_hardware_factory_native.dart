import 'dart:io';

import 'serial_android_impl.dart';
import 'serial_desktop_impl.dart';
import 'serial_hardware_interface.dart';

/// Native (VM) backend selection: USB serial on Android, libserialport on the
/// desktop platforms. Only compiled when `dart:io` is available.
SerialHardwareInterface createSerialHardware() {
  if (Platform.isAndroid) {
    return SerialAndroidImpl();
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return SerialDesktopImpl();
  }
  throw UnsupportedError('Platform not supported for serial hardware');
}
