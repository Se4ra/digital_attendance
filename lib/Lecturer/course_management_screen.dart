import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class Course {
  final String name;
  final String code;
  final String time;
  final DateTime date;
  final List<Student> students;
  final String id;
  final Map<String, dynamic>? location;

  Course({
    required this.name,
    required this.code,
    required this.time,
    required this.date,
    this.students = const [],
    required this.id,
    this.location,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'time': time,
    'date': date.toIso8601String(),
    'students': students.map((s) => s.toJson()).toList(),
    'id': id,
    'location': location,
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
    location: json['location'] != null
        ? Map<String, dynamic>.from(json['location'])
        : null,
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

class CourseManagementScreen extends StatefulWidget {
  final VoidCallback? onCoursesUpdated;

  const CourseManagementScreen({Key? key, this.onCoursesUpdated}) : super(key: key);

  @override
  _CourseManagementScreenState createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  List<Course> courses = [];
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseTimeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _saveCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> courseJsonList = courses.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList('courses', courseJsonList);
    widget.onCoursesUpdated?.call();
  }

  Future<void> _loadCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? courseJsonList = prefs.getStringList('courses');
    if (courseJsonList != null) {
      setState(() {
        courses = courseJsonList.map((jsonStr) =>
            Course.fromJson(jsonDecode(jsonStr))).toList();
      });
    }
  }

  Future<void> _pickLocation() async {
    final location = await showDialog<Map<String, dynamic>>(
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
                    'latitude': -15.3875,
                    'longitude': 28.3228,
                    'address': 'University Campus'
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

    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    }
  }

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Course"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _courseNameController,
                  decoration: const InputDecoration(labelText: "Course Name"),
                ),
                TextField(
                  controller: _courseCodeController,
                  decoration: const InputDecoration(labelText: "Course Code"),
                ),
                TextField(
                  controller: _courseTimeController,
                  decoration: const InputDecoration(labelText: "Course Time (e.g. 10:00 AM)"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickLocation,
                  child: const Text("Pick Location"),
                ),
                Text(_selectedLocation != null
                    ? "Location: ${_selectedLocation!['address'] ?? 'Selected'}"
                    : "No location selected"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_courseNameController.text.isNotEmpty &&
                    _courseCodeController.text.isNotEmpty &&
                    _courseTimeController.text.isNotEmpty) {
                  setState(() {
                    courses.add(Course(
                      name: _courseNameController.text,
                      code: _courseCodeController.text,
                      time: _courseTimeController.text,
                      date: _selectedDate,
                      id: UniqueKey().toString(),
                      location: _selectedLocation,
                    ));
                    _saveCourses();

                    // Clear fields
                    _courseNameController.clear();
                    _courseCodeController.clear();
                    _courseTimeController.clear();
                    _selectedLocation = null;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showAddStudentDialog(int courseIndex) {
    final TextEditingController studentNameController = TextEditingController();
    final TextEditingController studentIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentNameController,
                decoration: const InputDecoration(labelText: "Student Name"),
              ),
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(labelText: "Student ID"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (studentNameController.text.isNotEmpty &&
                    studentIdController.text.isNotEmpty) {
                  setState(() {
                    courses[courseIndex].students.add(Student(
                      name: studentNameController.text,
                      id: studentIdController.text,
                    ));
                    _saveCourses();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showQRDialog(Course course) {
    final user = FirebaseAuth.instance.currentUser;
    final lecturerName = user?.displayName ?? "Lecturer Zimba";

    final qrData = {
      'courseId': course.id,
      'courseName': course.name,
      'courseCode': course.code,
      'time': course.time,
      'date': DateFormat('yyyy-MM-dd').format(course.date),
      'lecturerName': lecturerName,
      'location': course.location ?? {'address': 'Location not set'},
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Course QR Code'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                QrImageView(
                  data: jsonEncode(qrData),
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 16),
                Text(
                  course.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(course.code),
                Text(course.time),
                Text(DateFormat('yyyy-MM-dd').format(course.date)),
                const SizedBox(height: 8),
                Text(
                  course.location != null
                      ? 'Location: ${course.location!['address'] ?? 'Selected location'}'
                      : 'Location not set',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseCard(Course course, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: const Icon(Icons.book, color: Color(0xFF064469)),
        title: Text(course.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(
            '${course.code} • ${course.time} • ${DateFormat('yyyy-MM-dd').format(course.date)}',
            style: const TextStyle(color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteCourse(index),
        ),
        children: [
          if (course.location != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Location: ${course.location!['address'] ?? 'Selected location'}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ...course.students.map((student) {
            return ListTile(
              title: Text(student.name),
              subtitle: Text('ID: ${student.id}'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    course.students.remove(student);
                    _saveCourses();
                  });
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddStudentDialog(index),
            icon: const Icon(Icons.person_add),
            label: const Text("Add Student"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF064469),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showQRDialog(course),
            icon: const Icon(Icons.qr_code),
            label: const Text("Generate QR Code"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF064469),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCourse(int index) {
    setState(() {
      courses.removeAt(index);
      _saveCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayCourses = courses.where((c) =>
    c.date.year == today.year &&
        c.date.month == today.month &&
        c.date.day == today.day).toList();

    final otherCourses = courses.where((c) =>
    !(c.date.year == today.year &&
        c.date.month == today.month &&
        c.date.day == today.day)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Management'),
        backgroundColor: const Color(0xFF064469),
        elevation: 2,
      ),
      body: ListView(
        children: [
          if (todayCourses.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Today\'s Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...todayCourses.map((c) => _buildCourseCard(c, courses.indexOf(c))),
          ],
          if (otherCourses.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('All Courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...otherCourses.map((c) => _buildCourseCard(c, courses.indexOf(c))),
          ],
          if (courses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                    'No courses added yet. Tap the + button to add a course.'),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF064469),
        onPressed: _showAddCourseDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Course"),
      ),
    );
  }
}