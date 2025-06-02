import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum AttendanceStatus { attended, absent, pending }

@immutable
class AttendanceRecord {
  final String id;
  final DateTime date;
  final String courseId;
  final String courseName;
  final String studentName;
  final String studentId;
  final AttendanceStatus status;
  final String time;
  final double latitude;
  final double longitude;

  const AttendanceRecord({
    required this.id,
    required this.date,
    required this.courseId,
    required this.courseName,
    required this.studentName,
    required this.studentId,
    required this.status,
    required this.time,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  /// Deserialize from Firestore
  factory AttendanceRecord.fromFirestore(String docId, Map<String, dynamic> data) {
    return AttendanceRecord(
      id: docId,
      date: DateTime.parse(data['sessionDate']),
      courseId: data['courseId'],
      courseName: data['courseName'],
      studentName: data['studentName'],
      studentId: data['studentId'],
      status: _parseStatus(data['status']),
      time: data['sessionTime'] ?? '00:00',
      latitude: data['location']?['latitude'] ?? 0.0,
      longitude: data['location']?['longitude'] ?? 0.0,
    );
  }

  /// Deserialize from JSON
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      courseId: json['courseId'],
      courseName: json['courseName'],
      studentName: json['studentName'],
      studentId: json['studentId'],
      status: AttendanceStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.pending,
      ),
      time: json['time'],
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'courseId': courseId,
      'courseName': courseName,
      'studentName': studentName,
      'studentId': studentId,
      'status': status.name,
      'time': time,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static AttendanceStatus _parseStatus(dynamic statusValue) {
    if (statusValue == null) return AttendanceStatus.pending;

    if (statusValue is String) {
      return AttendanceStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == statusValue.toLowerCase(),
        orElse: () => AttendanceStatus.pending,
      );
    }

    return AttendanceStatus.pending;
  }
}
