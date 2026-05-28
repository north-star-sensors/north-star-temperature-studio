import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'serial_hardware_interface.dart';

/// Web Serial API backend (Chrome / Edge / Opera on desktop).
///
/// The browser exposes no silent port enumeration — a port must be granted by
/// the user through a native picker, which can only be opened from a user
/// gesture. To fit [SerialHardwareInterface], [getDevices] lists
/// already-granted ports plus a [pickerSentinel] entry; connecting to the
/// sentinel (or any not-yet-granted entry) opens the picker.
///
/// Bindings use `dart:js_interop_unsafe` (dynamic property/method access)
/// rather than `extension type` declarations so the file parses under the
/// older analyzer that isar_generator pins.
class SerialWebImpl implements SerialHardwareInterface {
  /// Synthetic device entry that opens the browser's port picker on connect.
  static const String pickerSentinel = 'Choose serial port…';

  final Map<String, JSObject> _granted = <String, JSObject>{};
  JSObject? _port;
  JSObject? _reader;
  StreamController<List<int>>? _controller;

  JSObject? get _serial {
    final navigator = globalContext.getProperty<JSObject?>('navigator'.toJS);
    return navigator?.getProperty<JSObject?>('serial'.toJS);
  }

  JSObject _requireSerial() {
    final serial = _serial;
    if (serial == null) {
      throw UnsupportedError(
        'Web Serial is unavailable in this browser. '
        'Use Chrome, Edge, or Opera on desktop.',
      );
    }
    return serial;
  }

  @override
  Future<List<String>> getDevices() async {
    final serial = _serial;
    if (serial == null) return const <String>[];

    final ports =
        (await serial
                .callMethod<JSPromise<JSArray<JSObject>>>('getPorts'.toJS)
                .toDart)
            .toDart;

    _granted.clear();
    final labels = <String>[];
    for (var i = 0; i < ports.length; i++) {
      final label = 'Serial port ${i + 1}';
      _granted[label] = ports[i];
      labels.add(label);
    }
    // Always offer the picker so a first-time user can grant a port.
    labels.add(pickerSentinel);
    return labels;
  }

  @override
  Future<Stream<List<int>>> connect(String devicePath) async {
    final serial = _requireSerial();

    final existing = _granted[devicePath];
    final JSObject port;
    if (existing != null) {
      port = existing;
    } else {
      // Opens the browser picker — must be reached from a user gesture.
      final filters = <JSObject>[
        for (final pid in SerialDeviceFilter.allowedProductIds)
          JSObject()
            ..setProperty(
              'usbVendorId'.toJS,
              SerialDeviceFilter.allowedVendorId.toJS,
            )
            ..setProperty('usbProductId'.toJS, pid.toJS),
      ];
      final options = JSObject()..setProperty('filters'.toJS, filters.toJS);
      port = await serial
          .callMethodVarArgs<JSPromise<JSObject>>('requestPort'.toJS, [options])
          .toDart;
    }

    final openOptions = JSObject()..setProperty('baudRate'.toJS, 115200.toJS);
    await port.callMethodVarArgs<JSPromise>('open'.toJS, [openOptions]).toDart;
    _port = port;

    final controller = StreamController<List<int>>();
    _controller = controller;
    unawaited(_pumpReader(port, controller));
    return controller.stream;
  }

  Future<void> _pumpReader(
    JSObject port,
    StreamController<List<int>> controller,
  ) async {
    final readable = port.getProperty<JSObject?>('readable'.toJS);
    if (readable == null) {
      await controller.close();
      return;
    }
    final reader = readable.callMethod<JSObject>('getReader'.toJS);
    _reader = reader;
    try {
      while (true) {
        final result = await reader
            .callMethod<JSPromise<JSObject>>('read'.toJS)
            .toDart;
        final done = result.getProperty<JSBoolean>('done'.toJS).toDart;
        if (done) break;
        final value = result.getProperty<JSAny?>('value'.toJS);
        if (value != null) {
          controller.add((value as JSUint8Array).toDart);
        }
      }
    } catch (error) {
      if (!controller.isClosed) controller.addError(error);
    } finally {
      reader.callMethod<JSAny?>('releaseLock'.toJS);
    }
  }

  @override
  Future<void> disconnect() async {
    final reader = _reader;
    _reader = null;
    if (reader != null) {
      try {
        await reader.callMethod<JSPromise>('cancel'.toJS).toDart;
      } catch (_) {
        // The read loop may already be unwinding; ignore.
      }
    }

    final port = _port;
    _port = null;
    if (port != null) {
      try {
        await port.callMethod<JSPromise>('close'.toJS).toDart;
      } catch (_) {
        // Port may already be closing.
      }
    }

    await _controller?.close();
    _controller = null;
  }

  @override
  Future<void> sendData(List<int> data) async {
    final port = _port;
    final writable = port?.getProperty<JSObject?>('writable'.toJS);
    if (writable == null) {
      throw StateError('Serial port is not open');
    }
    final writer = writable.callMethod<JSObject>('getWriter'.toJS);
    try {
      await writer
          .callMethodVarArgs<JSPromise>('write'.toJS, [
            Uint8List.fromList(data).toJS,
          ])
          .toDart;
    } finally {
      writer.callMethod<JSAny?>('releaseLock'.toJS);
    }
  }
}
