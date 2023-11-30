import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SleepEfficiencyScreen extends StatelessWidget {
  final List<String> daysOfWeek = [
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white, // Set the background color to white
                      height: 300, // Adjust the height as needed
                      child: Column(
                        children: [
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                barGroups: _buildBarGroups(),
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
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ChartLegend(Color.fromARGB(255, 0, 2, 122),
                                  'Hours of Sleep'),
                              SizedBox(width: 10),
                              ChartLegend(
                                Color.fromARGB(255, 255, 167, 52),
                                'Hours in Cradle',
                              ),
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
                            child: ListView.builder(
                              // Wrap content
                              scrollDirection: Axis.vertical,
                              itemCount: daysOfWeek.length,
                              itemBuilder: (context, index) {
                                double sleepEfficiency =
                                    (hoursOfSleepData[index] /
                                            hoursInCradleData[index]) *
                                        100;

                                return Card(
                                  color:
                                      Theme.of(context).colorScheme.surfaceTint,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              daysOfWeek[index],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                                'Hours of Sleep: ${hoursOfSleepData[index]}'),
                                            Text(
                                                'Hours Spent in Cradle: ${hoursInCradleData[index]}'),
                                          ],
                                        ),
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _getColorForPercentage(
                                                sleepEfficiency),
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

  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < daysOfWeek.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: hoursOfSleepData[i],
              colors: [Color.fromARGB(255, 0, 2, 122)],
              width: 16,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              y: hoursInCradleData[i],
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
        interval: 2, // Set the interval to 2
      ),
      bottomTitles: SideTitles(
        showTitles: true,
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
    home: SleepEfficiencyScreen(),
  ));
}
