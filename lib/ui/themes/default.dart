import 'package:film_randomizer/ui/themes/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class DefaultTheme {
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      hoverColor: Colors.blue,
      highlightColor: Colors.yellow,

      scaffoldBackgroundColor: Colors.white,

      fontFamily: 'Montserrat',

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        labelSmall: TextStyle(fontSize: 12.0, fontFamily: 'Hind', fontWeight: FontWeight.bold),
      ),

      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ), 

      cardTheme: const CardTheme(
        color: Color.fromARGB(106, 0, 195, 255)
      ),

      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.blueAccent
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all<Color>(Colors.blue),
        trackOutlineColor: WidgetStateProperty.all<Color>(Colors.blue),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue.withOpacity(0.5); // Light blue for active state
            }
            return Colors.white; // Default color for inactive state
          },
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return Colors.black;
          }),
        )
      ),

      extensions: [
        CustomThemeExtension(
          chipColor: Colors.blue.withOpacity(0.5),
          textStyle: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
