import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Guarda un archivo PDF en Flutter Web utilizando package:web para compatibilidad con WASM.
///
/// Corrige problemas de compatibilidad de navegadores añadiendo el anchor al DOM
/// y gestionando correctamente el ciclo de vida del objeto URL.
Future<void> savePdf(Uint8List bytes, String fileName) async {
  // 1. Convertir bytes a formato compatible con JS (Blob)
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );

  // 2. Crear una URL para el objeto Blob
  final url = web.URL.createObjectURL(blob);

  // 3. Crear un elemento 'a' (anchor)
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;

  // 4. Corrección Crítica: Añadir el elemento al DOM.
  // Algunos navegadores (como Firefox) requieren que el elemento esté en el DOM para dispatchar el click.
  anchor.style.display = 'none';
  web.document.body?.append(anchor);

  // 5. Simular el click para iniciar la descarga
  anchor.click();

  // 6. Limpieza
  // Remover el elemento del DOM inmediatamente
  anchor.remove();

  // Liberar la URL del objeto.
  // Nota: Aunque algunos navegadores manejan la revocación inmediata,
  // es seguro hacerlo después del click síncrono en el mismo ciclo de eventos para descargas directas.
  web.URL.revokeObjectURL(url);
}
