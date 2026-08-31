import 'package:equatable/equatable.dart';
import 'day_status.dart';

class AttendanceDay extends Equatable {
  final DateTime date;
  final DayStatus status;

  const AttendanceDay({required this.date, required this.status});

  @override
  List<Object?> get props => [date, status];
}
