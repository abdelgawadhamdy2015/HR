import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? currentUser;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.currentUser,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? currentUser,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentUser, errorMessage];
}
