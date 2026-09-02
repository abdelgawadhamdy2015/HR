import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_attendance_app/core/router/app_routes.dart';
import '../theme/app_colors.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: InkWell(
        onTap: () {
          context.pushReplacement(AppRoutes.home);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold, width: 1.2),
            ),
            child: const Icon(Icons.shield_outlined,
                color: AppColors.gold, size: 20),
          ),
        ),
      ),
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: AppColors.gold),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
