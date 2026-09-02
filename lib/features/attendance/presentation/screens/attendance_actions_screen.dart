import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../employee/domain/entities/employee.dart';
import '../../../employee/presentation/cubit/employee_list_cubit.dart';
import '../cubit/attendance_actions_cubit.dart';

/// One screen covering every attendance quick action: تسجيل حضور/انصراف,
/// إجازة/انقطاع, تصحيح تأخير, مأمورية, and إذن. An employee is picked once
/// at the top and shared across all tabs.
class AttendanceActionsScreen extends StatelessWidget {
  /// Which tab to open first — handy when a dashboard button already implies
  /// an action (e.g. "المأموريات" opens straight to the mission tab).
  final int initialTabIndex;

  const AttendanceActionsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<EmployeeListCubit>()..loadEmployees()),
        BlocProvider(create: (_) => sl<AttendanceActionsCubit>()),
      ],
      child: _AttendanceActionsView(initialTabIndex: initialTabIndex),
    );
  }
}

class _AttendanceActionsView extends StatefulWidget {
  final int initialTabIndex;
  const _AttendanceActionsView({required this.initialTabIndex});

  @override
  State<_AttendanceActionsView> createState() => _AttendanceActionsViewState();
}

class _AttendanceActionsViewState extends State<_AttendanceActionsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Employee? _selectedEmployee;

  static const _tabs = [
    Tab(text: 'حضور / انصراف'),
    Tab(text: 'إجازة / انقطاع'),
    Tab(text: 'تصحيح تأخير'),
    Tab(text: 'مأمورية'),
    Tab(text: 'إذن'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      initialIndex: widget.initialTabIndex.clamp(0, _tabs.length - 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'إجراءات الحضور والانصراف',
      ),
      body: BlocListener<AttendanceActionsCubit, AttendanceActionsState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AttendanceActionStatus.success &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.green),
            );
          } else if (state.status == AttendanceActionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.danger),
            );
          }
        },
        child: Column(
          children: [
            _EmployeePicker(
              selected: _selectedEmployee,
              onChanged: (e) => setState(() => _selectedEmployee = e),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.gold,
              tabs: _tabs,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CheckInOutTab(employee: _selectedEmployee),
                  _MarkDayTab(employee: _selectedEmployee),
                  _LatenessTab(employee: _selectedEmployee),
                  _MissionTab(employee: _selectedEmployee),
                  _PermissionTab(employee: _selectedEmployee),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeePicker extends StatelessWidget {
  final Employee? selected;
  final ValueChanged<Employee?> onChanged;
  const _EmployeePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: BlocBuilder<EmployeeListCubit, EmployeeListState>(
        builder: (context, state) {
          if (state.status == EmployeeListStatus.loading ||
              state.status == EmployeeListStatus.initial) {
            return const LinearProgressIndicator(color: AppColors.gold);
          }
          if (state.status == EmployeeListStatus.failure) {
            return Text(state.errorMessage ?? 'تعذر تحميل الموظفين',
                style: const TextStyle(color: AppColors.danger));
          }

          return DropdownButtonFormField<Employee>(
            value: selected,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'الموظف'),
            items: state.employees
                .map((e) => DropdownMenuItem(
                    value: e, child: Text('${e.code} — ${e.fullName}')))
                .toList(),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}

/// Small helper shared by every tab below: shows a message instead of a form
/// when no employee has been picked yet, otherwise builds the form.
class _RequiresEmployee extends StatelessWidget {
  final Employee? employee;
  final Widget Function(BuildContext context, Employee employee) builder;
  const _RequiresEmployee({required this.employee, required this.builder});

  @override
  Widget build(BuildContext context) {
    final e = employee;
    if (e == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('اختر موظفاً أولاً من القائمة أعلاه',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }
    return builder(context, e);
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const _SubmitButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceActionsCubit, AttendanceActionsState>(
      builder: (context, state) {
        final submitting = state.status == AttendanceActionStatus.submitting;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitting ? null : onPressed,
            child: submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.background),
                  )
                : Text(label),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// تسجيل حضور / انصراف
// ---------------------------------------------------------------------------
class _CheckInOutTab extends StatelessWidget {
  final Employee? employee;
  const _CheckInOutTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return _RequiresEmployee(
      employee: employee,
      builder: (context, e) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('تسجيل حضور أو انصراف الآن لـ ${e.fullName}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            _SubmitButton(
              label: 'تسجيل حضور الآن',
              onPressed: () => context
                  .read<AttendanceActionsCubit>()
                  .checkIn(employeeId: e.id),
            ),
            const SizedBox(height: 12),
            _SubmitButton(
              label: 'تسجيل انصراف الآن',
              onPressed: () => context
                  .read<AttendanceActionsCubit>()
                  .checkOut(employeeId: e.id),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// إجازة / انقطاع (mark a day's status directly)
// ---------------------------------------------------------------------------
class _MarkDayTab extends StatefulWidget {
  final Employee? employee;
  const _MarkDayTab({required this.employee});

  @override
  State<_MarkDayTab> createState() => _MarkDayTabState();
}

class _MarkDayTabState extends State<_MarkDayTab> {
  DateTime _date = DateTime.now();
  String _status = 'annualLeave';

  static const _statusOptions = {
    'annualLeave': 'إجازة اعتيادية',
    'casualLeave': 'إجازة عارضة',
    'sickLeave': 'إجازة مرضية',
    'cutOff': 'انقطاع',
    'present': 'حاضر (تصحيح)',
    'none': 'بدون حالة (تصحيح)',
  };

  @override
  Widget build(BuildContext context) {
    return _RequiresEmployee(
      employee: widget.employee,
      builder: (context, e) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DatePickerField(
                date: _date, onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'الحالة'),
              items: _statusOptions.entries
                  .map((entry) => DropdownMenuItem(
                      value: entry.key, child: Text(entry.value)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 20),
            _SubmitButton(
              label: 'حفظ',
              onPressed: () => context
                  .read<AttendanceActionsCubit>()
                  .markDay(employeeId: e.id, date: _date, status: _status),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// تصحيح تأخير
// ---------------------------------------------------------------------------
class _LatenessTab extends StatefulWidget {
  final Employee? employee;
  const _LatenessTab({required this.employee});

  @override
  State<_LatenessTab> createState() => _LatenessTabState();
}

class _LatenessTabState extends State<_LatenessTab> {
  DateTime _date = DateTime.now();
  final _minutesController = TextEditingController();

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RequiresEmployee(
      employee: widget.employee,
      builder: (context, e) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DatePickerField(
                date: _date, onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: 16),
            TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'عدد دقائق التأخير'),
            ),
            const SizedBox(height: 20),
            _SubmitButton(
              label: 'حفظ',
              onPressed: () {
                final minutes = int.tryParse(_minutesController.text.trim());
                if (minutes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('أدخل عدداً صحيحاً من الدقائق')));
                  return;
                }
                context.read<AttendanceActionsCubit>().recordLateness(
                    employeeId: e.id, date: _date, minutes: minutes);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// مأمورية
// ---------------------------------------------------------------------------
class _MissionTab extends StatefulWidget {
  final Employee? employee;
  const _MissionTab({required this.employee});

  @override
  State<_MissionTab> createState() => _MissionTabState();
}

class _MissionTabState extends State<_MissionTab> {
  DateTime _date = DateTime.now();
  final _reasonController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RequiresEmployee(
      employee: widget.employee,
      builder: (context, e) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DatePickerField(
                date: _date, onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'سبب المأمورية'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'الجهة / المكان'),
            ),
            const SizedBox(height: 20),
            _SubmitButton(
              label: 'حفظ',
              onPressed: () =>
                  context.read<AttendanceActionsCubit>().createMission(
                        employeeId: e.id,
                        date: _date,
                        reason: _reasonController.text.trim(),
                        location: _locationController.text.trim(),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// إذن
// ---------------------------------------------------------------------------
class _PermissionTab extends StatefulWidget {
  final Employee? employee;
  const _PermissionTab({required this.employee});

  @override
  State<_PermissionTab> createState() => _PermissionTabState();
}

class _PermissionTabState extends State<_PermissionTab> {
  DateTime _date = DateTime.now();
  TimeOfDay _from = const TimeOfDay(hour: 11, minute: 0);
  TimeOfDay _to = const TimeOfDay(hour: 13, minute: 0);
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
        context: context, initialTime: isFrom ? _from : _to);
    if (picked == null) return;
    setState(() => isFrom ? _from = picked : _to = picked);
  }

  @override
  Widget build(BuildContext context) {
    return _RequiresEmployee(
      employee: widget.employee,
      builder: (context, e) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DatePickerField(
                date: _date, onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text('من: ${_formatTime(_from)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text('إلى: ${_formatTime(_to)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'سبب الإذن'),
            ),
            const SizedBox(height: 20),
            _SubmitButton(
              label: 'حفظ',
              onPressed: () => context
                  .read<AttendanceActionsCubit>()
                  .createPermissionRequest(
                    employeeId: e.id,
                    date: _date,
                    from: _formatTime(_from),
                    to: _formatTime(_to),
                    reason: _reasonController.text.trim(),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared date-picker field used by several tabs above.
// ---------------------------------------------------------------------------
class _DatePickerField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DatePickerField({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'التاريخ'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'),
            const Icon(Icons.calendar_today, size: 16, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
