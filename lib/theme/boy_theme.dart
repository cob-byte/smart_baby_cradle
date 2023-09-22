import 'package:flutter/material.dart';

final Color fourthColor = Color.fromRGBO(13, 133, 216, 0.2);

final ThemeData boyTheme = ThemeData(
  primaryColor: const Color.fromRGBO(13, 133, 216, 1),
  colorScheme: const ColorScheme(
    primary: Color.fromRGBO(28, 163, 222, 0.65),
    secondary: Color.fromRGBO(13, 133, 216, 0.8),
    tertiary: Color.fromRGBO(13, 133, 216, 0.6),
    surface: Colors.white,
    background: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Color.fromARGB(255, 171, 18, 18),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Color.fromRGBO(28, 163, 222, 0.65),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 0, 11, 106),
    ),
    // Add more text styles as needed
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromRGBO(28, 163, 222, 0.65),
    titleTextStyle: TextStyle(
      fontSize: 25.0,
      fontStyle: FontStyle.normal,
      color: Colors.white,
      fontFamily: 'Bold',
    ),
  ),
  // Define other theme properties as needed
);
