import '../../../employee/domain/entities/day_status.dart';
import '../../domain/entities/attendance_action_result.dart';

class AttendanceActionResultModel extends AttendanceActionResult {
  const AttendanceActionResultModel({
    required super.id,
    required super.employeeId,
    required super.date,
    required super.status,
    super.checkIn,
    super.checkOut,
    required super.lateMinutes,
  });

  // The .NET side serializes DayStatus as its raw int (no JsonStringEnumConverter
  // is configured), and the Dart DayStatus enum is declared in exactly the same
  // order as the C# enum, so the index lines up directly.
  factory AttendanceActionResultModel.fromJson(Map<String, dynamic> json) {
    return AttendanceActionResultModel(
      id: json['id'] as int,
      employeeId: json['employeeId'] as int,
      date: DateTime.parse(json['date'] as String),
      status: DayStatus.values[json['status'] as int],
      checkIn: json['checkIn'] as String?,
      checkOut: json['checkOut'] as String?,
      lateMinutes: json['lateMinutes'] as int,
    );
  }
}
