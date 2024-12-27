// auth_notifier.dart
import 'dart:async';
import 'package:film_randomizer/notifiers/backend_ip_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:film_randomizer/states/auth_state.dart';
import 'package:film_randomizer/services/auth_service.dart';

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {

  @override
  Future<AuthState> build() async {
    // 1) Load username/token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedToken = prefs.getString('token');

    // 2) If no username, user is not authenticated
    if (savedUsername == null || savedUsername.isEmpty) {
      return AuthState.unauthenticated();
    }

    // 3) Check if token is valid on the server
    final isLoggedIn = await _checkAuthStatus(savedToken);
    if (!isLoggedIn) {
      return AuthState.unauthenticated();
    }

    return AuthState(username: savedUsername, token: savedToken);
  }

  // ----------------------------------------------------------------------
  // Helper to check if the token is still valid by calling AuthService
  // ----------------------------------------------------------------------
  Future<bool> _checkAuthStatus(String? token) async {
    // Force a refresh of the backend IP
    await ref.read(backendIPProvider.notifier).downloadBackendIP();

    if (token == null || token.isEmpty) return false;

    // Create AuthService on the fly
    AuthService authService = _createAuthService();
    return await authService.isLoggedIn(token);
  }

  // ----------------------------------------------------------------------
  // Public methods: login, register, logout, getAuthStatus, etc.
  // ----------------------------------------------------------------------

  Future<bool> login(String username, String password) async {
    state = const AsyncValue.loading();

    // Ensure the backend IP is up to date
    await ref.read(backendIPProvider.notifier).downloadBackendIP();

    Logger().d("Logging in with username: $username");
    final userData = {'username': username, 'password': password};

    AuthService authService = _createAuthService();
    
    final newToken = await authService.login(userData);

    if (newToken != null) {
      await _saveAuthData(username, newToken);
      state = AsyncValue.data(AuthState(username: username, token: newToken));
      return true;
    }

    state = AsyncValue.data(AuthState.unauthenticated());
    return false;
  }

  Future<bool> register(String username, String password) async {
    state = const AsyncValue.loading();

    // Ensure the backend IP is up to date
    await ref.read(backendIPProvider.notifier).downloadBackendIP();

    final userData = {'username': username, 'password': password};

    AuthService authService = _createAuthService();

    final newToken = await authService.login(userData);

    if (newToken != null) {
      await _saveAuthData(username, newToken);
      state = AsyncValue.data(AuthState(username: username, token: newToken));
      return true;
    }

    state = AsyncValue.data(AuthState.unauthenticated());
    return false;
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    // Update backend IP if needed
    await ref.read(backendIPProvider.notifier).downloadBackendIP();

    // Clear local SharedPreferences
    await _saveAuthData("", "");

    // Reset to unauthenticated
    state = AsyncValue.data(AuthState.unauthenticated());
  }

  Future<bool> getAuthStatus() async {
    state = const AsyncValue.loading();

    // Update backend IP if needed
    await ref.read(backendIPProvider.notifier).downloadBackendIP();

    final currentValue = state.valueOrNull;
    if (currentValue == null || !currentValue.isAuthenticated) {
      // Already unauthenticated
      state = AsyncValue.data(AuthState.unauthenticated());
      return false;
    }

    // Now read the updated baseUrl from the backendIPProvider state
    AuthService authService = _createAuthService();

    final isLoggedIn = await authService.isLoggedIn(currentValue.token ?? "");
    Logger().d("isLoggedIn: $isLoggedIn");

    if (!isLoggedIn) {
      // If the server says not logged in, reset to unauthenticated
      state = AsyncValue.data(AuthState.unauthenticated());
      return false;
    }

    // Otherwise, keep the current user data
    state = AsyncValue.data(currentValue);
    return true;
  }

  AuthService _createAuthService() {
    // Now read the updated baseUrl from the backendIPProvider state
    final ipState = ref.read(backendIPProvider).valueOrNull; 
    final baseUrl = ipState?.apiBaseUrl ?? 'http://localhost:3002/api';
    
    // Create AuthService on the fly
    final authService = AuthService(baseUrl);
    return authService;
  }

  // ----------------------------------------------------------------------
  // Internal helper: save username/token to SharedPreferences
  // ----------------------------------------------------------------------
  Future<void> _saveAuthData(String username, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('token', token);
  }
}
