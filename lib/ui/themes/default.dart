import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get defaultTheme {
    return ThemeData(
      // Define the default brightness and colors.
      brightness: Brightness.light,
      primaryColor: Colors.blue,

      // Define the default font family.
      fontFamily: 'Montserrat',

      // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      ),

      // Define the default button theme. Use this to specify the default
      // layout and colors of material buttons.
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ), 
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.blueAccent
      ),
    );
  }
}
