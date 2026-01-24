import 'package:flutter/material.dart';

class AppStyles {
  // 1. Fuente Base: Inter (Configurada globalmente en MaterialApp)
  
  // 2. Estilo Oficial para Subtítulos (Secciones)
  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700, // Bold
    color: Color(0xFF004C3F), // Verde bosque
    letterSpacing: 1.2,
  );

  // 3. Texto Secundario (Descripciones / Ayuda)
  static const TextStyle helperText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF004C3F),
    height: 1.4,
  );

  // 4. Fondo de Pantalla (Todas las pantallas internas)
  static const BoxDecoration internalScreenBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFFFFF), // Blanco puro
        Color(0xFFF7FFFC), // Blanco verdoso suave
      ],
    ),
  );
}
