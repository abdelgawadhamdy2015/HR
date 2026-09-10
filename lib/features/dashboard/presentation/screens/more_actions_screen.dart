import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class MoreActionsScreen extends StatelessWidget {
  const MoreActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = sl<AuthCubit>();
    final user = auth.state.currentUser;
    bool can(String permission) {
      if (user?.hasPermission(permission) == true) return true;
      if (!permission.endsWith('.View')) return false;
      final base = permission.substring(0, permission.length - 5);
      return user?.hasPermission('$base.Manage') == true || user?.hasPermission('$base.Edit') == true;
    }
    final canManagePermissions = user?.hasPermission('Permissions.Manage') == true;

    final actions = <Widget>[
      if (can('Employees.View')) _Action(icon: Icons.groups_outlined, title: 'الموظفون', onTap: () => context.push(AppRoutes.employees)),
      if (can('Attendance.Manage')) _Action(icon: Icons.fingerprint, title: 'إجراءات الحضور', onTap: () => context.push(AppRoutes.attendanceActions)),
      if (can('Reports.View')) _Action(icon: Icons.assignment_outlined, title: 'تقارير الحضور', onTap: () => context.push(AppRoutes.attendanceReports)),
      if (can('Permissions.View')) _Action(icon: Icons.admin_panel_settings_outlined, title: canManagePermissions ? 'إدارة الصلاحيات' : 'عرض الصلاحيات', onTap: () => context.push(AppRoutes.permissions)),
      if (can('Notifications.View')) _Action(icon: Icons.notifications_none, title: 'الإشعارات', onTap: () => context.push(AppRoutes.notifications)),
      if (can('AuditLogs.View')) _Action(icon: Icons.history, title: 'سجل العمليات', onTap: () => context.push(AppRoutes.auditLogs)),
    ];

    return Scaffold(
      appBar: const AppTopBar(title: 'المزيد'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(user?.username ?? ''), subtitle: Text(user?.email ?? ''))),
          const SizedBox(height: 12),
          if (actions.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد إجراءات متاحة لحسابك.', textAlign: TextAlign.center))),
          ...actions,
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('تسجيل الخروج'),
              subtitle: const Text('مسح الجلسة والعودة إلى شاشة تسجيل الدخول'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('تسجيل الخروج'),
                    content: const Text('هل تريد تسجيل الخروج؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
                      ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('خروج')),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) await auth.logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: AppColors.gold), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
