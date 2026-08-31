import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Used on app startup to silently restore a session from the stored token.
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<AuthUser?> call() => repository.getCurrentUser();
}
