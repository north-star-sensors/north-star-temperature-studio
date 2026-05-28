/// Vendor/product allow-list for supported North Star sensor hardware.
///
/// The sensors enumerate as an STMicroelectronics USB CDC device
/// (VID 0x0483) advertising one of the known product IDs below. Both the
/// desktop ([SerialDesktopImpl]) and Android ([SerialAndroidImpl]) backends
/// filter against this single source of truth.
class SerialDeviceFilter {
  const SerialDeviceFilter._();

  /// 0x0483 — STMicroelectronics.
  static const int allowedVendorId = 1155;

  /// 0x5740 (STM32 virtual COM) and 0xA56A.
  static const Set<int> allowedProductIds = {22336, 42346};

  /// Whether a device with the given [vendorId]/[productId] is a supported
  /// North Star sensor.
  static bool isAllowed(int? vendorId, int? productId) =>
      vendorId == allowedVendorId &&
      productId != null &&
      allowedProductIds.contains(productId);
}

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
