import '../../../../core/utils/result.dart';
import '../../../employee/domain/entities/mission_entry.dart';
import '../../../employee/domain/entities/permission_entry.dart';
import '../entities/attendance_action_result.dart';

abstract class AttendanceActionsRepository {
  /// POST /api/attendance/checkin
  Future<Result<AttendanceActionResult>> checkIn({
    required int employeeId,
    DateTime? date,
    String? time,
  });

  /// POST /api/attendance/checkout
  Future<Result<AttendanceActionResult>> checkOut({
    required int employeeId,
    DateTime? date,
    String? time,
  });

  /// POST /api/attendance/mark
  /// [status] must be one of: present, annualLeave, casualLeave, sickLeave, cutOff, none
  Future<Result<AttendanceActionResult>> markDay({
    required int employeeId,
    required DateTime date,
    required String status,
  });

  /// POST /api/attendance/lateness
  Future<Result<AttendanceActionResult>> recordLateness({
    required int employeeId,
    required DateTime date,
    required int minutes,
  });

  /// POST /api/missions — مأمورية
  Future<Result<MissionEntry>> createMission({
    required int employeeId,
    required DateTime date,
    required String reason,
    required String location,
  });

  /// POST /api/permission-requests — إذن
  Future<Result<PermissionEntry>> createPermissionRequest({
    required int employeeId,
    required DateTime date,
    required String from,
    required String to,
    required String reason,
  });
}
