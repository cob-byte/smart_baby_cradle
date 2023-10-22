import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_baby_cradle/screens/wake_up_times_screen.dart';
import 'package:smart_baby_cradle/screens/sleep_score_screen.dart';

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

  Future<String> _getCurrentDateAndDay() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, yyyy (EEEE)').format(now);
    return formattedDate;
  }

  String _getCurrentTime() {
    return DateFormat.Hm().format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove the app bar shadow
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Set the background image
            Image.asset(
              'assets/image/night-background.png',
              fit: BoxFit.cover,
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.03,
              child: Container(
                padding: EdgeInsets.all(90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Hello, Parent',
                      style: TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    FutureBuilder<String>(
                      future: _getCurrentDateAndDay(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else {
                          return Text(
                            'Today is ${snapshot.data}',
                            style: TextStyle(
                              fontFamily: 'Medium',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 190,
              left: 20,
              right: 20,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10), // Add left padding here
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Current Time:',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                _currentTime,
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/image/moon element.png',
                          height: 130,
                          width: 130,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, SleepScoreScreen.routeName);
                        },
                        child: _buildCardWithIcon(
                            'Sleep', 'Score', Icons.nightlight_round),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, WakeUpTimesScreen.routeName);
                        },
                        child: _buildCardWithIcon(
                            'Wake-Up', 'Times', Icons.alarm_on),
                      ),
                    ],
                  ),
                  SizedBox(height: 80),
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
    );
  }

  Widget _buildCardWithIcon(String title, String subtitle, IconData icon) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20), // Add spacing between cards
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: 150,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10.0),
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
        ),
      ],
    );
  }
}
