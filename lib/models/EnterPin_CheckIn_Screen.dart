import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnterPinCheckInScreen extends StatefulWidget {
  const EnterPinCheckInScreen({Key? key}) : super(key: key);

  @override
  State<EnterPinCheckInScreen> createState() => _EnterPinCheckInScreenState();
}

class _EnterPinCheckInScreenState extends State<EnterPinCheckInScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isCheckingIn = false;

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePinCheckIn() async {
    final pin = _pinController.text.trim();
    if (pin.length != 6) {
      _showMessage("Invalid PIN", "PIN must be 6 digits.");
      return;
    }

    setState(() => _isCheckingIn = true);

    try {
      // 🔍 Check session with pinCode
      final sessionQuery = await FirebaseFirestore.instance
          .collection('sessions')
          .where('pinCode', isEqualTo: pin)
          .limit(1)
          .get();

      print("DEBUG: Sessions found = ${sessionQuery.docs.length}");

      if (sessionQuery.docs.isEmpty) {
        _showMessage("Invalid PIN", "No session found with this PIN.");
        return;
      }

      final sessionDoc = sessionQuery.docs.first;
      final sessionData = sessionDoc.data();
      final sessionId = sessionDoc.id;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage("Error", "You must be logged in.");
        return;
      }

      // 🚫 Prevent double check-in
      final existingCheckIn = await FirebaseFirestore.instance
          .collection('checkins')
          .where('sessionId', isEqualTo: sessionId)
          .where('studentId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingCheckIn.docs.isNotEmpty) {
        _showMessage("Already Checked In", "You have already checked in for this session.");
        return;
      }

      // ✅ Perform check-in
      await FirebaseFirestore.instance.collection('checkins').add({
        'sessionId': sessionId,
        'courseId': sessionData['courseId'],
        'courseName': sessionData['courseName'],
        'lectureName': sessionData['lectureName'] ?? '',
        'studentId': user.uid,
        'studentName': user.displayName ?? 'Student',
        'sessionDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'sessionTime': sessionData['sessionTime'] ?? sessionData['time'] ?? 'Unknown',
        'status': 'attended',
        'timestamp': FieldValue.serverTimestamp(),
        'location': {
          'latitude': 0.0,
          'longitude': 0.0,
        }
      });

      // 🔄 Update session with list of checked in students
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .update({
        'checkedInStudents': FieldValue.arrayUnion([user.uid])
      });

      _showMessage("Success", "You have been marked as present.");
      _pinController.clear();
    } catch (e) {
      print("PIN check-in error: $e");
      _showMessage("Error", "Something went wrong. Please try again.");
    } finally {
      setState(() => _isCheckingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check In With PIN"),
        backgroundColor: const Color(0xFF064469),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Enter the 6-digit PIN provided by the lecturer:",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "PIN Code",
                counterText: "",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: _isCheckingIn
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Text("Check In"),
              onPressed: _isCheckingIn ? null : _handlePinCheckIn,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF064469),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
