import '../../domain/entities/permission.dart';

class PermissionModel extends Permission {
  const PermissionModel({
    required super.id,
    required super.name,
    super.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
      };
}
