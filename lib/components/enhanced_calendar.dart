import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced Calendar Component with rectangular design and no visible borders
/// Implements accessibility features and responsive design
class EnhancedCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;

  const EnhancedCalendar({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.helpText,
    this.cancelText,
    this.confirmText,
  });

  @override
  State<EnhancedCalendar> createState() => _EnhancedCalendarState();
}

class _EnhancedCalendarState extends State<EnhancedCalendar> {
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late int _currentMonth;
  late int _currentYear;
  late int _selectedDay;

  // Month names in Spanish
  static const List<String> _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  // Weekday names (short)
  static const List<String> _weekdays = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
    _selectedDate = _currentDate;
    _currentMonth = _currentDate.month;
    _currentYear = _currentDate.year;
    _selectedDay = _currentDate.day;
  }

  /// Get days in current month
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Get first day of month (0 = Monday, 6 = Sunday)
  int _getFirstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  /// Navigate to previous month
  void _previousMonth() {
    if (_currentMonth == 1) {
      if (_currentYear > widget.firstDate.year) {
        setState(() {
          _currentMonth = 12;
          _currentYear--;
        });
      }
    } else {
      setState(() {
        _currentMonth--;
      });
    }
  }

  /// Navigate to next month
  void _nextMonth() {
    if (_currentMonth == 12) {
      if (_currentYear < widget.lastDate.year) {
        setState(() {
          _currentMonth = 1;
          _currentYear++;
        });
      }
    } else {
      setState(() {
        _currentMonth++;
      });
    }
  }

  /// Select a date
  void _selectDate(int day) {
    if (day == 0) return; // Empty cell

    final selectedDate = DateTime(_currentYear, _currentMonth, day);

    // Validate date is within range
    if (selectedDate.isBefore(widget.firstDate) ||
        selectedDate.isAfter(widget.lastDate)) {
      return;
    }

    setState(() {
      _selectedDay = day;
      _selectedDate = selectedDate;
    });

    widget.onDateSelected(selectedDate);
  }

  /// Build calendar grid
  List<Widget> _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_currentYear, _currentMonth);
    final firstDayOffset = _getFirstDayOfMonth(_currentYear, _currentMonth);
    final List<Widget> days = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < firstDayOffset; i++) {
      days.add(_buildDayCell(0, isEmpty: true));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentYear, _currentMonth, day);
      final isDisabled =
          date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);
      final isSelected =
          day == _selectedDay &&
          _currentMonth == _selectedDate.month &&
          _currentYear == _selectedDate.year;
      final isToday =
          day == DateTime.now().day &&
          _currentMonth == DateTime.now().month &&
          _currentYear == DateTime.now().year;

      days.add(
        _buildDayCell(
          day,
          isSelected: isSelected,
          isToday: isToday,
          isDisabled: isDisabled,
        ),
      );
    }

    return days;
  }

  /// Build individual day cell
  Widget _buildDayCell(
    int day, {
    bool isEmpty = false,
    bool isSelected = false,
    bool isToday = false,
    bool isDisabled = false,
  }) {
    if (isEmpty) {
      return Container(
        margin: const EdgeInsets.all(2),
        child: const SizedBox(width: 48, height: 48),
      );
    }

    // Color palette
    final backgroundColor = isSelected
        ? const Color(0xFFDDEBFF) // Pastel blue for selected
        : isToday
        ? const Color(0xFFFFF4C2) // Pastel yellow for today
        : Colors.transparent;

    final textColor = isDisabled
        ? const Color(0xFFC6CBD4) // Gray for disabled
        : isSelected
        ? const Color(0xFF4A90E2) // Blue for selected text
        : const Color(0xFF4B5563); // Dark gray for normal text

    return Container(
      margin: const EdgeInsets.all(2),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4), // Subtle rounding
        child: InkWell(
          onTap: () => _selectDate(day),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build year dropdown
  Widget _buildYearDropdown() {
    final years = List<int>.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF2), // Soft gray background
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        value: _currentYear,
        underline: const SizedBox(), // Remove underline
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4B5563)),
        items: years.map((year) {
          return DropdownMenuItem<int>(
            value: year,
            child: Text(
              year.toString(),
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (year) {
          if (year != null) {
            setState(() {
              _currentYear = year;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with month navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous month button
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF4B5563),
                  ),
                  tooltip: 'Mes anterior',
                ),

                // Month and year
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _months[_currentMonth - 1],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildYearDropdown(),
                    ],
                  ),
                ),

                // Next month button
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF4B5563),
                  ),
                  tooltip: 'Mes siguiente',
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE8ECF2)),

          // Weekday headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekdays.map((day) {
                return Container(
                  width: 48,
                  height: 32,
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Color(0xFF9AA3B3),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Calendar grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              children: _buildCalendarGrid(),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    widget.cancelText ?? 'Cancelar',
                    style: const TextStyle(color: Color(0xFF4A90E2)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onDateSelected(_selectedDate);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(widget.confirmText ?? 'Aceptar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced Date Picker Dialog
Future<DateTime?> showEnhancedDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
  String? cancelText,
  String? confirmText,
}) async {
  DateTime? selectedDate;

  try {
    print('=== showEnhancedDatePicker iniciado ===');
    print('Context: $context');
    print('Initial date: $initialDate');
    print('First date: $firstDate');
    print('Last date: $lastDate');

    await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        print('=== Dialog builder ejecutado ===');
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: EnhancedCalendar(
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                helpText: helpText,
                cancelText: cancelText,
                confirmText: confirmText,
                onDateSelected: (date) {
                  print('=== Fecha seleccionada: $date ===');
                  selectedDate = date;
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        );
      },
    );

    print('=== showEnhancedDatePicker finalizado, fecha seleccionada: $selectedDate ===');
    return selectedDate;
  } catch (e) {
    print('ERROR en showEnhancedDatePicker: $e');
    return null;
  }
}
