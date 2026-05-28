import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'serial_hardware_interface.dart';

class SerialDesktopImpl implements SerialHardwareInterface {
  SerialPort? _port;
  SerialPortReader? _reader;

  bool _isAllowedDevice(SerialPort port) =>
      SerialDeviceFilter.isAllowed(port.vendorId, port.productId);

  @override
  Future<List<String>> getDevices() async {
    final allowedPorts = <String>[];

    for (final devicePath in SerialPort.availablePorts) {
      final port = SerialPort(devicePath);
      try {
        if (_isAllowedDevice(port)) {
          allowedPorts.add(devicePath);
        }
      } finally {
        port.dispose();
      }
    }

    return allowedPorts;
  }

  @override
  Future<Stream<List<int>>> connect(String devicePath) async {
    final port = SerialPort(devicePath);
    if (!_isAllowedDevice(port)) {
      port.dispose();
      throw Exception('Unsupported device VID/PID for port $devicePath');
    }

    if (!port.openReadWrite()) {
      port.dispose();
      throw Exception('Failed to open port $devicePath');
    }

    _port = port;

    final config = SerialPortConfig();
    config.baudRate = 115200;
    port.config = config;

    _reader = SerialPortReader(port);
    return _reader!.stream;
  }

  @override
  Future<void> disconnect() async {
    _reader?.close();
    _port?.close();
    _port?.dispose();
    _port = null;
    _reader = null;
  }

  @override
  Future<void> sendData(List<int> data) async {
    if (_port == null || !_port!.isOpen) {
      throw Exception('Port not open');
    }
    _port!.write(Uint8List.fromList(data));
  }
}
