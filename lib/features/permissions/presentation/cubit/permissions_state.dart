import 'package:equatable/equatable.dart';

import '../../domain/entities/permission.dart';
import '../../domain/entities/user_summary.dart';

sealed class PermissionsState extends Equatable {
  const PermissionsState();
  @override List<Object?> get props => [];
}
class PermissionsInitial extends PermissionsState { const PermissionsInitial(); }
class PermissionsLoading extends PermissionsState { const PermissionsLoading(); }
class PermissionsLoaded extends PermissionsState {
  final List<Permission> permissions;
  final List<UserSummary> users;
  final int? selectedUserId;
  final List<Permission> userPermissions;
  final Set<int> selectedPermissionIds;

  const PermissionsLoaded({
    required this.permissions,
    this.users = const [],
    this.selectedUserId,
    this.userPermissions = const [],
    Set<int>? selectedPermissionIds,
  }) : selectedPermissionIds = selectedPermissionIds ?? const <int>{};

  bool get hasUnsavedChanges {
    final assignedIds = userPermissions.map((p) => p.id).toSet();
    return assignedIds.length != selectedPermissionIds.length || !assignedIds.containsAll(selectedPermissionIds);
  }

  UserSummary? get selectedUser {
    final id = selectedUserId;
    if (id == null) return null;
    for (final user in users) { if (user.id == id) return user; }
    return null;
  }

  PermissionsLoaded copyWith({
    List<Permission>? permissions,
    List<UserSummary>? users,
    int? selectedUserId,
    List<Permission>? userPermissions,
    Set<int>? selectedPermissionIds,
  }) => PermissionsLoaded(
    permissions: permissions ?? this.permissions,
    users: users ?? this.users,
    selectedUserId: selectedUserId ?? this.selectedUserId,
    userPermissions: userPermissions ?? this.userPermissions,
    selectedPermissionIds: selectedPermissionIds ?? this.selectedPermissionIds,
  );

  @override List<Object?> get props => [permissions, users, selectedUserId, userPermissions, selectedPermissionIds];
}
class PermissionsError extends PermissionsState {
  final String message;
  const PermissionsError(this.message);
  @override List<Object?> get props => [message];
}
class PermissionActionLoading extends PermissionsState {
  final PermissionsLoaded data;
  const PermissionActionLoading(this.data);
  @override List<Object?> get props => [data];
}
