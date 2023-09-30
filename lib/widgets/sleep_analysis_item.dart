import 'package:flutter/material.dart';
import 'package:smart_baby_cradle/theme_provider.dart';
import 'package:provider/provider.dart';
import '../screens/sleep_analysis_screen.dart'; // Import your SleepAnalysisScreen

class SleepAnalysisItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          color: currentTheme.primaryColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(),
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(SleepAnalysisScreen.routeName);
                },
                child: SizedBox(
                  height: 150,
                  width: constraints.maxWidth * 0.65,
                  child: Center(
                    child: Icon(
                      Icons
                          .bedtime, // You can use an appropriate icon for sleep analysis
                      size: 80,
                      color: currentTheme.colorScheme
                          .tertiaryContainer, // Customize the icon color
                    ),
                  ),
                ),
              ),
              const Text(
                'Sleep Analysis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
