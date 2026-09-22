import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/attendance_report_models.dart';
import '../../domain/repositories/attendance_reports_repository.dart';
import 'attendance_reports_state.dart';

class AttendanceReportsCubit extends Cubit<AttendanceReportsState> {
  final AttendanceReportsRepository repository;

  AttendanceReportsCubit(this.repository) : super(const AttendanceReportsInitial());

  Future<void> loadReport(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getReport(request);
    result.fold((failure) => emit(AttendanceReportsError(_message(failure))), (data) => emit(AttendanceReportsLoaded(data)));
  }

  Future<void> loadDailyReport({required DateTime date, int? employeeId, String? department}) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getDailyReport(date: date, employeeId: employeeId, department: department);
    result.fold((failure) => emit(AttendanceReportsError(_message(failure))), (data) => emit(AttendanceReportsLoaded(data)));
  }

  Future<void> loadLateReport(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getLateReport(request);
    result.fold((failure) => emit(AttendanceReportsError(_message(failure))), (data) => emit(AttendanceReportsLoaded(data)));
  }

  Future<void> loadEmployeeReport({required int employeeId, required DateTime fromDate, required DateTime toDate}) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getEmployeeReport(employeeId, fromDate, toDate);
    result.fold((failure) => emit(AttendanceReportsError(_message(failure))), (data) => emit(AttendanceReportsLoaded(data)));
  }

  Future<void> loadActions(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getActions(request);
    result.fold((failure) => emit(AttendanceReportsError(_message(failure))), (data) => emit(AttendanceReportsActionsLoaded(data)));
  }

  Future<List<int>?> loadPdf(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getPdf(request);
    return result.fold((failure) { emit(AttendanceReportsError(_message(failure))); return null; }, (data) { emit(AttendanceReportsPdfLoaded(data)); return data; });
  }

  Future<List<int>?> loadEmployeePdf({required int employeeId, required DateTime fromDate, required DateTime toDate}) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getEmployeePdf(employeeId, fromDate, toDate);
    return result.fold((failure) { emit(AttendanceReportsError(_message(failure))); return null; }, (data) { emit(AttendanceReportsPdfLoaded(data)); return data; });
  }

  String _message(Failure failure) => failure.message;
}
