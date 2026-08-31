import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.message,
    required super.severity,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as int,
      message: json['message'] as String,
      severity: AppNotification.severityFromString(json['severity'] as String),
    );
  }
}
