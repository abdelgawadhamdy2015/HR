/// Plain domain entity — no json, no Dio, no dependency on anything outside domain.
class AuthUser {
  final int id;
  final String username;
  final String email;
  final List<String> permissions;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.permissions,
  });

  bool hasPermission(String permission) => permissions.contains(permission);
}
