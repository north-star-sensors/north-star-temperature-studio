import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:temperature_studio/src/hardware/hardware_provider.dart';
import 'package:temperature_studio/src/ui/home/home_page.dart';

import '../hardware_test.mocks.dart';

void main() {
  testWidgets('HomePage scans for devices on load', (
    WidgetTester tester,
  ) async {
    final mockHardware = MockSerialHardwareInterface();
    when(mockHardware.getDevices()).thenAnswer((_) async => ['COM1', 'COM2']);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [serialHardwareProvider.overrideWithValue(mockHardware)],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    // Initial load might show loading or empty on first frame depending on Async
    // _scanDevices calls setState async.
    await tester.pumpAndSettle();

    verify(mockHardware.getDevices()).called(greaterThanOrEqualTo(1));

    expect(find.text('COM1'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
  });
}
