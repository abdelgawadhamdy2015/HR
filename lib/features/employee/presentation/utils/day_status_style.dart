import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/day_status.dart';

/// Maps a domain [DayStatus] to a UI [Color]. Lives in the presentation layer
/// (not on the entity itself) so `domain/` stays free of Flutter imports.
extension DayStatusColor on DayStatus {
  Color get color {
    switch (this) {
      case DayStatus.present:
        return AppColors.present;
      case DayStatus.annualLeave:
        return AppColors.annualLeave;
      case DayStatus.casualLeave:
        return AppColors.casualLeave;
      case DayStatus.sickLeave:
        return AppColors.sickLeave;
      case DayStatus.permission:
        return AppColors.permission;
      case DayStatus.cutOff:
        return AppColors.cutOff;
      case DayStatus.mission:
        return AppColors.mission;
      case DayStatus.none:
        return AppColors.none;
    }
  }
}
