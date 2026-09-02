class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Not found']);
}

/// Thrown on HTTP 409 — e.g. duplicate employee code, or an إذن request
/// that would exceed the monthly limit.
class ConflictException implements Exception {
  final String message;
  ConflictException([this.message = 'Conflict']);
}

/// Thrown on HTTP 400 — request failed a validation rule on the server
/// (e.g. invalid status, "to" time before "from" time).
class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Invalid request']);
}

/// Thrown on HTTP 403 — the logged-in user lacks the required permission
/// claim (see [RequirePermission] on the .NET controllers).
class ForbiddenException implements Exception {
  final String message;
  ForbiddenException([this.message = 'You do not have permission to do this.']);
}
