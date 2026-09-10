import '../../../../core/utils/result.dart';
import '../entities/permission.dart';
import '../repositories/permissions_repository.dart';

class CreatePermission {
  final PermissionsRepository repository;
  CreatePermission(this.repository);

  Future<Result<Permission>> call({required String name, String? description}) {
    return repository.create(name: name, description: description);
  }
}
