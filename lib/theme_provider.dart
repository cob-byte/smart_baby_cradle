import 'package:flutter/material.dart';
import '../theme/boy_theme.dart';
import '../theme/girl_theme.dart';
import '../theme/greyscale_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData currentTheme = girlTheme;
  bool isRaspberryPiOn = true;

  void toggleTheme() {
    currentTheme = currentTheme == girlTheme ? boyTheme : girlTheme;
    notifyListeners();
  }

  ThemeData getTheme() {
    if (isRaspberryPiOn) {
      return currentTheme;
    } else {
      return greyscaleTheme;
    }
  }

  void setRaspberryPiStatus(bool isOn) {
    isRaspberryPiOn = isOn;
    if (isRaspberryPiOn) {
      currentTheme = currentTheme == girlTheme ? boyTheme : girlTheme;
    } else {
      currentTheme = greyscaleTheme;
    }
    notifyListeners();
  }
}
