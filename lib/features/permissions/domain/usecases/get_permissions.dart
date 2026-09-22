import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/permission.dart';
import '../repositories/permissions_repository.dart';

class GetPermissions implements UseCase<List<Permission>, NoParams> {
  final PermissionsRepository repository;
  GetPermissions(this.repository);

  @override
  Future<Result<List<Permission>>> call(NoParams params) => repository.getAll();
}
