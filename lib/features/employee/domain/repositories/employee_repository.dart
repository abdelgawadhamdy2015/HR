import '../../../../core/utils/result.dart';
import '../entities/employee.dart';
import '../entities/employee_month_details.dart';
import '../entities/lateness_entry.dart';
import '../entities/mission_entry.dart';
import '../entities/permission_entry.dart';

abstract class EmployeeRepository {
  Future<Result<List<Employee>>> getEmployees();
  Future<Result<Employee>> getEmployeeById(int id);
  Future<Result<Employee>> createEmployee({
    required String code,
    required String fullName,
    required String jobTitle,
    required String department,
    String? avatarUrl,
  });
  Future<Result<EmployeeMonthDetails>> getMonthDetails(int employeeId, int year, int month);
  Future<Result<List<MissionEntry>>> getMissions(int employeeId, int year, int month);
  Future<Result<List<PermissionEntry>>> getPermissions(int employeeId, int year, int month);
  Future<Result<List<LatenessEntry>>> getLateness(int employeeId, int year, int month);
}
