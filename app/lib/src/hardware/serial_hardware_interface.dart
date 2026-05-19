/// Abstract interface for hardware interaction.
/// This allows us to swap implementations for Desktop (libserialport) and Android (usb_serial),
/// and mock it easily for testing.
abstract class SerialHardwareInterface {
  /// Scans for available devices and returns a list of device paths/names.
  Future<List<String>> getDevices();

  /// Connects to a device given its [devicePath].
  /// Returns a Stream of raw bytes from the device.
  Future<Stream<List<int>>> connect(String devicePath);

  /// Disconnects from the currently connected device.
  Future<void> disconnect();

  /// Sends data to the connected device.
  Future<void> sendData(List<int> data);
}
