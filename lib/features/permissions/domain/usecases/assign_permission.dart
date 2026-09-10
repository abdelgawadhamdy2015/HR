import '../../../../core/utils/result.dart';
import '../repositories/permissions_repository.dart';

class AssignPermission {
  final PermissionsRepository repository;
  AssignPermission(this.repository);

  Future<Result<void>> call({required int userId, required int permissionId}) {
    return repository.assign(userId: userId, permissionId: permissionId);
  }
}
