import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'serial_android_impl.dart';
import 'serial_desktop_impl.dart';
import 'serial_hardware_interface.dart';

part 'hardware_provider.g.dart';

@Riverpod(keepAlive: true)
SerialHardwareInterface serialHardware(SerialHardwareRef ref) {
  if (Platform.isAndroid) {
    return SerialAndroidImpl();
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return SerialDesktopImpl();
  } else {
    throw UnsupportedError('Platform not supported for serial hardware');
  }
}
