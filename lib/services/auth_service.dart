import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthService {
  final Logger _logger = Logger();
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<String?> login(Map<String, String> userData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          _logger.d(response.body);
          return token;
        } else {
          _logger.e('Login failed: ${response.body}');
        }
      } else {
        _logger.e('Login request failed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error during login: $e');
    }
    return null;
  }

  Future<String?> register(Map<String, String> userData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          return token;
        } else {
          _logger.e('Register failed: ${response.body}');
        }
      } else {
        _logger.e('Register request failed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error during register: $e');
    }
    return null;
  }

  Future<bool> isLoggedIn(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/status"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d(jsonDecode(response.body));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      _logger.e('Error checking login status: $e');
    }
    return false;
  }
}
