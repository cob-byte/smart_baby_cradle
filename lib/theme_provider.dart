import 'package:flutter/material.dart';
import '../theme/boy_theme.dart';
import '../theme/girl_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData currentTheme = girlTheme; // Default theme

  void toggleTheme() {
    currentTheme = currentTheme == girlTheme ? boyTheme : girlTheme;
    notifyListeners();
  }
}
