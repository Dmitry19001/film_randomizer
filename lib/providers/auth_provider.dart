import 'package:film_randomizer/providers/settings_provider.dart';
import 'package:film_randomizer/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _username;
  String? _token;

  String? get username => _username;
  String? get token => _token;

  bool get isAuthenticated => _username != null && _token != null;

  AuthProvider() {
    loadAuthData();
  }

  Future<bool> loadAuthData() async {
    final authData = await SettingsProvider.loadAuthData();

    if (authData["username"] == null 
      || authData["username"]!.isEmpty) return false;

    _username = authData["username"];
    _token = authData["token"];
    notifyListeners();

    return true;
  }

  Future<bool> login(String username, String password) async {
    Map<String, String> userData = {
      'username': username,
      'password': password
    };
    _token = await _authService.login(userData);

    if (_token != null)
    {
      SettingsProvider.saveAuthData(username: username, token: _token!);
      notifyListeners();

      return true;
    }

    return false;
  }

  Future<bool> register(String username, String password) async {
    Map<String, String> userData = {
      'username': username,
      'password': password
    };
    _token = await _authService.register(userData);

    if (_token != null)
    {
      SettingsProvider.saveAuthData(username: username, token: _token!);
      notifyListeners();

      return true;
    }

    return false;
  }

  Future<void> logout(String login, String password) async {
    _token = null;
    _username = null;
    
    SettingsProvider.saveAuthData();

    notifyListeners();
  }
}