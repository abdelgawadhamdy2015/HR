import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/permissions_cubit.dart';
import '../cubit/permissions_state.dart';

class UserPermissionsScreen extends StatefulWidget {
  const UserPermissionsScreen({super.key, this.initialUserId});
  final int? initialUserId;

  @override
  State<UserPermissionsScreen> createState() => _UserPermissionsScreenState();
}

class _UserPermissionsScreenState extends State<UserPermissionsScreen> {
  late final PermissionsCubit _cubit;
  late Future<List<_UserItem>> _usersFuture;
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialUserId;
    _cubit = sl<PermissionsCubit>()..load();
    _usersFuture = _loadUsers();
  }

  Future<List<_UserItem>> _loadUsers() async {
    final response = await sl<Dio>().get(ApiConstants.users);
    if (response.data is! List) throw StateError('Invalid users response');
    final items = (response.data as List).map((item) {
      final json = Map<String, dynamic>.from(item as Map);
      return _UserItem(id: json['id'] as int, username: '${json['username'] ?? ''}', fullName: '${json['fullName'] ?? ''}');
    }).toList();
    if (_selectedUserId == null && items.isNotEmpty) _selectedUserId = items.first.id;
    if (_selectedUserId != null) await _cubit.selectUser(_selectedUserId!);
    return items;
  }

  Future<void> _changePermission({required int userId, required int permissionId, required bool assign}) async {
    if (assign) {
      await _cubit.assign(userId: userId, permissionId: permissionId);
    } else {
      await _cubit.revoke(userId: userId, permissionId: permissionId);
    }
    await sl<AuthCubit>().refreshCurrentUser();
  }

  Future<void> _createPermission() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة صلاحية'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الصلاحية', hintText: 'Example.Manage')),
          const SizedBox(height: 12),
          TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'الوصف')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (result == true && nameController.text.trim().isNotEmpty && mounted) {
      await _cubit.create(name: nameController.text.trim(), description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim());
      nameController.dispose();
      descriptionController.dispose();
    } else {
      nameController.dispose();
      descriptionController.dispose();
    }
  }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final canManage = sl<AuthCubit>().hasPermission('Permissions.Manage');
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppTopBar(title: 'إدارة صلاحيات المستخدمين', actions: [if (canManage) IconButton(onPressed: _createPermission, icon: const Icon(Icons.add_moderator))]),
        body: FutureBuilder<List<_UserItem>>(
          future: _usersFuture,
          builder: (context, usersSnapshot) {
            if (usersSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            if (usersSnapshot.hasError) return Center(child: Text('تعذر تحميل المستخدمين: ${usersSnapshot.error}'));
            final users = usersSnapshot.data ?? const <_UserItem>[];
            if (users.isEmpty) return const Center(child: Text('لا يوجد مستخدمون في قاعدة البيانات'));
            return BlocConsumer<PermissionsCubit, PermissionsState>(
              listener: (context, state) { if (state is PermissionsError) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); },
              builder: (context, state) {
                final data = state is PermissionsLoaded ? state : state is PermissionActionLoading ? state.data : null;
                if (data == null) return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                return RefreshIndicator(
                  onRefresh: () async { setState(() => _usersFuture = _loadUsers()); await _usersFuture; await _cubit.load(); if (_selectedUserId != null) await _cubit.selectUser(_selectedUserId!); },
                  color: AppColors.gold,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonFormField<int>(
                        value: users.any((u) => u.id == _selectedUserId) ? _selectedUserId : null,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'المستخدم'),
                        items: users.map((u) => DropdownMenuItem(value: u.id, child: Text('${u.username} — ${u.fullName}'))).toList(),
                        onChanged: (id) { if (id == null) return; setState(() => _selectedUserId = id); _cubit.selectUser(id); },
                      ),
                      const SizedBox(height: 20),
                      const Text('الصلاحيات الحالية من قاعدة البيانات', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      ...data.permissions.map((permission) {
                        final assigned = data.userPermissions.any((p) => p.id == permission.id);
                        final busy = state is PermissionActionLoading;
                        return Card(child: SwitchListTile(title: Text(permission.name), subtitle: permission.description == null ? null : Text(permission.description!), value: assigned, activeColor: AppColors.gold, onChanged: _selectedUserId == null || busy || !canManage ? null : (value) => _changePermission(userId: _selectedUserId!, permissionId: permission.id, assign: value)));
                      }),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _UserItem {
  final int id;
  final String username;
  final String fullName;
  const _UserItem({required this.id, required this.username, required this.fullName});
}
