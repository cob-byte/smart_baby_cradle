import 'package:flutter/material.dart';

final Color fourthColor = Color.fromRGBO(86, 174, 237, 0.608);

final ThemeData boyTheme = ThemeData(
  primaryColor: Color.fromARGB(255, 6, 126, 142),
  colorScheme: const ColorScheme(
    primary: Color.fromRGBO(37, 137, 177, 1),
    secondary: Color.fromRGBO(153, 209, 250, 1),
    tertiary: Color.fromRGBO(151, 209, 250, 1),
    surface: Colors.white,
    background: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Color.fromRGBO(60, 118, 186, 1),
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Color.fromARGB(255, 171, 18, 18),
    brightness: Brightness.light,
    inversePrimary: Color.fromRGBO(212, 250, 255, 1),
    inverseSurface: Color.fromRGBO(142, 239, 252, 1),
    onPrimaryContainer: Color.fromRGBO(2, 39, 65, 1),
    onInverseSurface: Color.fromRGBO(39, 98, 166, 1),
    onSurfaceVariant: Color.fromRGBO(128, 205, 249, 1),
    surfaceVariant: Color.fromRGBO(1, 47, 87, 1),
    onTertiary: Color.fromRGBO(217, 239, 255, 1),
  ),
  scaffoldBackgroundColor: Color.fromRGBO(255, 255, 255, 0.647),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 0, 11, 106),
    ),
    // Add more text styles as needed
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromRGBO(60, 118, 186, 1),
    titleTextStyle: TextStyle(
      fontSize: 25.0,
      fontStyle: FontStyle.normal,
      color: Colors.white,
      fontFamily: 'Bold',
    ),
  ),
  // Define other theme properties as needed
);
