import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';  // <-- Add this import
import 'package:digital_attendance_system/utils/date_range_picker.dart';
import 'package:digital_attendance_system/utils/loading_indicator.dart';
import 'attendance_record.dart';
import 'attendance_list_item.dart';

class LecturerAttendanceHistoryScreen extends StatefulWidget {
  final String? initialCourseId;

  const LecturerAttendanceHistoryScreen({super.key, this.initialCourseId});

  @override
  State<LecturerAttendanceHistoryScreen> createState() =>
      _LecturerAttendanceHistoryScreenState();
}

class _LecturerAttendanceHistoryScreenState
    extends State<LecturerAttendanceHistoryScreen> {
  late List<AttendanceRecord> _fullHistory = [];
  late List<AttendanceRecord> _filteredHistory = [];
  late List<Map<String, String>> _coursesForFilter = [];
  bool _isLoading = true;
  String? _selectedCourseId;
  DateTimeRange? _selectedDateRange;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  final Color colorLightBlue = const Color(0xFFeff3ff);
  final Color colorMediumBlue = const Color(0xFF9ecae1);
  final Color colorDarkBlue = const Color(0xFF3182bd);

  @override
  void initState() {
    super.initState();
    // Initialize filters from saved preferences, then fetch history
    _loadFiltersFromPrefs().then((_) {
      _fetchAttendanceHistory();
    });
  }

  Future<void> _loadFiltersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCourseId = prefs.getString('selectedCourseId') ?? widget.initialCourseId?.toLowerCase() ?? 'all';
    final savedStartDate = prefs.getString('selectedStartDate');
    final savedEndDate = prefs.getString('selectedEndDate');

    DateTimeRange? savedRange;
    if (savedStartDate != null && savedEndDate != null) {
      try {
        final start = DateTime.parse(savedStartDate);
        final end = DateTime.parse(savedEndDate);
        savedRange = DateTimeRange(start: start, end: end);
      } catch (_) {
        savedRange = null;
      }
    }

    setState(() {
      _selectedCourseId = savedCourseId;
      _selectedDateRange = savedRange;
    });
  }

  Future<void> _saveFiltersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCourseId', _selectedCourseId ?? 'all');
    if (_selectedDateRange != null) {
      await prefs.setString('selectedStartDate', _selectedDateRange!.start.toIso8601String());
      await prefs.setString('selectedEndDate', _selectedDateRange!.end.toIso8601String());
    } else {
      await prefs.remove('selectedStartDate');
      await prefs.remove('selectedEndDate');
    }
  }

  Future<void> _clearFiltersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedCourseId');
    await prefs.remove('selectedStartDate');
    await prefs.remove('selectedEndDate');
  }

  Future<void> _fetchAttendanceHistory() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('checkins')
          .orderBy('timestamp', descending: true)
          .get();

      final List<AttendanceRecord> fetchedHistory = snapshot.docs.map((doc) {
        final data = doc.data();
        final sessionDate = data['sessionDate'];
        final parsedDate = sessionDate is Timestamp
            ? sessionDate.toDate()
            : DateTime.tryParse(sessionDate ?? '') ?? DateTime.now();

        return AttendanceRecord(
          id: doc.id,
          date: parsedDate,
          courseId: data['courseId'],
          courseName: data['courseName'],
          studentName: data['studentName'],
          studentId: data['studentId'],
          status: AttendanceStatus.attended,
          time: data['sessionTime'] ?? '00:00',
          latitude: data['location']?['latitude'] ?? 0,
          longitude: data['location']?['longitude'] ?? 0,
        );
      }).toList();

      final uniqueCourses = {for (var r in fetchedHistory) r.courseId: r.courseName};

      final List<Map<String, String>> fetchedCourses = [
        {'id': 'all', 'name': 'All Courses'},
        ...uniqueCourses.entries.map((e) => {'id': e.key, 'name': e.value})
      ];

      setState(() {
        _fullHistory = fetchedHistory;
        _coursesForFilter = fetchedCourses;
      });

      _applyFilters();
    } catch (e) {
      print("Error fetching attendance history: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load attendance records.')),
      );
      setState(() {
        _fullHistory = [];
        _filteredHistory = [];
        _coursesForFilter = [
          {'id': 'all', 'name': 'All Courses'}
        ];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<AttendanceRecord> filtered = _fullHistory;

    if (_selectedCourseId != 'all') {
      filtered =
          filtered.where((record) => record.courseId == _selectedCourseId).toList();
    }

    if (_selectedDateRange != null) {
      filtered = filtered.where((record) {
        return record.date.isAfter(
            _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            record.date
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Save filters persistently
    _saveFiltersToPrefs();

    setState(() {
      _filteredHistory = filtered;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCourseId = 'all';
      _selectedDateRange = null;
    });

    _applyFilters();
    _clearFiltersFromPrefs();
  }

  void _exportData() {
    print("Exporting data for ${_filteredHistory.length} records...");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality to be implemented.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorLightBlue,
        appBar: AppBar(
          backgroundColor: colorDarkBlue,
          title: const Text('Attendance'),
          bottom: TabBar(
            indicatorColor: colorMediumBlue,
            tabs: const [
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.live_tv), text: 'Live Check-Ins'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHistoryTab(),
            _buildRealTimeTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _fetchAttendanceHistory,
      child: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading ? const LoadingIndicator() : _buildAttendanceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeTab() {
    return Center(
      child: Text(
        'Live check-in data coming soon...',
        style: TextStyle(color: colorDarkBlue, fontSize: 16),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: colorMediumBlue.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedCourseId,
                  decoration: InputDecoration(
                    labelText: 'Filter by Course',
                    filled: true,
                    fillColor: Colors.white,
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: _coursesForFilter
                      .map<DropdownMenuItem<String>>((course) {
                    return DropdownMenuItem<String>(
                      value: course['id'],
                      child: Text(course['name']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCourseId = newValue;
                        _applyFilters();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: DateRangePickerButton(
                  selectedDateRange: _selectedDateRange,
                  onDateRangeSelected: (pickedRange) {
                    setState(() {
                      _selectedDateRange = pickedRange;
                      _applyFilters();
                    });
                  },
                  buttonText: 'Filter by Date',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: colorDarkBlue,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.file_download),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorDarkBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_filteredHistory.isEmpty) {
      return const Center(child: Text('No attendance records found.'));
    }

    return ListView.builder(
      itemCount: _filteredHistory.length,
      itemBuilder: (context, index) {
        return AttendanceListItem(
          record: _filteredHistory[index],
        );
      },
    );
  }
}
