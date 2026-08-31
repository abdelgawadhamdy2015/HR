import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../domain/entities/day_status.dart';
import '../../domain/entities/employee_month_details.dart';
import '../utils/day_status_style.dart';
import 'day_cell.dart';

/// Renders a Saturday-first month grid, matching the Arabic calendar screen.
class MonthCalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final EmployeeMonthDetails details;

  const MonthCalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.details,
  });

  /// Saturday=0 ... Friday=6
  int _columnIndex(DateTime date) => (date.weekday + 1) % 7;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDay = DateTime(year, month, 1);
    final leadingEmpty = _columnIndex(firstDay);
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: ArabicDateFormatter.weekDaysSatFirst
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        for (int r = 0; r < rows; r++)
          Row(
            children: List.generate(7, (c) {
              final cellIndex = r * 7 + c;
              final day = cellIndex - leadingEmpty + 1;
              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox(height: 44));
              }
              final date = DateTime(year, month, day);
              final status = details.statusFor(date);
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              return Expanded(
                child: DayCell(day: day, status: status, isToday: isToday),
              );
            }),
          ),
      ],
    );
  }
}

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  static const _items = [
    DayStatus.present,
    DayStatus.annualLeave,
    DayStatus.sickLeave,
    DayStatus.permission,
    DayStatus.mission,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 8,
      children: _items
          .map((s) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(s.legendLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ))
          .toList(),
    );
  }
}
