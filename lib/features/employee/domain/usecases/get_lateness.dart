import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/lateness_entry.dart';
import '../repositories/employee_repository.dart';
import 'employee_month_params.dart';

class GetLateness implements UseCase<List<LatenessEntry>, EmployeeMonthParams> {
  final EmployeeRepository repository;
  GetLateness(this.repository);

  @override
  Future<Result<List<LatenessEntry>>> call(EmployeeMonthParams params) {
    return repository.getLateness(params.employeeId, params.year, params.month);
  }
}
