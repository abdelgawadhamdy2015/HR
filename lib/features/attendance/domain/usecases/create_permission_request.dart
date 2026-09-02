import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../../employee/domain/entities/permission_entry.dart';
import '../repositories/attendance_actions_repository.dart';
import 'attendance_action_params.dart';

class CreatePermissionRequest implements UseCase<PermissionEntry, CreatePermissionRequestParams> {
  final AttendanceActionsRepository repository;
  CreatePermissionRequest(this.repository);

  @override
  Future<Result<PermissionEntry>> call(CreatePermissionRequestParams params) =>
      repository.createPermissionRequest(
        employeeId: params.employeeId,
        date: params.date,
        from: params.from,
        to: params.to,
        reason: params.reason,
      );
}
