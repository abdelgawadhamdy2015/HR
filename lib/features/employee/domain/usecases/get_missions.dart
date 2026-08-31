import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/mission_entry.dart';
import '../repositories/employee_repository.dart';
import 'employee_month_params.dart';

class GetMissions implements UseCase<List<MissionEntry>, EmployeeMonthParams> {
  final EmployeeRepository repository;
  GetMissions(this.repository);

  @override
  Future<Result<List<MissionEntry>>> call(EmployeeMonthParams params) {
    return repository.getMissions(params.employeeId, params.year, params.month);
  }
}
