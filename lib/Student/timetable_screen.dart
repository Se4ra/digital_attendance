import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StudentTimetableScreen extends StatelessWidget {
  const StudentTimetableScreen({super.key});

  Future<Map<String, List<Map<String, String>>>> _getTimetable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? courseJsonList = prefs.getStringList('courses');

    if (courseJsonList == null) {
      return {
        'Monday': [],
        'Tuesday': [],
        'Wednesday': [],
        'Thursday': [],
        'Friday': [],
      };
    }

    Map<String, List<Map<String, String>>> timetable = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
    };

    for (String jsonStr in courseJsonList) {
      Map<String, dynamic> courseData = jsonDecode(jsonStr);
      String day = courseData['day'] ?? 'Friday';
      String lecturer = 'Lecturer';

      if (timetable.containsKey(day)) {
        timetable[day]!.add({
          'course': courseData['name'],
          'time': courseData['time'],
          'lecturer': lecturer,
        });
      }
    }

    return timetable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Weekly Timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, List<Map<String, String>>>>(
        future: _getTimetable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.values.every((e) => e.isEmpty)) {
            return const Center(
              child: Text('No timetable data available. Add courses first.'),
            );
          }

          final timetable = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: timetable.length,
            itemBuilder: (context, index) {
              final day = timetable.keys.elementAt(index);
              final classes = timetable[day]!;

              if (classes.isEmpty) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...classes.map((cls) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                          Text(
                            cls['course']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(cls['time']!),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 4),
                              Text(cls['lecturer']!),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }
}