import 'package:flutter/material.dart';
import 'package:digital_attendance_system/Lecturer/attendance_record.dart';

class AttendanceService {
  /// Fetch full attendance history (simulate API call)
  Future<List<AttendanceRecord>> getFullAttendanceHistory() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulated delay
    // TODO: Replace with actual API call
    return _mockAttendanceHistory;
  }

  /// Submit a check-in using code and GPS location
  Future<bool> submitCheckIn(String code, double latitude, double longitude) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulated delay
    print('Check-in submitted: Code=$code, Location=($latitude, $longitude)');

    // TODO: Replace with actual backend verification
    return code.trim().isNotEmpty;
  }

  /// Generate attendance code for a course at a given time and location
  Future<String?> generateAttendanceCode(String courseId, String timeSlot, String locationInfo) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulated delay
    print('Generating code for $courseId ($timeSlot) at $locationInfo');

    // TODO: Implement backend logic to generate code
    return '${courseId.substring(0, 3).toUpperCase()}${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  /// Filter attendance records by optional courseId and date range
  List<AttendanceRecord> filterHistory({
    required List<AttendanceRecord> fullHistory,
    String? courseId,
    DateTimeRange? dateRange,
  }) {
    List<AttendanceRecord> filtered = fullHistory;

    // Filter by course
    if (courseId != null && courseId.toLowerCase() != 'all') {
      filtered = filtered.where((record) => record.courseId == courseId).toList();
    }

    // Filter by date range
    if (dateRange != null) {
      final start = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
      final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
      filtered = filtered.where((record) {
        final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
        return !recordDate.isBefore(start) && !recordDate.isAfter(end);
      }).toList();
    }

    // Sort by most recent date and then alphabetically by student
    filtered.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      return dateComparison != 0 ? dateComparison : a.studentName.compareTo(b.studentName);
    });

    return filtered;
  }
}

/// Mock data for development/testing
final List<AttendanceRecord> _mockAttendanceHistory = [
  // Cyber Security (cyber101)
  AttendanceRecord(id: '1', date: DateTime(2024, 7, 15), courseId: 'cyber101', courseName: 'Cyber Security Fundamentals', studentName: 'Alice Smith', studentId: 'S111', status: AttendanceStatus.attended, time: '09:00'),
  AttendanceRecord(id: '2', date: DateTime(2024, 7, 15), courseId: 'cyber101', courseName: 'Cyber Security Fundamentals', studentName: 'Bob Johnson', studentId: 'S222', status: AttendanceStatus.attended, time: '09:00'),
  AttendanceRecord(id: '3', date: DateTime(2024, 7, 15), courseId: 'cyber101', courseName: 'Cyber Security Fundamentals', studentName: 'Charlie Brown', studentId: 'S333', status: AttendanceStatus.absent, time: '09:00'),
  AttendanceRecord(id: '4', date: DateTime(2024, 7, 22), courseId: 'cyber101', courseName: 'Cyber Security Fundamentals', studentName: 'Alice Smith', studentId: 'S111', status: AttendanceStatus.attended, time: '09:00'),
  AttendanceRecord(id: '5', date: DateTime(2024, 7, 22), courseId: 'cyber101', courseName: 'Cyber Security Fundamentals', studentName: 'Bob Johnson', studentId: 'S222', status: AttendanceStatus.absent, time: '09:00'),
  AttendanceRecord(id: '6', date: DateTime(2024, 7, 22), courseId: 'cyber101', courseName: 'Cyber Security Fundamentals', studentName: 'Charlie Brown', studentId: 'S333', status: AttendanceStatus.attended, time: '09:00'),
  // Mobile App Dev (mobileapp202)
  AttendanceRecord(id: '7', date: DateTime(2024, 7, 16), courseId: 'mobileapp202', courseName: 'Mobile Application Development', studentName: 'Diana Prince', studentId: 'S444', status: AttendanceStatus.attended, time: '11:00'),
  AttendanceRecord(id: '8', date: DateTime(2024, 7, 16), courseId: 'mobileapp202', courseName: 'Mobile Application Development', studentName: 'Eve Adams', studentId: 'S555', status: AttendanceStatus.attended, time: '11:00'),
  AttendanceRecord(id: '9', date: DateTime(2024, 7, 23), courseId: 'mobileapp202', courseName: 'Mobile Application Development', studentName: 'Diana Prince', studentId: 'S444', status: AttendanceStatus.attended, time: '11:00'),
  AttendanceRecord(id: '10', date: DateTime(2024, 7, 23), courseId: 'mobileapp202', courseName: 'Mobile Application Development', studentName: 'Eve Adams', studentId: 'S555', status: AttendanceStatus.attended, time: '11:00'),
  // Data Structures (datastruct)
  AttendanceRecord(id: '11', date: DateTime(2024, 7, 17), courseId: 'datastruct', courseName: 'Data Structures and Algorithms', studentName: 'Frank Castle', studentId: 'S666', status: AttendanceStatus.absent, time: '13:00'),
  AttendanceRecord(id: '12', date: DateTime(2024, 7, 24), courseId: 'datastruct', courseName: 'Data Structures and Algorithms', studentName: 'Frank Castle', studentId: 'S666', status: AttendanceStatus.attended, time: '13:00'),
];

/// Returns unique course list for dropdown filters
List<Map<String, String>> getCoursesForFilter(List<AttendanceRecord> history) {
  final Map<String, String> uniqueCourses = {'all': 'All Courses'};
  for (final record in history) {
    uniqueCourses[record.courseId] = record.courseName;
  }
  return uniqueCourses.entries
      .map((entry) => {'id': entry.key, 'name': entry.value})
      .toList();
}
