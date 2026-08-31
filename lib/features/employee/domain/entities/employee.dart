import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final int id;
  final String code;
  final String fullName;
  final String jobTitle;
  final String department;
  final String? avatarUrl;

  const Employee({
    required this.id,
    required this.code,
    required this.fullName,
    required this.jobTitle,
    required this.department,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, code, fullName, jobTitle, department, avatarUrl];
}
