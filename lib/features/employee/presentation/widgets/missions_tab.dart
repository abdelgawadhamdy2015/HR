import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../domain/entities/mission_entry.dart';

class MissionsTab extends StatelessWidget {
  final List<MissionEntry> items;
  const MissionsTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('لا توجد مأموريات هذا الشهر', style: TextStyle(color: AppColors.textMuted))),
      );
    }
    return Column(
      children: items
          .map((e) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: AppColors.surfaceLight,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.flight_takeoff, color: AppColors.mission),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ArabicDateFormatter.full(e.date), style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(e.reason, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      Text(e.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
