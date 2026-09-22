import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/usecases/assign_permission.dart';
import '../../domain/usecases/create_permission.dart';
import '../../domain/usecases/get_permissions.dart';
import '../../domain/usecases/get_user_permissions.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/revoke_permission.dart';
import '../../domain/usecases/update_user_permissions.dart';
import 'permissions_state.dart';

class PermissionsCubit extends Cubit<PermissionsState> {
  final GetPermissions getPermissions;
  final GetUserPermissions getUserPermissions;
  final GetUsers getUsers;
  final CreatePermission createPermission;
  final AssignPermission assignPermission;
  final RevokePermission revokePermission;
  final UpdateUserPermissions updateUserPermissions;

  PermissionsCubit({
    required this.getPermissions,
    required this.getUserPermissions,
    required this.getUsers,
    required this.createPermission,
    required this.assignPermission,
    required this.revokePermission,
    required this.updateUserPermissions,
  }) : super(const PermissionsInitial());

  Future<void> load() async {
    emit(const PermissionsLoading());
    final results =
        await Future.wait([getPermissions(const NoParams()), getUsers()]);
    final permissionResult = results[0] as Result<List<Permission>>;
    final usersResult = results[1] as Result<List<UserSummary>>;

    permissionResult.fold(
      (failure) => emit(PermissionsError(failure.message)),
      (permissions) => usersResult.fold(
        (failure) => emit(PermissionsError(failure.message)),
        (users) =>
            emit(PermissionsLoaded(permissions: permissions, users: users)),
      ),
    );
  }

  Future<void> loadUserPermissions(int userId) async {
    final current = _loadedState;
    if (current == null) emit(const PermissionsLoading());
    final result = await getUserPermissions(userId);
    result.fold(
      (failure) => emit(PermissionsError(failure.message)),
      (userPermissions) => emit(PermissionsLoaded(
        permissions: current?.permissions ?? const <Permission>[],
        users: current?.users ?? const <UserSummary>[],
        selectedUserId: userId,
        userPermissions: userPermissions,
        selectedPermissionIds: userPermissions.map((p) => p.id).toSet(),
      )),
    );
  }

  Future<void> selectUser(int userId) => loadUserPermissions(userId);

  void togglePermission(int permissionId, bool enabled) {
    final current = _loadedState;
    if (current == null) return;

    final ids = {...current.selectedPermissionIds};
    enabled ? ids.add(permissionId) : ids.remove(permissionId);
    emit(current.copyWith(selectedPermissionIds: ids));
  }

  Future<void> save() async {
    final current = _loadedState;
    final userId = current?.selectedUserId;
    if (current == null || userId == null || !current.hasUnsavedChanges) return;
    emit(PermissionActionLoading(current));
    final result = await updateUserPermissions(
      userId: userId,
      permissionIds: current.selectedPermissionIds.toList()..sort(),
    );
    result.fold(
      (failure) => emit(PermissionsError(failure.message)),
      (userPermissions) => emit(PermissionsLoaded(
        permissions: current.permissions,
        users: current.users,
        selectedUserId: userId,
        userPermissions: userPermissions,
        selectedPermissionIds: userPermissions.map((p) => p.id).toSet(),
      )),
    );
  }

  Future<void> create({required String name, String? description}) async {
    final current = _loadedState;
    if (current == null) return;
    emit(PermissionActionLoading(current));
    final result = await createPermission(name: name, description: description);
    await result.fold(
      (failure) async => emit(PermissionsError(failure.message)),
      (_) async {
        final selectedUserId = current.selectedUserId;
        await load();
        if (selectedUserId != null) await loadUserPermissions(selectedUserId);
      },
    );
  }

  Future<void> assign({required int userId, required int permissionId}) =>
      _changeAssignment(
          action: () =>
              assignPermission(userId: userId, permissionId: permissionId),
          userId: userId);

  Future<void> revoke({required int userId, required int permissionId}) =>
      _changeAssignment(
          action: () =>
              revokePermission(userId: userId, permissionId: permissionId),
          userId: userId);

  Future<void> _changeAssignment(
      {required Future<Result<void>> Function() action,
      required int userId}) async {
    final current = _loadedState;
    if (current == null) return;
    emit(PermissionActionLoading(current));
    final result = await action();
    await result.fold(
      (failure) async => emit(PermissionsError(failure.message)),
      (_) async => loadUserPermissions(userId),
    );
  }

  PermissionsLoaded? get _loadedState {
    final current = state;
    if (current is PermissionsLoaded) return current;
    if (current is PermissionActionLoading) return current.data;
    return null;
  }
}
