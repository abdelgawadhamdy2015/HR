import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import 'attendance_reports_screen.dart';

/// Hosts the attendance reports feature inside the application's Reports tab.
class AttendanceReportsTabScreen extends StatelessWidget {
  const AttendanceReportsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(child: AttendanceReportsScreen()),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 2) {
            context.go(AppRoutes.home);
          } else if (index == 3) {
            context.push(AppRoutes.employees);
          }
        },
      ),
    );
  }
}
