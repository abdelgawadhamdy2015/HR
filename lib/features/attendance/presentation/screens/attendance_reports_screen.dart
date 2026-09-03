import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_attendance_app/core/utils/usecase.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../employee/domain/entities/day_status.dart';
import '../../../employee/domain/entities/employee.dart';
import '../../../employee/domain/usecases/get_employees.dart';
import '../../data/models/attendance_report_models.dart';
import '../cubit/attendance_reports_cubit.dart';
import '../cubit/attendance_reports_state.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({super.key});

  @override
  State<AttendanceReportsScreen> createState() =>
      _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  late DateTime _from;
  late DateTime _to;
  DayStatus? _status;
  bool _lateOnly = false;
  int? _employeeId;
  String? _department;
  late Future<List<Employee>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = DateTime(now.year, now.month + 1, 0);
    _employeesFuture = _loadEmployees();
  }

  Future<List<Employee>> _loadEmployees() async {
    final result = await sl<GetEmployees>()(const NoParams());
    return result.fold((_) => <Employee>[], (employees) => employees);
  }

  AttendanceReportRequestModel get _request => AttendanceReportRequestModel(
        fromDate: _from,
        toDate: _to,
        employeeId: _employeeId,
        department: _department,
        status: _status,
        lateOnly: _lateOnly ? true : null,
      );

  void _load() {
    if (_from.isAfter(_to)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تاريخ البداية يجب أن يكون قبل تاريخ النهاية')),
      );
      return;
    }
    sl<AttendanceReportsCubit>().loadReport(_request);
  }

  Future<void> _printPdf() async {
    final bytes = await sl<AttendanceReportsCubit>().loadPdf(_request);
    if (!mounted || bytes == null || bytes.isEmpty) return;
    await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
  }

  Future<void> _showActions() async {
    await sl<AttendanceReportsCubit>().loadActions(_request);
    if (!mounted) return;
    final state = sl<AttendanceReportsCubit>().state;
    if (state is AttendanceReportsActionsLoaded) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ActionsSheet(actions: state.actions),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AttendanceReportsCubit>()..loadReport(_request),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('تقارير الحضور والانصراف'),
            actions: [
              IconButton(
                tooltip: 'الإجراءات',
                icon: const Icon(Icons.list_alt),
                onPressed: _showActions,
              ),
              IconButton(
                tooltip: 'طباعة PDF',
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: _printPdf,
              ),
            ],
          ),
          body: Column(
            children: [
              FutureBuilder<List<Employee>>(
                future: _employeesFuture,
                builder: (context, snapshot) => _Filters(
                  from: _from,
                  to: _to,
                  status: _status,
                  lateOnly: _lateOnly,
                  employeeId: _employeeId,
                  department: _department,
                  employees: snapshot.data ?? const [],
                  employeesLoading:
                      snapshot.connectionState == ConnectionState.waiting,
                  onFromChanged: (value) => setState(() => _from = value),
                  onToChanged: (value) => setState(() => _to = value),
                  onStatusChanged: (value) => setState(() => _status = value),
                  onLateChanged: (value) => setState(() => _lateOnly = value),
                  onEmployeeChanged: (value) {
                    final employee = (snapshot.data ?? const <Employee>[])
                        .where((item) => item.id == value)
                        .firstOrNull;
                    setState(() {
                      _employeeId = value;
                      _department = employee?.department;
                    });
                  },
                  onSearch: _load,
                  onReloadEmployees: () =>
                      setState(() => _employeesFuture = _loadEmployees()),
                ),
              ),
              Expanded(
                child:
                    BlocBuilder<AttendanceReportsCubit, AttendanceReportsState>(
                  builder: (context, state) {
                    if (state is AttendanceReportsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AttendanceReportsError) {
                      return _ErrorView(message: state.message, onRetry: _load);
                    }
                    if (state is AttendanceReportsLoaded) {
                      return _ReportBody(report: state.report);
                    }
                    return const Center(child: Text('لا توجد بيانات'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final DateTime from, to;
  final DayStatus? status;
  final bool lateOnly;
  final int? employeeId;
  final String? department;
  final List<Employee> employees;
  final bool employeesLoading;
  final ValueChanged<DateTime> onFromChanged, onToChanged;
  final ValueChanged<DayStatus?> onStatusChanged;
  final ValueChanged<bool> onLateChanged;
  final ValueChanged<int?> onEmployeeChanged;
  final VoidCallback onSearch, onReloadEmployees;

  const _Filters({
    required this.from,
    required this.to,
    required this.status,
    required this.lateOnly,
    required this.employeeId,
    required this.department,
    required this.employees,
    required this.employeesLoading,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onStatusChanged,
    required this.onLateChanged,
    required this.onEmployeeChanged,
    required this.onSearch,
    required this.onReloadEmployees,
  });

  Future<void> _pick(BuildContext context, DateTime initial,
      ValueChanged<DateTime> changed) async {
    final value = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (value != null) changed(value);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd');
    final departments = employees
        .map((e) => e.department)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pick(context, from, onFromChanged),
              icon: const Icon(Icons.calendar_month),
              label: Text('من ${formatter.format(from)}'),
            ),
            OutlinedButton.icon(
              onPressed: () => _pick(context, to, onToChanged),
              icon: const Icon(Icons.calendar_month),
              label: Text('إلى ${formatter.format(to)}'),
            ),
            SizedBox(
              width: 230,
              child: DropdownButtonFormField<int?>(
                value: employeeId,
                decoration: const InputDecoration(
                    labelText: 'الموظف', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('كل الموظفين')),
                  ...employees.map((e) => DropdownMenuItem<int?>(
                      value: e.id, child: Text('${e.fullName} (${e.code})'))),
                ],
                onChanged: employeesLoading ? null : onEmployeeChanged,
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String?>(
                value: department,
                decoration: const InputDecoration(
                    labelText: 'القسم', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('كل الأقسام')),
                  ...departments.map((e) =>
                      DropdownMenuItem<String?>(value: e, child: Text(e))),
                ],
                onChanged: (value) {
                  // Department is deliberately derived from the selected employee.
                  // This callback is handled by the parent only through employee selection.
                },
              ),
            ),
            DropdownButton<DayStatus?>(
              value: status,
              hint: const Text('الحالة'),
              items: [
                const DropdownMenuItem<DayStatus?>(
                    value: null, child: Text('كل الحالات')),
                ...DayStatus.values.where((e) => e != DayStatus.none).map(
                      (e) => DropdownMenuItem<DayStatus?>(
                          value: e, child: Text(e.legendLabel)),
                    ),
              ],
              onChanged: onStatusChanged,
            ),
            FilterChip(
                label: const Text('المتأخرون فقط'),
                selected: lateOnly,
                onSelected: onLateChanged),
            FilledButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search),
                label: const Text('بحث')),
            IconButton(
                tooltip: 'إعادة تحميل الموظفين',
                onPressed: onReloadEmployees,
                icon: const Icon(Icons.refresh)),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  final AttendanceReportModel report;
  const _ReportBody({required this.report});

  String _minutes(int value) =>
      '${value ~/ 60}:${(value % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (report.employees.isEmpty) {
      return const Center(child: Text('لا توجد سجلات في الفترة المحددة'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Stat('الموظفون', '${report.employeeCount}'),
            _Stat('أيام العمل', '${report.workingDays}'),
            _Stat('السجلات', '${report.totalRecords}'),
            _Stat('حضور', '${report.presentDays}'),
            _Stat('غياب', '${report.absentDays}'),
            _Stat('أيام التأخير', '${report.lateDays}'),
            _Stat('دقائق التأخير', '${report.totalLateMinutes}'),
            _Stat('إجمالي العمل', _minutes(report.totalWorkedMinutes)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('الموظف')),
                DataColumn(label: Text('القسم')),
                DataColumn(label: Text('حضور')),
                DataColumn(label: Text('غياب')),
                DataColumn(label: Text('تأخير')),
                DataColumn(label: Text('دقائق')),
                DataColumn(label: Text('ساعات العمل')),
              ],
              rows: report.employees.map((employee) {
                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => _showEmployee(context, employee),
                        child: Text('${employee.fullName}\n${employee.code}'),
                      ),
                    ),
                    DataCell(Text(employee.department)),
                    DataCell(Text('${employee.presentDays}')),
                    DataCell(Text('${employee.absentDays}')),
                    DataCell(Text('${employee.lateDays}')),
                    DataCell(Text('${employee.totalLateMinutes}')),
                    DataCell(Text(_minutes(employee.totalWorkedMinutes))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showEmployee(
      BuildContext context, EmployeeAttendanceReportModel employee) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EmployeeDetailsSheet(employee: employee),
    );
  }
}

class _EmployeeDetailsSheet extends StatelessWidget {
  final EmployeeAttendanceReportModel employee;
  const _EmployeeDetailsSheet({required this.employee});

  String _time(String? value) => value == null || value.isEmpty
      ? '-'
      : value.length >= 5
          ? value.substring(0, 5)
          : value;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .75,
      maxChildSize: .95,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          controller: controller,
          itemCount: employee.days.length + 1,
          itemBuilder: (_, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(employee.fullName,
                    style: Theme.of(context).textTheme.titleLarge),
              );
            }
            final day = employee.days[index - 1];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${day.date.day}')),
                title: Text(DateFormat('yyyy-MM-dd').format(day.date)),
                subtitle: Text(
                    '${day.status.legendLabel}  •  دخول ${_time(day.checkIn)}  •  خروج ${_time(day.checkOut)}'),
                trailing: Text('تأخير ${day.lateMinutes} د'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionsSheet extends StatelessWidget {
  final List<AttendanceActionReportModel> actions;
  const _ActionsSheet({required this.actions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: actions.isEmpty
            ? const Center(child: Text('لا توجد إجراءات في الفترة المحددة'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: actions.length,
                itemBuilder: (_, index) {
                  final action = actions[index];
                  return ListTile(
                    leading: const Icon(Icons.event_note),
                    title: Text(action.employeeName),
                    subtitle: Text(
                        '${DateFormat('yyyy-MM-dd').format(action.date)} • ${action.actionType}${action.details == null ? '' : '\n${action.details}'}'),
                    trailing: Text(action.time ?? ''),
                  );
                },
              ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title, value;
  const _Stat(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 5),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
