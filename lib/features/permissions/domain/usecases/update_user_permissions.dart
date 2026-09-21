import '../../../../core/utils/result.dart';
import '../entities/permission.dart';
import '../repositories/permissions_repository.dart';

class UpdateUserPermissions {
  final PermissionsRepository repository;

  UpdateUserPermissions(this.repository);

  Future<Result<List<Permission>>> call({
    required int userId,
    required List<int> permissionIds,
  }) {
    return repository.updateUserPermissions(
      userId: userId,
      permissionIds: permissionIds,
    );
  }
}
