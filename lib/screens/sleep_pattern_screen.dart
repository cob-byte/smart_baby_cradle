import 'package:flutter/material.dart';

class SleepPatternScreen extends StatefulWidget {
  @override
  _SleepPatternScreenState createState() => _SleepPatternScreenState();
}

class _SleepPatternScreenState extends State<SleepPatternScreen> {
  DateTime selectedDate = DateTime.now(); // Initial selected date
  List<SleepDateInfo> sleepData = [
    SleepDateInfo(
      date: DateTime.now(),
      sleepInfo: [
        SleepInfo(
          timePutToBed: '10:00 PM',
          timeFellAsleep: '10:30 PM',
          sleepOnsetLatency: '30 mins',
          mood: 'Great Mood',
        ),
      ],
    ),
    SleepDateInfo(
      date: DateTime(2023, 11, 25),
      sleepInfo: [
        SleepInfo(
          timePutToBed: '11:30 PM',
          timeFellAsleep: '12:00 AM',
          sleepOnsetLatency: '45 mins',
          mood: 'Good Mood',
        ),
        SleepInfo(
          timePutToBed: '9:45 PM',
          timeFellAsleep: '10:15 PM',
          sleepOnsetLatency: '25 mins',
          mood: 'Excellent Mood',
        ),
        SleepInfo(
          timePutToBed: '9:45 PM',
          timeFellAsleep: '10:15 PM',
          sleepOnsetLatency: '25 mins',
          mood: 'Excellent Mood',
        ),
        SleepInfo(
          timePutToBed: '9:45 PM',
          timeFellAsleep: '10:15 PM',
          sleepOnsetLatency: '25 mins',
          mood: 'Excellent Mood',
        ),
      ],
    ),
    // Add more entries as needed
  ];

  SleepDateInfo getSelectedDateInfo() {
    return sleepData.firstWhere(
      (sleepDate) => sleepDate.date == selectedDate,
      orElse: () => SleepDateInfo(date: selectedDate, sleepInfo: []),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Pattern Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text('Select Date'),
            ),
            SizedBox(height: 16),
            Text(
              'Selected Date: ${selectedDate.toLocal()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sleep Pattern Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Display details only for the selected date
                      getSelectedDateInfo().sleepInfo.isEmpty
                          ? Text(
                              'No information available for the selected date.',
                              style: TextStyle(fontSize: 16),
                            )
                          : Expanded(
                              child: ListView(
                                children: getSelectedDateInfo()
                                    .sleepInfo
                                    .map((info) => SleepInfoCard(
                                          label:
                                              'Date: ${selectedDate.toLocal()}',
                                          value:
                                              'Time Put to Bed: ${info.timePutToBed}\n'
                                              'Time Fell Asleep: ${info.timeFellAsleep}\n'
                                              'Sleep Onset Latency: ${info.sleepOnsetLatency}\n'
                                              'Mood: ${info.mood}',
                                        ))
                                    .toList(),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SleepDateInfo {
  final DateTime date;
  final List<SleepInfo> sleepInfo;

  SleepDateInfo({required this.date, required this.sleepInfo});
}

class SleepInfoCard extends StatelessWidget {
  final String label;
  final String value;

  SleepInfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class SleepInfo {
  final String timePutToBed;
  final String timeFellAsleep;
  final String sleepOnsetLatency;
  final String mood;

  SleepInfo({
    this.timePutToBed = '',
    this.timeFellAsleep = '',
    this.sleepOnsetLatency = '',
    this.mood = '',
  });
}

void main() {
  runApp(MaterialApp(
    home: SleepPatternScreen(),
  ));
}
