part of 'employee_list_cubit.dart';

enum EmployeeListStatus { initial, loading, success, failure }

/// Separate status for the "add employee" form so it doesn't disturb the
/// list's own loading/success/failure state while the user is submitting.
enum CreateEmployeeStatus { idle, submitting, success, failure }

class EmployeeListState extends Equatable {
  final EmployeeListStatus status;
  final List<Employee> employees;
  final String searchQuery;
  final String? errorMessage;

  final CreateEmployeeStatus createStatus;
  final String? createErrorMessage;

  const EmployeeListState({
    this.status = EmployeeListStatus.initial,
    this.employees = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.createStatus = CreateEmployeeStatus.idle,
    this.createErrorMessage,
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
    CreateEmployeeStatus? createStatus,
    String? createErrorMessage,
  }) {
    return EmployeeListState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      createStatus: createStatus ?? this.createStatus,
      createErrorMessage: createErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        employees,
        searchQuery,
        errorMessage,
        createStatus,
        createErrorMessage,
      ];
}
