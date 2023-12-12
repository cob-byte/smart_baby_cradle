import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/screens/wake_up_times_screen.dart';
import '../services/status_service.dart';
import '../theme_provider.dart';

class SleepPatternScreen extends StatefulWidget {
  @override
  _SleepPatternScreenState createState() => _SleepPatternScreenState();
}

enum SleepInfoType {
  hoursOfSleep,
  hoursInCradle,
  wakeUpTimes,
  timePutToBed,
  sleepOnsetLatency,
  timeFellAsleep,
}

class _SleepPatternScreenState extends State<SleepPatternScreen> {
  SleepInfoType selectedSleepInfoType = SleepInfoType.hoursOfSleep;

  final List<String> daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

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
            'Sleep Pattern Graphs',
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
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 5),
                    Text(
                      '${_getTitleForGraph(selectedSleepInfoType)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: 375,
                        padding: const EdgeInsets.all(24.0),
                        color: Colors.white,
                        height: 420,
                        child: Column(
                          children: [
                            SizedBox(height: 24),
                            Expanded(
                              child: FutureBuilder<Map<String, List<SleepInfo>>>(
                                future: _getSleepInfo(),
                                builder: (BuildContext context, AsyncSnapshot<Map<String, List<SleepInfo>>> snapshot) {
                                  if (snapshot.hasData) {
                                    Map<String, List<SleepInfo>> sleepInfos = snapshot.data!;
                                    // Calculate averages and other necessary data here

                                    return LineChart(
                                      LineChartData(
                                        lineBarsData: _buildLineBarsData(sleepInfos), // Pass the fetched data to _buildLineBarsData
                                        titlesData: _buildTitlesData(),
                                        borderData: FlBorderData(show: true),
                                        gridData: FlGridData(show: true),
                                        axisTitleData: FlAxisTitleData(
                                          leftTitle: AxisTitle(
                                            showTitle: true,
                                            titleText: selectedSleepInfoType ==
                                                SleepInfoType.timePutToBed ||
                                                selectedSleepInfoType ==
                                                    SleepInfoType.wakeUpTimes ||
                                                selectedSleepInfoType ==
                                                    SleepInfoType.timeFellAsleep
                                                ? 'Time'
                                                : 'Number of Hours',
                                            margin: 2,
                                          ),
                                          bottomTitle: AxisTitle(
                                            showTitle: true,
                                            titleText: 'Days of the Week',
                                            margin: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 10),
                                ChartLegend(
                                  _getColorForSleepInfoType(selectedSleepInfoType),
                                  _getLegendText(selectedSleepInfoType),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          switch (selectedSleepInfoType) {
                            case SleepInfoType.hoursOfSleep:
                              selectedSleepInfoType =
                                  SleepInfoType.hoursInCradle;
                              break;
                            case SleepInfoType.hoursInCradle:
                              selectedSleepInfoType = SleepInfoType.wakeUpTimes;
                              break;
                            case SleepInfoType.wakeUpTimes:
                              selectedSleepInfoType =
                                  SleepInfoType.timePutToBed;
                              break;
                            case SleepInfoType.timePutToBed:
                              selectedSleepInfoType =
                                  SleepInfoType.sleepOnsetLatency;
                              break;
                            case SleepInfoType.sleepOnsetLatency:
                              selectedSleepInfoType =
                                  SleepInfoType.timeFellAsleep;
                              break;
                            case SleepInfoType.timeFellAsleep:
                              selectedSleepInfoType =
                                  SleepInfoType.hoursOfSleep;
                              break;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      icon: Icon(Icons.swap_horiz),
                      label: Text('Switch Graph'),
                    ),
                    SizedBox(height: 12),
                    _buildCombinedInsightsContainer()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildCombinedInsightsContainer() {
  Map<String, List<SleepInfo>> sleepInfos = {};

  Map<String, double> averageHoursOfSleep = _calculateAverageHoursOfSleep(sleepInfos);
  double totalAverageHours = 0;
  averageHoursOfSleep.forEach((day, hours) {
    totalAverageHours += hours;
  });
  double overallAverageHours = totalAverageHours / averageHoursOfSleep.length;

  String currentAgeCategory = 'New Born (0-4 weeks)';
  
  Map<String, double> averageTimeFellAsleep = _calculateAverageTimeFellAsleep(sleepInfos);
  List<double> averageTimeList = _convertMapToList(averageTimeFellAsleep);
  List<DateTime> averageTimeDateTime = _convertListToDateTime(averageTimeList);

  List<Map<String, String>> ageCategories = [
    {'age': 'New Born (0-4 weeks)', 'range': '14-18 hours'},
    {'age': '1 month – 2 months', 'range': '11-15 hours'},
    {'age': '3 months to 5 months', 'range': '12-16 hours'},
    {'age': '6 months to 1 year old', 'range': '12-14 hours'},
  ];

  String generateSleepInsightsText(double lowerRange, double upperRange, double averageHours) {
    if (averageHours >= lowerRange && averageHours <= upperRange) {
      return "Congratulations! Your baby's sleep falls within the recommended range. This is beneficial for their overall health and development. Continue maintaining a consistent sleep schedule, providing a calming bedtime routine, and monitoring for any changes in their sleep patterns or behaviors.";
    } else if (averageHours < lowerRange) {
      return "Your baby may be getting less sleep than recommended. Inadequate sleep can impact their growth, mood, and cognitive development. Ensure a quiet, dimly lit sleep environment. Establish a consistent bedtime routine, soothing activities, and try to identify and address any potential discomfort or disruptions affecting their sleep.";
    } else {
      return "Your baby is sleeping more than the recommended amount. While sufficient sleep is crucial, excessive sleep might be a concern. Ensure your baby is active during waking hours with interactive play and tummy time. Monitor for any signs of lethargy or unusual behaviors. If you notice prolonged changes in sleep patterns, consider consulting with your pediatrician to rule out any underlying issues.";
    }
  }

  String generateTimeFellAsleepInsightsText(DateTime lowerRange, DateTime upperRange, DateTime averageTime) {
    if (averageTime.isAfter(lowerRange) && averageTime.isBefore(upperRange)) {
      return "Your baby's bedtime falls within the recommended range, which is excellent for their sleep routine. Keep up the good work! Continue with a consistent bedtime routine, create a comfortable sleep space, and monitor for any signs of restlessness or changes in sleep patterns.";
    } else if (averageTime.isBefore(lowerRange)) {
      return "Your baby's bedtime is earlier than the recommended range. While early bedtime can be beneficial, ensure your baby is getting enough wakeful hours during the day for developmental activities. If you notice any disturbances in their sleep patterns or if they seem overly sleepy during the day, consider adjusting bedtime in consultation with your pediatrician.";
    } else {
      return "It seems your baby's bedtime is later than the recommended range. Adjusting bedtime earlier can contribute to better sleep quality. Ensure a calming bedtime routine, dim the lights, and create a soothing sleep environment to help your baby wind down and sleep more soundly.";
    }
  }

  String sleepInsightsText;
  if (currentAgeCategory == 'New Born (0-4 weeks)') {
    sleepInsightsText = generateSleepInsightsText(14, 18, overallAverageHours);
  } else if (currentAgeCategory == '1 month – 2 months') {
    sleepInsightsText = generateSleepInsightsText(11, 15, overallAverageHours);
  } else if (currentAgeCategory == '3 months to 5 months') {
    sleepInsightsText = generateSleepInsightsText(12, 16, overallAverageHours);
  } else if (currentAgeCategory == '6 months to 1 year old') {
    sleepInsightsText = generateSleepInsightsText(12, 14, overallAverageHours);
  } else {
    sleepInsightsText = "Invalid age category"; // Handle unknown age categories
  }

  String timeFellAsleepInsightsText;
  if (currentAgeCategory == 'New Born (0-4 weeks)') {
    timeFellAsleepInsightsText = generateTimeFellAsleepInsightsText(DateTime(2023, 1, 1, 21, 0), DateTime(2023, 1, 1, 23, 0), averageTimeDateTime[0]);
  } else if (currentAgeCategory == '1 month – 4 months') {
    timeFellAsleepInsightsText = generateTimeFellAsleepInsightsText(DateTime(2023, 1, 1, 20, 0), DateTime(2023, 1, 1, 23, 0), averageTimeDateTime[0]);
  } else if (currentAgeCategory == '5 months to 8 months') {
    timeFellAsleepInsightsText = generateTimeFellAsleepInsightsText(DateTime(2023, 1, 1, 18, 0), DateTime(2023, 1, 1, 19, 30), averageTimeDateTime[0]);
  } else if (currentAgeCategory == '9 months to 1 year old') {
    timeFellAsleepInsightsText = generateTimeFellAsleepInsightsText(DateTime(2023, 1, 1, 18, 0), DateTime(2023, 1, 1, 20, 0), averageTimeDateTime[0]);
  } else {
    timeFellAsleepInsightsText = "Invalid age category"; // Handle unknown age categories
  }

  return Container(
    width: 400,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sleep Insights:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(sleepInsightsText,
        textAlign: TextAlign.justify,),
        SizedBox(height: 10),
        Text(timeFellAsleepInsightsText,
        textAlign: TextAlign.justify,),
        SizedBox(height: 10),
        Text(
          "Disclaimer:",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Remember, these are general guidelines, and each baby is unique. Always consult with your pediatrician for personalized advice based on your baby's specific needs and circumstances.",
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}


  String _getTitleForGraph(SleepInfoType type) {
    switch (type) {
      case SleepInfoType.hoursOfSleep:
        return 'Hours of Sleep';
      case SleepInfoType.hoursInCradle:
        return 'Hours in Cradle';
      case SleepInfoType.wakeUpTimes:
        return 'Wake Up Times';
      case SleepInfoType.timePutToBed:
        return 'Time Put to Bed';
      case SleepInfoType.sleepOnsetLatency:
        return 'Sleep Onset Latency';
      case SleepInfoType.timeFellAsleep:
        return 'Time Fell Asleep';
    }
  }

  String _getLegendText(SleepInfoType type) {
    switch (type) {
      case SleepInfoType.hoursOfSleep:
        return 'Sleep Duration';
      case SleepInfoType.hoursInCradle:
        return 'Hours in Cradle';
      case SleepInfoType.wakeUpTimes:
        return 'Wake-up Times';
      case SleepInfoType.timePutToBed:
        return 'Time put to Bed';
      case SleepInfoType.sleepOnsetLatency:
        return 'Sleep Onset Latency';
      case SleepInfoType.timeFellAsleep:
        return 'Time Fell Asleep';
    }
  }

  Map<String, double> _calculateAverageHoursOfSleep(Map<String, List<SleepInfo>> sleepInfos) {
    Map<String, double> averages = {};

    sleepInfos.forEach((day, infos) {
      double totalHoursOfSleep = 0;

      infos.forEach((info) {
        if (info.timeFellAsleep != null && info.wakeUpTime != null) {
          Duration fellAsleep = Duration(hours: info.timeFellAsleep.hour, minutes: info.timeFellAsleep.minute);
          Duration wokeUp = Duration(hours: info.wakeUpTime.hour, minutes: info.wakeUpTime.minute);
          if (wokeUp < fellAsleep) {
            wokeUp += Duration(hours: 24);
          }
          totalHoursOfSleep += (wokeUp.inMinutes - fellAsleep.inMinutes) / 60;
        }
      });

      averages[day] = infos.isNotEmpty ? totalHoursOfSleep / infos.length : 0;
    });

    return averages;
  }

  Map<String, double> _calculateAverageHoursInCradle(Map<String, List<SleepInfo>> sleepInfos) {
    Map<String, double> averages = {};

    sleepInfos.forEach((day, infos) {
      double totalHoursInCradle = 0;

      infos.forEach((info) {
        if (info.timePutToBed != null && info.wakeUpTime != null) {
          Duration putToBed = Duration(hours: info.timePutToBed.hour, minutes: info.timePutToBed.minute);
          Duration wokeUp = Duration(hours: info.wakeUpTime.hour, minutes: info.wakeUpTime.minute);
          if (wokeUp < putToBed) {
            wokeUp += Duration(hours: 24);
          }
          totalHoursInCradle += (wokeUp.inMinutes - putToBed.inMinutes) / 60;
        }
      });

      averages[day] = infos.isNotEmpty ? totalHoursInCradle / infos.length : 0;
    });

    return averages;
  }

  Map<String, double> _calculateAverageSleepOnsetLatency(Map<String, List<SleepInfo>> sleepInfos) {
    Map<String, double> averages = {};

    sleepInfos.forEach((day, infos) {
      double totalSleepOnsetLatency = 0;

      infos.forEach((info) {
        if (info.timePutToBed != null && info.timeFellAsleep != null) {
          Duration putToBed = Duration(hours: info.timePutToBed.hour, minutes: info.timePutToBed.minute);
          Duration fellAsleep = Duration(hours: info.timeFellAsleep.hour, minutes: info.timeFellAsleep.minute);
          if (fellAsleep < putToBed) {
            fellAsleep += Duration(hours: 24);
          }
          totalSleepOnsetLatency += (fellAsleep.inMinutes - putToBed.inMinutes) / 60;
        }
      });

      averages[day] = infos.isNotEmpty ? totalSleepOnsetLatency / infos.length : 0;
    });

    return averages;
  }

  Map<String, double> _calculateAverageWakeUpTimes(Map<String, List<SleepInfo>> sleepInfos) {
    Map<String, double> averages = {};

    sleepInfos.forEach((day, infos) {
      double totalWakeUpTimes = 0;

      infos.forEach((info) {
        if (info.wakeUpTime != null) {
          totalWakeUpTimes += info.wakeUpTime.hour * 60 + info.wakeUpTime.minute;
        }
      });

      averages[day] = infos.isNotEmpty ? totalWakeUpTimes / infos.length : 0;
    });

    return averages;
  }

  Map<String, double> _calculateAverageTimePutToBed(Map<String, List<SleepInfo>> sleepInfos) {
    Map<String, double> averages = {};

    sleepInfos.forEach((day, infos) {
      double totalTimePutToBed = 0;

      infos.forEach((info) {
        if (info.timePutToBed != null) {
          totalTimePutToBed += info.timePutToBed.hour * 60 + info.timePutToBed.minute;
        }
      });

      averages[day] = infos.isNotEmpty ? totalTimePutToBed / infos.length : 0;
    });

    return averages;
  }

  Map<String, double> _calculateAverageTimeFellAsleep(Map<String, List<SleepInfo>> sleepInfos) {
    Map<String, double> averages = {};

    sleepInfos.forEach((day, infos) {
      double totalTimeFellAsleep = 0;

      infos.forEach((info) {
        if (info.timeFellAsleep != null) {
          totalTimeFellAsleep += info.timeFellAsleep.hour * 60 + info.timeFellAsleep.minute;
        }
      });

      averages[day] = infos.isNotEmpty ? totalTimeFellAsleep / infos.length : 0;
    });

    return averages;
  }

  List<double> _convertMapToList(Map<String, double> map) {
    List<String> orderedKeys = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return orderedKeys.map((key) => map[key] ?? 0).toList();
  }

  List<DateTime> _convertListToDateTime(List<double> list) {
    return list.map((minutesPastMidnight) {
      int hours = (minutesPastMidnight / 60).floor();
      int minutes = (minutesPastMidnight % 60).floor();
      return DateTime(2023, 1, 1, hours, minutes);
    }).toList();
  }

  List<LineChartBarData> _buildLineBarsData(Map<String, List<SleepInfo>> sleepInfos) {
    List<LineChartBarData> lineBarsData = [];

    // Calculate averages for each day of the week
    Map<String, double> averageHoursOfSleep = _calculateAverageHoursOfSleep(sleepInfos);
    List<double> hoursOfSleepD = _convertMapToList(averageHoursOfSleep);

    Map<String, double> averageHoursInCradle = _calculateAverageHoursInCradle(sleepInfos);
    List<double> hoursInCradleD = _convertMapToList(averageHoursInCradle);

    Map<String, double> averageSleepLatency = _calculateAverageSleepOnsetLatency(sleepInfos);
    List<double> sleepLatencyD = _convertMapToList(averageSleepLatency);

    Map<String, double> averageWakeUpTimes = _calculateAverageWakeUpTimes(sleepInfos);
    List<double> wakeUpTimesD = _convertMapToList(averageWakeUpTimes);

    Map<String, double> averageTimePutToBed = _calculateAverageTimePutToBed(sleepInfos);
    List<double> timePutToBedD = _convertMapToList(averageTimePutToBed);

    Map<String, double> averageTimeFellAsleep = _calculateAverageTimeFellAsleep(sleepInfos);
    List<double> timeFellAsleepD = _convertMapToList(averageTimeFellAsleep);


    switch (selectedSleepInfoType) {
      case SleepInfoType.hoursOfSleep:
        lineBarsData.add(
          LineChartBarData(
            spots: _buildSpots(hoursOfSleepD),
            isCurved: false,
            colors: [Color.fromARGB(255, 0, 2, 122)],
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            isStrokeCapRound: true,
          ),
        );
        break;
      case SleepInfoType.hoursInCradle:
        lineBarsData.add(
          LineChartBarData(
            spots: _buildSpots(hoursInCradleD),
            isCurved: false,
            colors: [Color.fromARGB(255, 255, 167, 52)],
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            isStrokeCapRound: true,
          ),
        );
        break;
      case SleepInfoType.wakeUpTimes:
        lineBarsData.add(
          LineChartBarData(
            spots: _buildDateTimeSpots(_convertListToDateTime(wakeUpTimesD)),
            isCurved: false,
            colors: [Colors.green],
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            isStrokeCapRound: true,
          ),
        );
        break;
      case SleepInfoType.timePutToBed:
        lineBarsData.add(
          LineChartBarData(
            spots: _buildDateTimeSpots(_convertListToDateTime(timePutToBedD)),
            isCurved: false,
            colors: [Colors.orange],
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            isStrokeCapRound: true,
          ),
        );
        break;
      case SleepInfoType.sleepOnsetLatency:
        lineBarsData.add(
          LineChartBarData(
            spots: _buildSpots(sleepLatencyD),
            isCurved: false,
            colors: [Colors.purple],
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            isStrokeCapRound: true,
          ),
        );
        break;
      case SleepInfoType.timeFellAsleep:
        lineBarsData.add(
          LineChartBarData(
            spots: _buildDateTimeSpots(_convertListToDateTime(timeFellAsleepD)),
            isCurved: false,
            colors: [Colors.red],
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            isStrokeCapRound: true,
          ),
        );
        break;
    }

    return lineBarsData;
  }

  List<FlSpot> _buildDateTimeSpots(List<DateTime> data) {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      double time = data[i].hour + data[i].minute / 60.0;
      spots.add(FlSpot(i.toDouble(), time));
    }

    return spots;
  }

  List<FlSpot> _buildSpots(List<double> data) {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return spots;
  }

  Color _getColorForSleepInfoType(SleepInfoType type) {
    switch (type) {
      case SleepInfoType.hoursOfSleep:
        return Color.fromARGB(255, 0, 2, 122);
      case SleepInfoType.hoursInCradle:
        return Color.fromARGB(255, 255, 167, 52);
      case SleepInfoType.wakeUpTimes:
        return Colors.green;
      case SleepInfoType.timePutToBed:
        return Colors.orange;
      case SleepInfoType.sleepOnsetLatency:
        return Colors.purple;
      case SleepInfoType.timeFellAsleep:
        return Colors.red;
    }
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
        interval: 2,
        reservedSize: 70,
        getTitles: (value) {
          if (selectedSleepInfoType == SleepInfoType.timePutToBed ||
              selectedSleepInfoType == SleepInfoType.wakeUpTimes ||
              selectedSleepInfoType == SleepInfoType.timeFellAsleep) {
            int totalMinutes = (value * 60).toInt();
            int hour = (totalMinutes / 60).toInt() % 12;
            hour = hour != 0 ? hour : 12; // To display 12 instead of 0
            String period = totalMinutes >= 720 ? 'PM' : 'AM';
            int minute = totalMinutes % 60;
            String formattedTime = '$hour:${minute.toString().padLeft(2, '0')}';
            return '$formattedTime $period';
          } else {
            return (value.toInt() % 25).toString();
          }
        },
        margin: 5, // Increase this margin as needed
      ),
      bottomTitles: SideTitles(
        showTitles: true,
        interval: 1,
        getTitles: (value) {
          if (value >= 0 && value < daysOfWeek.length) {
            return daysOfWeek[value.toInt()];
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
    home: SleepPatternScreen(),
  ));
}
