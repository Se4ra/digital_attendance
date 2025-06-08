import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanning = true;

  Future<void> _handleQRCode(String data) async {
    try {
      setState(() => isScanning = false);

      final Map<String, dynamic> qrData = jsonDecode(data);

      final String courseId = qrData['courseId'];
      final String courseName = qrData['courseName'];
      final String lectureName = qrData['lectureName'];
      final String sessionTime = qrData['time'];
      final String sessionDate = qrData['date'];
      final Map<String, dynamic> location = qrData['location'];
      final DateTime startTime = DateTime.parse(qrData['startTime']);

      final duration = DateTime.now().difference(startTime).inMinutes;

      if (duration < -15) {
        _showDialog('Too Early', 'You can only check in 15 minutes before class.');
        return;
      }
      if (duration > 30) {
        _showDialog('QR Code Expired', 'This QR code is no longer valid.');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showDialog('Error', 'User not logged in.');
        return;
      }

      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        location['latitude'],
        location['longitude'],
      );

      if (distanceInMeters > 100) {
        _showDialog('Location Mismatch', 'You are not within the allowed location.');
        return;
      }

      // 🔍 Find matching session
      final sessionQuery = await FirebaseFirestore.instance
          .collection('sessions')
          .where('courseId', isEqualTo: courseId)
          .where('sessionTime', isEqualTo: sessionTime)
          .where('sessionDate', isEqualTo: sessionDate)
          .limit(1)
          .get();

      if (sessionQuery.docs.isEmpty) {
        _showDialog('Session Not Found', 'No matching session found.');
        return;
      }

      final sessionDoc = sessionQuery.docs.first;
      final sessionId = sessionDoc.id;

      // 🛑 Prevent duplicate check-in
      final existingCheckin = await FirebaseFirestore.instance
          .collection('checkins')
          .where('sessionId', isEqualTo: sessionId)
          .where('studentId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingCheckin.docs.isNotEmpty) {
        _showDialog('Already Checked In', 'You already checked in for this session.');
        return;
      }

      // ✅ Save check-in
      await FirebaseFirestore.instance.collection('checkins').add({
        'sessionId': sessionId,
        'courseId': courseId,
        'courseName': courseName,
        'lectureName': lectureName,
        'studentId': user.uid,
        'studentName': user.displayName ?? 'Student',
        'sessionDate': sessionDate,
        'sessionTime': sessionTime,
        'status': 'attended',
        'timestamp': FieldValue.serverTimestamp(),
        'location': {
          'latitude': location['latitude'],
          'longitude': location['longitude'],
        },
      });

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .update({
        'checkedInStudents': FieldValue.arrayUnion([user.uid])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in successful. You have been marked as present.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("⚠️ QR Scan Error: $e");
      _showDialog('Error', 'Something went wrong during check-in.');
    } finally {
      if (mounted) {
        setState(() => isScanning = true);
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => isScanning = true);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: isScanning
          ? MobileScanner(
        controller: MobileScannerController(facing: CameraFacing.back),
        onDetect: (BarcodeCapture capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            _handleQRCode(barcodes.first.rawValue!);
          }
        },
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
