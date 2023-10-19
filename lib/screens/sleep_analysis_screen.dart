import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class SleepAnalysisScreen extends StatefulWidget {
  static const routeName = '/sleep-analysis';

  @override
  _SleepAnalysisScreenState createState() => _SleepAnalysisScreenState();
}

class _SleepAnalysisScreenState extends State<SleepAnalysisScreen> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    // Initialize the time and start the timer to update it every second
    _currentTime = _getCurrentTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is removed from the tree
    _timer.cancel();
    super.dispose();
  }

  String _getCurrentTime() {
    return DateFormat.Hm().format(DateTime.now());
  }

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
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Set the background image
              Image.asset(
                'assets/image/sleep-background.jpg',
                fit: BoxFit.cover,
              ),
              // Position the moon element at the center of the screen
              Positioned(
                top: 50,
                child: Image.asset(
                  'assets/image/moon element.png',
                  height: 200,
                  width: 200,
                ),
              ),
              // Positioned the Row closer to the moon element
              Positioned(
                top: 270,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Current Time: $_currentTime',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10), // Add spacing between texts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.alarm,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(
                          width: 10,
                        ), // Add spacing between icon and text
                        Text(
                          'Alarm Time: 07:00 AM',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20), // Add spacing between texts and cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildCardWithIcon(
                            'Sleep', 'Score', Icons.nightlight_round),
                        _buildCardWithIcon('Wake-Up', 'Times', Icons.alarm_on),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ), // Spacing between cards and button
                    InkWell(
                      onTap: () {
                        // Add functionality for the button tap
                        // For example, navigate to another screen or perform an action
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(
                          Icons.keyboard_double_arrow_up_rounded,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWithIcon(String title, String subtitle, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: 150,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 252, 255, 156),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.black,
                size: 36,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Medium',
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Medium',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
