import 'package:hr_attendance_app/features/auth/data/models/auth_request_models.dart';
import 'package:hr_attendance_app/features/auth/data/models/auth_response_model.dart';

import '../entities/auth_user.dart';

/// Domain-layer contract. The data layer provides the real implementation
/// (AuthRepositoryImpl); presentation only ever depends on this interface.
abstract class AuthRepository {
  Future<AuthResponseModel> login({required LoginRequest request});

  Future<AuthResponseModel> register({required RegisterRequest request});

  Future<void> logout();

  /// Resolves the current session from the stored token by calling /auth/me.
  /// Returns null if there's no valid session.
  Future<AuthUser?> getCurrentUser();

  Future<bool> isLoggedIn();
}
