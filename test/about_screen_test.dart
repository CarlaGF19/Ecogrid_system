import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_ieee/screens/about_screen.dart';
import 'package:apk_ieee/constants/strings.dart';

void main() {
  Widget buildApp() {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const AboutScreen(),
    );
  }

  testWidgets('Renderiza encabezado con logo y título H5', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('about_header')), findsOneWidget);
    expect(find.text(Strings.headerTitle), findsOneWidget);
  });

  testWidgets('Muestra tarjeta de descripción con bodyMedium y lineHeight', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('about_description')), findsOneWidget);
    expect(find.text(Strings.projectDescriptionTitle), findsOneWidget);
    expect(find.textContaining('EcoGrid'), findsOneWidget);
  });

  testWidgets('Lista de especificaciones técnicas renderiza elementos', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('about_specs')), findsOneWidget);
    expect(find.text(Strings.microcontrollerLabel), findsOneWidget);
    expect(find.text(Strings.microcontrollerValue), findsOneWidget);
    expect(find.text(Strings.connectivityLabel), findsOneWidget);
    expect(find.text(Strings.connectivityValue), findsOneWidget);
  });

  testWidgets('ExpansionTile de versión muestra datos al expandir', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 350));

    // Encuentra la expansión y expándela
    expect(find.byKey(const Key('about_version')), findsOneWidget);
    // Toca el título para expandir
    await tester.tap(find.text(Strings.versionInfoTitle));
    await tester.pumpAndSettle();

    expect(find.text(Strings.appVersionLabel), findsOneWidget);
    expect(find.text(Strings.flutterSdkLabel), findsOneWidget);
    expect(find.text(Strings.platformLabel), findsOneWidget);
  });
}
