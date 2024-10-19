import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ichibanauto/screens/admin_home_screen.dart';
import 'package:ichibanauto/screens/login_screen.dart';
import 'package:ichibanauto/screens/mechanic_home_screen.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/auth_event.dart';
import 'blocs/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(AppStarted()), // Check authentication on app start
      child: MaterialApp(
        title: 'Car Workshop',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthHandler(), // Handle auth state on app start
      ),
    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator()); // Show loading spinner while fetching user info
        } else if (state is AdminAuthenticated) {
          return const AdminHomeScreen(); // Navigate to Admin Home Screen
        } else if (state is MechanicAuthenticated) {
          return const MechanicHomeScreen(); // Navigate to Mechanic Home Screen
        } else {
          return const AuthScreen(); // Show login screen if not authenticated
        }
      },
    );
  }
}
