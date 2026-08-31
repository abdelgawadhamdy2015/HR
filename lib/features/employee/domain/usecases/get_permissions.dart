import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/permission_entry.dart';
import '../repositories/employee_repository.dart';
import 'employee_month_params.dart';

class GetPermissions implements UseCase<List<PermissionEntry>, EmployeeMonthParams> {
  final EmployeeRepository repository;
  GetPermissions(this.repository);

  @override
  Future<Result<List<PermissionEntry>>> call(EmployeeMonthParams params) {
    return repository.getPermissions(params.employeeId, params.year, params.month);
  }
}
