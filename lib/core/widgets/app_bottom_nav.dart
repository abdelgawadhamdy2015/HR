import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'التقارير'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'الإشعارات'),
        BottomNavigationBarItem(icon: _HomeIcon(), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'الموظفون'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'المزيد'),
      ],
    );
  }
}

class _HomeIcon extends StatelessWidget {
  const _HomeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.home, color: AppColors.background, size: 20),
    );
  }
}
