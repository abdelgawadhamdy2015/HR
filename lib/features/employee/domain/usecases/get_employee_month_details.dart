import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/employee_month_details.dart';
import '../repositories/employee_repository.dart';
import 'employee_month_params.dart';

class GetEmployeeMonthDetails implements UseCase<EmployeeMonthDetails, EmployeeMonthParams> {
  final EmployeeRepository repository;
  GetEmployeeMonthDetails(this.repository);

  @override
  Future<Result<EmployeeMonthDetails>> call(EmployeeMonthParams params) {
    return repository.getMonthDetails(params.employeeId, params.year, params.month);
  }
}
