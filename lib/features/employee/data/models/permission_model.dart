import '../../domain/entities/permission_entry.dart';

class PermissionModel extends PermissionEntry {
  const PermissionModel({
    required super.id,
    required super.date,
    required super.from,
    required super.to,
    required super.reason,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      from: json['from'] as String,
      to: json['to'] as String,
      reason: json['reason'] as String,
    );
  }
}
