import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/employee_month_details.dart';
import '../../domain/entities/lateness_entry.dart';
import '../../domain/entities/mission_entry.dart';
import '../../domain/entities/permission_entry.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_data_source.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;
  EmployeeRepositoryImpl(this.remoteDataSource);

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Error(NotFoundFailure(e.message));
    } on ConflictException catch (e) {
      return Error(ConflictFailure(e.message));
    } on ValidationException catch (e) {
      return Error(ValidationFailure(e.message));
    } on ForbiddenException catch (e) {
      return Error(ForbiddenFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<List<Employee>>> getEmployees() => _guard(remoteDataSource.getEmployees);

  @override
  Future<Result<Employee>> getEmployeeById(int id) => _guard(() => remoteDataSource.getEmployeeById(id));

  @override
  Future<Result<Employee>> createEmployee({
    required String code,
    required String fullName,
    required String jobTitle,
    required String department,
    String? avatarUrl,
  }) =>
      _guard(() => remoteDataSource.createEmployee({
            'code': code,
            'fullName': fullName,
            'jobTitle': jobTitle,
            'department': department,
            'avatarUrl': avatarUrl,
          }));

  @override
  Future<Result<EmployeeMonthDetails>> getMonthDetails(int employeeId, int year, int month) =>
      _guard(() => remoteDataSource.getMonthDetails(employeeId, year, month));

  @override
  Future<Result<List<MissionEntry>>> getMissions(int employeeId, int year, int month) =>
      _guard(() => remoteDataSource.getMissions(employeeId, year, month));

  @override
  Future<Result<List<PermissionEntry>>> getPermissions(int employeeId, int year, int month) =>
      _guard(() => remoteDataSource.getPermissions(employeeId, year, month));

  @override
  Future<Result<List<LatenessEntry>>> getLateness(int employeeId, int year, int month) =>
      _guard(() => remoteDataSource.getLateness(employeeId, year, month));
}
