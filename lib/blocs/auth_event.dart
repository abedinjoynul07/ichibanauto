import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class GoogleSignInEvent extends AuthEvent {}

class AppleSignInEvent extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String email;
  final String password;


  const LoggedIn(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String role;

  const RegisterWithEmail(this.email, this.password, this.role);

  @override
  List<Object> get props => [email, password];
}


class LoggedOut extends AuthEvent {}
