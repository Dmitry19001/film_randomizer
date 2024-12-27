import 'package:flutter/material.dart';

enum AppTheme { light, dark }

class SettingsState {
  final Locale language;
  final bool showWatched;
  final AppTheme theme;

  const SettingsState({
    required this.language,
    required this.showWatched,
    required this.theme,
  });

  SettingsState copyWith({
    Locale? language,
    bool? showWatched,
    AppTheme? theme,
  }) {
    return SettingsState(
      language: language ?? this.language,
      showWatched: showWatched ?? this.showWatched,
      theme: theme ?? this.theme,
    );
  }
}
