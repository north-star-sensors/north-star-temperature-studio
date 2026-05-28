import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'serial_hardware_interface.dart';
// Platform-specific backend, picked at compile time so that native-only
// libraries (dart:ffi via libserialport, dart:io) never reach the web bundle
// and the Web Serial backend never reaches native builds.
import 'serial_hardware_factory_stub.dart'
    if (dart.library.io) 'serial_hardware_factory_native.dart'
    if (dart.library.js_interop) 'serial_hardware_factory_web.dart';

part 'hardware_provider.g.dart';

@Riverpod(keepAlive: true)
SerialHardwareInterface serialHardware(SerialHardwareRef ref) {
  return createSerialHardware();
}
