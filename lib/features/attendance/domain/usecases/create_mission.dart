import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../../employee/domain/entities/mission_entry.dart';
import '../repositories/attendance_actions_repository.dart';
import 'attendance_action_params.dart';

class CreateMission implements UseCase<MissionEntry, CreateMissionParams> {
  final AttendanceActionsRepository repository;
  CreateMission(this.repository);

  @override
  Future<Result<MissionEntry>> call(CreateMissionParams params) => repository.createMission(
        employeeId: params.employeeId,
        date: params.date,
        reason: params.reason,
        location: params.location,
      );
}
