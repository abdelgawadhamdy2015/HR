import '../../domain/entities/user_summary.dart';

class UserSummaryModel extends UserSummary {
  const UserSummaryModel({
    required super.id,
    required super.username,
    super.email,
    super.fullName,
    required super.isActive,
    super.permissions,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      permissions: (json['permissions'] as List?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const [],
    );
  }
}
