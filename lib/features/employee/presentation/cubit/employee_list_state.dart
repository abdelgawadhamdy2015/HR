part of 'employee_list_cubit.dart';

enum EmployeeListStatus { initial, loading, success, failure }

class EmployeeListState extends Equatable {
  final EmployeeListStatus status;
  final List<Employee> employees;
  final String searchQuery;
  final String? errorMessage;

  const EmployeeListState({
    this.status = EmployeeListStatus.initial,
    this.employees = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  List<Employee> get filtered {
    if (searchQuery.trim().isEmpty) return employees;
    final q = searchQuery.trim();
    return employees
        .where((e) => e.fullName.contains(q) || e.code.contains(q))
        .toList();
  }

  EmployeeListState copyWith({
    EmployeeListStatus? status,
    List<Employee>? employees,
    String? searchQuery,
    String? errorMessage,
  }) {
    return EmployeeListState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, employees, searchQuery, errorMessage];
}
