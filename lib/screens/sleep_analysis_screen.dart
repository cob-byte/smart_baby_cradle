import 'package:flutter/material.dart';
import 'package:smart_baby_cradle/widgets/sleep_analysis_item.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class SleepAnalysisScreen extends StatelessWidget {
  static const routeName = '/sleep-analysis';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    // Get the current time and date
    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month}-${now.day}';
    final formattedTime = '${now.hour}:${now.minute}';

    // Replace this value with your actual sleep quality percentage
    final sleepQualityPercentage = 85.0;

    // Replace this value with the actual sleep duration
    final sleepDurationHours = 8;
    final sleepDurationMinutes = 30;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sleep Analysis'),
        ),
        body: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align content at the top
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Rectangle with gradient background for current time and date
            Container(
              width: double.infinity, // Occupies the whole width
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Date: $formattedDate', // Display the formatted date
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.wb_sunny, // You can replace with a moon icon
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Time: $formattedTime', // Display the formatted time
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Rounded rectangle with gradient background for sleep quality
            Container(
              width: 300, // Adjust the width as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Sleep Quality',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.star, // You can replace with an appropriate icon
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Stack to place the percentage text inside the progress indicator
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: sleepQualityPercentage / 100.0,
                          strokeWidth: 8,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      Text(
                        '${sleepQualityPercentage.round()}%', // Display the sleep quality percentage
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Rounded rectangle with gradient background for sleep duration
            Container(
              width: 300, // Adjust the width as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Sleep Duration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.access_time, // You can replace with a clock icon
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$sleepDurationHours hours $sleepDurationMinutes minutes', // Replace with the actual sleep duration
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
