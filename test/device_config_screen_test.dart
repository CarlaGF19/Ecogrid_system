import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_ieee/screens/device_config_screen.dart';
import 'package:apk_ieee/widgets/bottom_navigation_widget.dart';

void main() {
  testWidgets('DeviceConfigScreen displays BottomNavigationWidget',
      (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: DeviceConfigScreen(),
    ));

    // Verify that BottomNavigationWidget is present
    expect(find.byType(BottomNavigationWidget), findsOneWidget);

    // Verify that the title text is present
    expect(find.text('Configurar IP del ESP32'), findsOneWidget);
  });
}
