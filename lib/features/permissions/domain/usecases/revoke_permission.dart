import '../../../../core/utils/result.dart';
import '../repositories/permissions_repository.dart';

class RevokePermission {
  final PermissionsRepository repository;
  RevokePermission(this.repository);

  Future<Result<void>> call({required int userId, required int permissionId}) {
    return repository.revoke(userId: userId, permissionId: permissionId);
  }
}
