import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_home_screen.dart';
import 'login_screen.dart';
import 'mechanic_home_screen.dart';

class CommonHomePage extends StatefulWidget {
  const CommonHomePage({super.key});

  @override
  CommonHomePageState createState() => CommonHomePageState();
}

class CommonHomePageState extends State<CommonHomePage> {
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          _userRole = userDoc['role'];
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error fetching role: $e")));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userRole == 'admin') {
      return const AdminHomeScreen();
    } else if (_userRole == 'mechanic') {
      return const MechanicHomeScreen();
    } else {
      return const Scaffold(
        body: Center(child: Text("Unknown role or user not found.")),
      );
    }
  }
}
