import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/get_employees.dart';

part 'employee_list_state.dart';

class EmployeeListCubit extends Cubit<EmployeeListState> {
  final GetEmployees getEmployees;

  EmployeeListCubit({required this.getEmployees}) : super(const EmployeeListState());

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
}
