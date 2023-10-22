import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WakeUpTimesScreen extends StatelessWidget {
  static const routeName = '/wake-up-times';

  final List<FlSpot> wakeUpTimesData = [
    FlSpot(1, 6.5),
    FlSpot(2, 7.0),
    FlSpot(3, 6.8),
    FlSpot(4, 7.2),
    // Add more data points as needed (x represents day, y represents wake-up time)
  ];

  final List<String> labels = [
    'Day 1',
    'Day 2',
    'Day 3',
    'Day 4',
    // Add corresponding labels for each data point
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wake-Up Times Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Set the background image
          Image.asset(
            'assets/image/night-background.png',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 80), // Add margin above the alarm icon
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Baby Wake-Up Times:',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 300,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) {
                                      if (value >= 1 &&
                                          value <= labels.length.toDouble()) {
                                        return labels[value.toInt() - 1];
                                      }
                                      return '';
                                    },
                                  ),
                                  leftTitles: SideTitles(showTitles: false),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: wakeUpTimesData,
                                    isCurved: true,
                                    colors: [Colors.blue], // Line color
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(show: false),
                                    dotData: FlDotData(
                                        show: true), // Show dots on data points
                                  ),
                                ],
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    tooltipBgColor: Colors
                                        .yellow, // Tooltip background color
                                    getTooltipItems:
                                        (List<LineBarSpot> lineBarsSpot) {
                                      return lineBarsSpot.map((lineBarSpot) {
                                        final int index = lineBarSpot.x.toInt();
                                        if (index >= 0 &&
                                            index < labels.length) {
                                          return LineTooltipItem(
                                            labels[index],
                                            TextStyle(color: Colors.black),
                                          );
                                        }
                                        return null;
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
