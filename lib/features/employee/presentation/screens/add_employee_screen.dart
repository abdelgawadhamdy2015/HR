import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/employee_list_cubit.dart';

/// Form to add a new employee (POST /api/employees).
/// Expects an [EmployeeListCubit] to already be provided above it in the
/// tree (the employee list page provides one via BlocProvider).
class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await context.read<EmployeeListCubit>().createEmployee(
          code: _codeController.text.trim(),
          fullName: _fullNameController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          department: _departmentController.text.trim(),
        );

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة موظف')),
      body: BlocListener<EmployeeListCubit, EmployeeListState>(
        listenWhen: (previous, current) => previous.createStatus != current.createStatus,
        listener: (context, state) {
          if (state.createStatus == CreateEmployeeStatus.failure &&
              state.createErrorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.createErrorMessage!)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'الرقم الوظيفي (Code)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'الرقم الوظيفي مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'الاسم بالكامل'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(labelText: 'الوظيفة'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'الوظيفة مطلوبة' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'الإدارة'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'الإدارة مطلوبة' : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<EmployeeListCubit, EmployeeListState>(
                  builder: (context, state) {
                    final submitting = state.createStatus == CreateEmployeeStatus.submitting;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitting ? null : _submit,
                        child: submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.background,
                                ),
                              )
                            : const Text('حفظ'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
