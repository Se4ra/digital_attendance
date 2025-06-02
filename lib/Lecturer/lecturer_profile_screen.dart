import 'package:digital_attendance_system/auth/login_screen.dart';
import 'package:flutter/material.dart';

// Shared color constants
const Color kPrimaryColor = Color(0xFF3E8EED);
const Color kSecondaryColor = Color(0xFFF0F4FA);
const Color kAccentColor = Color(0xFF1A73E8);
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);

class LecturerProfileScreen extends StatelessWidget {
  const LecturerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lecturerName = 'Ms Nauluta';
    final email = 'lecturernauluta@example.com';

    return Scaffold(
      backgroundColor: kSecondaryColor,
      appBar: AppBar(
        title: const Text('Lecturer Profile'),
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
              backgroundImage: AssetImage('assets/images/lecturer.png'),
            ),
            const SizedBox(height: 20),
            Text(
              lecturerName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: kAccentColor),
                    title: const Text("Edit Profile", style: TextStyle(color: kTextPrimary)),
                    onTap: () {
                      // TODO: Implement edit profile functionality
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings, color: kAccentColor),
                    title: const Text("Settings", style: TextStyle(color: kTextPrimary)),
                    onTap: () {
                      // TODO: Implement settings functionality
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text("Logout", style: TextStyle(color: kTextPrimary)),
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
