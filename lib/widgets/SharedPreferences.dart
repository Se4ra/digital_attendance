import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendancePreferences {
  static const _keySelectedCourseId = 'selectedCourseId';
  static const _keyDateRangeStart = 'dateRangeStart';
  static const _keyDateRangeEnd = 'dateRangeEnd';

  // Save selected course ID
  static Future<void> saveSelectedCourseId(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCourseId, courseId);
  }

  // Get selected course ID, default to 'all'
  static Future<String> getSelectedCourseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCourseId) ?? 'all';
  }

  // Save selected date range (start and end as ISO strings)
  static Future<void> saveSelectedDateRange(DateTimeRange? range) async {
    final prefs = await SharedPreferences.getInstance();
    if (range != null) {
      await prefs.setString(_keyDateRangeStart, range.start.toIso8601String());
      await prefs.setString(_keyDateRangeEnd, range.end.toIso8601String());
    } else {
      await prefs.remove(_keyDateRangeStart);
      await prefs.remove(_keyDateRangeEnd);
    }
  }

  // Get selected date range
  static Future<DateTimeRange?> getSelectedDateRange() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString(_keyDateRangeStart);
    final endStr = prefs.getString(_keyDateRangeEnd);
    if (startStr != null && endStr != null) {
      final start = DateTime.tryParse(startStr);
      final end = DateTime.tryParse(endStr);
      if (start != null && end != null) {
        return DateTimeRange(start: start, end: end);
      }
    }
    return null;
  }
}
