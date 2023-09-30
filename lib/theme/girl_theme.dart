import 'package:flutter/material.dart';

final Color fourthColor = Color.fromRGBO(217, 217, 217, 0);

final ThemeData girlTheme = ThemeData(
  primaryColor: Color.fromARGB(255, 208, 87, 105),
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
    inversePrimary: Color.fromRGBO(255, 202, 212, 1),
    inverseSurface: Color.fromRGBO(244, 172, 183, 1),
    onPrimaryContainer: Color.fromRGBO(233, 116, 138, 1),
    onInverseSurface: Color.fromRGBO(248, 164, 180, 1),
    onSurfaceVariant: Color.fromRGBO(255, 197, 208, 1),
    surfaceVariant: Color.fromRGBO(255, 226, 232, 1),
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
