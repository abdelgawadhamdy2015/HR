import 'dart:convert';
import 'package:hr_attendance_app/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // TODO: point this at your backend.
  //   Android emulator -> http://10.0.2.2:5000
  //   iOS simulator / web / desktop -> http://localhost:5000
  //   Physical device -> http://<your-machine-lan-ip>:5000
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static const _tokenKey = 'auth_token';
  static const _permissionsKey = 'auth_permissions';
  static const _usernameKey = 'auth_username';
  static const _userIdKey = 'auth_user_id';

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }

    final result = AuthResult.fromJson(jsonDecode(response.body));
    await _persistSession(result);
    return result;
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }

    final result = AuthResult.fromJson(jsonDecode(response.body));
    await _persistSession(result);
    return result;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_permissionsKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<List<String>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_permissionsKey) ?? [];
  }

  Future<bool> hasPermission(String permission) async {
    final permissions = await getPermissions();
    return permissions.contains(permission);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Use this as the headers for any authenticated request to your API.
  Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _persistSession(AuthResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, result.token);
    await prefs.setStringList(_permissionsKey, result.permissions);
    await prefs.setString(_usernameKey, result.username);
    await prefs.setInt(_userIdKey, result.userId);
  }

  String _extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('message'))
        return body['message'].toString();
      if (body is String) return body;
    } catch (_) {}
    return 'Request failed with status ${response.statusCode}';
  }
}
