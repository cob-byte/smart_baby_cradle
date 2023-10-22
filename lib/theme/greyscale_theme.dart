import 'package:flutter/material.dart';

final Color fourthColor = Color.fromRGBO(86, 174, 237, 0.608);

final ThemeData greyscaleTheme = ThemeData(
  primaryColor: Color.fromARGB(255, 143, 143, 144),
  colorScheme: const ColorScheme(
    primary: Color.fromRGBO(115, 115, 115, 1),
    secondary: Color.fromRGBO(132, 132, 132, 1),
    tertiary: Color.fromRGBO(151, 151, 151, 1),
    surface: Colors.white,
    background: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Color.fromRGBO(111, 111, 111, 1),
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Color.fromARGB(255, 171, 18, 18),
    brightness: Brightness.light,
    inversePrimary: Color.fromRGBO(187, 187, 187, 1),
    inverseSurface: Color.fromRGBO(111, 111, 111, 1),
    onPrimaryContainer: Color.fromRGBO(130, 130, 130, 1),
    onInverseSurface: Color.fromRGBO(152, 152, 152, 1),
    onSurfaceVariant: Color.fromRGBO(70, 70, 70, 1),
    surfaceVariant: Color.fromRGBO(82, 82, 82, 1),
    onTertiary: Color.fromRGBO(129, 129, 129, 1),
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
    backgroundColor: Color.fromRGBO(134, 134, 134, 1),
    titleTextStyle: TextStyle(
      fontSize: 25.0,
      fontStyle: FontStyle.normal,
      color: Colors.white,
      fontFamily: 'Bold',
    ),
  ),
  // Define other theme properties as needed
);
