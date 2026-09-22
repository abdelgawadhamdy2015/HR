class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const employees = '/employees';
  static const attendanceActions = '/attendance-actions';
  static const attendanceCheckInOut = '/attendance-check-in-out';
  static const attendanceReports = '/attendance-reports';
  static const permissions = '/permissions';
  static const notifications = '/notifications';
  static const auditLogs = '/audit-logs';

  static String employeeDetails(int id) => '/employees/$id';
  static String permissionsForUser(int userId) => '/permissions?userId=$userId';
}
