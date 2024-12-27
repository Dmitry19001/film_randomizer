// backend_ip_notifier.dart
import 'dart:async';
import 'package:film_randomizer/states/backend_ip_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:film_randomizer/config/config.dart'; // for dropBoxIPConfigLink

final backendIPProvider =
    AsyncNotifierProvider<BackendIPNotifier, BackendIPState>(BackendIPNotifier.new);

class BackendIPNotifier extends AsyncNotifier<BackendIPState> {
  // The build method is called once when the provider is first read.
  @override
  FutureOr<BackendIPState> build() async {
    // 1) Load backend IP from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('backendUrl') ?? '';

    // 2) If empty, try to download from Dropbox link
    if (savedUrl.isEmpty) {
      await _downloadBackendIP();
      // Now read again after we (maybe) updated it
      final updatedPrefs = await SharedPreferences.getInstance();
      final updatedUrl = updatedPrefs.getString('backendUrl') ?? _defaultUrl();
      return BackendIPState(apiBaseUrl: updatedUrl);
    } else {
      // We already have something in local storage
      return BackendIPState(apiBaseUrl: savedUrl);
    }
  }

  // Equivalent to your old "downloadBackendIP" method
  Future<void> _downloadBackendIP() async {
    try {
      final response = await http.get(Uri.parse(dropBoxIPConfigLink));
      if (response.statusCode == 200) {
        final backendIP = response.body.trim();
        Logger().d("Backend IP from Dropbox: $backendIP");

        if (_isValidIP(backendIP)) {
          // Save: "http://<IP>:3001/api"
          final url = "http://$backendIP:3001/api";
          await _saveBackendIP(url);
        } else {
          throw Exception("Invalid IP address format: $backendIP");
        }
      } else {
        throw Exception(
          "Failed to fetch backend IP from Dropbox. Status code: ${response.statusCode}",
        );
      }
    } catch (error) {
      debugPrint("Error downloading backend IP: $error");
      // We won't throw here because we can still fallback to default
    }
  }

  // A public method if you want to trigger a re-download manually
  Future<void> downloadBackendIP() async {
    state = const AsyncValue.loading();
    try {
      await _downloadBackendIP();
      // Reload our state from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final updatedUrl = prefs.getString('backendUrl') ?? _defaultUrl();
      state = AsyncValue.data(BackendIPState(apiBaseUrl: updatedUrl));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Equivalent to your old "saveBackendIP" method
  Future<void> saveBackendIP(String url) async {
    state = const AsyncValue.loading();
    try {
      await _saveBackendIP(url);
      // Update local state
      final newState = BackendIPState(apiBaseUrl: url);
      Logger().d("Updated API base URL: ${newState.apiBaseUrl}");
      state = AsyncValue.data(newState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --------------------------------------------------------------------------
  // Internal helper methods
  // --------------------------------------------------------------------------

  Future<void> _saveBackendIP(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backendUrl', url);
    Logger().d("Saved backend url to shared preferences: $url");
  }

  // Validate IP
  static bool _isValidIP(String ip) {
    final regex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    return regex.hasMatch(ip);
  }

  String _defaultUrl() => "http://localhost:3002/api";
}
