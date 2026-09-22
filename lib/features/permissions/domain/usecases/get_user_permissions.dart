import '../../../../core/utils/result.dart';
import '../entities/permission.dart';
import '../repositories/permissions_repository.dart';

class GetUserPermissions {
  final PermissionsRepository repository;
  GetUserPermissions(this.repository);

  Future<Result<List<Permission>>> call(int userId) => repository.getForUser(userId);
}
