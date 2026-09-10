import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/permission.dart';
import '../../domain/usecases/assign_permission.dart';
import '../../domain/usecases/create_permission.dart';
import '../../domain/usecases/get_permissions.dart';
import '../../domain/usecases/get_user_permissions.dart';
import '../../domain/usecases/revoke_permission.dart';
import 'permissions_state.dart';

class PermissionsCubit extends Cubit<PermissionsState> {
  final GetPermissions getPermissions;
  final GetUserPermissions getUserPermissions;
  final CreatePermission createPermission;
  final AssignPermission assignPermission;
  final RevokePermission revokePermission;

  PermissionsCubit({
    required this.getPermissions,
    required this.getUserPermissions,
    required this.createPermission,
    required this.assignPermission,
    required this.revokePermission,
  }) : super(const PermissionsInitial());

  Future<void> load() async {
    emit(const PermissionsLoading());
    final result = await getPermissions(const NoParams());
    result.fold(
      (failure) => emit(PermissionsError(failure.message)),
      (permissions) => emit(PermissionsLoaded(permissions: permissions)),
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
        selectedUserId: userId,
        userPermissions: userPermissions,
      )),
    );
  }

  Future<void> selectUser(int userId) => loadUserPermissions(userId);

  Future<void> create({required String name, String? description}) async {
    final current = _loadedState;
    if (current == null) return;

    emit(PermissionActionLoading(current));
    final result = await createPermission(name: name, description: description);
    await result.fold(
      (failure) async => emit(PermissionsError(failure.message)),
      (_) async {
        await load();
        if (current.selectedUserId != null) {
          await loadUserPermissions(current.selectedUserId!);
        }
      },
    );
  }

  Future<void> assign({required int userId, required int permissionId}) {
    return _changeAssignment(
      action: () => assignPermission(userId: userId, permissionId: permissionId),
      userId: userId,
    );
  }

  Future<void> revoke({required int userId, required int permissionId}) {
    return _changeAssignment(
      action: () => revokePermission(userId: userId, permissionId: permissionId),
      userId: userId,
    );
  }

  Future<void> _changeAssignment({
    required Future<Result<void>> Function() action,
    required int userId,
  }) async {
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
