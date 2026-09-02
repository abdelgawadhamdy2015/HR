import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/create_employee.dart';
import '../../domain/usecases/get_employees.dart';

part 'employee_list_state.dart';

class EmployeeListCubit extends Cubit<EmployeeListState> {
  final GetEmployees getEmployees;
  final CreateEmployee createEmployeeUseCase;

  EmployeeListCubit({
    required this.getEmployees,
    required this.createEmployeeUseCase,
  }) : super(const EmployeeListState());

  Future<void> loadEmployees() async {
    emit(state.copyWith(status: EmployeeListStatus.loading));
    final result = await getEmployees(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: EmployeeListStatus.failure,
        errorMessage: failure.message,
      )),
      (employees) => emit(state.copyWith(
        status: EmployeeListStatus.success,
        employees: employees,
      )),
    );
  }

  void search(String query) => emit(state.copyWith(searchQuery: query));

  Future<void> refresh() => loadEmployees();

  /// Creates a new employee, then refreshes the list on success.
  /// Returns true on success so the calling screen can e.g. pop itself.
  Future<bool> createEmployee({
    required String code,
    required String fullName,
    required String jobTitle,
    required String department,
    String? avatarUrl,
  }) async {
    emit(state.copyWith(createStatus: CreateEmployeeStatus.submitting, createErrorMessage: null));

    final result = await createEmployeeUseCase(CreateEmployeeParams(
      code: code,
      fullName: fullName,
      jobTitle: jobTitle,
      department: department,
      avatarUrl: avatarUrl,
    ));

    return result.fold(
      (failure) {
        emit(state.copyWith(
          createStatus: CreateEmployeeStatus.failure,
          createErrorMessage: failure.message,
        ));
        return false;
      },
      (employee) {
        emit(state.copyWith(createStatus: CreateEmployeeStatus.success));
        loadEmployees();
        return true;
      },
    );
  }
}
