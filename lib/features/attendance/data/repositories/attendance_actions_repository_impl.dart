import 'package:intl/intl.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../employee/domain/entities/mission_entry.dart';
import '../../../employee/domain/entities/permission_entry.dart';
import '../../domain/entities/attendance_action_result.dart';
import '../../domain/repositories/attendance_actions_repository.dart';
import '../datasources/attendance_actions_remote_data_source.dart';

class AttendanceActionsRepositoryImpl implements AttendanceActionsRepository {
  final AttendanceActionsRemoteDataSource remoteDataSource;
  AttendanceActionsRepositoryImpl(this.remoteDataSource);

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Error(NotFoundFailure(e.message));
    } on ConflictException catch (e) {
      return Error(ConflictFailure(e.message));
    } on ValidationException catch (e) {
      return Error(ValidationFailure(e.message));
    } on ForbiddenException catch (e) {
      return Error(ForbiddenFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<AttendanceActionResult>> checkIn({
    required int employeeId,
    DateTime? date,
    String? time,
  }) =>
      _guard(() => remoteDataSource.checkIn({
            'employeeId': employeeId,
            if (date != null) 'date': _dateFormat.format(date),
            if (time != null) 'time': time,
          }));

  @override
  Future<Result<AttendanceActionResult>> checkOut({
    required int employeeId,
    DateTime? date,
    String? time,
  }) =>
      _guard(() => remoteDataSource.checkOut({
            'employeeId': employeeId,
            if (date != null) 'date': _dateFormat.format(date),
            if (time != null) 'time': time,
          }));

  @override
  Future<Result<AttendanceActionResult>> markDay({
    required int employeeId,
    required DateTime date,
    required String status,
  }) =>
      _guard(() => remoteDataSource.markDay({
            'employeeId': employeeId,
            'date': _dateFormat.format(date),
            'status': status,
          }));

  @override
  Future<Result<AttendanceActionResult>> recordLateness({
    required int employeeId,
    required DateTime date,
    required int minutes,
  }) =>
      _guard(() => remoteDataSource.recordLateness({
            'employeeId': employeeId,
            'date': _dateFormat.format(date),
            'minutes': minutes,
          }));

  @override
  Future<Result<MissionEntry>> createMission({
    required int employeeId,
    required DateTime date,
    required String reason,
    required String location,
  }) =>
      _guard(() => remoteDataSource.createMission({
            'employeeId': employeeId,
            'date': _dateFormat.format(date),
            'reason': reason,
            'location': location,
          }));

  @override
  Future<Result<PermissionEntry>> createPermissionRequest({
    required int employeeId,
    required DateTime date,
    required String from,
    required String to,
    required String reason,
  }) =>
      _guard(() => remoteDataSource.createPermissionRequest({
            'employeeId': employeeId,
            'date': _dateFormat.format(date),
            'from': from,
            'to': to,
            'reason': reason,
          }));
}
