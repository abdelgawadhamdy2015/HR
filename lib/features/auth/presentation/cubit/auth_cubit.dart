import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_attendance_app/features/auth/data/models/auth_request_models.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const AuthState());

  /// Call once on app startup to silently restore a session, if any.
  Future<void> restoreSession() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _getCurrentUserUseCase();
      emit(state.copyWith(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        currentUser: user,
      ));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<bool> login({required LoginRequest request}) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final data = await _loginUseCase(request: request);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        currentUser: data.user,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<bool> register({required RegisterRequest request}) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final data = await _registerUseCase(request: request);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        currentUser: data.user,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  bool hasPermission(String permission) {
    return state.currentUser?.hasPermission(permission) ?? false;
  }
}
