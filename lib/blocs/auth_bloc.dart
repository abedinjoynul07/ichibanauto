import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          emit(Authenticated(user.uid));
        } else {
          emit(Unauthenticated());
        }
      } catch (_) {
        emit(Unauthenticated());
      }
    });

    on<LoggedIn>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(result.user!.uid));
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
        emit(Authenticated(result.user!.uid));
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

        final UserCredential result = await _auth.signInWithCredential(credential);
        emit(Authenticated(result.user!.uid));
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
