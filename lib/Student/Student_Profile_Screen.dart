import 'package:digital_attendance_system/auth/login_screen.dart';
import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF3E8EED);
const Color kSecondaryColor = Color(0xFFF0F4FA);
const Color kAccentColor = Color(0xFF1A73E8);
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy student data – replace with real data if needed
    final studentName = 'Sephora Nauluta';
    final studentID = 'STU2025-001';
    final email = 'sephora@example.com';
    final course = 'BSc. Computing with Business';

    return Scaffold(
      backgroundColor: kSecondaryColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_avatar.png'),
            ),
            const SizedBox(height: 16),
            Text(
              studentName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              studentID,
              style: const TextStyle(
                fontSize: 16,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: kAccentColor),
                    title: const Text('Email', style: TextStyle(color: kTextPrimary)),
                    subtitle: Text(email, style: const TextStyle(color: kTextSecondary)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.school, color: kAccentColor),
                    title: const Text('Course', style: TextStyle(color: kTextPrimary)),
                    subtitle: Text(course, style: const TextStyle(color: kTextSecondary)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
