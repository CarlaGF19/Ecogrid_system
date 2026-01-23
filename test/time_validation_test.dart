
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Logic to be tested (duplicated here for testing, will be in the main file)
TimeOfDay? parseTimeInput(String input) {
  if (input.isEmpty) return null;

  // 1. Try HH:MM format
  final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
  final timeMatch = timeRegex.firstMatch(input);
  if (timeMatch != null) {
    final hour = int.parse(timeMatch.group(1)!);
    final minute = int.parse(timeMatch.group(2)!);
    return TimeOfDay(hour: hour, minute: minute);
  }

  // 2. Try Numeric Minutes format
  final numericRegex = RegExp(r'^\d+$');
  if (numericRegex.hasMatch(input)) {
    final totalMinutes = int.parse(input);
    if (totalMinutes >= 0 && totalMinutes < 1440) {
      final hour = totalMinutes ~/ 60;
      final minute = totalMinutes % 60;
      return TimeOfDay(hour: hour, minute: minute);
    }
  }

  return null;
}

void main() {
  group('Time Input Validation & Parsing', () {
    test('Parses HH:MM format correctly', () {
      expect(parseTimeInput('01:30'), const TimeOfDay(hour: 1, minute: 30));
      expect(parseTimeInput('18:45'), const TimeOfDay(hour: 18, minute: 45));
      expect(parseTimeInput('00:00'), const TimeOfDay(hour: 0, minute: 0));
      expect(parseTimeInput('23:59'), const TimeOfDay(hour: 23, minute: 59));
    });

    test('Parses single digit hour H:MM correctly', () {
      expect(parseTimeInput('1:30'), const TimeOfDay(hour: 1, minute: 30));
      expect(parseTimeInput('9:05'), const TimeOfDay(hour: 9, minute: 5));
    });

    test('Parses numeric minutes correctly', () {
      expect(parseTimeInput('90'), const TimeOfDay(hour: 1, minute: 30));
      expect(parseTimeInput('0'), const TimeOfDay(hour: 0, minute: 0));
      expect(parseTimeInput('120'), const TimeOfDay(hour: 2, minute: 0));
      expect(parseTimeInput('1439'), const TimeOfDay(hour: 23, minute: 59));
    });

    test('Returns null for invalid inputs', () {
      expect(parseTimeInput('24:00'), null); // Out of range
      expect(parseTimeInput('12:60'), null); // Invalid minute
      expect(parseTimeInput('abc'), null); // Not numeric
      expect(parseTimeInput('-10'), null); // Negative
      expect(parseTimeInput('1440'), null); // Out of range minutes (24h)
    });
  });
}
