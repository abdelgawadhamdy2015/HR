import 'package:equatable/equatable.dart';

enum NotificationSeverity { info, warning, danger }

class AppNotification extends Equatable {
  final int id;
  final String message;
  final NotificationSeverity severity;

  const AppNotification({
    required this.id,
    required this.message,
    required this.severity,
  });

  static NotificationSeverity severityFromString(String value) {
    switch (value) {
      case 'warning':
        return NotificationSeverity.warning;
      case 'danger':
        return NotificationSeverity.danger;
      default:
        return NotificationSeverity.info;
    }
  }

  @override
  List<Object?> get props => [id, message, severity];
}
