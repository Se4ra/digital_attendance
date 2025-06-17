import 'package:digital_attendance_system/Lecturer/attendance_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:digital_attendance_system/Lecturer/course_management_screen.dart';
import 'package:digital_attendance_system/models/qr_generator_screen.dart';
import 'package:digital_attendance_system/Lecturer/lecturer_profile_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LecturerHomeScreen extends StatefulWidget {
  @override
  _LecturerHomeScreenState createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  int _currentIndex = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Course> _courses = [];

  final Color primaryColor = Colors.deepPurple;
  final Color accentColor = Color(0xFFD1C4E9);
  final Color bgColor = Color(0xFFF4F2F7);

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? courseJsonList = prefs.getStringList('courses');
    if (courseJsonList != null) {
      setState(() {
        _courses = courseJsonList.map((jsonStr) => Course.fromJson(jsonDecode(jsonStr))).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeContent(courses: _courses, onCoursesUpdated: _loadCourses),
          CourseManagementScreen(onCoursesUpdated: _loadCourses),
          LecturerAttendanceHistoryScreen(),
          LecturerProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final List<Course> courses;
  final VoidCallback onCoursesUpdated;

  const HomeContent({required this.courses, required this.onCoursesUpdated});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Color primaryColor = Colors.blueAccent;
  final Color accentColor = Color(0xFFD1C4E9);

  Future<dynamic> _pickLocation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Pick Location"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx, {
                    'latitude': 15.4122,
                    'longitude': 28.3121,
                    'address': 'Selected Classroom'
                  });
                },
                icon: const Icon(Icons.map),
                label: const Text("Pick Classroom Location"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayCourses = widget.courses.where((course) =>
    course.date.year == DateTime.now().year &&
        course.date.month == DateTime.now().month &&
        course.date.day == DateTime.now().day).toList();

    final otherCourses = widget.courses.where((course) =>
    !(course.date.year == DateTime.now().year &&
        course.date.month == DateTime.now().month &&
        course.date.day == DateTime.now().day)).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildCalendar(),
            const SizedBox(height: 20),
            Text(
              'Today\'s Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 10),
            if (todayCourses.isEmpty)
              _buildNoClassesCard("No classes scheduled for today"),
            ..._buildCourseCards(todayCourses),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    String today = DateFormat('EEE, MMM d, y').format(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/lecturer.png'),
            onBackgroundImageError: (_, __) => const Icon(Icons.person),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Lecturer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 4),
              Text(today, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildActionCard(Icons.qr_code, 'QR Code', () async {
            if (widget.courses.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No courses available to generate QR")),
              );
              return;
            }

            // Default to first course if available
            final course = widget.courses.first;
            final location = await _pickLocation(context);
            if (location == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QrGeneratorScreen(
                  courseId: course.id,
                  courseName: course.name,
                  lectureName: "Lecturer Name", // Replace with actual lecturer name
                  sessionTime: course.time,
                  location: location,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryColor, size: 30),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
        ),
        headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
      ),
    );
  }

  List<Widget> _buildCourseCards(List<Course> courses) {
    return courses.map((course) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Code: ${course.code}"),
              Text("Time: ${course.time}"),
              Text("Date: ${DateFormat('yyyy-MM-dd').format(course.date)}"),
              Text("Location: ${course.location?['address'] ?? 'Not set'}"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.location_on),
                    label: const Text("Set Location & QR"),
                    onPressed: () async {
                      final location = await _pickLocation(context);
                      if (location == null) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QrGeneratorScreen(
                            courseId: course.id,
                            courseName: course.name,
                            lectureName: "Lecturer Nauluta", // Replace with actual lecturer name
                            sessionTime: course.time,
                            location: location,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text("View Attendance"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LecturerAttendanceHistoryScreen(),
                        ),
                      );},
                  ),],),],),),);}).toList();
  }

  Widget _buildNoClassesCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ClassSchedule {
  final String className;
  final String classCode;
  final int enrolledStudents;
  final String location;

  ClassSchedule({
    required this.className,
    required this.classCode,
    required this.enrolledStudents,
    required this.location,
  });
}