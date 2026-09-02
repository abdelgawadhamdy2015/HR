part of 'attendance_actions_cubit.dart';

enum AttendanceActionStatus { idle, submitting, success, failure }

/// Single state shared by every quick action on the screen (check-in,
/// check-out, mark day, lateness, mission, permission request). Each action
/// method resets [status] to submitting before running, so the UI can show
/// one shared spinner/snackbar regardless of which form was submitted.
class AttendanceActionsState extends Equatable {
  final AttendanceActionStatus status;
  final String? errorMessage;
  final String? successMessage;

  const AttendanceActionsState({
    this.status = AttendanceActionStatus.idle,
    this.errorMessage,
    this.successMessage,
  });

  AttendanceActionsState copyWith({
    AttendanceActionStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return AttendanceActionsState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}
