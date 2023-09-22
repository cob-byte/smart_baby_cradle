import 'package:flutter/material.dart';

final Color fourthColor = Color.fromRGBO(217, 217, 217, 0);

final ThemeData girlTheme = ThemeData(
  primaryColor: const Color.fromRGBO(244, 172, 183, 0.65),
  colorScheme: const ColorScheme(
    primary: Color.fromRGBO(244, 172, 183, 0.65),
    secondary: Color.fromRGBO(255, 229, 217, 1),
    tertiary: Color.fromRGBO(217, 217, 217, 0),
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
  scaffoldBackgroundColor: const Color.fromRGBO(255, 202, 212, 1),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.pink,
    ),
    // Add more text styles as needed
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromRGBO(244, 172, 183, 0.65),
    titleTextStyle: TextStyle(
      fontSize: 25.0,
      fontStyle: FontStyle.normal,
      color: Colors.white,
      fontFamily: 'Bold',
    ),
  ),
  // Define other theme properties as needed
);
