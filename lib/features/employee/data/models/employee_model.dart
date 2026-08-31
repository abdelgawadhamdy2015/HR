import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.code,
    required super.fullName,
    required super.jobTitle,
    required super.department,
    super.avatarUrl,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int,
      code: json['code'] as String,
      fullName: json['fullName'] as String,
      jobTitle: json['jobTitle'] as String,
      department: json['department'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
