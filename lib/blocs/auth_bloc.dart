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
    Future<void> fetchUserRole(User user, Emitter<AuthState> emit) async {
      try {
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final String role = userDoc['role'];
          emit(RoleFetched(user.uid, role)); // Emit state with role
        } else {
          emit(const AuthError('User role not found.'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    }

    on<AppStarted>((event, emit) async {
      final user = _auth.currentUser;
      if (user != null) {
        await fetchUserRole(user, emit);
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
        await fetchUserRole(userCredential.user!, emit);
      } catch (e) {
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

        await fetchUserRole(result.user!, emit);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoggedOut>((event, emit) async {
      await _auth.signOut();
      emit(Unauthenticated());
    });
  }
}
