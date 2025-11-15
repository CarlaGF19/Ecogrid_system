import 'package:flutter/material.dart';
import '../styles/calendar_theme.dart';

class CalendarEvent {
  final DateTime date;
  final String title;
  final Color color;
  CalendarEvent({required this.date, required this.title, required this.color});
}

class CustomCalendar extends StatefulWidget {
  final DateTime initialDate;
  final ValueNotifier<List<CalendarEvent>> events;
  final void Function(DateTime selected)? onConfirm;

  const CustomCalendar({
    super.key,
    required this.initialDate,
    required this.events,
    this.onConfirm,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _cursor;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _cursor = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    _selected = widget.initialDate;
  }

  @override
  void didUpdateWidget(CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      setState(() {
        _cursor = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
        _selected = widget.initialDate;
      });
    }
  }

  List<String> get _weekdays => const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  List<String> get _months => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final isMobile = w < 768;
      final cellMinHeight = isMobile ? 60.0 : 80.0;
      final textSize = isMobile ? 12.0 : 14.0;
      final titleSize = isMobile ? 18.0 : 20.0;

      return Container(
        decoration: BoxDecoration(
          gradient: CalendarTheme.baseGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [CalendarTheme.baseShadow],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Date',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: CalendarTheme.titleColor,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _cursor = DateTime(_cursor.year, _cursor.month - 1, 1);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _cursor = DateTime(_cursor.year, _cursor.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _monthDropdown(textSize),
                const SizedBox(width: 12),
                _yearDropdown(textSize),
              ],
            ),
            const SizedBox(height: 12),
            _weekHeader(textSize),
            const SizedBox(height: 8),
            _calendarGrid(cellMinHeight, textSize),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA628),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _selected == null
                    ? null
                    : () => widget.onConfirm?.call(_selected!),
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _monthDropdown(double textSize) {
    return Container(
      decoration: BoxDecoration(
        color: CalendarTheme.grayBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CalendarTheme.graySoft),
        boxShadow: const [CalendarTheme.baseShadow],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButton<String>(
        value: _months[_cursor.month - 1],
        underline: const SizedBox.shrink(),
        items: _months
            .map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(fontSize: textSize, color: CalendarTheme.textPrimary))))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          final idx = _months.indexOf(v) + 1;
          setState(() {
            _cursor = DateTime(_cursor.year, idx, 1);
          });
        },
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
      ),
    );
  }

  Widget _yearDropdown(double textSize) {
    final years = List<int>.generate(201, (i) => 1900 + i);
    return Container(
      decoration: BoxDecoration(
        color: CalendarTheme.grayBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CalendarTheme.graySoft),
        boxShadow: const [CalendarTheme.baseShadow],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButton<int>(
        value: _cursor.year,
        underline: const SizedBox.shrink(),
        items: years
            .map((y) => DropdownMenuItem(value: y, child: Text('$y', style: TextStyle(fontSize: textSize, color: CalendarTheme.textPrimary))))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _cursor = DateTime(v, _cursor.month, 1);
          });
        },
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
      ),
    );
  }

  Widget _weekHeader(double textSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Text(
              _weekdays[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: textSize,
                color: i == 0 ? CalendarTheme.sundayColor : CalendarTheme.textPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _calendarGrid(double cellMinHeight, double textSize) {
    final firstWeekday = DateTime(_cursor.year, _cursor.month, 1).weekday % 7; // Sunday=0
    final daysInMonth = DateTime(_cursor.year, _cursor.month + 1, 0).day;
    final prevMonthDays = DateTime(_cursor.year, _cursor.month, 0).day;

    final cells = <Widget>[];
    for (int i = 0; i < firstWeekday; i++) {
      final d = prevMonthDays - firstWeekday + i + 1;
      cells.add(_dayCell(d, disabled: true, minHeight: cellMinHeight, textSize: textSize));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(_dayCell(d, minHeight: cellMinHeight, textSize: textSize));
    }
    while (cells.length % 7 != 0) {
      final d = cells.length - firstWeekday - daysInMonth + 1;
      cells.add(_dayCell(d, disabled: true, minHeight: cellMinHeight, textSize: textSize));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  Widget _dayCell(int day, {bool disabled = false, required double minHeight, required double textSize}) {
    final date = DateTime(_cursor.year, _cursor.month, day);
    final isSelected = _selected != null && _selected!.year == date.year && _selected!.month == date.month && _selected!.day == date.day;
    final inMonth = date.month == _cursor.month;
    final displayColor = disabled || !inMonth ? const Color(0xFFD4D4D4) : (isSelected ? CalendarTheme.selectedText : CalendarTheme.textPrimary);

    return GestureDetector(
      onTap: disabled || !inMonth
          ? null
          : () {
              setState(() => _selected = date);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(6),
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.white,
          gradient: isSelected ? CalendarTheme.selectedGradient : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? const [CalendarTheme.baseShadow] : const [],
        ),
        child: Center(
          child: Text(
            day.toString().padLeft(2, '0'),
            style: TextStyle(fontSize: textSize, color: displayColor, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}