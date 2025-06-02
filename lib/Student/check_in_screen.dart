import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/EnterPin_CheckIn_Screen.dart';

class StudentCheckInScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const StudentCheckInScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  State<StudentCheckInScreen> createState() => _StudentCheckInScreenState();
}

class _StudentCheckInScreenState extends State<StudentCheckInScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  Future<void> _handleQrData(String rawData) async {
    try {
      final Map<String, dynamic> qrData = jsonDecode(rawData);

      final String courseId = qrData['courseId'];
      final String courseName = qrData['courseName'];
      final String lectureName = qrData['lectureName'];
      final String sessionTime = qrData['time'];
      final String sessionDate = qrData['date'];
      final location = qrData['location'];
      final String? pinCode = qrData['pin'];
      print("🔐 PIN in QR: $pinCode");

      if (location == null || location['latitude'] == null || location['longitude'] == null) {
        _showError("QR code missing location data.");
        return;
      }

      final double targetLat = location['latitude'];
      final double targetLng = location['longitude'];
      final bool isAllowed = await _isWithinAllowedDistance(targetLat, targetLng);

      if (!isAllowed) {
        _showError("You are not in the correct location to check in.");
        return;
      }

      final sessionQuery = await FirebaseFirestore.instance
          .collection('sessions')
          .where('courseId', isEqualTo: courseId)
          .where('sessionDate', isEqualTo: sessionDate)
          .where('sessionTime', isEqualTo: sessionTime)
          .limit(1)
          .get();

      if (sessionQuery.docs.isEmpty) {
        _showError("No matching session found. Try PIN instead.");
        return;
      }

      final sessionDoc = sessionQuery.docs.first;
      final sessionId = sessionDoc.id;

      final alreadyChecked = await FirebaseFirestore.instance
          .collection('checkins')
          .where('sessionId', isEqualTo: sessionId)
          .where('studentId', isEqualTo: widget.studentId)
          .limit(1)
          .get();

      if (alreadyChecked.docs.isNotEmpty) {
        _showError("You already checked in for this session.");
        return;
      }

      await FirebaseFirestore.instance.collection('checkins').add({
        'sessionId': sessionId,
        'courseId': courseId,
        'courseName': courseName,
        'lectureName': lectureName,
        'studentId': widget.studentId,
        'studentName': widget.studentName,
        'status': 'attended',
        'sessionDate': sessionDate,
        'sessionTime': sessionTime,
        'timestamp': FieldValue.serverTimestamp(),
        'location': {
          'latitude': targetLat,
          'longitude': targetLng,
        }
      });

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .update({
        'checkedInStudents': FieldValue.arrayUnion([widget.studentId])
      });

      _showSuccess("Successfully checked in for $courseName!");
    } catch (e) {
      debugPrint('QR Scan Error: $e');
      _showError("Something went wrong. Try again.");
    }
  }

  Future<bool> _isWithinAllowedDistance(double targetLat, double targetLng) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLat,
      targetLng,
    );

    return distance <= 100; // within 100 meters
  }

  void _showSuccess(String msg) {
    setState(() => hasScanned = true);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Check-In Successful"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Check-In Failed"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check In"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.indigo,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Scan QR code to check in"),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnterPinCheckInScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Can't scan? Enter PIN",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!hasScanned) {
        setState(() => hasScanned = true);
        controller.pauseCamera();
        await _handleQrData(scanData.code ?? '');
      }
    });
  }
}
