import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    Future<void> fetchUserRoleAndRedirect(User user, Emitter<AuthState> emit, {bool showToast = false}) async {
      debugPrint("Entered");
      try {
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final String role = userDoc['role'];
          debugPrint("User role fetched: $role for user: ${user.uid}");

          if (role == 'admin') {
            debugPrint("Emitting Admin role");
            emit(AdminAuthenticated(user.uid));
            debugPrint("Admin exit");
          } else if (role == 'mechanic') {
            debugPrint("Emitting Mechanic role");
            emit(MechanicAuthenticated(user.uid));
            debugPrint("Mechanic exit");
          }
        } else {
          emit(const AuthError('User role not found.'));
        }
      } catch (e) {
        debugPrint("Error fetching user role: $e");
        emit(AuthError(e.toString()));
      }
    }

    on<AppStarted>((event, emit) async {
      final user = _auth.currentUser;
      if (user != null) {
        await fetchUserRoleAndRedirect(user, emit);
      } else {
        emit(Unauthenticated());
      }
    });

    on<LoggedIn>((event, emit) async {
      emit(AuthLoading());
      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        debugPrint("Login successful for: ${userCredential.user?.uid}");

        await userCredential.user!.getIdToken(true);

        await fetchUserRoleAndRedirect(userCredential.user!, emit);

      } catch (e) {
        debugPrint("Login error: $e");
        emit(AuthError(e.toString()));
      }
    });


    on<RegisterWithEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        await _firestore.collection('users').doc(result.user!.uid).set({
          'email': event.email,
          'role': event.role,
        });

        await fetchUserRoleAndRedirect(result.user!, emit, showToast: true);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoggedOut>((event, emit) async {
      await _auth.signOut();
      FirebaseAuth.instance.authStateChanges();
      emit(Unauthenticated());
    });

  }
}
