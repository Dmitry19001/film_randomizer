import 'package:film_randomizer/ui/themes/custom_theme_extension.dart';
import 'package:film_randomizer/ui/themes/default.dart';
import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get themeData {
    final defaultTextTheme = DefaultTheme.themeData.textTheme;

    final darkTextTheme = defaultTextTheme.copyWith(
      displayLarge: defaultTextTheme.displayLarge?.copyWith(color: Colors.white70),
      titleLarge: defaultTextTheme.titleLarge?.copyWith(color: Colors.white),
      bodyLarge: defaultTextTheme.bodyMedium?.copyWith(color: Colors.white),
      bodyMedium: defaultTextTheme.bodyMedium?.copyWith(color: Colors.white),
      bodySmall: defaultTextTheme.bodyMedium?.copyWith(color: Colors.white),
      labelSmall: defaultTextTheme.labelSmall?.copyWith(color: Colors.white38)
    );

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.grey[800],
      hoverColor: Colors.deepPurpleAccent,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.deepPurpleAccent,
      ),
      fontFamily: 'Montserrat',
      textTheme: darkTextTheme,
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        buttonColor: Colors.tealAccent[200],
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white70,
        ),
      ),

      switchTheme: _buildSwitchThemeData(),

      cardTheme: CardTheme(
        color: Colors.deepPurple[800],
      ),
      extensions: [
        CustomThemeExtension(
          chipColor: Colors.deepPurpleAccent,
          textStyle: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  static SwitchThemeData _buildSwitchThemeData() {
    return SwitchThemeData(
      trackColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          return Colors.transparent;
        },
      ),
      thumbColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.deepPurpleAccent;
          }
          return Colors.white;
        },
      ),
      trackOutlineColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.deepPurpleAccent;
          }
          return Colors.white;
        },
      ),
    );
  }
}
