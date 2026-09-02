import 'package:equatable/equatable.dart';

class CheckInParams extends Equatable {
  final int employeeId;
  final DateTime? date;
  final String? time;
  const CheckInParams({required this.employeeId, this.date, this.time});

  @override
  List<Object?> get props => [employeeId, date, time];
}

class CheckOutParams extends Equatable {
  final int employeeId;
  final DateTime? date;
  final String? time;
  const CheckOutParams({required this.employeeId, this.date, this.time});

  @override
  List<Object?> get props => [employeeId, date, time];
}

class MarkAttendanceParams extends Equatable {
  final int employeeId;
  final DateTime date;
  final String status;
  const MarkAttendanceParams({required this.employeeId, required this.date, required this.status});

  @override
  List<Object?> get props => [employeeId, date, status];
}

class RecordLatenessParams extends Equatable {
  final int employeeId;
  final DateTime date;
  final int minutes;
  const RecordLatenessParams({required this.employeeId, required this.date, required this.minutes});

  @override
  List<Object?> get props => [employeeId, date, minutes];
}

class CreateMissionParams extends Equatable {
  final int employeeId;
  final DateTime date;
  final String reason;
  final String location;
  const CreateMissionParams({
    required this.employeeId,
    required this.date,
    required this.reason,
    required this.location,
  });

  @override
  List<Object?> get props => [employeeId, date, reason, location];
}

class CreatePermissionRequestParams extends Equatable {
  final int employeeId;
  final DateTime date;
  final String from;
  final String to;
  final String reason;
  const CreatePermissionRequestParams({
    required this.employeeId,
    required this.date,
    required this.from,
    required this.to,
    required this.reason,
  });

  @override
  List<Object?> get props => [employeeId, date, from, to, reason];
}
