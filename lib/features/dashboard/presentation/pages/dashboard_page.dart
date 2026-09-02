import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_attendance_app/core/router/app_routes.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/notification_tile.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  void _openAttendanceActions(BuildContext context, int tab) {
    context.push('${AppRoutes.attendanceActions}?tab=$tab');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'شؤون العاملين'),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading || state.status == DashboardStatus.initial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }
          if (state.status == DashboardStatus.failure) {
            return _ErrorView(
              message: state.errorMessage ?? 'حدث خطأ',
              onRetry: () => context.read<DashboardCubit>().refresh(),
            );
          }

          final stats = state.stats!;
          return RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.surface,
            onRefresh: () => context.read<DashboardCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('لوحة التحكم', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _DatePickerChip(
                  date: state.selectedDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && context.mounted) context.read<DashboardCubit>().changeDate(picked);
                  },
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                  children: [
                    StatCard(icon: Icons.groups, iconColor: AppColors.violet, value: '${stats.totalEmployees}', label: 'إجمالي الموظفين'),
                    StatCard(icon: Icons.check_circle, iconColor: AppColors.green, value: '${stats.presentToday}', label: 'حاضر اليوم'),
                    StatCard(icon: Icons.access_time_filled, iconColor: AppColors.pink, value: '${stats.lateToday}', label: 'متأخر اليوم'),
                    StatCard(icon: Icons.flight_takeoff, iconColor: AppColors.blue, value: '${stats.onMission}', label: 'في مأمورية'),
                    StatCard(icon: Icons.bed, iconColor: AppColors.amber, value: '${stats.onLeave}', label: 'في إجازة'),
                    StatCard(icon: Icons.badge, iconColor: AppColors.slate, value: '${stats.absentToday}', label: 'غياب اليوم'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('المهام السريعة', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    QuickActionButton(icon: Icons.groups_outlined, iconColor: AppColors.gold, label: 'قائمة الموظفين', onTap: () => context.push(AppRoutes.employees)),
                    QuickActionButton(icon: Icons.fingerprint, iconColor: AppColors.gold, label: 'تسجيل حضور', onTap: () => _openAttendanceActions(context, 0)),
                    QuickActionButton(icon: Icons.access_time, iconColor: AppColors.gold, label: 'التأخيرات', onTap: () => _openAttendanceActions(context, 2)),
                    QuickActionButton(icon: Icons.beach_access, iconColor: AppColors.gold, label: 'الإجازات', onTap: () => _openAttendanceActions(context, 1)),
                    QuickActionButton(icon: Icons.edit_note, iconColor: AppColors.gold, label: 'الإذن', onTap: () => _openAttendanceActions(context, 4)),
                    QuickActionButton(icon: Icons.flight, iconColor: AppColors.gold, label: 'المأموريات', onTap: () => _openAttendanceActions(context, 3)),
                    QuickActionButton(icon: Icons.assignment_outlined, iconColor: AppColors.gold, label: 'تقارير الحضور', onTap: () => context.push(AppRoutes.attendanceReports)),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('تنبيهات', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const Divider(height: 24),
                        if (state.notifications.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('لا توجد تنبيهات حالياً', style: TextStyle(color: AppColors.textMuted)),
                          )
                        else
                          ...state.notifications.map((n) => NotificationTile(notification: n)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.push(AppRoutes.attendanceReports);
          if (i == 3) context.push(AppRoutes.employees);
        },
      ),
    );
  }
}

class _DatePickerChip extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DatePickerChip({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ArabicDateFormatter.full(date), style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 15, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
