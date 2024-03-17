import 'dart:convert';
import 'package:film_randomizer/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthService {
  final Logger _logger = Logger();

  Future<String?> login(Map<String, String> userData) async {
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      if (response.statusCode == 200) {
        Logger().d(response.body);
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        _logger.e('Failed to login: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error login: $e');
    }
    return null;
  }

  Future<String?> register(Map<String, String> userData) async {
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/register"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        _logger.e('Failed to register: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error register: $e');
    }
    return null;
  }
}
