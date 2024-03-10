import 'dart:ui' as ui;
import 'package:film_randomizer/ui/themes/dark.dart';
import 'package:film_randomizer/ui/themes/default.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _language;
  bool _showWatched;
  ThemeData _themeData;

  static const defaultLanguage = 'en';
  static const defaultShowWatched = true;
  static final defaultTheme = DefaultTheme.themeData;

  SettingsProvider()
      : _language = defaultLanguage,
        _showWatched = defaultShowWatched,
        _themeData = defaultTheme;

  String get language => _language;
  bool get showWatched => _showWatched;
  ThemeData get theme => _themeData;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _language = prefs.getString('language') ?? 
        ui.PlatformDispatcher.instance.locale.toLanguageTag().substring(0, 2);
    _language = _language.isEmpty ? defaultLanguage : _language;

    _showWatched = prefs.getBool('showWatched') ?? defaultShowWatched;

    final storedBrightness = prefs.getString('theme');
    final currentPlatformBrightness = ui.PlatformDispatcher.instance.platformBrightness;
    _themeData = determineTheme(storedBrightness, currentPlatformBrightness);

    notifyListeners();
  }

  ThemeData determineTheme(String? storedBrightness, ui.Brightness currentPlatformBrightness) {
    if (storedBrightness != null) {
      return storedBrightness == 'dark' ? DarkTheme.themeData : defaultTheme;
    } else {
      return currentPlatformBrightness == ui.Brightness.dark ? DarkTheme.themeData : defaultTheme;
    }
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    _language = language;
    notifyListeners();
  }

  Future<void> setShowWatched(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWatched', value);
    _showWatched = value;
    notifyListeners();
  }

  Future<void> setTheme(ThemeData theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme == DarkTheme.themeData ? 'dark' : 'light');
    _themeData = theme;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == defaultTheme) {
      setTheme(DarkTheme.themeData);
      Logger().d(DarkTheme.themeData);
    } else {
      setTheme(defaultTheme);
      Logger().d(defaultTheme);
    }
  }
}
