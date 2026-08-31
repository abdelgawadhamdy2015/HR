import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class GetEmployeeById implements UseCase<Employee, int> {
  final EmployeeRepository repository;
  GetEmployeeById(this.repository);

  @override
  Future<Result<Employee>> call(int params) => repository.getEmployeeById(params);
}
