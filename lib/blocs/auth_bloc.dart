import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    Future<void> fetchUserRoleAndRedirect(User user, Emitter<AuthState> emit, {bool showToast = false}) async {
      try {
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final String role = userDoc['role'];
          if (role == 'admin') {
            emit(AdminAuthenticated(user.uid));
          } else if (role == 'mechanic') {
            emit(MechanicAuthenticated(user.uid));
          }
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
        await fetchUserRoleAndRedirect(userCredential.user!, emit, showToast: true);
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

        await fetchUserRoleAndRedirect(result.user!, emit, showToast: true);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<GoogleSignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          emit(Unauthenticated());
          return;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential result = await _auth.signInWithCredential(credential);
        emit(Authenticated(result.user!.uid));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AppleSignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oAuthProvider = OAuthProvider("apple.com");
        final credential = oAuthProvider.credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        emit(Authenticated(userCredential.user!.uid));
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
