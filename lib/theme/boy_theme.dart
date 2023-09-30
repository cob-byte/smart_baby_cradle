import 'package:flutter/material.dart';

final Color fourthColor = Color.fromRGBO(86, 174, 237, 0.608);

final ThemeData boyTheme = ThemeData(
  primaryColor: Color.fromARGB(255, 6, 126, 142),
  colorScheme: const ColorScheme(
      primary: Color.fromRGBO(146, 221, 251, 1),
      secondary: Color.fromRGBO(204, 215, 255, 1),
      tertiary: Color.fromRGBO(151, 209, 250, 1),
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Color.fromARGB(255, 171, 18, 18),
      brightness: Brightness.light,
      inversePrimary: Color.fromRGBO(197, 255, 255, 1),
      inverseSurface: Color.fromRGBO(142, 239, 252, 1),
      onPrimaryContainer: Color.fromRGBO(106, 191, 252, 1),
      onInverseSurface: Color.fromRGBO(156, 196, 255, 1),
      onSurfaceVariant: Color.fromRGBO(128, 205, 249, 1),
      surfaceVariant: Color.fromRGBO(225, 241, 255, 1)),
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
