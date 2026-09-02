import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/attendance_action_result.dart';
import '../repositories/attendance_actions_repository.dart';
import 'attendance_action_params.dart';

class RecordLateness implements UseCase<AttendanceActionResult, RecordLatenessParams> {
  final AttendanceActionsRepository repository;
  RecordLateness(this.repository);

  @override
  Future<Result<AttendanceActionResult>> call(RecordLatenessParams params) => repository.recordLateness(
        employeeId: params.employeeId,
        date: params.date,
        minutes: params.minutes,
      );
}
