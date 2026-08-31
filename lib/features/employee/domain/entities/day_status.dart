enum DayStatus {
  none,
  present,
  annualLeave,
  casualLeave,
  sickLeave,
  permission,
  cutOff,
  mission,
}

extension DayStatusX on DayStatus {
  static DayStatus fromApi(String value) {
    switch (value) {
      case 'present':
        return DayStatus.present;
      case 'annualLeave':
        return DayStatus.annualLeave;
      case 'casualLeave':
        return DayStatus.casualLeave;
      case 'sickLeave':
        return DayStatus.sickLeave;
      case 'permission':
        return DayStatus.permission;
      case 'cutOff':
        return DayStatus.cutOff;
      case 'mission':
        return DayStatus.mission;
      default:
        return DayStatus.none;
    }
  }

  /// Short Arabic label shown inside a calendar cell (e.g. "إذن", "مرضي").
  String get shortLabel {
    switch (this) {
      case DayStatus.present:
        return '';
      case DayStatus.annualLeave:
        return 'إجازة';
      case DayStatus.casualLeave:
        return 'عارضة';
      case DayStatus.sickLeave:
        return 'مرضي';
      case DayStatus.permission:
        return 'إذن';
      case DayStatus.cutOff:
        return 'انقطاع';
      case DayStatus.mission:
        return '';
      case DayStatus.none:
        return '';
    }
  }

  /// Full label used in the legend row.
  String get legendLabel {
    switch (this) {
      case DayStatus.present:
        return 'حاضر';
      case DayStatus.annualLeave:
        return 'إجازة اعتيادية';
      case DayStatus.casualLeave:
        return 'إجازة عارضة';
      case DayStatus.sickLeave:
        return 'إجازة مرضية';
      case DayStatus.permission:
        return 'إذن';
      case DayStatus.cutOff:
        return 'انقطاع';
      case DayStatus.mission:
        return 'مأمورية';
      case DayStatus.none:
        return '';
    }
  }

  bool get isDot => this == DayStatus.present || this == DayStatus.mission;
}
