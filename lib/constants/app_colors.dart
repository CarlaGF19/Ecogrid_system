import 'package:flutter/material.dart';

/// Paleta de colores extraída del MainMenu
class AppColors {
  // Superficie y fondos
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color mintSurface = Color(0xFFE6FFF5);

  // Verdes principales del MainMenu
  static const Color deepGreen = Color(0xFF004C3F); // Títulos e íconos
  static const Color secondaryGreen = Color(0xFF009E73); // Íconos secundarios

  // Acentos (gradientes y énfasis)
  static const Color mintAccent = Color(0xFF00E0A6);
  static const Color tealAccent = Color(0xFF00B7B0);

  // Sombras y halos usados en MainMenu
  static const Color shadowMint40 = Color(0x6600E0A6); // rgba(0,224,166,0.4)
  static const Color shadowMint25 = Color(0x4000E0A6); // rgba(0,224,166,0.25)
  static const Color shadowMint60 = Color(0x9900E0A6); // rgba(0,224,166,0.6)
  static const Color shadowMint20 = Color(0x3300E0A6); // rgba(0,224,166,0.2)
  static const Color shadowMint10 = Color(0x1A00E0A6); // rgba(0,224,166,0.1)
  static const Color shadowTeal15 = Color(0x2600A078); // rgba(0,160,120,0.15)

  // Estado (badge)
  static const Color badgeGreen = Color(0xFF66BB6A);
}