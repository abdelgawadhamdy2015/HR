import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/employee.dart';
import '../../domain/entities/employee_month_details.dart';
import '../../domain/entities/lateness_entry.dart';
import '../../domain/entities/mission_entry.dart';
import '../../domain/entities/permission_entry.dart';
import '../../domain/usecases/employee_month_params.dart';
import '../../domain/usecases/get_employee_by_id.dart';
import '../../domain/usecases/get_employee_month_details.dart';
import '../../domain/usecases/get_lateness.dart';
import '../../domain/usecases/get_missions.dart';
import '../../domain/usecases/get_permissions.dart';

part 'employee_details_state.dart';

class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  final GetEmployeeById getEmployeeById;
  final GetEmployeeMonthDetails getEmployeeMonthDetails;
  final GetMissions getMissions;
  final GetPermissions getPermissions;
  final GetLateness getLateness;

  final int employeeId;

  EmployeeDetailsCubit({
    required this.employeeId,
    required this.getEmployeeById,
    required this.getEmployeeMonthDetails,
    required this.getMissions,
    required this.getPermissions,
    required this.getLateness,
  }) : super(EmployeeDetailsState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: EmployeeDetailsStatus.loading));

    final employeeResult = await getEmployeeById(employeeId);
    final monthResult = await getEmployeeMonthDetails(
      EmployeeMonthParams(employeeId: employeeId, year: state.year, month: state.month),
    );

    employeeResult.fold(
      (failure) => emit(state.copyWith(
        status: EmployeeDetailsStatus.failure,
        errorMessage: failure.message,
      )),
      (employee) {
        monthResult.fold(
          (failure) => emit(state.copyWith(
            status: EmployeeDetailsStatus.failure,
            errorMessage: failure.message,
          )),
          (details) => emit(state.copyWith(
            status: EmployeeDetailsStatus.success,
            employee: employee,
            monthDetails: details,
          )),
        );
      },
    );

    // Preload the currently active tab's data.
    await _loadTabData(state.activeTab);
  }

  Future<void> changeMonth(int delta) async {
    var newMonth = state.month + delta;
    var newYear = state.year;
    if (newMonth < 1) {
      newMonth = 12;
      newYear -= 1;
    } else if (newMonth > 12) {
      newMonth = 1;
      newYear += 1;
    }
    emit(state.copyWith(
      year: newYear,
      month: newMonth,
      status: EmployeeDetailsStatus.loading,
      missions: const [],
      permissions: const [],
      lateness: const [],
    ));

    final monthResult = await getEmployeeMonthDetails(
      EmployeeMonthParams(employeeId: employeeId, year: newYear, month: newMonth),
    );
    monthResult.fold(
      (failure) => emit(state.copyWith(
        status: EmployeeDetailsStatus.failure,
        errorMessage: failure.message,
      )),
      (details) => emit(state.copyWith(
        status: EmployeeDetailsStatus.success,
        monthDetails: details,
      )),
    );
    await _loadTabData(state.activeTab);
  }

  Future<void> selectTab(EmployeeDetailsTab tab) async {
    emit(state.copyWith(activeTab: tab));
    await _loadTabData(tab);
  }

  Future<void> _loadTabData(EmployeeDetailsTab tab) async {
    final params = EmployeeMonthParams(employeeId: employeeId, year: state.year, month: state.month);
    switch (tab) {
      case EmployeeDetailsTab.details:
        return; // already loaded via monthDetails
      case EmployeeDetailsTab.lateness:
        if (state.lateness.isNotEmpty) return;
        final result = await getLateness(params);
        result.fold((_) {}, (data) => emit(state.copyWith(lateness: data)));
        return;
      case EmployeeDetailsTab.permissions:
        if (state.permissions.isNotEmpty) return;
        final result = await getPermissions(params);
        result.fold((_) {}, (data) => emit(state.copyWith(permissions: data)));
        return;
      case EmployeeDetailsTab.missions:
        if (state.missions.isNotEmpty) return;
        final result = await getMissions(params);
        result.fold((_) {}, (data) => emit(state.copyWith(missions: data)));
        return;
    }
  }

  Future<void> refresh() => load();
}
