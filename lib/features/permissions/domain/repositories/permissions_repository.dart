import '../../../../core/utils/result.dart';
import '../entities/permission.dart';
import '../entities/user_summary.dart';

abstract class PermissionsRepository {
  Future<Result<List<Permission>>> getAll();
  Future<Result<List<Permission>>> getForUser(int userId);
  Future<Result<List<UserSummary>>> getUsers();
  Future<Result<Permission>> create(
      {required String name, String? description});
  Future<Result<void>> assign({required int userId, required int permissionId});
  Future<Result<void>> revoke({required int userId, required int permissionId});
  Future<Result<List<Permission>>> updateUserPermissions({
    required int userId,
    required List<int> permissionIds,
  });
}
