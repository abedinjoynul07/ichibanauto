import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichibanauto/screens/admin/admin_home_screen.dart';
import 'package:ichibanauto/screens/mechanic/mechanic_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ichibanauto/screens/authentication/registration/registration_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final userRole = await _getUserRole(userCredential.user!);

      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else if (userRole == 'mechanic') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MechanicHomeScreen()),
        );
      } else {
        _showSnackBar('Unknown user role.');
      }

      Fluttertoast.showToast(
        msg: "Login Successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _showSnackBar('No user found with this email.');
          break;
        case 'wrong-password':
          _showSnackBar('Incorrect password. Please try again.');
          break;
        case 'invalid-email':
          _showSnackBar('Invalid email address format.');
          break;
        case 'user-disabled':
          _showSnackBar('This user account has been disabled.');
          break;
        default:
          _showSnackBar(e.message ?? 'Login failed. Please try again later.');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String> _getUserRole(User user) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return docSnapshot['role'] ?? 'mechanic';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ichiban Auto',
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.teal),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50.0),
                _buildTextField('Email', _emailController, false),
                const SizedBox(height: 20.0),
                _buildTextField('Password', _passwordController, true),
                const SizedBox(height: 30.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: const Text(
                    'Don’t have an account? Register',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(isPassword ? Icons.lock : Icons.email, color: Colors.teal),
      ),
    );
  }
}
