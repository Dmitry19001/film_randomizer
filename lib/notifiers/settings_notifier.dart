import 'dart:ui' as ui;
import 'package:film_randomizer/states/settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  // The build method is called when the provider is first accessed.
  // We can do our async initialization here.
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load language
    final storedLanguage = prefs.getString('language') ??
        ui.PlatformDispatcher.instance.locale.toLanguageTag().substring(0, 2);
    final language = storedLanguage.isEmpty
        ? const ui.Locale('en')
        : ui.Locale(storedLanguage);

    // 2. Load showWatched
    final showWatched = prefs.getBool('showWatched') ?? true;

    // 3. Load theme
    final storedTheme = prefs.getString('theme');
    final currentPlatformBrightness =
        ui.PlatformDispatcher.instance.platformBrightness;

    final resolvedTheme = _determineTheme(storedTheme, currentPlatformBrightness);

    // Build the initial state
    return SettingsState(
      language: language,
      showWatched: showWatched,
      theme: resolvedTheme,
    );
  }

  // --- Helper to match your old logic for theme determination ---
  AppTheme _determineTheme(String? storedBrightness, ui.Brightness systemBrightness) {
    if (storedBrightness != null) {
      return storedBrightness == 'dark' ? AppTheme.dark : AppTheme.light;
    } else {
      return systemBrightness == ui.Brightness.dark ? AppTheme.dark : AppTheme.light;
    }
  }

  // ----------------------------------------------------------------
  // Methods for updating the state (and persisting to SharedPrefs)
  // ----------------------------------------------------------------

  Future<void> setLanguage(ui.Locale newLanguage) async {
    // Update SharedPrefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLanguage.languageCode);

    // Update the state
    state = AsyncValue.data(
      state.value!.copyWith(language: newLanguage),
    );
  }

  Future<void> setShowWatched(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWatched', value);

    state = AsyncValue.data(
      state.value!.copyWith(showWatched: value),
    );
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = theme == AppTheme.dark ? 'dark' : 'default';
    await prefs.setString('theme', themeString);

    state = AsyncValue.data(
      state.value!.copyWith(theme: theme),
    );
  }

  Future<void> toggleTheme() async {
    final current = state.value!;
    final newTheme = current.theme == AppTheme.light
        ? AppTheme.dark
        : AppTheme.light;
    await setTheme(newTheme);
  }
}
