import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark }

class SettingsProvider with ChangeNotifier {
  Locale _language;
  bool _showWatched;
  AppTheme _themeData;

  static const defaultLanguage = Locale('en');
  static const defaultShowWatched = true;
  static final defaultTheme = AppTheme.light;

  SettingsProvider()
      : _language = defaultLanguage,
        _showWatched = defaultShowWatched,
        _themeData = AppTheme.light;

  Locale get language => _language;
  bool get showWatched => _showWatched;
  AppTheme get theme => _themeData;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final languageString = prefs.getString('language') ?? 
        ui.PlatformDispatcher.instance.locale.toLanguageTag().substring(0, 2);
    _language = languageString.isEmpty ? defaultLanguage : Locale(languageString);

    _showWatched = prefs.getBool('showWatched') ?? defaultShowWatched;

    final storedBrightness = prefs.getString('theme');
    final currentPlatformBrightness = ui.PlatformDispatcher.instance.platformBrightness;
    _themeData = determineTheme(storedBrightness, currentPlatformBrightness);

    notifyListeners();
  }

  AppTheme determineTheme(String? storedBrightness, ui.Brightness currentPlatformBrightness) {
    if (storedBrightness != null) {
      return storedBrightness == 'dark' ? AppTheme.dark : defaultTheme;
    } else {
      return currentPlatformBrightness == ui.Brightness.dark ? AppTheme.dark : defaultTheme;
    }
  }

  Future<void> setLanguage(Locale language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language.languageCode);
    _language = language;
    notifyListeners();
  }

  Future<void> setShowWatched(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWatched', value);
    _showWatched = value;
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme == AppTheme.dark ? 'dark' : 'default');
    _themeData = theme;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == defaultTheme) {
      setTheme(AppTheme.dark);
    } else {
      setTheme(defaultTheme);
    }
  }

  static Future<void> saveAuthData({String username = "", String token = ""}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('token', token);
  }

  static Future<Map<String, String?>> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final token = prefs.getString('token');
    return {
      "username": username,
      "token": token,
    };
  }
}
