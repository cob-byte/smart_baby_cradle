import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class BabyMoodTrackerWidget extends StatefulWidget {
  static const routeName = '/wake-up-times';

  @override
  _BabyMoodTrackerWidgetState createState() => _BabyMoodTrackerWidgetState();
}

class _BabyMoodTrackerWidgetState extends State<BabyMoodTrackerWidget> {
  Map<DateTime, int> wakeUpTimes = {
    DateTime.now().subtract(Duration(days: 2)): 1,
    DateTime.now().subtract(Duration(days: 1)): 2,
    DateTime.now(): 3,
  };
  DateTime _selectedDay = DateTime.now();
  int _selectedMood = 0;
  bool _viewAllWakeUpTimes = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baby Mood Tracker'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (!_viewAllWakeUpTimes)
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

                    // Check if yung selected date is may wake-up times, if meron show details
                    if (wakeUpTimes.containsKey(selectedDay)) {
                      int mood = wakeUpTimes[selectedDay]!;
                      _showDetailsDialog(selectedDay, mood);
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
              if (!_viewAllWakeUpTimes) SizedBox(height: 20),
              if (!_viewAllWakeUpTimes)
                ElevatedButton(
                  onPressed: () {
                    _showTimePicker();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_alarm),
                      SizedBox(width: 8),
                      Text('Add Wake-Up Time'),
                    ],
                  ),
                ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wake up Times and Mood',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _viewAllWakeUpTimes = !_viewAllWakeUpTimes;
                      });
                    },
                    child: Text(
                      _viewAllWakeUpTimes ? 'Hide' : 'View All',
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
                child: _getEventsForSelectedDay().isEmpty
                    ? Container(
                        padding: EdgeInsets.all(16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 218, 54,
                              43), // Change the background color as needed
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors
                                  .white, // Change the icon color as needed
                            ),
                            SizedBox(width: 8),
                            Text(
                              'No events listed on this day',
                              style: TextStyle(
                                color: Colors
                                    .white, // Change the text color as needed
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _viewAllWakeUpTimes
                            ? _getEventsForSelectedDay().length
                            : min(3, _getEventsForSelectedDay().length),
                        itemBuilder: (context, index) {
                          List<DateTime> events = _getEventsForSelectedDay();
                          DateTime dateTime = events[index];
                          int mood = wakeUpTimes[dateTime]!;

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
                                leading: _getMoodIcon(mood),
                                title: Text(
                                  '${DateFormat('h:mm a').format(dateTime.toLocal())}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  _getMoodLabel(mood),
                                  style: TextStyle(color: _getMoodColor(mood)),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _showEditDialog(dateTime, mood);
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteDialog(dateTime);
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
              if (_selectedMood != 0) MoodSelectionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  double _getContainerHeight() {
    double fixedHeight = _viewAllWakeUpTimes ? 350.0 : 250.0;

    return fixedHeight;
  }

  List<DateTime> _getEventsForSelectedDay() {
    return [
      for (var entry in wakeUpTimes.entries)
        if (isSameDay(entry.key, _selectedDay)) entry.key
    ];
  }

  void _showTimePicker() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      DateTime selectedDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Allow entering details for past dates
      _showMoodSelectionDialog(selectedDateTime);
    }
  }

  void _showMoodSelectionDialog(DateTime selectedDateTime) async {
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
        // Allow entering details for past dates
        wakeUpTimes[selectedDateTime] = selectedMood;
        _selectedMood = 0; // Reset selected mood after adding a wake-up time

        // Check if the selected date is in the past
        if (selectedDateTime.isBefore(DateTime.now())) {
          // Force a rebuild of the widget to update the past events
          setState(() {});
        }
      });
    }
  }

  void _showDetailsDialog(DateTime dateTime, int mood) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Details for ${dateTime.toLocal()}'),
          content: Text(_getMoodLabel(mood)),
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

  void _showEditDialog(DateTime dateTime, int mood) async {
    int? selectedMood = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Mood'),
          content: MoodSelectionButtons(),
        );
      },
    );

    if (selectedMood != null) {
      setState(() {
        wakeUpTimes[dateTime] = selectedMood;
        _selectedMood = 0; // Reset selected mood after editing a wake-up time
      });
    }
  }

  void _showDeleteDialog(DateTime dateTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Wake-Up Time'),
          content: Text('Are you sure you want to delete this wake-up time?'),
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
                  wakeUpTimes.remove(dateTime);
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

  Widget _getMoodIcon(int mood) {
    IconData icon;
    switch (mood) {
      case 1:
        icon = Icons.mood_bad; // Bad Mood
        break;
      case 2:
        icon = Icons.sentiment_neutral; // Average Mood
        break;
      case 3:
        icon = Icons.mood; // Great Mood
        break;
      default:
        icon = Icons.sentiment_very_satisfied; // Default icon
    }
    return Icon(icon, color: _getMoodColor(mood));
  }
}

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
        SizedBox(height: 8.0), // Add spacing between buttons
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
        SizedBox(height: 8.0), // Add spacing between buttons
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

void main() {
  runApp(MaterialApp(
    home: BabyMoodTrackerWidget(),
  ));
}
