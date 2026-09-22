class UpdateUserPermissionsRequest {
  final int userId;
  final List<int> permissionIds;

  const UpdateUserPermissionsRequest({
    required this.userId,
    required this.permissionIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'permissionIds': permissionIds,
    };
  }
}
