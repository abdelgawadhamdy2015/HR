import 'package:equatable/equatable.dart';

class EmployeeMonthParams extends Equatable {
  final int employeeId;
  final int year;
  final int month;

  const EmployeeMonthParams({required this.employeeId, required this.year, required this.month});

  @override
  List<Object?> get props => [employeeId, year, month];
}
