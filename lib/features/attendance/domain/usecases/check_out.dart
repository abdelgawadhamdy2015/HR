import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/attendance_action_result.dart';
import '../repositories/attendance_actions_repository.dart';
import 'attendance_action_params.dart';

class CheckOut implements UseCase<AttendanceActionResult, CheckOutParams> {
  final AttendanceActionsRepository repository;
  CheckOut(this.repository);

  @override
  Future<Result<AttendanceActionResult>> call(CheckOutParams params) => repository.checkOut(
        employeeId: params.employeeId,
        date: params.date,
        time: params.time,
      );
}
