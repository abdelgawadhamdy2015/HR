import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/models/attendance_report_models.dart';
import '../../../employee/domain/entities/day_status.dart';
import '../cubit/attendance_reports_cubit.dart';
import '../cubit/attendance_reports_state.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({super.key});
  @override
  State<AttendanceReportsScreen> createState() => _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  late DateTime _from;
  late DateTime _to;
  DayStatus? _status;
  bool _lateOnly = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = DateTime(now.year, now.month + 1, 0);
  }

  AttendanceReportRequestModel get _request => AttendanceReportRequestModel(
        fromDate: _from,
        toDate: _to,
        status: _status,
        lateOnly: _lateOnly ? true : null,
      );

  void _load() => context.read<AttendanceReportsCubit>().loadReport(_request);

  Future<void> _printPdf() async {
    final bytes = await context.read<AttendanceReportsCubit>().loadPdf(_request);
    if (!mounted || bytes == null || bytes.isEmpty) return;
    await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AttendanceReportsCubit>()..loadReport(_request),
      child: Builder(builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('تقارير الحضور والانصراف'),
          actions: [IconButton(tooltip: 'طباعة PDF', icon: const Icon(Icons.picture_as_pdf), onPressed: _printPdf)],
        ),
        body: Column(children: [
          _Filters(from: _from, to: _to, status: _status, lateOnly: _lateOnly,
            onFromChanged: (v) => setState(() => _from = v),
            onToChanged: (v) => setState(() => _to = v),
            onStatusChanged: (v) => setState(() => _status = v),
            onLateChanged: (v) => setState(() => _lateOnly = v), onSearch: _load),
          Expanded(child: BlocBuilder<AttendanceReportsCubit, AttendanceReportsState>(builder: (context, state) {
            if (state is AttendanceReportsLoading) return const Center(child: CircularProgressIndicator());
            if (state is AttendanceReportsError) return Center(child: Text(state.message));
            if (state is AttendanceReportsLoaded) return _ReportBody(report: state.report);
            return const SizedBox.shrink();
          })),
        ]),
      )),
    );
  }
}

class _Filters extends StatelessWidget {
  final DateTime from, to;
  final DayStatus? status;
  final bool lateOnly;
  final ValueChanged<DateTime> onFromChanged, onToChanged;
  final ValueChanged<DayStatus?> onStatusChanged;
  final ValueChanged<bool> onLateChanged;
  final VoidCallback onSearch;
  const _Filters({required this.from, required this.to, required this.status, required this.lateOnly, required this.onFromChanged, required this.onToChanged, required this.onStatusChanged, required this.onLateChanged, required this.onSearch});

  Future<void> _pick(BuildContext context, DateTime initial, ValueChanged<DateTime> onChanged) async {
    final value = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (value != null) onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd');
    return Card(margin: const EdgeInsets.all(12), child: Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      OutlinedButton.icon(onPressed: () => _pick(context, from, onFromChanged), icon: const Icon(Icons.calendar_month), label: Text('من ${format.format(from)}')),
      OutlinedButton.icon(onPressed: () => _pick(context, to, onToChanged), icon: const Icon(Icons.calendar_month), label: Text('إلى ${format.format(to)}')),
      DropdownButton<DayStatus?>(value: status, hint: const Text('الحالة'), items: [const DropdownMenuItem(value: null, child: Text('كل الحالات')), ...DayStatus.values.where((e) => e != DayStatus.none).map((e) => DropdownMenuItem(value: e, child: Text(e.legendLabel)))], onChanged: onStatusChanged),
      FilterChip(label: const Text('المتأخرون فقط'), selected: lateOnly, onSelected: onLateChanged),
      FilledButton.icon(onPressed: onSearch, icon: const Icon(Icons.search), label: const Text('بحث')),
    ])));
  }
}

class _ReportBody extends StatelessWidget {
  final AttendanceReportModel report;
  const _ReportBody({required this.report});
  String _minutes(int value) => '${value ~/ 60}:${(value % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 24), children: [
    Wrap(spacing: 10, runSpacing: 10, children: [
      _Stat('الموظفون', '${report.employeeCount}'), _Stat('السجلات', '${report.totalRecords}'), _Stat('حضور', '${report.presentDays}'),
      _Stat('غياب', '${report.absentDays}'), _Stat('أيام التأخير', '${report.lateDays}'), _Stat('دقائق التأخير', '${report.totalLateMinutes}'),
    ]),
    const SizedBox(height: 12),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns: const [DataColumn(label: Text('الموظف')), DataColumn(label: Text('القسم')), DataColumn(label: Text('حضور')), DataColumn(label: Text('غياب')), DataColumn(label: Text('تأخير')), DataColumn(label: Text('دقائق')), DataColumn(label: Text('ساعات العمل'))],
      rows: report.employees.map((e) => DataRow(cells: [DataCell(Text('${e.fullName}\n${e.code}')), DataCell(Text(e.department)), DataCell(Text('${e.presentDays}')), DataCell(Text('${e.absentDays}')), DataCell(Text('${e.lateDays}')), DataCell(Text('${e.totalLateMinutes}')), DataCell(Text(_minutes(e.totalWorkedMinutes)))])).toList(),
    )))
  ]);
}

class _Stat extends StatelessWidget {
  final String title, value;
  const _Stat(this.title, this.value);
  @override
  Widget build(BuildContext context) => SizedBox(width: 150, child: Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), const SizedBox(height: 5), Text(value, style: Theme.of(context).textTheme.headlineSmall)]))));
}
