import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../domain/entities/lateness_entry.dart';

class LatenessTab extends StatelessWidget {
  final List<LatenessEntry> items;
  const LatenessTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(message: 'لا يوجد تأخيرات هذا الشهر');
    }
    return Column(
      children: items
          .map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: AppColors.pink),
                title: Text(ArabicDateFormatter.full(e.date), style: const TextStyle(fontSize: 13.5)),
                trailing: Text('${e.minutes} دقيقة', style: const TextStyle(color: AppColors.textSecondary)),
              ))
          .toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: Text(message, style: const TextStyle(color: AppColors.textMuted))),
    );
  }
}
