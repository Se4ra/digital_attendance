import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class LecturerCalendar extends StatefulWidget {
  final Function(DateTime) onDaySelected;

  LecturerCalendar({required this.onDaySelected});

  @override
  _LecturerCalendarState createState() => _LecturerCalendarState();
}

class _LecturerCalendarState extends State<LecturerCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        widget.onDaySelected(selectedDay);
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.green, // New color for today
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.purple, // New color for selected day
          shape: BoxShape.circle,
        ),
        weekendTextStyle: TextStyle(color: Colors.redAccent),
        todayTextStyle: TextStyle(color: Colors.white),
        selectedTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
