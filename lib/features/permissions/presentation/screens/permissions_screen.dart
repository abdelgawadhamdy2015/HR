import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/permissions_cubit.dart';
import '../cubit/permissions_state.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key, this.userId});

  final int? userId;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late final PermissionsCubit _cubit;
  late final TextEditingController _userIdController;
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _cubit = sl<PermissionsCubit>()..load();
    final currentUserId = sl<AuthCubit>().state.currentUser?.id;
    _selectedUserId = widget.userId ?? currentUserId;
    _userIdController = TextEditingController(
      text: _selectedUserId?.toString() ?? '',
    );
    if (_selectedUserId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cubit.selectUser(_selectedUserId!);
      });
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _loadUser() {
    final id = int.tryParse(_userIdController.text.trim());
    if (id == null || id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم مستخدم صحيح')),
      );
      return;
    }
    setState(() => _selectedUserId = id);
    _cubit.selectUser(id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: const AppTopBar(title: 'إدارة الصلاحيات'),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.gold,
          onPressed: () => _showCreatePermissionDialog(context),
          child: const Icon(Icons.add, color: AppColors.background),
        ),
        body: BlocConsumer<PermissionsCubit, PermissionsState>(
          listener: (context, state) {
            if (state is PermissionsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is PermissionsLoading || state is PermissionsInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            final data = state is PermissionsLoaded
                ? state
                : state is PermissionActionLoading
                    ? state.data
                    : null;
            if (data == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: _cubit.load,
                  child: const Text('إعادة المحاولة'),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.gold,
              onRefresh: _cubit.load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _userIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'رقم المستخدم User ID',
                      prefixIcon: const Icon(Icons.person_outline),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _loadUser,
                      ),
                    ),
                    onSubmitted: (_) => _loadUser(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يمكنك البدء بالمستخدم الحالي، أو إدخال User ID لمستخدم آخر إذا كانت لديك صلاحية Permissions.Manage.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedUserId == null)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'أدخل User ID لعرض الصلاحيات الخاصة بالمستخدم.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...data.permissions.map((permission) {
                      final assigned = data.userPermissions
                          .any((item) => item.id == permission.id);
                      final busy = state is PermissionActionLoading;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: SwitchListTile(
                          title: Text(permission.name),
                          subtitle: permission.description == null
                              ? null
                              : Text(permission.description!),
                          value: assigned,
                          activeColor: AppColors.gold,
                          onChanged: busy
                              ? null
                              : (value) {
                                  if (value) {
                                    _cubit.assign(
                                      userId: _selectedUserId!,
                                      permissionId: permission.id,
                                    );
                                  } else {
                                    _cubit.revoke(
                                      userId: _selectedUserId!,
                                      permissionId: permission.id,
                                    );
                                  }
                                },
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreatePermissionDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة صلاحية'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الصلاحية'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'أدخل اسم الصلاحية'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext);
              _cubit.create(
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    nameController.dispose();
    descriptionController.dispose();
  }
}
