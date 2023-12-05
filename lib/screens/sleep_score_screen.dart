import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_baby_cradle/screens/sleep_pattern_screen.dart';
import 'package:smart_baby_cradle/screens/sleep_efficiency_screen.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/screens/wake_up_times_screen.dart';
import '../services/status_service.dart';
import '../theme_provider.dart';
import 'package:intl/intl.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SleepScoreScreen(),
      ),
    );

class SleepScoreScreen extends StatelessWidget {
  static const routeName = '/sleep-score';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sleep Score',
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
              bottom: -60,
              right: -50,
              child: Image(
                image: AssetImage('assets/image/cradle_bg.png'),
                width: 200,
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SleepQualityCard(),
                    SizedBox(height: 16),
                    SleepPatternCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, List<SleepInfo>>> _getSleepInfo() async {
  String? deviceID = await auth.getDeviceID();

  Map<String, List<SleepInfo>> sleepInfos = {};

  if (deviceID != null) {
    // Fetch sleep info data from Firebase
    DataSnapshot snapshot;
    try {
      snapshot = (await FirebaseDatabase.instance
          .ref()
          .child("devices")
          .child(deviceID)
          .child("tracker")
          .once()).snapshot;
    } catch (e) {
      print("Failed to fetch data from Firebase: $e");
      return sleepInfos;
    }

    if (snapshot.value != null) {
      Map<dynamic, dynamic> sleepData = snapshot.value as Map<dynamic, dynamic>;
      sleepData.forEach((key, value) {
        try {
          // key is the date
          DateTime date = DateTime.parse(key);
          String dayOfWeek = DateFormat('EEEE').format(date); // 'EEEE' gives full name of the day of week ex Monday Tuesday wed etc
          // value is a map of timestamps
          Map<dynamic, dynamic> timestamps = value as Map<dynamic, dynamic>;
          timestamps.forEach((timestamp, sleepInfoData) {
            // Convert data from Firebase to SleepInfo object
            SleepInfo info = SleepInfo(
              _parseTimeOfDay(sleepInfoData['timePutToBed']),
              _parseTimeOfDay(sleepInfoData['timeFellAsleep']),
              _parseTimeOfDay(sleepInfoData['wakeUpTime']),
            );

            // If there's no list for this day of the week, create one
            if (!sleepInfos.containsKey(dayOfWeek)) {
              sleepInfos[dayOfWeek] = [];
            }

            // Add the SleepInfo object to the list for this day of the week
            sleepInfos[dayOfWeek]!.add(info);
          });
        } catch (e) {
          print("Failed to parse sleep info data: $e");
        }
      });
    }
  }

  return sleepInfos;
}

TimeOfDay _parseTimeOfDay(String timeString) {
  List<String> parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

class SleepQualityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Overall Sleep Quality Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            FutureBuilder<Map<String, List<SleepInfo>>>(
              future: _getSleepInfo(),
              builder: (BuildContext context, AsyncSnapshot<Map<String, List<SleepInfo>>> snapshot) {
                if (snapshot.hasData) {
                  Map<String, List<SleepInfo>> sleepInfos = snapshot.data!;
                  double totalHoursOfSleep = 0;
                  double totalHoursInCradle = 0;
                  int totalAwakenings = 0;

                  sleepInfos.forEach((day, infos) {
                    infos.forEach((info) {
                      Duration fellAsleep = Duration(hours: info.timeFellAsleep.hour, minutes: info.timeFellAsleep.minute);
                      Duration wokeUp = Duration(hours: info.wakeUpTime.hour, minutes: info.wakeUpTime.minute);
                      if (wokeUp < fellAsleep) {
                        wokeUp += Duration(hours: 24);
                      }
                      totalHoursOfSleep += (wokeUp.inMinutes - fellAsleep.inMinutes) / 60;

                      Duration putToBed = Duration(hours: info.timePutToBed.hour, minutes: info.timePutToBed.minute);
                      if (wokeUp < putToBed) {
                        wokeUp += Duration(hours: 24);
                      }
                      totalHoursInCradle += (wokeUp.inMinutes - putToBed.inMinutes) / 60;

                      totalAwakenings++;
                    });
                  });

                  double sleepEfficiency = (totalHoursOfSleep / totalHoursInCradle) * 100;

                  return Column(
                    children: [
                      SleepInfoRow(
                          icon: Icons.access_time,
                          label: 'Sleep Efficiency',
                          value: '${sleepEfficiency.toStringAsFixed(1)}%'),
                      SizedBox(height: 16),
                      Container(
                        height: 200,
                        child: Row(
                          children: [
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: totalHoursOfSleep,
                                      color: Colors.blue,
                                      title: 'Sleep',
                                      radius: 50,
                                    ),
                                    PieChartSectionData(
                                      value: totalHoursInCradle,
                                      color: Colors.red,
                                      title: 'In Bed',
                                      radius: 50,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PieChartPercentage(label: 'Sleep', percentage: '${(totalHoursOfSleep / (totalHoursOfSleep + totalHoursInCradle) * 100).toStringAsFixed(1)}%'),
                                PieChartPercentage(label: 'In Bed', percentage: '${(totalHoursInCradle / (totalHoursOfSleep + totalHoursInCradle) * 100).toStringAsFixed(1)}%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      SleepInfoRow(
                          icon: Icons.nightlight_round,
                          label: 'Total Tracked Sleep',
                          value: '$totalAwakenings'),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Return a loading indicator while waiting for the future to complete
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SleepEfficiencyScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: Size(10, 35),
              ),
              icon: Icon(Icons.expand_more),
              label: Text('See More'),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartPercentage extends StatelessWidget {
  final String label;
  final String percentage;

  PieChartPercentage({required this.label, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: label == 'Sleep' ? Colors.blue : Colors.red,
          ),
          SizedBox(width: 8),
          Text(
            '$label: $percentage',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class SleepPatternCard extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    // DUMMY DATA
    DateTime sleepStartTime = DateTime.parse('2023-01-01 22:00:00');
    DateTime sleepEndTime = DateTime.parse('2023-01-02 06:00:00');
    DateTime sleepOnsetTime = DateTime.parse('2023-01-01 22:15:00');

    // Calculate sleep duration
    Duration sleepDuration = sleepEndTime.difference(sleepStartTime);
    int hours = sleepDuration.inHours;
    int minutes = sleepDuration.inMinutes.remainder(60);

    // Calculate sleep onset latency
    Duration sleepOnsetLatency = sleepOnsetTime.difference(sleepStartTime);
    int onsetMinutes = sleepOnsetLatency.inMinutes;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sleep Pattern Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SleepInfoRow(
                icon: Icons.access_time,
                label: 'Time Put to Bed',
                value: '${DateFormat.jm().format(sleepStartTime)}'),
            SizedBox(height: 16),
            SleepInfoRow(
                icon: Icons.access_time,
                label: 'Time Fell Asleep',
                value:
                    '${DateFormat.jm().format(sleepOnsetTime)}'), // Use sleep onset time
            SizedBox(height: 16),
            SleepInfoRow(
                icon: Icons.wb_sunny,
                label: 'Wake Up Time',
                value: '${DateFormat.jm().format(sleepEndTime)}'),
            SizedBox(height: 16),
            SleepInfoRow(
                icon: Icons.hourglass_empty,
                label: 'Sleep Duration',
                value: '$hours hours and $minutes minutes'),
            SizedBox(height: 16),
            SleepInfoRow(
                icon: Icons.hourglass_empty,
                label: 'Sleep Onset Latency',
                value: '$onsetMinutes minutes'),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SleepPatternScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: Size(10, 35),
              ),
              icon: Icon(Icons.expand_more),
              label: Text('See More'),
            ),
          ],
        ),
      ),
    );
  }
}

class SleepInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  SleepInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
