import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_baby_cradle/screens/sleep_pattern_screen.dart';
import 'package:smart_baby_cradle/screens/sleep_efficiency_screen.dart';
import 'package:provider/provider.dart';
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
            Text('Sleep Quality Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SleepInfoRow(
                icon: Icons.access_time,
                label: 'Sleep Efficiency',
                value: '85%'),
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
                            value: 70,
                            color: Colors.blue,
                            title: 'Sleep',
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: 30,
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
                      PieChartPercentage(label: 'Sleep', percentage: '70%'),
                      PieChartPercentage(label: 'In Bed', percentage: '30%'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SleepInfoRow(
                icon: Icons.nightlight_round,
                label: 'Total Awakenings',
                value: '3'),
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
            SleepInfoRow(icon: Icons.mood, label: 'Mood', value: 'Great Mood'),
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

  // Define icons and colors for each mood
  IconData? getMoodIcon() {
    if (label.toLowerCase() == 'mood') {
      switch (value.toLowerCase()) {
        case 'bad mood':
          return Icons.mood_bad;
        case 'average mood':
          return Icons.sentiment_satisfied;
        case 'great mood':
          return Icons.mood;
        default:
          return Icons.sentiment_neutral;
      }
    }
    return null;
  }

  Color? getMoodColor() {
    if (label.toLowerCase() == 'mood') {
      switch (value.toLowerCase()) {
        case 'bad mood':
          return Colors.red;
        case 'average mood':
          return Colors.amber;
        case 'great mood':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }
    return null;
  }

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
          if (label.toLowerCase() == 'mood')
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    getMoodIcon()!,
                    color: getMoodColor()!,
                  ),
                  SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: getMoodColor()!,
                    ),
                  ),
                ],
              ),
            ),
          if (label.toLowerCase() != 'mood')
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
