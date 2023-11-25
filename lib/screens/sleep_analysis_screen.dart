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
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sleep Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/night-background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hello, Parent',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  FutureBuilder<String>(
                    future: _getCurrentDateAndDay(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        return Text(
                          'Today is ${snapshot.data}',
                          style: TextStyle(
                            fontFamily: 'Medium',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                ]),
          ),
          const SizedBox(height: 20),
          Positioned(
            top: 310,
            left: 20,
            right: 20,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Current Time:',
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color.fromARGB(255, 0, 0, 0)
                                    .withOpacity(1),
                              ),
                            ),
                            Text(
                              _currentTime,
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
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
                const SizedBox(height: 5),
                SizedBox(
                  //width: MediaQuery.of(context).size.width -
                  //70, // Match the width of the Positioned widget
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              context, BabyMoodTrackerWidget.routeName);
                        },
                        child: _buildCardWithIcon(
                            'Wake-Up', 'Times', Icons.alarm_on),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWithIcon(String title, String subtitle, IconData icon) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 5,
          color: Colors.white.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.20,
            width: 168,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: Colors.black,
                  size: 40,
                ),
                //const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Medium',
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Medium',
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
