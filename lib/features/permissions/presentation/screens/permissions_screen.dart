import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../employee/domain/entities/employee.dart';
import '../../../employee/domain/usecases/get_employees.dart';
import '../cubit/permissions_cubit.dart';
import '../cubit/permissions_state.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PermissionsCubit>()..load(),
      child: const _PermissionsView(),
    );
  }
}

class _PermissionsView extends StatefulWidget {
  const _PermissionsView();

  @override
  State<_PermissionsView> createState() => _PermissionsViewState();
}

class _PermissionsViewState extends State<_PermissionsView> {
  List<Employee> _employees = const [];
  int? _selectedUserId;
  bool _loadingEmployees = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loadingEmployees = true);
    final result = await sl<GetEmployees>()(const NoParams());
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (employees) {
        setState(() {
          _employees = employees;
          _loadingEmployees = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: () => context.read<PermissionsCubit>().load(),
                child: const Text('إعادة المحاولة'),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () => context.read<PermissionsCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'المستخدم',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: _loadingEmployees
                      ? const []
                      : _employees
                          .map(
                            (employee) => DropdownMenuItem<int>(
                              value: employee.id,
                              child: Text('${employee.fullName} (${employee.code})'),
                            ),
                          )
                          .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    setState(() => _selectedUserId = id);
                    context.read<PermissionsCubit>().selectUser(id);
                  },
                ),
                const SizedBox(height: 24),
                if (_selectedUserId == null)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'اختر مستخدمًا لعرض وإدارة الصلاحيات الخاصة به.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...data.permissions.map(
                    (permission) {
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
                                    context.read<PermissionsCubit>().assign(
                                          userId: _selectedUserId!,
                                          permissionId: permission.id,
                                        );
                                  } else {
                                    context.read<PermissionsCubit>().revoke(
                                          userId: _selectedUserId!,
                                          permissionId: permission.id,
                                        );
                                  }
                                },
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
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
              context.read<PermissionsCubit>().create(
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
