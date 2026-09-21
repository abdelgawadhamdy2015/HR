import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/repositories/permissions_repository.dart';
import '../datasources/permissions_remote_data_source.dart';

class PermissionsRepositoryImpl implements PermissionsRepository {
  final PermissionsRemoteDataSource remoteDataSource;
  PermissionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Permission>>> getAll() async {
    try { return Success(await remoteDataSource.getAll()); }
    on NetworkException catch (e) { return Error(NetworkFailure(e.message)); }
    on ForbiddenException catch (e) { return Error(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Error(ServerFailure(e.message)); }
    catch (_) { return const Error(UnknownFailure()); }
  }

  @override
  Future<Result<List<Permission>>> getForUser(int userId) async {
    try { return Success(await remoteDataSource.getForUser(userId)); }
    on NetworkException catch (e) { return Error(NetworkFailure(e.message)); }
    on NotFoundException catch (e) { return Error(NotFoundFailure(e.message)); }
    on ForbiddenException catch (e) { return Error(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Error(ServerFailure(e.message)); }
    catch (_) { return const Error(UnknownFailure()); }
  }

  @override
  Future<Result<List<UserSummary>>> getUsers() async {
    try { return Success(await remoteDataSource.getUsers()); }
    on NetworkException catch (e) { return Error(NetworkFailure(e.message)); }
    on ForbiddenException catch (e) { return Error(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Error(ServerFailure(e.message)); }
    catch (_) { return const Error(UnknownFailure()); }
  }

  @override
  Future<Result<Permission>> create({required String name, String? description}) async {
    try { return Success(await remoteDataSource.create(name: name, description: description)); }
    on NetworkException catch (e) { return Error(NetworkFailure(e.message)); }
    on ValidationException catch (e) { return Error(ValidationFailure(e.message)); }
    on ConflictException catch (e) { return Error(ConflictFailure(e.message)); }
    on ForbiddenException catch (e) { return Error(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Error(ServerFailure(e.message)); }
    catch (_) { return const Error(UnknownFailure()); }
  }

  @override
  Future<Result<void>> assign({required int userId, required int permissionId}) async {
    try {
      await remoteDataSource.assign(userId: userId, permissionId: permissionId);
      return const Success(null);
    } on NetworkException catch (e) { return Error(NetworkFailure(e.message)); }
    on NotFoundException catch (e) { return Error(NotFoundFailure(e.message)); }
    on ForbiddenException catch (e) { return Error(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Error(ServerFailure(e.message)); }
    catch (_) { return const Error(UnknownFailure()); }
  }

  @override
  Future<Result<void>> revoke({required int userId, required int permissionId}) async {
    try {
      await remoteDataSource.revoke(userId: userId, permissionId: permissionId);
      return const Success(null);
    } on NetworkException catch (e) { return Error(NetworkFailure(e.message)); }
    on NotFoundException catch (e) { return Error(NotFoundFailure(e.message)); }
    on ForbiddenException catch (e) { return Error(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Error(ServerFailure(e.message)); }
    catch (_) { return const Error(UnknownFailure()); }
  }

  @override
  Future<Result<List<Permission>>> updateUserPermissions({required int userId, required List<int> permissionIds}) async {
    try {
      return Success(await remoteDataSource.updateUserPermissions(userId: userId, permissionIds: permissionIds));
    } on NetworkException catch (e) { return Error(NetworkFailure(e.message)); }
    on ValidationException catch (e) { return Error(ValidationFailure(e.message)); }
    on NotFoundException catch (e) { return Error(NotFoundFailure(e.message)); }
    on ForbiddenException catch (e) { return Error(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Error(ServerFailure(e.message)); }
    catch (_) { return const Error(UnknownFailure()); }
  }
}
