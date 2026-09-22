import '../../../../core/utils/result.dart';
import '../entities/user_summary.dart';
import '../repositories/permissions_repository.dart';

class GetUsers {
  final PermissionsRepository repository;
  GetUsers(this.repository);

  Future<Result<List<UserSummary>>> call() => repository.getUsers();
}
