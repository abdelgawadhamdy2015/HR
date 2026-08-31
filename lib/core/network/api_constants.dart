class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5080/api',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Permissions
  static const String permissions = '/permissions';
  static const String assignPermission = '/permissions/assign';
  static const String revokePermission = '/permissions/revoke';
  static String permissionsForUser(int userId) => '/permissions/user/$userId';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';
  static const String notifications = '/dashboard/notifications';

  // Employees
  static const String employees = '/employees';
  static String employeeById(int id) => '/employees/$id';
  static String employeeDetails(int id) => '/employees/$id/details';
  static String employeeMissions(int id) => '/employees/$id/missions';
  static String employeePermissions(int id) => '/employees/$id/permissions';
  static String employeeLateness(int id) => '/employees/$id/lateness';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
