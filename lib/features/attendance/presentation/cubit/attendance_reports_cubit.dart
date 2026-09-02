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
    result.fold(
      (failure) => emit(AttendanceReportsError(_message(failure))),
      (data) => emit(AttendanceReportsLoaded(data)),
    );
  }

  Future<void> loadActions(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getActions(request);
    result.fold(
      (failure) => emit(AttendanceReportsError(_message(failure))),
      (data) => emit(AttendanceReportsActionsLoaded(data)),
    );
  }

  Future<List<int>?> loadPdf(AttendanceReportRequestModel request) async {
    emit(const AttendanceReportsLoading());
    final result = await repository.getPdf(request);
    List<int>? bytes;
    result.fold(
      (failure) => emit(AttendanceReportsError(_message(failure))),
      (data) {
        bytes = data;
        emit(AttendanceReportsPdfLoaded(data));
      },
    );
    return bytes;
  }

  String _message(Failure failure) => failure.message;
}
