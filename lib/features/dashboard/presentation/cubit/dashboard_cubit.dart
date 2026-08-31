import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_notifications.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardStats getDashboardStats;
  final GetNotifications getNotifications;

  DashboardCubit({
    required this.getDashboardStats,
    required this.getNotifications,
  }) : super(DashboardState.initial());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    final statsResult = await getDashboardStats(state.selectedDate);
    final notificationsResult = await getNotifications(const NoParams());

    statsResult.fold(
      (failure) => emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: failure.message,
      )),
      (stats) {
        notificationsResult.fold(
          (failure) => emit(state.copyWith(
            status: DashboardStatus.success,
            stats: stats,
            notifications: const [],
          )),
          (notifications) => emit(state.copyWith(
            status: DashboardStatus.success,
            stats: stats,
            notifications: notifications,
          )),
        );
      },
    );
  }

  Future<void> changeDate(DateTime date) async {
    emit(state.copyWith(selectedDate: date));
    await loadDashboard();
  }

  Future<void> refresh() => loadDashboard();
}
