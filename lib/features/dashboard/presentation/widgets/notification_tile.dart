import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const NotificationTile({super.key, required this.notification});

  Color get _dotColor {
    switch (notification.severity) {
      case NotificationSeverity.danger:
        return AppColors.danger;
      case NotificationSeverity.warning:
        return AppColors.warning;
      case NotificationSeverity.info:
        return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notification.message,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
