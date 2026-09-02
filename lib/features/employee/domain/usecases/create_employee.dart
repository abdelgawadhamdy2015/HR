import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class CreateEmployeeParams {
  final String code;
  final String fullName;
  final String jobTitle;
  final String department;
  final String? avatarUrl;

  const CreateEmployeeParams({
    required this.code,
    required this.fullName,
    required this.jobTitle,
    required this.department,
    this.avatarUrl,
  });
}

class CreateEmployee implements UseCase<Employee, CreateEmployeeParams> {
  final EmployeeRepository repository;
  CreateEmployee(this.repository);

  @override
  Future<Result<Employee>> call(CreateEmployeeParams params) => repository.createEmployee(
        code: params.code,
        fullName: params.fullName,
        jobTitle: params.jobTitle,
        department: params.department,
        avatarUrl: params.avatarUrl,
      );
}
