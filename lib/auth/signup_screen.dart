import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Lecturer/course_management_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'student'; // Default role

  bool isLoading = false;
  bool obscure = true;

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> signupUser() async {
    try {
      setState(() => isLoading = true);

      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(authResult.user!.uid).set({
        'email': emailController.text.trim(),
        'role': selectedRole,
        'createdAt': Timestamp.now(),
      });

      if (selectedRole == 'lecturer') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => CourseManagementScreen()));
      }
    } on FirebaseAuthException catch (e) {
      showSnack("Signup error: ${e.message}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7F9),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(Icons.school, size: 80, color: Color(0xFF172449)), // Graduation cap icon
                Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 24, color: Color(0xFF172449), fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF79A0C9)),
                    filled: true,
                    fillColor: Color(0xFFD3DDE9),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color(0xFF79A0C9)),
                    filled: true,
                    fillColor: Color(0xFFD3DDE9),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFF4676B4),
                      ),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    labelStyle: TextStyle(color: Color(0xFF79A0C9)),
                    filled: true,
                    fillColor: Color(0xFFD3DDE9),
                    border: OutlineInputBorder(),
                  ),
                  items: ['student', 'lecturer'].map((role) {
                    return DropdownMenuItem(
                        value: role,
                        child: Text(role.toUpperCase(),
                            style: TextStyle(color: Color(0xFF172449))));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: signupUser,
                  child: Text("Sign Up", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: Color(0xFF4676B4),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Color(0xFF172449)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
