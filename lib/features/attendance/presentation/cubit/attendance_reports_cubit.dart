import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/attendance_report_models.dart';
import '../../domain/repositories/attendance_reports_repository.dart';
import 'attendance_reports_state.dart';

class AttendanceReportsCubit extends Cubit<AttendanceReportsState> {
  final AttendanceReportsRepository repository;

  AttendanceReportsCubit(this.repository) : super(const AttendanceReportsInitial());

  Future<void> loadReport(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getReport(request);
    result.when(
      success: (data) => emit(AttendanceReportsLoaded(data)),
      error: (failure) => emit(AttendanceReportsError(_message(failure))),
    );
  }

  Future<void> loadActions(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getActions(request);
    result.when(
      success: (data) => emit(AttendanceReportsActionsLoaded(data)),
      error: (failure) => emit(AttendanceReportsError(_message(failure))),
    );
  }

  Future<List<int>?> loadPdf(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getPdf(request);
    List<int>? bytes;
    result.when(
      success: (data) {
        bytes = data;
        emit(AttendanceReportsPdfLoaded(data));
      },
      error: (failure) => emit(AttendanceReportsError(_message(failure))),
    );
    return bytes;
  }

  String _message(Failure failure) => failure.message;
}
