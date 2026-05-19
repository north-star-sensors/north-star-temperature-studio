import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'serial_hardware_interface.dart';

class SerialAndroidImpl implements SerialHardwareInterface {
  static const int _allowedVid = 1155;
  static const Set<int> _allowedPids = {22336, 42346};

  UsbPort? _port;

  bool _isAllowedDevice(UsbDevice device) {
    final vid = device.vid;
    final pid = device.pid;
    return vid == _allowedVid && pid != null && _allowedPids.contains(pid);
  }

  @override
  Future<List<String>> getDevices() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    return devices
        .where(_isAllowedDevice)
        .map((d) => d.deviceName)
        .whereType<String>()
        .toList();
  }

  @override
  Future<Stream<List<int>>> connect(String devicePath) async {
    // Note: On Android, devicePath is usually the device name or ID.
    // For simplicity in this stub, we'll re-scan to find the device object.
    List<UsbDevice> devices = await UsbSerial.listDevices();
    final device = devices.firstWhere(
      (d) => d.deviceName == devicePath,
      orElse: () => throw Exception('Device not found'),
    );

    if (!_isAllowedDevice(device)) {
      throw Exception('Unsupported device VID/PID for $devicePath');
    }

    _port = await device.create();
    if (_port == null) {
      throw Exception('Failed to create port');
    }

    bool openResult = await _port!.open();
    if (!openResult) {
      throw Exception('Failed to open port');
    }

    await _port!.setDTR(true);
    await _port!.setRTS(true);

    await _port!.setPortParameters(
      115200,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    return _port!.inputStream!;
  }

  @override
  Future<void> disconnect() async {
    await _port?.close();
    _port = null;
  }

  @override
  Future<void> sendData(List<int> data) async {
    if (_port == null) {
      throw Exception('Port not open');
    }
    await _port!.write(Uint8List.fromList(data));
  }
}
