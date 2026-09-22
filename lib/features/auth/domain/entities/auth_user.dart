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
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool hasAnyPermission(Iterable<String> permissions) {
    return permissions.any(hasPermission);
  }

  bool hasAllPermissions(Iterable<String> permissions) {
    return permissions.every(hasPermission);
  }
}
