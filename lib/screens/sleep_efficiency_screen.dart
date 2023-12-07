import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/screens/wake_up_times_screen.dart';
import '../services/status_service.dart';
import '../theme_provider.dart';

class SleepEfficiencyScreen extends StatefulWidget {
  @override
  _SleepEfficiencyScreenState createState() => _SleepEfficiencyScreenState();
}

class _SleepEfficiencyScreenState extends State<SleepEfficiencyScreen> {
  bool isWeekly = true; // Track whether it's weekly or monthly view
  DateTime selectedDate = DateTime.now();
  Future<List<DropdownMenuItem<DateTime>>>? _dropdownMenuItems;

  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = _buildDropdownItems();
  }

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

  Future<Map<DateTime, List<SleepInfo>>> _getSleepInfo2() async {
    String? deviceID = await auth.getDeviceID();

    Map<DateTime, List<SleepInfo>> sleepInfos = {};

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
            // value is a map of timestamps
            Map<dynamic, dynamic> timestamps = value as Map<dynamic, dynamic>;
            timestamps.forEach((timestamp, sleepInfoData) {
              // Convert data from Firebase to SleepInfo object
              SleepInfo info = SleepInfo(
                _parseTimeOfDay(sleepInfoData['timePutToBed']),
                _parseTimeOfDay(sleepInfoData['timeFellAsleep']),
                _parseTimeOfDay(sleepInfoData['wakeUpTime']),
              );

              // If there's no list for this date, create one
              if (!sleepInfos.containsKey(date)) {
                sleepInfos[date] = [];
              }

              // Add the SleepInfo object to the list for this date
              sleepInfos[date]!.add(info);
            });
          } catch (e) {
            print("Failed to parse sleep info data: $e");
          }
        });
      }
    }
    return sleepInfos;
  }

  Future<List<DropdownMenuItem<DateTime>>> _buildDropdownItems() async {
    List<DropdownMenuItem<DateTime>> items = [];
    if (isWeekly) {
      // Get the sleep info data as a map of dates and sleep infos
      Map<DateTime, List<SleepInfo>> sleepData = await _getSleepInfo2();

      // Get the list of dates from the sleep data map
      List<DateTime> dates = sleepData.keys.toList();

      // Sort the dates in ascending order
      dates.sort();

      // Set the currentDate to the start of the week of the first date
      DateTime currentDate = dates.first.subtract(Duration(days: (dates.first.weekday - 1) % 7)); // This will set the currentDate to the previous Monday

      // Set the endDate to the end of the week of the last date
      DateTime endDate = dates.last.add(Duration(days: (7 - dates.last.weekday) % 7)); // This will set the endDate to the next Sunday

      // Iterate through all weeks from the week of the first date to the week of the last date
      while (currentDate.isBefore(endDate)) {
        DateTime weekEnd = currentDate.add(Duration(days: 6));
        items.add(DropdownMenuItem<DateTime>(
          value: currentDate,
          child: Text(
              '${DateFormat('MMM d').format(currentDate)} - ${DateFormat('MMM d').format(weekEnd)}'),
        ));
        currentDate = currentDate.add(Duration(days: 7));
      }

      items = items.reversed.toList();
    } else {
      // Implement logic to generate monthly dropdown items
      // Iterate through months from January to December of the current year
      // Populate a list of DropdownMenuItems<DateTime> for each month

      // Get the current year
      int year = DateTime.now().year;
      // Use a loop to iterate through the months
      for (int i = 1; i <= 12; i++) {
        // Create a date object for the first day of each month
        DateTime monthStart = DateTime(year, i, 1);
        // Create a dropdown menu item for the current month
        // The value is the start date of the month
        // The child is a text widget showing the month name
        items.add(DropdownMenuItem<DateTime>(
          value: monthStart,
          child: Text(DateFormat('MMMM').format(monthStart)),
        ));
      }
    }
    // Return the generated dropdown items
    return items;
  }

  Future<Map<String, List<SleepInfo>>> _getSleepInfo(DateTime selectedDate, bool isWeekly) async {
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

            // Check if the date is in the selected week/month
            if (isWeekly) {
              if (date.isAfter(selectedDate.subtract(Duration(days: 1))) && date.isBefore(selectedDate.add(Duration(days: 7)))) {
                processSleepData(value, sleepInfos, dayOfWeek);
              }
            } else { // Monthly
              if (date.year == selectedDate.year && date.month == selectedDate.month) {
                processSleepData(value, sleepInfos, dayOfWeek);
              }
            }
          } catch (e) {
            print("Failed to parse sleep info data: $e");
          }
        });
      }
    }

    return sleepInfos;
  }

  void processSleepData(dynamic value, Map<String, List<SleepInfo>> sleepInfos, String dayOfWeek) {
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
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isWeekly = !isWeekly;
                            _dropdownMenuItems = _buildDropdownItems();
                          });

                          if(isWeekly){
                            var items = await _dropdownMenuItems;
                            if(items!.isNotEmpty){
                              setState(() {
                                selectedDate = items.first.value!; // Extract DateTime from DropdownMenuItem
                              });
                            }
                          } else {
                            selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
                          }
                        },
                        child: Text(isWeekly ? 'Weekly' : 'Monthly'),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: FutureBuilder<List<DropdownMenuItem<DateTime>>>(
                        future: _dropdownMenuItems,
                        builder: (BuildContext context, AsyncSnapshot<List<DropdownMenuItem<DateTime>>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Check if selectedDate is in the list of dates
                            if (!snapshot.data!.any((item) => item.value == selectedDate)) {
                              // If not, assign the first date in the list to selectedDate
                              selectedDate = snapshot.data!.first.value!;
                            }
                            return Center(
                              child: DropdownButton<DateTime>(
                                value: selectedDate,
                                onChanged: (DateTime? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedDate = newValue;
                                    });
                                  }
                                },
                                items: snapshot.data,
                              ),
                            );
                          }
                        },
                      ),
                    ),
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
                              future: _getSleepInfo(selectedDate, isWeekly),
                              builder: (BuildContext context, AsyncSnapshot<Map<String, List<SleepInfo>>> snapshot) {
                                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
                                } else if (snapshot.data!.isEmpty){
                                  return Container(
                                    padding: EdgeInsets.all(16.0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.error,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'No events listed on this selection.',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
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
                              future: _getSleepInfo(selectedDate, isWeekly),
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
                                                  Text('Hours of Sleep: ${hoursOfSleepData[index].isNotEmpty ? hoursOfSleepData[index].reduce((a, b) => a + b).toStringAsFixed(2) : 0}'),
                                                  Text('Hours Spent in Cradle: ${hoursInCradleData[index].isNotEmpty ? hoursInCradleData[index].reduce((a, b) => a + b).toStringAsFixed(2) : 0}'),
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
                                                      '${sleepEfficiency.toStringAsFixed(2)}%',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    )
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
