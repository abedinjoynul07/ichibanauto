import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final String userId;
  const Authenticated(this.userId);
}

class AdminAuthenticated extends AuthState {
  final String userId;
  const AdminAuthenticated(this.userId);
}

class MechanicAuthenticated extends AuthState {
  final String userId;
  const MechanicAuthenticated(this.userId);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String error;
  const AuthError(this.error);

  @override
  List<Object> get props => [error];
}
