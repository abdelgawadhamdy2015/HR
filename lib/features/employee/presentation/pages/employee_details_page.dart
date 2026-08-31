import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../cubit/employee_details_cubit.dart';
import '../widgets/details_tab.dart';
import '../widgets/details_tab_selector.dart';
import '../widgets/lateness_tab.dart';
import '../widgets/missions_tab.dart';
import '../widgets/month_calendar_grid.dart';
import '../widgets/permissions_tab.dart';

class EmployeeDetailsPage extends StatelessWidget {
  final int employeeId;
  const EmployeeDetailsPage({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EmployeeDetailsCubit>(param1: employeeId)..load(),
      child: const _EmployeeDetailsView(),
    );
  }
}

class _EmployeeDetailsView extends StatelessWidget {
  const _EmployeeDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'بيانات الموظف'),
      body: BlocBuilder<EmployeeDetailsCubit, EmployeeDetailsState>(
        builder: (context, state) {
          if (state.status == EmployeeDetailsStatus.initial ||
              (state.status == EmployeeDetailsStatus.loading && state.employee == null)) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }
          if (state.status == EmployeeDetailsStatus.failure && state.employee == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'حدث خطأ', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<EmployeeDetailsCubit>().refresh(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final employee = state.employee!;
          final details = state.monthDetails;

          return RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.surface,
            onRefresh: () => context.read<EmployeeDetailsCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.surfaceLight,
                          child: Icon(Icons.person, size: 32, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      employee.fullName,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.gold),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(employee.code, style: const TextStyle(fontSize: 11, color: AppColors.gold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(employee.jobTitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                              Text(employee.department, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Calendar card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: AppColors.gold),
                              onPressed: () => context.read<EmployeeDetailsCubit>().changeMonth(-1),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ArabicDateFormatter.monthYear(DateTime(state.year, state.month)),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.calendar_today, size: 14, color: AppColors.gold),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: AppColors.gold),
                              onPressed: () => context.read<EmployeeDetailsCubit>().changeMonth(1),
                            ),
                          ],
                        ),
                        if (details == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(color: AppColors.gold),
                          )
                        else ...[
                          MonthCalendarGrid(year: state.year, month: state.month, details: details),
                          const SizedBox(height: 12),
                          const CalendarLegend(),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tabs card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DetailsTabSelector(
                          activeTab: state.activeTab,
                          missionsCount: state.missions.length,
                          permissionsCount: state.permissions.length,
                          onSelect: (tab) => context.read<EmployeeDetailsCubit>().selectTab(tab),
                        ),
                        const Divider(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _TabBody(state: state, details: details),
                        ),
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
      bottomNavigationBar: AppBottomNav(currentIndex: 3, onTap: (_) {}),
    );
  }
}

class _TabBody extends StatelessWidget {
  final EmployeeDetailsState state;
  final dynamic details;
  const _TabBody({required this.state, required this.details});

  @override
  Widget build(BuildContext context) {
    switch (state.activeTab) {
      case EmployeeDetailsTab.details:
        if (details == null) return const SizedBox.shrink();
        return DetailsTab(details: details);
      case EmployeeDetailsTab.lateness:
        return LatenessTab(items: state.lateness);
      case EmployeeDetailsTab.permissions:
        return PermissionsTab(items: state.permissions);
      case EmployeeDetailsTab.missions:
        return MissionsTab(items: state.missions);
    }
  }
}
