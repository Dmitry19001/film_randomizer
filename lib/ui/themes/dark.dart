import 'package:film_randomizer/ui/themes/default.dart';
import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get themeData {
    final defaultTextTheme = AppTheme.defaultTheme.textTheme;

    final darkTextTheme = defaultTextTheme.copyWith(
      displayLarge: defaultTextTheme.displayLarge?.copyWith(color: Colors.white70),
      titleLarge: defaultTextTheme.titleLarge?.copyWith(color: Colors.white70),
      bodyMedium: defaultTextTheme.bodyMedium?.copyWith(color: Colors.white60),
    );

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.grey[900],
      colorScheme: ColorScheme.dark(
        primary: Colors.grey[900]!,
        secondary: Colors.tealAccent[200]!,
      ),
      fontFamily: 'Montserrat',
      textTheme: darkTextTheme,
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        buttonColor: Colors.tealAccent[200],
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
