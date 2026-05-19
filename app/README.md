# temperature_studio (Flutter app)

This is the Flutter project for [North Star Temperature Studio](../README.md). For an overview of the project, licensing, and contribution flow, start at the [repo root README](../README.md).

## Shared checks (any host OS)

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Run specific test files:

```
flutter test test/database_test.dart
flutter test test/hardware_test.dart
flutter test test/recording_service_feature_test.dart
flutter test test/ui/home_page_test.dart
```

## Platform smoke tests

### Windows

```
flutter run -d windows
```

### macOS

```
flutter run -d macos
```

### Linux

```
flutter run -d linux
```

### Android (USB cable)

```
flutter devices
flutter run -d <ANDROID_DEVICE_ID>
```

For Android hardware validation (USB serial):

1. Connect a supported USB serial device via OTG.
2. Open the app and tap device scan.
3. Confirm the device appears, connect, and verify incoming temperature values.
4. Start/stop recording and verify data is stored in session history.

### iOS (macOS only)

```
flutter run -d ios
```

### Web

```
flutter run -d chrome
```

## Wireless Debugging (Android)

To debug on an Android device while using the USB port for a peripheral:

1. Connect via USB first.
2. Enable TCP/IP mode:
    ```
    adb tcpip 5555
    ```
3. Disconnect the USB cable.
4. Find your phone's IP address (Settings → System → About phone → Network).
5. Connect via Wi-Fi:
    ```
    adb connect <PHONE_IP_ADDRESS>:5555
    ```
6. Run the app:
    ```
    flutter run
    ```
