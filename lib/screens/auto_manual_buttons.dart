import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../services/status_service.dart';
import '../theme_provider.dart';
import 'package:smart_baby_cradle/screens/wake_up_times_screen.dart';
import 'package:smart_baby_cradle/screens/auto_tracker.dart';


void main() {
  runApp(MaterialApp(
    home: SleepTrackingScreen(),
  ));
}

class SleepTrackingScreen extends StatefulWidget {
  static const routeName = '/sleep-tracking';

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sleep Tracking',
            style: currentTheme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: currentTheme.appBarTheme.backgroundColor,
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      currentTheme.colorScheme.primary,
                      currentTheme.colorScheme.secondary,
                      currentTheme.colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -30,
              child: Image(
                image: AssetImage('assets/image/cradle_bg.png'),
                width: 300,
                height: 300,
              ),
            ),
            SizedBox(height: 100),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24.0),
          color: Colors.transparent,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AutoTrackerScreen.routeName,
                  );
                },
                child: Container(
                  width: 250,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20), // Adjust the value for more rounded corners
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_fix_high,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10), // Adjust the spacing between the icon and text
                        Text(
                          'Auto Sleep Tracking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Handle manual sleep tracking button tap
                  Navigator.pushNamed(
                    context,
                    BabySleepTrackerWidget.routeName,
                  );
                },
                child: Container(
                  width: 250,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20), // Adjust the value for more rounded corners
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.track_changes,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10), // Adjust the spacing between the icon and text
                        Text(
                          'Manual Sleep Tracking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
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
