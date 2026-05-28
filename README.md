# North Star Temperature Studio

A multi-platform Flutter app for capturing, analyzing, and exporting temperature sensor data. Built around a streaming algorithm lab, session recording with on-device storage, and live charting; works against simulated sources or USB / serial hardware on Windows, macOS, Linux, Android, and the web.

### Platform notes

- **Desktop (Windows/macOS/Linux) & Android** — full support: USB/serial hardware and on-device (Isar) recording storage.
- **Web** — runs on **Chromium-based desktop browsers (Chrome, Edge, Opera)**. Live hardware uses the browser's [Web Serial API](https://developer.mozilla.org/docs/Web/API/Web_Serial_API) (no extension needed); you grant a port via the browser's picker on connect. Firefox and Safari don't implement Web Serial, so they're simulator-only. Recording storage on the web is **in-memory** (Isar can't compile to web), so sessions don't persist across reloads — exports still work.

## Project layout

```
.
├── app/                # Flutter application (Dart, all platform runners)
├── .github/workflows/  # CLA enforcement + Flutter CI
├── CLA.md              # Harmony Individual CLA v1.0, Option Five
├── CONTRIBUTING.md     # How to contribute
└── LICENSE             # AGPL-3.0-or-later
```

## Getting started

Prerequisites:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.10.3`)
- Platform-specific toolchains for whichever target you want to run (Android Studio, Xcode, Visual Studio with Desktop C++, etc.)

Install dependencies and regenerate codegen output:

```
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Run on your platform of choice:

```
flutter run -d windows    # or macos, linux, chrome, or an Android device id
```

See [`app/README.md`](app/README.md) for the full per-platform command reference, smoke-test steps, and the wireless-debugging recipe for Android-with-USB-peripheral setups.

## Tests

```
cd app
flutter analyze
flutter test
```

CI runs the same checks on every push and pull request — see [`.github/workflows/flutter-ci.yml`](.github/workflows/flutter-ci.yml).

## Contributing

Contributions are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) — your first pull request will prompt you to sign the [CLA](CLA.md) via CLA Assistant.

## License

Distributed under the [GNU Affero General Public License v3.0 or later](LICENSE). Contributions are additionally licensed under the [Harmony Individual CLA v1.0, Option Five](CLA.md), which keeps the project AGPL today while preserving the option to dual-license in the future. Documentation and other non-code contributions are licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
