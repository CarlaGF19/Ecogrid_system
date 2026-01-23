import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_ieee/screens/home_screen.dart';
import 'package:apk_ieee/screens/sensor_dashboard_screen.dart';
import 'package:apk_ieee/screens/notifications_screen.dart';
import 'package:apk_ieee/screens/image_gallery_screen.dart';
import 'package:apk_ieee/screens/device_config_screen.dart';
import 'package:apk_ieee/widgets/bottom_navigation_widget.dart';

void main() {
  group('Navigation Rules Tests', () {
    testWidgets('HomeScreen should have BottomNavigationWidget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.byType(BottomNavigationWidget), findsOneWidget);
    });

    testWidgets('SensorDashboardScreen should have BottomNavigationWidget', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const MaterialApp(home: SensorDashboardScreen(ip: '')),
      );
      expect(find.byType(BottomNavigationWidget), findsOneWidget);
    });

    testWidgets('NotificationsScreen should NOT have BottomNavigationWidget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      expect(find.byType(BottomNavigationWidget), findsNothing);
    });

    testWidgets('ImageGalleryScreen should have BottomNavigationWidget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImageGalleryScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationWidget), findsOneWidget);
    });

    testWidgets('DeviceConfigScreen should have BottomNavigationWidget', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: DeviceConfigScreen()));
      expect(find.byType(BottomNavigationWidget), findsOneWidget);
    });
  });
}
