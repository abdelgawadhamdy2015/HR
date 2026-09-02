import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/attendance_action_result.dart';
import '../repositories/attendance_actions_repository.dart';
import 'attendance_action_params.dart';

class CheckIn implements UseCase<AttendanceActionResult, CheckInParams> {
  final AttendanceActionsRepository repository;
  CheckIn(this.repository);

  @override
  Future<Result<AttendanceActionResult>> call(CheckInParams params) => repository.checkIn(
        employeeId: params.employeeId,
        date: params.date,
        time: params.time,
      );
}
