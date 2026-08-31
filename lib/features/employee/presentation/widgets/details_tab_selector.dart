import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/employee_details_cubit.dart';

class DetailsTabSelector extends StatelessWidget {
  final EmployeeDetailsTab activeTab;
  final int missionsCount;
  final int permissionsCount;
  final ValueChanged<EmployeeDetailsTab> onSelect;

  const DetailsTabSelector({
    super.key,
    required this.activeTab,
    required this.missionsCount,
    required this.permissionsCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = <(EmployeeDetailsTab, String)>[
      (EmployeeDetailsTab.missions, 'المأموريات${missionsCount > 0 ? ' ($missionsCount)' : ''}'),
      (EmployeeDetailsTab.permissions, 'الإذن${permissionsCount > 0 ? ' ($permissionsCount)' : ''}'),
      (EmployeeDetailsTab.lateness, 'التأخيرات'),
      (EmployeeDetailsTab.details, 'التفاصيل'),
    ];

    return Row(
      children: tabs
          .map((t) => Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(t.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: activeTab == t.$1 ? AppColors.gold : Colors.transparent,
                          width: 2.4,
                        ),
                      ),
                    ),
                    child: Text(
                      t.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: activeTab == t.$1 ? FontWeight.w700 : FontWeight.w400,
                        color: activeTab == t.$1 ? AppColors.gold : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
