import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Course {
  String name;
  String code;
  String time;
  String id;
  String room;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.time,
    required this.room,
  });
}

class QRDisplayScreen extends StatefulWidget {
  final Course course;

  const QRDisplayScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  String? _pinCode;
  String? _qrData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generatePinAndQR();
  }

  void _generatePinAndQR() async {
    final pin = _generatePinCode();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final qrPayload = {
      'courseId': widget.course.id,
      'courseName': widget.course.name,
      'lectureName': 'Dr. Smith', // Customize if needed
      'time': widget.course.time,
      'room': widget.course.room,
      'pin': pin,
      'location': {
        'latitude': 0.0,
        'longitude': 0.0,
      },
      'date': formattedDate,
      'startTime': now.toIso8601String(), // for QR time validation
    };

    final qrString = jsonEncode(qrPayload);

    await FirebaseFirestore.instance.collection('sessions').add({
      ...qrPayload,
      'pinCode': pin, // Redundant but readable in Firestore
      'sessionDate': formattedDate,
      'sessionTime': widget.course.time,
      'checkedInStudents': [],
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _pinCode = pin;
      _qrData = qrString;
      _isLoading = false;
    });

    print("✅ QR and PIN generated: $_pinCode");
  }

  String _generatePinCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // 6-digit PIN
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course QR Code"),
        backgroundColor: const Color(0xFF064469),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: _qrData!,
              version: QrVersions.auto,
              size: 250.0,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
            const SizedBox(height: 20),
            Text(
              "Scan this QR or use the PIN to check in:\n\n"
                  "📘 Course: ${widget.course.name}\n"
                  "🆔 ID: ${widget.course.id}\n"
                  "🕒 Time: ${widget.course.time}\n"
                  "🏫 Room: ${widget.course.room}\n\n"
                  "🔐 PIN Code: $_pinCode",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
