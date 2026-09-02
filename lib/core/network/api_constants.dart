class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://0.0.0.0:5080/api',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Permissions (RBAC roles/permissions — not إذن, see permissionRequests below)
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

  // Attendance actions (تسجيل حضور / انصراف / إجازة / انقطاع / تصحيح تأخير)
  static const String attendanceCheckIn = '/attendance/checkin';
  static const String attendanceCheckOut = '/attendance/checkout';
  static const String attendanceMark = '/attendance/mark';
  static const String attendanceLateness = '/attendance/lateness';

  // Missions (مأمورية)
  static const String missions = '/missions';

  // Permission requests (إذن) — distinct from `permissions` (RBAC) above
  static const String permissionRequests = '/permission-requests';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
