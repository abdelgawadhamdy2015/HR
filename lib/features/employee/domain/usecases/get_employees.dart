import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class GetEmployees implements UseCase<List<Employee>, NoParams> {
  final EmployeeRepository repository;
  GetEmployees(this.repository);

  @override
  Future<Result<List<Employee>>> call(NoParams params) => repository.getEmployees();
}
