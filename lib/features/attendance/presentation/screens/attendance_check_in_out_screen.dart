import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../employee/domain/entities/employee.dart';
import '../../../employee/presentation/cubit/employee_list_cubit.dart';
import '../cubit/attendance_actions_cubit.dart';

class AttendanceCheckInOutScreen extends StatelessWidget {
  const AttendanceCheckInOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<EmployeeListCubit>()..loadEmployees()),
        BlocProvider(create: (_) => sl<AttendanceActionsCubit>()),
      ],
      child: const _View(),
    );
  }
}

class _View extends StatefulWidget {
  const _View();
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  Employee? _employee;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  String _dateText(DateTime value) => '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  String _timeText(TimeOfDay value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(context: context, initialTime: _time);
    if (value != null) setState(() => _time = value);
  }

  void _submit(bool checkIn) {
    final employee = _employee;
    if (employee == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر الموظف أولاً')));
      return;
    }
    final cubit = context.read<AttendanceActionsCubit>();
    final time = _timeText(_time);
    if (checkIn) {
      cubit.checkIn(employeeId: employee.id, date: _date, time: time);
    } else {
      cubit.checkOut(employeeId: employee.id, date: _date, time: time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'تسجيل حضور / انصراف'),
      body: BlocListener<AttendanceActionsCubit, AttendanceActionsState>(
        listener: (context, state) {
          if (state.status == AttendanceActionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.successMessage ?? 'تم الحفظ'), backgroundColor: AppColors.green));
          } else if (state.status == AttendanceActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'حدث خطأ'), backgroundColor: AppColors.danger));
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocBuilder<EmployeeListCubit, EmployeeListState>(
              builder: (context, state) {
                if (state.status == EmployeeListStatus.loading || state.status == EmployeeListStatus.initial) {
                  return const LinearProgressIndicator(color: AppColors.gold);
                }
                if (state.status == EmployeeListStatus.failure) {
                  return Text(state.errorMessage ?? 'تعذر تحميل الموظفين', style: const TextStyle(color: AppColors.danger));
                }
                return DropdownButtonFormField<Employee>(
                  value: _employee,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'الموظف'),
                  items: state.employees.map((e) => DropdownMenuItem(value: e, child: Text('${e.code} — ${e.fullName}'))).toList(),
                  onChanged: (value) => setState(() => _employee = value),
                );
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.surface,
              leading: const Icon(Icons.calendar_today, color: AppColors.gold),
              title: const Text('التاريخ'),
              subtitle: Text(_dateText(_date)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.surface,
              leading: const Icon(Icons.access_time, color: AppColors.gold),
              title: const Text('الوقت'),
              subtitle: Text(_timeText(_time)),
              trailing: const Icon(Icons.schedule),
              onTap: _pickTime,
            ),
            const SizedBox(height: 8),
            const Text('يمكن تسجيل تاريخ ووقت فعليين أو تصحيح سجل سابق. البيانات تحفظ في قاعدة البيانات.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            BlocBuilder<AttendanceActionsCubit, AttendanceActionsState>(
              builder: (context, state) {
                final busy = state.status == AttendanceActionStatus.submitting;
                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: busy ? null : () => _submit(true), icon: const Icon(Icons.login), label: const Text('تسجيل حضور'))),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: busy ? null : () => _submit(false), icon: const Icon(Icons.logout), label: const Text('تسجيل انصراف'))),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
