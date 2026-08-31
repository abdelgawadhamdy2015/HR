part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardStats? stats;
  final List<AppNotification> notifications;
  final DateTime selectedDate;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.stats,
    this.notifications = const [],
    required this.selectedDate,
    this.errorMessage,
  });

  factory DashboardState.initial() => DashboardState(selectedDate: DateTime.now());

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardStats? stats,
    List<AppNotification>? notifications,
    DateTime? selectedDate,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      notifications: notifications ?? this.notifications,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, notifications, selectedDate, errorMessage];
}
