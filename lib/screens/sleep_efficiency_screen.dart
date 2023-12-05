import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/screens/wake_up_times_screen.dart';
import '../services/status_service.dart';
import '../theme_provider.dart';

class SleepEfficiencyScreen extends StatelessWidget {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> daysShorten = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  // Dummy data for sleep efficiency, hours of sleep, and hours in cradle
  final List<double> hoursOfSleepData = [8, 7, 6, 9, 5, 10, 8];
  final List<double> hoursInCradleData = [9, 8, 7, 10, 6, 11, 9];

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sleep Efficiency',
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                      Text(
                      'Sleep Efficiency Graph',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white, // Set the background color to white
                      height: 300, // Adjust the height as needed
                      child: Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<Map<String, List<SleepInfo>>>(
                              future: _getSleepInfo(),
                              builder: (BuildContext context, AsyncSnapshot<Map<String, List<SleepInfo>>> snapshot) {
                                if (snapshot.hasData) {
                                  Map<String, List<SleepInfo>> sleepInfos = snapshot.data!;
                                  List<List<double>> hoursOfSleepData = List.generate(daysOfWeek.length, (index) => []);
                                  List<List<double>> hoursInCradleData = List.generate(daysOfWeek.length, (index) => []);

                                  sleepInfos.forEach((day, infos) {
                                    int index = daysOfWeek.indexOf(day);
                                    if (index != -1) {
                                      hoursOfSleepData[index] = infos.map((info) {
                                        Duration fellAsleep = Duration(hours: info.timeFellAsleep.hour, minutes: info.timeFellAsleep.minute);
                                        Duration wokeUp = Duration(hours: info.wakeUpTime.hour, minutes: info.wakeUpTime.minute);
                                        if (wokeUp < fellAsleep) {
                                          wokeUp += Duration(hours: 24);
                                        }
                                        return (wokeUp.inMinutes - fellAsleep.inMinutes) / 60;
                                      }).toList();

                                      hoursInCradleData[index] = infos.map((info) {
                                        Duration putToBed = Duration(hours: info.timePutToBed.hour, minutes: info.timePutToBed.minute);
                                        Duration wokeUp = Duration(hours: info.wakeUpTime.hour, minutes: info.wakeUpTime.minute);
                                        if (wokeUp < putToBed) {
                                          wokeUp += Duration(hours: 24);
                                        }
                                        return (wokeUp.inMinutes - putToBed.inMinutes)/60;
                                      }).toList();
                                    }
                                  });

                                  return BarChart(
                                    BarChartData(
                                      barGroups: _buildBarGroups(hoursOfSleepData, hoursInCradleData),
                                      titlesData: _buildTitlesData(),
                                      borderData: FlBorderData(show: true),
                                      axisTitleData: FlAxisTitleData(
                                        leftTitle: AxisTitle(
                                          showTitle: true,
                                          titleText: 'Number of hours',
                                          margin: 12,
                                        ),
                                        bottomTitle: AxisTitle(
                                          showTitle: true,
                                          titleText: 'Days of the Week',
                                          margin: 4,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // Return a loading indicator while waiting for the future to complete
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ChartLegend(Color.fromARGB(255, 0, 2, 122), 'Hours of Sleep'),
                              SizedBox(width: 10),
                              ChartLegend(Color.fromARGB(255, 255, 167, 52), 'Hours in Cradle'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Details for Each Day',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            height: 300, // Adjust the height as needed
                            child: FutureBuilder<Map<String, List<SleepInfo>>>(
                              future: _getSleepInfo(),
                              builder: (BuildContext context, AsyncSnapshot<Map<String, List<SleepInfo>>> snapshot) {
                                if (snapshot.hasData) {
                                  Map<String, List<SleepInfo>> sleepInfos = snapshot.data!;
                                  List<List<double>> hoursOfSleepData = List.generate(daysOfWeek.length, (index) => []);
                                  List<List<double>> hoursInCradleData = List.generate(daysOfWeek.length, (index) => []);

                                  sleepInfos.forEach((day, infos) {
                                    int index = daysOfWeek.indexOf(day);
                                    if (index != -1) {
                                      hoursOfSleepData[index] = infos.isNotEmpty ? infos.map((info) {
                                        Duration fellAsleep = Duration(hours: info.timeFellAsleep.hour, minutes: info.timeFellAsleep.minute);
                                        Duration wokeUp = Duration(hours: info.wakeUpTime.hour, minutes: info.wakeUpTime.minute);
                                        if (wokeUp < fellAsleep) {
                                          wokeUp += Duration(hours: 24);
                                        }
                                        return (wokeUp.inMinutes - fellAsleep.inMinutes) / 60;
                                      }).toList() : [0.0];

                                      hoursInCradleData[index] = infos.isNotEmpty ? infos.map((info) {
                                        Duration putToBed = Duration(hours: info.timePutToBed.hour, minutes: info.timePutToBed.minute);
                                        Duration wokeUp = Duration(hours: info.wakeUpTime.hour, minutes: info.wakeUpTime.minute);
                                        if (wokeUp < putToBed) {
                                          wokeUp += Duration(hours: 24);
                                        }
                                        return (wokeUp.inMinutes - putToBed.inMinutes)/60;
                                      }).toList() : [0.0];
                                    }
                                  });

                                  return ListView.builder(
                                    // Wrap content
                                    scrollDirection: Axis.vertical,
                                    itemCount: daysOfWeek.length,
                                    itemBuilder: (context, index) {
                                      double sleepEfficiency =
                                          (hoursOfSleepData[index].isNotEmpty ? hoursOfSleepData[index].reduce((a, b) => a + b) : 0) /
                                              (hoursInCradleData[index].isNotEmpty ? hoursInCradleData[index].reduce((a, b) => a + b) : 1) *
                                              100;

                                      return Card(
                                        color: Theme.of(context).colorScheme.surfaceTint,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    daysOfWeek[index],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text('Hours of Sleep: ${hoursOfSleepData[index].isNotEmpty ? hoursOfSleepData[index].reduce((a, b) => a + b) : 0}'),
                                                  Text('Hours Spent in Cradle: ${hoursInCradleData[index].isNotEmpty ? hoursInCradleData[index].reduce((a, b) => a + b) : 0}'),
                                                ],
                                              ),
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _getColorForPercentage(sleepEfficiency),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${sleepEfficiency.toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // Return a loading indicator while waiting for the future to complete
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<List<double>> hoursOfSleepData, List<List<double>> hoursInCradleData) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < daysOfWeek.length; i++) {
      double hoursOfSleep = hoursOfSleepData[i].isEmpty ? 0 : hoursOfSleepData[i].reduce((a, b) => a + b);
      double hoursInCradle = hoursInCradleData[i].isEmpty ? 0 : hoursInCradleData[i].reduce((a, b) => a + b);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: hoursOfSleep,
              colors: [Color.fromARGB(255, 0, 2, 122)],
              width: 16,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              y: hoursInCradle,
              colors: [const Color.fromARGB(255, 255, 167, 52)],
              width: 16,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage < 50) {
      return Colors.red;
    } else if (percentage < 75) {
      return Colors.yellow;
    } else if (percentage < 90) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      rightTitles: SideTitles(showTitles: false),
      topTitles: SideTitles(showTitles: false),
      leftTitles: SideTitles(
        showTitles: true,
        interval: 10, // Set the interval to 2
      ),
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (value) {
          if (value >= 0 && value < daysShorten.length) {
            return daysShorten[value.toInt()];
          }
          return '';
        },
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  final Color color;
  final String text;

  ChartLegend(this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SleepEfficiencyScreen(),
  ));
}
