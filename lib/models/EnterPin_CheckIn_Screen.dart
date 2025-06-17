import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EnterPinCheckInScreen extends StatefulWidget {
  const EnterPinCheckInScreen({Key? key}) : super(key: key);

  @override
  State<EnterPinCheckInScreen> createState() => _EnterPinCheckInScreenState();
}

class _EnterPinCheckInScreenState extends State<EnterPinCheckInScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isCheckingIn = false;

  // Simulate a logged-in user (replace with real auth if available)
  final String _currentUserId = 'user123';
  final String _currentUserName = 'John Doe';

  Future<void> _handlePinCheckIn() async {
    final pin = _pinController.text.trim();

    if (pin.length != 6) {
      _showMessage("Invalid PIN", "PIN must be 6 digits.");
      return;
    }

    setState(() => _isCheckingIn = true);

    try {
      // Query Firestore for session with matching pinCode
      final querySnapshot = await FirebaseFirestore.instance
          .collection('sessions')
          .where('pinCode', isEqualTo: pin)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showMessage("Invalid PIN", "No session found with this PIN.");
        setState(() => _isCheckingIn = false);
        return;
      }

      final sessionDoc = querySnapshot.docs.first;
      final sessionData = sessionDoc.data();
      final sessionId = sessionDoc.id;

      // Check if user already checked in by checking 'checkedInStudents' array in session document
      final List<dynamic> checkedInStudents = sessionData['checkedInStudents'] ?? [];

      if (checkedInStudents.contains(_currentUserId)) {
        _showMessage(
            "Already Checked In", "You have already checked in for this session.");
        setState(() => _isCheckingIn = false);
        return;
      }

      // Add the current user to the checkedInStudents array in Firestore
      await FirebaseFirestore.instance.collection('sessions').doc(sessionId).update({
        'checkedInStudents': FieldValue.arrayUnion([_currentUserId]),
      });

      // Optionally, you can save a separate 'checkIns' collection for record keeping
      await FirebaseFirestore.instance.collection('checkIns').add({
        'sessionId': sessionId,
        'courseId': sessionData['courseId'],
        'courseName': sessionData['courseName'],
        'lectureName': sessionData['lectureName'] ?? '',
        'studentId': _currentUserId,
        'studentName': _currentUserName,
        'sessionDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'sessionTime': sessionData['sessionTime'],
        'status': 'attended',
        'timestamp': FieldValue.serverTimestamp(),
        'location': {'latitude': 0.0, 'longitude': 0.0}, // Optional: Add real location if available
      });

      _showMessage("Success", "You have been marked as present.");
      _pinController.clear();
    } catch (e) {
      _showMessage("Error", "Something went wrong: $e");
    }

    setState(() => _isCheckingIn = false);
  }

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

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
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
                  color: Colors.white,
                  strokeWidth: 2,
                ),
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
