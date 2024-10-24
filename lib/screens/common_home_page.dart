import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import 'admin_home_screen.dart';
import 'mechanic_home_screen.dart';

class CommonHomePage extends StatelessWidget {
  const CommonHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is RoleFetched) {
          if (state.role == 'admin') {
            return const AdminHomeScreen();
          } else if (state.role == 'mechanic') {
            return const MechanicHomeScreen();
          } else {
            return const Center(child: Text("Unknown role"));
          }
        } else if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AuthError) {
          return const Center(child: Text('Error fetching role'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
