import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:temperature_studio/src/hardware/hardware_provider.dart';
import 'package:temperature_studio/src/hardware/serial_android_impl.dart';
import 'package:temperature_studio/src/hardware/serial_desktop_impl.dart';
import 'package:temperature_studio/src/hardware/serial_hardware_interface.dart';

@GenerateNiceMocks([MockSpec<SerialHardwareInterface>()])
import 'hardware_test.mocks.dart';

void main() {
  group('HardwareProvider Tests', () {
    test('Returns correct implementation for platform', () {
      // We cannot easily mock Platform.isAndroid in a unit test without external packages or custom wrappers.
      // So we verify that it returns *some* implementation of SerialHardwareInterface
      // and check the type based on the real platform running the test (likely Windows/Linux/Mac for unit tests).

      final container = ProviderContainer();
      final hardware = container.read(serialHardwareProvider);

      expect(hardware, isA<SerialHardwareInterface>());

      if (Platform.isAndroid) {
        expect(hardware, isA<SerialAndroidImpl>());
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        expect(hardware, isA<SerialDesktopImpl>());
      }
    });

    test('Can mock SerialHardwareInterface', () async {
      final mockHardware = MockSerialHardwareInterface();

      when(mockHardware.getDevices()).thenAnswer((_) async => ['COM1', 'COM2']);
      when(mockHardware.connect(any)).thenAnswer(
        (_) async => Stream.fromIterable([
          [0x01, 0x02],
          [0x03],
        ]),
      );

      final devices = await mockHardware.getDevices();
      expect(devices, ['COM1', 'COM2']);

      final stream = await mockHardware.connect('COM1');
      final data = await stream.toList();
      expect(data, [
        [0x01, 0x02],
        [0x03],
      ]);

      verify(mockHardware.connect('COM1')).called(1);
    });
  });
}
