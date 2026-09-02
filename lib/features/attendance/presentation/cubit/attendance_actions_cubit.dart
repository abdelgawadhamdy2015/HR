import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/attendance_action_params.dart';
import '../../domain/usecases/check_in.dart';
import '../../domain/usecases/check_out.dart';
import '../../domain/usecases/create_mission.dart';
import '../../domain/usecases/create_permission_request.dart';
import '../../domain/usecases/mark_attendance_day.dart';
import '../../domain/usecases/record_lateness.dart';

part 'attendance_actions_state.dart';

class AttendanceActionsCubit extends Cubit<AttendanceActionsState> {
  final CheckIn checkInUseCase;
  final CheckOut checkOutUseCase;
  final MarkAttendanceDay markAttendanceDayUseCase;
  final RecordLateness recordLatenessUseCase;
  final CreateMission createMissionUseCase;
  final CreatePermissionRequest createPermissionRequestUseCase;

  AttendanceActionsCubit({
    required this.checkInUseCase,
    required this.checkOutUseCase,
    required this.markAttendanceDayUseCase,
    required this.recordLatenessUseCase,
    required this.createMissionUseCase,
    required this.createPermissionRequestUseCase,
  }) : super(const AttendanceActionsState());

  Future<void> checkIn({required int employeeId, DateTime? date, String? time}) async {
    emit(state.copyWith(status: AttendanceActionStatus.submitting, errorMessage: null));
    final result = await checkInUseCase(CheckInParams(employeeId: employeeId, date: date, time: time));
    result.fold(
      (failure) => emit(state.copyWith(status: AttendanceActionStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AttendanceActionStatus.success, successMessage: 'تم تسجيل الحضور')),
    );
  }

  Future<void> checkOut({required int employeeId, DateTime? date, String? time}) async {
    emit(state.copyWith(status: AttendanceActionStatus.submitting, errorMessage: null));
    final result = await checkOutUseCase(CheckOutParams(employeeId: employeeId, date: date, time: time));
    result.fold(
      (failure) => emit(state.copyWith(status: AttendanceActionStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AttendanceActionStatus.success, successMessage: 'تم تسجيل الانصراف')),
    );
  }

  /// [status] must be one of: present, annualLeave, casualLeave, sickLeave, cutOff, none
  Future<void> markDay({required int employeeId, required DateTime date, required String status}) async {
    emit(state.copyWith(status: AttendanceActionStatus.submitting, errorMessage: null));
    final result = await markAttendanceDayUseCase(
      MarkAttendanceParams(employeeId: employeeId, date: date, status: status),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AttendanceActionStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AttendanceActionStatus.success, successMessage: 'تم تحديث اليوم')),
    );
  }

  Future<void> recordLateness({required int employeeId, required DateTime date, required int minutes}) async {
    emit(state.copyWith(status: AttendanceActionStatus.submitting, errorMessage: null));
    final result = await recordLatenessUseCase(
      RecordLatenessParams(employeeId: employeeId, date: date, minutes: minutes),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AttendanceActionStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AttendanceActionStatus.success, successMessage: 'تم تصحيح التأخير')),
    );
  }

  Future<void> createMission({
    required int employeeId,
    required DateTime date,
    required String reason,
    required String location,
  }) async {
    emit(state.copyWith(status: AttendanceActionStatus.submitting, errorMessage: null));
    final result = await createMissionUseCase(
      CreateMissionParams(employeeId: employeeId, date: date, reason: reason, location: location),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AttendanceActionStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AttendanceActionStatus.success, successMessage: 'تم تسجيل المأمورية')),
    );
  }

  Future<void> createPermissionRequest({
    required int employeeId,
    required DateTime date,
    required String from,
    required String to,
    required String reason,
  }) async {
    emit(state.copyWith(status: AttendanceActionStatus.submitting, errorMessage: null));
    final result = await createPermissionRequestUseCase(
      CreatePermissionRequestParams(employeeId: employeeId, date: date, from: from, to: to, reason: reason),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AttendanceActionStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AttendanceActionStatus.success, successMessage: 'تم تسجيل الإذن')),
    );
  }
}
