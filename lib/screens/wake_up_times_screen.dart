import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
  final int mood;
  final TimeOfDay timePutToBed;
  final TimeOfDay timeFellAsleep;
  final TimeOfDay wakeUpTime;

  SleepInfo(this.mood, this.timePutToBed, this.timeFellAsleep, this.wakeUpTime);
}

class _BabySleepTrackerWidgetState extends State<BabySleepTrackerWidget> {
  Map<DateTime, SleepInfo> sleepInfo = {
    DateTime.now().subtract(Duration(days: 2)): SleepInfo(
        1,
        TimeOfDay(hour: 20, minute: 0),
        TimeOfDay(hour: 22, minute: 0),
        TimeOfDay(hour: 6, minute: 0)),
    DateTime.now().subtract(Duration(days: 1)): SleepInfo(
        2,
        TimeOfDay(hour: 21, minute: 0),
        TimeOfDay(hour: 23, minute: 0),
        TimeOfDay(hour: 7, minute: 0)),
    DateTime.now(): SleepInfo(3, TimeOfDay(hour: 22, minute: 0),
        TimeOfDay(hour: 23, minute: 30), TimeOfDay(hour: 8, minute: 0)),
  };

  DateTime _selectedDay = DateTime.now();
  bool _viewAllSleepInfo = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baby Sleep Tracker'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (!_viewAllSleepInfo)
                TableCalendar(
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
                    });

                    if (sleepInfo.containsKey(selectedDay)) {
                      SleepInfo info = sleepInfo[selectedDay]!;
                      _showDetailsDialog(selectedDay, info);
                    }
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
              if (!_viewAllSleepInfo) SizedBox(height: 20),
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
              Container(
                height: _getContainerHeight(),
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _getSleepInfoForSelectedDay().isEmpty
                    ? Container(
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
                      )
                    : ListView.builder(
                        itemCount: _viewAllSleepInfo
                            ? _getSleepInfoForSelectedDay().length
                            : min(3, _getSleepInfoForSelectedDay().length),
                        itemBuilder: (context, index) {
                          List<DateTime> dates = _getSleepInfoForSelectedDay();
                          DateTime date = dates[index];
                          SleepInfo info = sleepInfo[date]!;

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
                                    color:
                                        const Color.fromARGB(255, 219, 217, 217)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time Fell Asleep: ${_formatTimeOfDay(info.timeFellAsleep)}',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    Text(
                                      'Wake Up Time: ${_formatTimeOfDay(info.wakeUpTime)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Mood: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Icon(
                                          _getMoodIcon(info.mood),
                                          color: _getMoodColor(info.mood),
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          _getMoodLabel(info.mood),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _getMoodColor(info.mood),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _showEditSleepInfoDialog(date, info);
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteSleepInfoDialog(date);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to get the container height based on the view mode
  double _getContainerHeight() {
    double fixedHeight = _viewAllSleepInfo ? 350.0 : 250.0;
    return fixedHeight;
  }

  // Function to get the list of dates with sleep information for the selected day
  List<DateTime> _getSleepInfoForSelectedDay() {
    return [
      for (var entry in sleepInfo.entries)
        if (isSameDay(entry.key, _selectedDay)) entry.key
    ];
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
          int? selectedMood = await showDialog<int>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Select Mood'),
                content: SizedBox(
                  width: 300.0,
                  height: 200.0,
                  child: MoodSelectionButtons(),
                ),
              );
            },
          );

          if (selectedMood != null) {
            DateTime selectedDateTime = DateTime(
              _selectedDay.year,
              _selectedDay.month,
              _selectedDay.day,
              timePutToBed.hour,
              timePutToBed.minute,
            );

            SleepInfo newInfo = SleepInfo(
                selectedMood, timePutToBed, timeFellAsleep, wakeUpTime);

            setState(() {
              sleepInfo[selectedDateTime] = newInfo;
            });
          }
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
              Text('Mood: ${_getMoodLabel(info.mood)}'),
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

  void _showEditSleepInfoDialog(DateTime dateTime, SleepInfo info) async {
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
          int? selectedMood = await showDialog<int>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Select Mood'),
                content: SizedBox(
                  width: 300.0,
                  height: 200.0,
                  child: MoodSelectionButtons(),
                ),
              );
            },
          );

          if (selectedMood != null) {
            setState(() {
              SleepInfo updatedInfo = SleepInfo(
                  selectedMood, timePutToBed, timeFellAsleep, wakeUpTime);
              sleepInfo[dateTime] = updatedInfo;
            });
          }
        }
      }
    }
  }

  void _showDeleteSleepInfoDialog(DateTime dateTime) {
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
                setState(() {
                  sleepInfo.remove(dateTime);
                });
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

  // Function to get the mood label
  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Bad Mood';
      case 2:
        return 'Average Mood';
      case 3:
        return 'Great Mood';
      default:
        return '';
    }
  }

  // Function to get the mood color
  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return Colors.red; // Bad Mood
      case 2:
        return Colors.amber; // Average Mood
      case 3:
        return Colors.green; // Great Mood
      default:
        return Colors.black; // Default color
    }
  }

// Function to get the mood icon
  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 1:
        return Icons.mood_bad; // Bad Mood
      case 2:
        return Icons.sentiment_neutral; // Average Mood
      case 3:
        return Icons.mood; // Great Mood
      default:
        return Icons.sentiment_very_satisfied; // Default icon
    }
  }
}

// Class for the mood selection buttons
class MoodSelectionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(1); // Bad Mood
          },
          child: SizedBox(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mood_bad),
                SizedBox(width: 8.0),
                Text('Bad Mood'),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop(2); // Average Mood
          },
          child: SizedBox(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_neutral),
                SizedBox(width: 8.0),
                Text('Average Mood'),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(3); // Great Mood
          },
          child: SizedBox(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mood),
                SizedBox(width: 8.0),
                Text('Great Mood'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
