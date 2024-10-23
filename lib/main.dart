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
      create: (context) => AuthBloc()..add(AppStarted()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Car Workshop',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthHandler(),
      ),
    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AdminAuthenticated) {
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          });
          context.read<AuthBloc>().add(AppStarted());
        } else if (state is MechanicAuthenticated) {
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MechanicHomeScreen()),
            );
          });
          context.read<AuthBloc>().add(AppStarted());
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
          context.read<AuthBloc>().add(AppStarted());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is Unauthenticated) {
            return const AuthScreen();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}