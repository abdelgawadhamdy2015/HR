import 'package:equatable/equatable.dart';

import '../../domain/entities/permission.dart';

sealed class PermissionsState extends Equatable {
  const PermissionsState();

  @override
  List<Object?> get props => [];
}

class PermissionsInitial extends PermissionsState {
  const PermissionsInitial();
}

class PermissionsLoading extends PermissionsState {
  const PermissionsLoading();
}

class PermissionsLoaded extends PermissionsState {
  final List<Permission> permissions;
  final int? selectedUserId;
  final List<Permission> userPermissions;

  const PermissionsLoaded({
    required this.permissions,
    this.selectedUserId,
    this.userPermissions = const [],
  });

  PermissionsLoaded copyWith({
    List<Permission>? permissions,
    int? selectedUserId,
    List<Permission>? userPermissions,
  }) {
    return PermissionsLoaded(
      permissions: permissions ?? this.permissions,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      userPermissions: userPermissions ?? this.userPermissions,
    );
  }

  @override
  List<Object?> get props => [permissions, selectedUserId, userPermissions];
}

class PermissionsError extends PermissionsState {
  final String message;
  const PermissionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PermissionActionLoading extends PermissionsState {
  final PermissionsLoaded data;
  const PermissionActionLoading(this.data);

  @override
  List<Object?> get props => [data];
}
