import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/day_status.dart';
import '../utils/day_status_style.dart';

class DayCell extends StatelessWidget {
  final int day;
  final DayStatus status;
  final bool isToday;

  const DayCell({
    super.key,
    required this.day,
    required this.status,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = status.shortLabel;

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$day',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: status == DayStatus.none ? AppColors.textPrimary : AppColors.textPrimary,
          ),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: status.color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          )
        else if (status.isDot)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
            ),
          ),
      ],
    );

    if (isToday) {
      content = Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gold, width: 1.6),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: content,
    );
  }
}
