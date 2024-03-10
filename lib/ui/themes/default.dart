import 'package:film_randomizer/ui/themes/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get defaultTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,

      fontFamily: 'Montserrat',

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      ),

      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ), 
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.blueAccent
      ),

      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all<Color>(Colors.blue),
        trackOutlineColor: MaterialStateProperty.all<Color>(Colors.blue),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue.withOpacity(0.5); // Light blue for active state
            }
            return Colors.white; // Default color for inactive state
          },
        ),
      ),
      extensions: [
        CustomThemeExtension(
          chipColor: Colors.blue.withOpacity(0.5),
          textStyle: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
