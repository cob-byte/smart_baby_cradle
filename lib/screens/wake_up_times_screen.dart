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

void main() {
  runApp(MaterialApp(
    home: BabySleepTrackerWidget(),
  ));
}

class BabySleepTrackerWidget extends StatefulWidget {
  static const routeName = '/sleep-tracker';

  @override
  _BabySleepTrackerWidgetState createState() => _BabySleepTrackerWidgetState();
}

class SleepInfo {
  final TimeOfDay timePutToBed;
  final TimeOfDay timeFellAsleep;
  final TimeOfDay wakeUpTime;

  SleepInfo(this.timePutToBed, this.timeFellAsleep, this.wakeUpTime);
}

class _BabySleepTrackerWidgetState extends State<BabySleepTrackerWidget> {
  DateTime _selectedDay = DateTime.now();
  bool _viewAllSleepInfo = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Future<List<SleepInfo>> _sleepInfoFuture;
  Map<SleepInfo, Map<String, dynamic>> sleepInfoMap = {};
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _sleepInfoFuture = _getSleepInfoForSelectedDay();

    subscription();
  }

  Future<void> subscription() async {
    String? deviceID = await auth.getDeviceID();
    DatabaseReference rootRef = FirebaseDatabase.instance.ref().child("devices").child(deviceID!).child("tracker");

    _subscription = rootRef.onValue.listen((event) {
      setState(() {
        _sleepInfoFuture = _getSleepInfoForSelectedDay();
      });
    });
  }

    @override
  void dispose() {
    _subscription?.cancel();  // Cancel the subscription when the widget is disposed.
    super.dispose();
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
            'Sleep Tracker',
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
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: !_viewAllSleepInfo
                          ? Column(
                        key: ValueKey('calendar'),
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 3,
                                  blurRadius: 7,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TableCalendar(
                              headerVisible: true,
                              focusedDay: _selectedDay,
                              firstDay: DateTime.utc(2022, 1, 1),
                              lastDay: DateTime.utc(2023, 12, 31),
                              calendarFormat: _calendarFormat,
                              selectedDayPredicate: (DateTime date) {
                                return isSameDay(_selectedDay, date);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _sleepInfoFuture = _getSleepInfoForSelectedDay();
                                });
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              calendarBuilders: CalendarBuilders(
                                selectedBuilder: (context, date, events) {
                                  return Container(
                                    margin: const EdgeInsets.all(4.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      )
                          : SizedBox.shrink(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showSleepInfoDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_hotel),
                          SizedBox(width: 8),
                          Text('Add Sleep Information'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sleep Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _viewAllSleepInfo = !_viewAllSleepInfo;
                            });
                          },
                          child: Text(
                            _viewAllSleepInfo ? 'Hide' : 'View All',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    AnimatedContainer(
                      height: _getContainerHeight(),
                      duration: Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      width: 400,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: FutureBuilder<List<SleepInfo>>(
                        future: _sleepInfoFuture,
                        builder: (BuildContext context, AsyncSnapshot<List<SleepInfo>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Container(
                              padding: EdgeInsets.all(16.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 218, 54, 43),
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
                                    "Failed to fetch data",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(16.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 218, 54, 43),
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
                                    'No events listed on this day',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Display the list of SleepInfo in a ListView
                            return ListView.builder(
                              itemCount: _viewAllSleepInfo
                                  ? snapshot.data!.length
                                  : min(3, snapshot.data!.length),
                              itemBuilder: (context, index) {
                                SleepInfo info = snapshot.data![index];
                                Map<String, dynamic>? infoData = sleepInfoMap[info];
                                String dateTime = infoData?['dateTime'];
                                String uniqueID = infoData?['uniqueID'];
                                return Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderRadius: BorderRadius.circular(5.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                              255, 219, 217, 217)
                                              .withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        'Time Put to Bed: ${_formatTimeOfDay(info.timePutToBed)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Time Fell Asleep: ${_formatTimeOfDay(info.timeFellAsleep)}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            'Wake Up Time: ${_formatTimeOfDay(info.wakeUpTime)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _showEditSleepInfoDialog(dateTime, info, uniqueID);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              _showDeleteSleepInfoDialog(dateTime, uniqueID);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      )
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Function to get the container height based on the view mode
  double _getContainerHeight() {
    double fixedHeight = _viewAllSleepInfo ? 350.0 : 250.0;
    return fixedHeight;
  }

  Future<List<SleepInfo>> _getSleepInfoForSelectedDay() async {
    String? deviceID = await auth.getDeviceID();

    List<SleepInfo> sleepInfos = [];

    if (deviceID != null) {
      String formattedDate = "${_selectedDay.year}-${_selectedDay.month
          .toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(
          2, '0')}";

      // Fetch sleep info data from Firebase for the selected date
      DataSnapshot snapshot;
      try {
        snapshot = (await FirebaseDatabase.instance
            .ref()
            .child("devices")
            .child(deviceID)
            .child("tracker")
            .child(formattedDate)
            .once()).snapshot;
      } catch (e) {
        print("Failed to fetch data from Firebase: $e");
        return sleepInfos;
      }

      if (snapshot.value != null) {
        Map<dynamic, dynamic> sleepData = snapshot.value as Map<dynamic, dynamic>;
        sleepData.forEach((key, value) {
          try {
            // Convert data from Firebase to SleepInfo object
            SleepInfo info = SleepInfo(
              _parseTimeOfDay(value['timePutToBed']),
              _parseTimeOfDay(value['timeFellAsleep']),
              _parseTimeOfDay(value['wakeUpTime']),
            );

            // Store the dateTime and uniqueID in a separate map
            sleepInfoMap[info] = {
              'dateTime': formattedDate,
              'uniqueID': key,
            };

            sleepInfos.add(info);
          } catch (e) {
            print("Failed to parse sleep info data: $e");
          }
        });
      }
    }

    return sleepInfos;
  }

  // Function to parse Firebase time string to TimeOfDay
  TimeOfDay _parseTimeOfDay(String timeString) {
    List<String> parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> saveSleepInfoToFirebase(DateTime date, SleepInfo info) async {
    String? deviceID = await auth.getDeviceID();

    if (deviceID != null) {
      // Get Firebase database reference
      DatabaseReference rootRef = FirebaseDatabase.instance.ref().child("devices").child(deviceID).child("tracker");

      // Convert TimeOfDay to String
      String timePutToBed = _formatTOD(info.timePutToBed);
      String timeFellAsleep = _formatTOD(info.timeFellAsleep);
      String wakeUpTime = _formatTOD(info.wakeUpTime);

      // Generate a unique identifier for the sleep record
      String uniqueID = DateTime.now().millisecondsSinceEpoch.toString(); // Using timestamp as ID

      // Create a map containing sleep info data
      Map<String, dynamic> sleepInfoData = {
        "timePutToBed": timePutToBed,
        "timeFellAsleep": timeFellAsleep,
        "wakeUpTime": wakeUpTime,
      };

      String formattedDate = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";

      // Set the sleep info data in Firebase under the specified date and unique ID
      rootRef.child(formattedDate).child(uniqueID).set(sleepInfoData);
    }
  }

  String _formatTOD(TimeOfDay time) {
    return "${time.hour}:${time.minute}";
  }

  void _showSleepInfoDialog() async {
    TimeOfDay? timePutToBed = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Time Put to Bed',
    );

    if (timePutToBed != null) {
      TimeOfDay? timeFellAsleep = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Select Time Fell Asleep',
      );

      if (timeFellAsleep != null) {
        TimeOfDay? wakeUpTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          helpText: 'Select Wake Up Time',
        );

        if (wakeUpTime != null) {
          DateTime selectedDateTime = DateTime(
            _selectedDay.year,
            _selectedDay.month,
            _selectedDay.day,
            timePutToBed.hour,
            timePutToBed.minute,
          );

          SleepInfo newInfo = SleepInfo(
              timePutToBed, timeFellAsleep, wakeUpTime);

          saveSleepInfoToFirebase(selectedDateTime, newInfo);

          setState(() {
            _sleepInfoFuture = _getSleepInfoForSelectedDay();
          });
        }
      }
    }
  }

  void _showDetailsDialog(DateTime dateTime, SleepInfo info) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Details for ${dateTime.toLocal()}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time Put to Bed: ${_formatTimeOfDay(info.timePutToBed)}'),
              Text(
                  'Time Fell Asleep: ${_formatTimeOfDay(info.timeFellAsleep)}'),
              Text('Wake Up Time: ${_formatTimeOfDay(info.wakeUpTime)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editSleepInfo(String date, SleepInfo info, String unique) async {
    String? deviceID = await auth.getDeviceID();

    if (deviceID != null) {
      // Get Firebase database reference
      DatabaseReference rootRef = FirebaseDatabase.instance.ref().child("devices").child(deviceID).child("tracker");

      // Convert TimeOfDay to String
      String timePutToBed = _formatTOD(info.timePutToBed);
      String timeFellAsleep = _formatTOD(info.timeFellAsleep);
      String wakeUpTime = _formatTOD(info.wakeUpTime);

      // Create a map containing sleep info data
      Map<String, dynamic> sleepInfoData = {
        "timePutToBed": timePutToBed,
        "timeFellAsleep": timeFellAsleep,
        "wakeUpTime": wakeUpTime,
      };

      // Set the sleep info data in Firebase under the specified date and unique ID
      rootRef.child(date).child(unique).set(sleepInfoData);
    }
  }

  void _showEditSleepInfoDialog(String dateTime, SleepInfo info, String uniqueID) async {
    TimeOfDay? timePutToBed = await showTimePicker(
      context: context,
      initialTime: info.timePutToBed,
      helpText: 'Select Time Put to Bed',
    );

    if (timePutToBed != null) {
      TimeOfDay? timeFellAsleep = await showTimePicker(
        context: context,
        initialTime: info.timeFellAsleep,
        helpText: 'Select Time Fell Asleep',
      );

      if (timeFellAsleep != null) {
        TimeOfDay? wakeUpTime = await showTimePicker(
          context: context,
          initialTime: info.wakeUpTime,
          helpText: 'Select Wake Up Time',
        );

        if (wakeUpTime != null) {
          SleepInfo updatedInfo = SleepInfo(
            timePutToBed, timeFellAsleep, wakeUpTime);
            editSleepInfo(dateTime ,updatedInfo, uniqueID);
            setState(() {
              _sleepInfoFuture = _getSleepInfoForSelectedDay();
          });
        }
      }
    }
  }

  Future<void> deleteSleepInfoFromFirebase(String date, String uniqueID) async {
    String? deviceID = await auth.getDeviceID();

    if (deviceID != null) {
      // Get Firebase database reference
      DatabaseReference rootRef = FirebaseDatabase.instance.ref().child("devices").child(deviceID).child("tracker");
      rootRef.child(date).child(uniqueID).remove();

      setState(() {
        _sleepInfoFuture = _getSleepInfoForSelectedDay();
      });
    }
  }

  void _showDeleteSleepInfoDialog(String dateTime, String uniqueID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Sleep Information'),
          content:
              Text('Are you sure you want to delete this sleep information?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteSleepInfoFromFirebase(dateTime, uniqueID);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Function to format TimeOfDay as a string
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);

    return DateFormat('h:mm a').format(dateTime);
  }
}
