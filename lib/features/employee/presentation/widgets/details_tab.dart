import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/employee_month_details.dart';

class DetailsTab extends StatelessWidget {
  final EmployeeMonthDetails details;
  const DetailsTab({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final rows = <_DetailRowData>[
      _DetailRowData('إجمالي أيام الحضور', '${details.totalPresentDays} يوم', Icons.event_available, AppColors.blue),
      _DetailRowData('إجازة اعتيادية', '${details.annualLeaveDays} يوم', Icons.beach_access, AppColors.green),
      _DetailRowData('إجازة عارضة', '${details.casualLeaveDays} يوم', Icons.beach_access, AppColors.casualLeave),
      _DetailRowData('إجازة مرضية', '${details.sickLeaveDays} يوم', Icons.medical_services, AppColors.sickLeave),
      _DetailRowData('انقطاعات', '${details.cutOffDays} يوم', Icons.report_gmailerrorred, AppColors.cutOff),
      _DetailRowData(
        'أذونات مستخدمة',
        '${details.permissionsUsed} / ${details.permissionsAllowed} إذن',
        Icons.assignment_outlined,
        AppColors.permission,
      ),
      _DetailRowData('إجمالي التأخير', '${details.totalLateMinutes} دقيقة', Icons.access_time, AppColors.pink),
    ];

    return Column(
      children: rows.map((r) => _DetailRow(data: r)).toList(),
    );
  }
}

class _DetailRowData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _DetailRowData(this.label, this.value, this.icon, this.color);
}

class _DetailRow extends StatelessWidget {
  final _DetailRowData data;
  const _DetailRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: data.color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(data.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ),
          Text(data.value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
