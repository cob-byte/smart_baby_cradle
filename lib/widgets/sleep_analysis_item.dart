import 'package:flutter/material.dart';
import 'package:smart_baby_cradle/theme_provider.dart';
import 'package:provider/provider.dart';
import '../screens/sleep_analysis_screen.dart'; // Import your SleepAnalysisScreen

import '../services/controller_service.dart';

class SleepAnalysisItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Scaffold(
      body: Theme(
        data: currentTheme,
        child: Center(
          child: Container(
            height: 200, // Set a fixed height for the container
            width: 200, // Set a fixed width for the container
            decoration: BoxDecoration(
              color: currentTheme.colorScheme.onTertiary,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(SleepAnalysisScreen.routeName);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.bedtime,
                    size: 80,
                    color: currentTheme.colorScheme.tertiaryContainer,
                  ),
                  const SizedBox(height: 30),
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
        ),
      ),
    );
  }
}
