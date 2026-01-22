@TestOn('browser')
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_ieee/utils/pdf_saver_web.dart';

void main() {
  group('PDF Saver Web Tests', () {
    test('savePdf ejecuta manipulación del DOM sin errores', () async {
      // Datos de prueba simulados (Header PDF básico)
      final Uint8List mockPdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D]); // %PDF-
      const String fileName = 'test_download.pdf';

      // Ejecutar la función savePdf
      // Esta prueba verifica que:
      // 1. La conversión a JS Blob funciona.
      // 2. La creación de URL funciona.
      // 3. La creación y manipulación del elemento Anchor funciona.
      // 4. No se lanzan excepciones de tipo (TypeErrors) en la interoperabilidad Dart-JS.
      try {
        await savePdf(mockPdfBytes, fileName);
      } catch (e) {
        fail('savePdf lanzó una excepción: $e');
      }
    });
  });
}
