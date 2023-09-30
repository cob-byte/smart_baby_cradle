import 'package:flutter/material.dart';
import 'package:smart_baby_cradle/widgets/sleep_analysis_item.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/theme_provider.dart';
// Import the SleepAnalysisItem widget

class SleepAnalysisScreen extends StatelessWidget {
  static const routeName = '/sleep-analysis';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
        data: currentTheme,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Sleep Analysis'),
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome to Sleep Analysis!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                    height:
                        20), // You can include the SleepAnalysisItem widget here
                SizedBox(height: 20),
                // Add more content here as needed
              ],
            ),
          ),
        ));
  }
}
