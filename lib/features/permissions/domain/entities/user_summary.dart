class UserSummary {
  final int id;
  final String username;
  final String? email;
  final String? fullName;
  final bool isActive;
  final List<String> permissions;

  const UserSummary({
    required this.id,
    required this.username,
    this.email,
    this.fullName,
    required this.isActive,
    this.permissions = const [],
  });

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return username;
  }
}
