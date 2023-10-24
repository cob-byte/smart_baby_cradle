import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SleepScoreScreen(85), // Pass the actual sleep score here
      ),
    );

class SleepScoreScreen extends StatelessWidget {
  static const routeName = '/sleep-score';

  final int sleepScore; // Pass the actual sleep score as a parameter

  SleepScoreScreen(this.sleepScore);

  Color _getStatusBarColor(int score) {
    if (score >= 80) {
      return Colors.green; // Green color for good sleep score
    } else if (score >= 60) {
      return Colors.yellow; // Yellow color for average sleep score
    } else {
      return Colors.red; // Red color for low sleep score
    }
  }

  String _getStatusText(int score) {
    if (score >= 80) {
      return 'Excellent Sleep';
    } else if (score >= 60) {
      return 'Good Sleep';
    } else {
      return 'Poor Sleep';
    }
  }

  Widget _buildExpandedCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.black,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Score'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/night-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 100),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: sleepScore.toDouble(),
                          color: _getStatusBarColor(sleepScore),
                          title: '',
                          radius: 50,
                          showTitle: false, // Hide the title
                        ),
                        PieChartSectionData(
                          value: (100 - sleepScore).toDouble(),
                          color: Colors.transparent,
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Your Sleep Score:',
                  style: TextStyle(
                    fontFamily: 'Medium',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 0.01), // Add padding above the Text widget
                  child: Text(
                    '$sleepScore%', // Display the actual sleep score
                    style: TextStyle(
                      fontFamily: 'Bold',
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 30,
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _getStatusBarColor(sleepScore),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      _getStatusText(sleepScore),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsets.all(15),
                    child: ListView(
                      padding: EdgeInsets.only(
                          top: 0), // Remove space before the quality card
                      children: [
                        _buildExpandedCard(
                          'Quality',
                          'Excellent',
                          Icons.star,
                        ),
                        _buildExpandedCard(
                          'Duration',
                          '7 hours',
                          Icons.access_time,
                        ),
                        _buildExpandedCard(
                          'Restfulness',
                          'High',
                          Icons.cloud,
                        ),
                        _buildExpandedCard(
                          'Snoring',
                          'Low',
                          Icons.noise_aware,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
