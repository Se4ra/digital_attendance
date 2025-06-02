import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class QRGeneratorScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  QRGeneratorScreen({required this.courseId, required this.courseName});

  @override
  _QRGeneratorScreenState createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  String? sessionId;
  String? qrData;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _generateSession();
  }

  Future<void> _generateSession() async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Get current location
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Create session document in Firestore
      DocumentReference sessionRef =
      await FirebaseFirestore.instance.collection('sessions').add({
        'courseId': widget.courseId,
        'courseName': widget.courseName,
        'lectureId': user.uid,
        'lectureName': user.displayName ?? 'Lecturer',
        'startTime': DateTime.now().toIso8601String(),
        'location': {
          'latitude': currentPosition!.latitude,
          'longitude': currentPosition!.longitude,
        },
        'expectedStudents': [], // Populate with student IDs as needed
        'checkedInStudents': [],
        'status': 'open',
      });

      setState(() {
        sessionId = sessionRef.id;
        qrData = jsonEncode({
          'sessionId': sessionRef.id,
          'courseId': widget.courseId,
          'courseName': widget.courseName,
          'lectureName': user.displayName ?? 'Lecturer',
          'startTime': DateTime.now().toIso8601String(),
          'location': {
            'latitude': currentPosition!.latitude,
            'longitude': currentPosition!.longitude,
          },
        });
      });
    } catch (e) {
      print("Error generating session: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate QR Code'),
      ),
      body: Center(
        child: qrData == null
            ? CircularProgressIndicator()
            : QrImageView(
          data: qrData!,
          version: QrVersions.auto,
          size: 300.0,
        ),
      ),
    );
  }
}
