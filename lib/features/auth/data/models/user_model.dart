class AuthResult {
  final int userId;
  final String username;
  final String email;
  final String token;
  final DateTime expiresAt;
  final List<String> permissions;

  AuthResult({
    required this.userId,
    required this.username,
    required this.email,
    required this.token,
    required this.expiresAt,
    required this.permissions,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      userId: json['userId'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ?? DateTime.now(),
      permissions: (json['permissions'] as List<dynamic>? ?? [])
          .map((p) => p.toString())
          .toList(),
    );
  }

  bool hasPermission(String permission) => permissions.contains(permission);
}
