import 'package:flutter/material.dart';

class CalendarTheme {
  static const Color textPrimary = Color(0xFF333333);
  static const Color titleColor = Color(0xFF111827);
  static const Color graySoft = Color(0xFFE6E6E6);
  static const Color grayBg = Color(0xFFF7F7F7);
  static const Color sundayColor = Color(0xFFF59E0B);
  static const Color selectedText = Colors.white;
  static const LinearGradient selectedGradient = LinearGradient(
    colors: [Color(0xFFF9C651), Color(0xFFF7A928)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient baseGradient = LinearGradient(
    colors: [Color(0xFFE1F5FE), Color(0xFFE8F5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BoxShadow baseShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 4,
    spreadRadius: 1,
    offset: Offset(0, 2),
  );
}