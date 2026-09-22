import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/user_summary.dart';
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
  late final TextEditingController _searchController;
  int? _selectedUserId;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _cubit = sl<PermissionsCubit>()..load();
    _searchController = TextEditingController();
    _selectedUserId = widget.userId;
    if (_selectedUserId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cubit.selectUser(_selectedUserId!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  bool get _canManage =>
      sl<AuthCubit>().state.currentUser?.hasPermission('Permissions.Manage') ??
      false;

  void _selectUser(int? id) {
    if (id == null) return;
    setState(() => _selectedUserId = id);
    _cubit.selectUser(id);
  }

  List<UserSummary> _filteredUsers(List<UserSummary> users) {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return users;
    return users.where((user) {
      return user.displayName.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query) ||
          user.id.toString().contains(query) ||
          (user.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: const AppTopBar(title: 'إدارة الصلاحيات'),
        floatingActionButton: _canManage
            ? FloatingActionButton(
                backgroundColor: AppColors.gold,
                onPressed: () => _showCreatePermissionDialog(context),
                child: const Icon(Icons.add, color: AppColors.background),
              )
            : null,
        bottomNavigationBar: BlocBuilder<PermissionsCubit, PermissionsState>(
          builder: (context, state) {
            final data = state is PermissionsLoaded
                ? state
                : state is PermissionActionLoading
                    ? state.data
                    : null;
            if (data == null ||
                data.selectedUserId == null ||
                !_canManage ||
                !data.hasUnsavedChanges) {
              return const SizedBox.shrink();
            }
            final saving = state is PermissionActionLoading;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : _cubit.save,
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('حفظ تغييرات الصلاحيات'),
                  ),
                ),
              ),
            );
          },
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

            final users = _filteredUsers(data.users);
            final selectedExists =
                data.users.any((u) => u.id == _selectedUserId);

            return RefreshIndicator(
              color: AppColors.gold,
              onRefresh: () async {
                await _cubit.load();
                if (_selectedUserId != null) {
                  await _cubit.selectUser(_selectedUserId!);
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'بحث عن المستخدم',
                      hintText: 'الاسم أو اسم المستخدم أو البريد أو ID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _search.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _search = '');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onChanged: (value) => setState(() => _search = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedExists ? _selectedUserId : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'المستخدم',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    hint: const Text('اختر المستخدم'),
                    items: users.map((user) {
                      return DropdownMenuItem<int>(
                        value: user.id,
                        child: Text(
                          user.displayName,
                        ),
                      );
                    }).toList(),
                    onChanged:
                        state is PermissionActionLoading ? null : _selectUser,
                  ),
                  if (data.users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'لا يوجد مستخدمون في قاعدة البيانات.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _canManage
                        ? 'اختر مستخدمًا، ثم فعّل أو عطّل الصلاحيات. لا يتم تعديل قاعدة البيانات حتى تضغط حفظ.'
                        : 'وضع العرض فقط. تحتاج إلى Permissions.Manage لتعديل الصلاحيات.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedUserId == null)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'اختر مستخدمًا لعرض صلاحياته.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (data.permissions.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'لا توجد صلاحيات معرفة في قاعدة البيانات.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...data.permissions.map((permission) {
                      final assigned =
                          data.selectedPermissionIds.contains(permission.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: SwitchListTile(
                          title: Text(permission.name),
                          subtitle: permission.description == null
                              ? null
                              : Text(permission.description!),
                          value: assigned,
                          activeColor: AppColors.gold,
                          onChanged: !_canManage ||
                                  state is PermissionActionLoading
                              ? null
                              : (value) =>
                                  _cubit.togglePermission(permission.id, value),
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
