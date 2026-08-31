part of 'employee_details_cubit.dart';

enum EmployeeDetailsStatus { initial, loading, success, failure }
enum EmployeeDetailsTab { details, lateness, permissions, missions }

class EmployeeDetailsState extends Equatable {
  final EmployeeDetailsStatus status;
  final Employee? employee;
  final EmployeeMonthDetails? monthDetails;
  final List<MissionEntry> missions;
  final List<PermissionEntry> permissions;
  final List<LatenessEntry> lateness;
  final int year;
  final int month;
  final EmployeeDetailsTab activeTab;
  final String? errorMessage;

  const EmployeeDetailsState({
    this.status = EmployeeDetailsStatus.initial,
    this.employee,
    this.monthDetails,
    this.missions = const [],
    this.permissions = const [],
    this.lateness = const [],
    required this.year,
    required this.month,
    this.activeTab = EmployeeDetailsTab.details,
    this.errorMessage,
  });

  factory EmployeeDetailsState.initial() {
    final now = DateTime.now();
    return EmployeeDetailsState(year: now.year, month: now.month);
  }

  EmployeeDetailsState copyWith({
    EmployeeDetailsStatus? status,
    Employee? employee,
    EmployeeMonthDetails? monthDetails,
    List<MissionEntry>? missions,
    List<PermissionEntry>? permissions,
    List<LatenessEntry>? lateness,
    int? year,
    int? month,
    EmployeeDetailsTab? activeTab,
    String? errorMessage,
  }) {
    return EmployeeDetailsState(
      status: status ?? this.status,
      employee: employee ?? this.employee,
      monthDetails: monthDetails ?? this.monthDetails,
      missions: missions ?? this.missions,
      permissions: permissions ?? this.permissions,
      lateness: lateness ?? this.lateness,
      year: year ?? this.year,
      month: month ?? this.month,
      activeTab: activeTab ?? this.activeTab,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        employee,
        monthDetails,
        missions,
        permissions,
        lateness,
        year,
        month,
        activeTab,
        errorMessage,
      ];
}
