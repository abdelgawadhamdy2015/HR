import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/attendance_action_result.dart';
import '../repositories/attendance_actions_repository.dart';
import 'attendance_action_params.dart';

class MarkAttendanceDay implements UseCase<AttendanceActionResult, MarkAttendanceParams> {
  final AttendanceActionsRepository repository;
  MarkAttendanceDay(this.repository);

  @override
  Future<Result<AttendanceActionResult>> call(MarkAttendanceParams params) => repository.markDay(
        employeeId: params.employeeId,
        date: params.date,
        status: params.status,
      );
}
