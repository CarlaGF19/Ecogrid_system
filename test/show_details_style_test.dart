import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_ieee/screens/sensor_dashboard_screen.dart';

void main() {
  Future<void> pumpDashboard(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SensorDashboardScreen(ip: '')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Show details label uses glassmorphism and white text', (tester) async {
    await pumpDashboard(tester);
    final labelFinder = find.byKey(const ValueKey('label-details-temperatura'));
    expect(labelFinder, findsOneWidget);

    final container = tester.widget<Container>(labelFinder);
    final decoration = container.decoration as BoxDecoration;
    final opacity = decoration.color!.opacity;
    expect(opacity >= 0.3 && opacity <= 0.5, isTrue);

    final textFinder = find.descendant(of: labelFinder, matching: find.text('show details'));
    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style!.color, const Color(0xFFFFFFFF));
  });
}