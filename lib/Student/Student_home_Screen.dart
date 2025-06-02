import 'package:flutter/material.dart';
import 'package:digital_attendance_system/Student/student_attendance_history.dart';
import 'package:digital_attendance_system/Student/check_in_screen.dart';
import 'package:digital_attendance_system/Student/Student_Profile_Screen.dart';
import 'package:digital_attendance_system/Student/timetable_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


const Color kPrimaryColor = Color(0xFF3E8EED);
const Color kSecondaryColor = Color(0xFFF0F4FA);
const Color kAccentColor = Color(0xFF1A73E8);
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);

class Course {
  final String name;
  final String code;
  final String time;
  final DateTime date;
  final List<Student> students;
  final String id;

  Course({
    required this.name,
    required this.code,
    required this.time,
    required this.date,
    this.students = const [],
    required this.id,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'time': time,
    'date': date.toIso8601String(),
    'students': students.map((s) => s.toJson()).toList(),
    'id': id,
  };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    name: json['name'],
    code: json['code'],
    time: json['time'],
    date: DateTime.parse(json['date']),
    students: (json['students'] as List<dynamic>)
        .map((s) => Student.fromJson(s))
        .toList(),
    id: json['id'],
  );
}

class Student {
  final String name;
  final String id;

  Student({required this.name, required this.id});

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    name: json['name'],
    id: json['id'],
  );
}

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  final DateTime _currentDate = DateTime.now();
  Map<String, dynamic>? _currentLesson;
  String? _lessonStatus;
  Map<String, List<Map<String, String>>> _timetable = {};
  List<Course> _courses = [];
  String _studentId = "12345";
  String _studentName = "Student";

  @override
  void initState() {
    super.initState();
    _loadTimetableAndCourses();
    _loadStudentInfo();
  }

  Future<void> _loadStudentInfo() async {
    // Load student info from shared preferences or database
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName = prefs.getString('studentName') ?? "Student";
      _studentId = prefs.getString('studentId') ?? "12345";
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentAttendanceHistoryScreen(studentId: _studentId),
          ),
        );

        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StudentTimetableScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StudentProfileScreen()));
        break;
    }
  }

  Future<void> _loadTimetableAndCourses() async {
    _timetable = await _fetchTimetable();
    _courses = await _fetchCourses();
    _loadCurrentLesson();
  }

  Future<List<Course>> _fetchCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? courseJsonList = prefs.getStringList('courses');
    if (courseJsonList != null) {
      return courseJsonList
          .map((jsonStr) => Course.fromJson(jsonDecode(jsonStr)))
          .toList();
    } else {
      return [];
    }
  }

  void _loadCurrentLesson() {
    final now = DateTime.now();

    Course? currentCourse;
    for (var course in _courses) {
      if (course.date.year == now.year &&
          course.date.month == now.month &&
          course.date.day == now.day) {
        if (isTimeWithinRange(now, course.time)) {
          currentCourse = course;
          break;
        } else if (now.isBefore(_parseTime(course.time.split(" - ")[0]))) {
          currentCourse = course;
          break;
        }
      }
    }

    if (currentCourse != null) {
      setState(() {
        _currentLesson = {
          'course': currentCourse?.name,
          'time': currentCourse?.time,
          'id': currentCourse?.id,
        };
        _lessonStatus = isTimeWithinRange(now, currentCourse!.time)
            ? "ongoing"
            : "upcoming";
      });
    } else {
      setState(() {
        _currentLesson = null;
        _lessonStatus = "missed";
      });
    }
  }

  bool isTimeWithinRange(DateTime now, String timeRange) {
    final parts = timeRange.split(" - ");
    if (parts.length != 2) return false;

    final startTime = _parseTime(parts[0]);
    final endTime = _parseTime(parts[1]);
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  DateTime _parseTime(String timeString) {
    final now = DateTime.now();
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Student Dashboard',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // TODO: Add logout logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(_currentDate),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary)),
            const SizedBox(height: 16),
            _buildWeekDaysSelector(),
            const SizedBox(height: 16),
            Text('Current Lesson',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800])),
            const SizedBox(height: 12),
            _currentLesson != null
                ? _buildLessonCard(_currentLesson!)
                : _buildNoLessonCard(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kTextSecondary,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle), label: 'Attendance'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Timetable'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson['course'] ?? "Course Name",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.access_time, size: 16),
            const SizedBox(width: 4),
            Text(lesson['time'] ?? "No Time")
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentCheckInScreen(
                        studentId: _studentId,
                        studentName: _studentName,
                      ),
                    ),
                  );
                },
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_lessonStatus == "ongoing"
                  ? "Check In"
                  : _lessonStatus == "upcoming"
                  ? "Upcoming Class"
                  : "You Missed Class"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _lessonStatus == "ongoing"
                    ? Colors.indigo
                    : _lessonStatus == "upcoming"
                    ? Colors.grey.shade400
                    : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLessonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Text(
        "No lesson is scheduled for today.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWeekDaysSelector() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = date.day == _currentDate.day;

          return Container(
            width: 50,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weekdays[index],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : kTextPrimary)),
                  Text('${date.day}',
                      style: TextStyle(
                          color:
                          isSelected ? Colors.white : kTextPrimary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekday = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return "${weekday[date.weekday % 7]}, ${DateFormat('d MMMM').format(date)}";
  }

  Future<Map<String, List<Map<String, String>>>> _fetchTimetable() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'Monday': [
        {'course': 'Innovation', 'time': '08:00 - 09:30'},
        {'course': 'Mobile App', 'time': '10:00 - 11:30'},
      ],
      'Tuesday': [
        {'course': 'Basic Knowledge', 'time': '08:00 - 09:30'},
        {'course': 'ICT in Society', 'time': '10:00 - 11:30'},
        {'course': 'Innovation', 'time': '13:00 - 14:30'},
      ],
      'Wednesday': [
        {'course': 'Mobile App', 'time': '09:00 - 10:30'},
        {'course': 'ICT in Society', 'time': '11:00 - 12:30'},
      ],
      'Thursday': [
        {'course': 'Basic Knowledge', 'time': '08:30 - 10:00'},
        {'course': 'Innovation', 'time': '10:30 - 12:00'},
      ],
      'Friday': [
        {'course': 'Mobile App', 'time': '08:00 - 09:30'},
        {'course': 'ICT in Society', 'time': '10:00 - 11:30'},
        {'course': 'Basic Knowledge', 'time': '13:00 - 14:30'},
      ],
    };
  }
}