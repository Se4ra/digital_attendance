import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color kPrimaryColor = Color(0xFF3E8EED);
const Color kSecondaryColor = Color(0xFFF0F4FA);
const Color kAccentColor = Color(0xFF1A73E8);
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kBackgroundColor = Color(0xFFF6F7F9);

class StudentAttendanceHistoryScreen extends StatefulWidget {
  final String studentId;

  const StudentAttendanceHistoryScreen({super.key, required this.studentId});

  @override
  State<StudentAttendanceHistoryScreen> createState() =>
      _StudentAttendanceHistoryScreenState();
}

class _StudentAttendanceHistoryScreenState
    extends State<StudentAttendanceHistoryScreen> {
  List<Map<String, dynamic>> attendanceRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('checkins')
          .where('studentId', isEqualTo: widget.studentId)
          .orderBy('sessionDate', descending: true)
          .get();

      final List<Map<String, dynamic>> records = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'subject': data['courseName'] ?? 'Unknown',
          'date': data['sessionDate'] ?? '',
          'attended': data['status'] == 'attended',
        };
      }).toList();

      setState(() {
        attendanceRecords = records;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching attendance: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attended = attendanceRecords.where((e) => e['attended']).length;
    final absent = attendanceRecords.length - attended;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Attendance Summary'),
        backgroundColor: kPrimaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attendanceRecords.isEmpty
          ? const Center(child: Text("No attendance records found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: kTextPrimary),
            ),
            const SizedBox(height: 16),
            _buildPieChart(attended, absent),
            const SizedBox(height: 32),
            Text(
              'Attendance Details',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: kTextPrimary),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendanceRecords.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = attendanceRecords[index];
                final formattedDate = DateFormat('EEE, MMM d')
                    .format(DateTime.parse(record['date']));
                final isPresent = record['attended'];

                return GestureDetector(
                  onTap: () {
                    _showCourseAttendanceDetails(context,
                        record['subject'], attendanceRecords);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(record['subject'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  color: kTextSecondary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPresent
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPresent ? 'Present' : 'Absent',
                            style: TextStyle(
                              color: isPresent
                                  ? Colors.green[800]
                                  : Colors.red[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseAttendanceDetails(BuildContext context, String subject,
      List<Map<String, dynamic>> records) {
    final subjectRecords = records
        .where((record) => record['subject'] == subject)
        .toList();
    final attended =
        subjectRecords.where((record) => record['attended']).length;
    final missed = subjectRecords.length - attended;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(subject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total classes: ${subjectRecords.length}'),
            const SizedBox(height: 8),
            Text('Attended: $attended'),
            Text('Missed: $missed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  Widget _buildPieChart(int attended, int absent) {
    final total = attended + absent;
    final percentAttended =
    total == 0 ? 0 : (attended / total * 100).toInt();
    final percentAbsent = total == 0 ? 0 : (absent / total * 100).toInt();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 50,
              sectionsSpace: 4,
              sections: [
                PieChartSectionData(
                  value: attended.toDouble(),
                  color: Colors.green,
                  title: '$percentAttended%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: absent.toDouble(),
                  color: Colors.red,
                  title: '$percentAbsent%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: Colors.green, label: 'Attended'),
            SizedBox(width: 16),
            _Legend(color: Colors.red, label: 'Absent'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
