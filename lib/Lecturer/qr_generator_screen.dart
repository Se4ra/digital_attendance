import 'dart:convert';
import 'dart:math'; // For generating the PIN
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class QrGeneratorScreen extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String lectureName;
  final String sessionTime;
  final Map<String, dynamic> location;

  const QrGeneratorScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.lectureName,
    required this.sessionTime,
    required this.location,
  });

  // 🔐 PIN generator
  String _generatePinCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // 6-digit PIN

  }

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String pinCode = _generatePinCode(); // 🔐 Generate PIN

    // 🧾 QR payload includes PIN

    final Map<String, dynamic> qrPayload = {
      'courseId': courseId,
      'courseName': courseName,
      'lectureName': lectureName,
      'time': sessionTime,
      'date': date,
      'pin': pinCode, // 🔐 Include pin
      'location': location,
    };

    FirebaseFirestore.instance.collection('sessions').add({
      ...qrPayload,
      'pinCode': pinCode, // 🔥 must match what student enters
      'sessionDate': date,
      'sessionTime': sessionTime,
      'checkedInStudents': [],
      'timestamp': FieldValue.serverTimestamp(),
    });


    final String qrData = jsonEncode(qrPayload);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated QR Code"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 300.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 24),
            Text("Course: $courseName", style: const TextStyle(fontSize: 16)),
            Text("Lecture: $lectureName", style: const TextStyle(fontSize: 16)),
            Text("Date: $date", style: const TextStyle(fontSize: 16)),
            Text("Time: $sessionTime", style: const TextStyle(fontSize: 16)),
            Text("Location: ${_formatLocation(location)}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              "🔐 PIN Code: $pinCode",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLocation(dynamic loc) {
    if (loc is String) return loc;
    if (loc is Map<String, dynamic> && loc.containsKey('latitude')) {
      return "Lat: ${loc['latitude']}, Lng: ${loc['longitude']}";
    }
    return "Not Picked";
  }
}
