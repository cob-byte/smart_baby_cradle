import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
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
  final List<double> hoursOfSleepData = [8, 7, 6, 9, 5, 10, 8];
  final List<double> hoursInCradleData = [9, 8, 7, 10, 6, 11, 9];
  final List<double> sleepOnsetLatencyData = [15, 10, 20, 12, 23, 18, 15];
  final List<DateTime> wakeUpTimesData = [
    DateTime(2023, 1, 1, 7, 0), // 7:00 AM
    DateTime(2023, 1, 1, 6, 30), // 6:30 AM
    DateTime(2023, 1, 1, 8, 0), // 8:00 AM
    DateTime(2023, 1, 1, 7, 30), // 7:30 AM
    DateTime(2023, 1, 1, 6, 0), // 6:00 AM
    DateTime(2023, 1, 1, 8, 30), // 8:30 AM
    DateTime(2023, 1, 1, 7, 0), // 7:00 AM
  ];

  final List<DateTime> timePutToBedData = [
    DateTime(2023, 1, 1, 23, 0), // 11:00 PM
    DateTime(2023, 1, 1, 22, 0), // 10:00 PM
    DateTime(2023, 1, 1, 23, 30), // 11:30 PM
    DateTime(2023, 1, 1, 22, 30), // 10:30 PM
    DateTime(2023, 1, 1, 22, 0), // 10:00 PM
    DateTime(2023, 1, 1, 24, 0), // 12:00 AM
    DateTime(2023, 1, 1, 23, 0), // 11:00 PM
  ];

  final List<DateTime> timeFellAsleepData = [
    DateTime(2023, 1, 1, 23, 15), // 11:15 PM
    DateTime(2023, 1, 1, 22, 10), // 10:10 PM
    DateTime(2023, 1, 1, 23, 50), // 11:50 PM
    DateTime(2023, 1, 1, 22, 50), // 10:50 PM
    DateTime(2023, 1, 1, 22, 0), // 10:00 PM
    DateTime(2023, 1, 1, 24, 0), // 12:00 AM
    DateTime(2023, 1, 1, 23, 15), // 11:15 PM
  ];

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
                        width: 450,
                        padding: const EdgeInsets.all(24.0),
                        color: Colors.white,
                        height: 470,
                        child: Column(
                          children: [
                            SizedBox(height: 24),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  lineBarsData: _buildLineBarsData(),
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
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 10),
                                ChartLegend(
                                  _getColorForSleepInfoType(
                                      selectedSleepInfoType),
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
                  ],
                ),
              ),
            ),
          ],
        ),
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

  List<LineChartBarData> _buildLineBarsData() {
    List<LineChartBarData> lineBarsData = [];

    switch (selectedSleepInfoType) {
      case SleepInfoType.hoursOfSleep:
        lineBarsData.add(
          LineChartBarData(
            spots: _buildSpots(hoursOfSleepData),
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
            spots: _buildSpots(hoursInCradleData),
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
            spots: _buildDateTimeSpots(wakeUpTimesData),
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
            spots: _buildDateTimeSpots(timePutToBedData),
            isCurved: false,
            colors: [Colors.orange],
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            isStrokeCapRound: true,
          ),
        );
        break;
      case SleepInfoType.sleepOnsetLatency:
        // Add sleep onset latency data
        lineBarsData.add(
          LineChartBarData(
            spots: _buildSpots(sleepOnsetLatencyData),
            isCurved: false,
            colors: [Colors.purple],
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            isStrokeCapRound: true,
          ),
        );
        break;
      case SleepInfoType.timeFellAsleep:
        // Add sleep duration data
        lineBarsData.add(
          LineChartBarData(
            spots: _buildDateTimeSpots(timeFellAsleepData),
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
