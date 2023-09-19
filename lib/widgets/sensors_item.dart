import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SensorsItem extends StatelessWidget {
  final double temperature;
  final double humidity;

  const SensorsItem({
    Key? key,
    required this.temperature,
    required this.humidity,
  }) : super(key: key);

  Color get temperatureStatusColor {
    if (temperature <= 15) {
      return const Color.fromRGBO(0, 0, 255, 1);
    } else if (temperature > 15 && temperature <= 20) {
      return const Color.fromRGBO(255, 255, 0, 1);
    } else if (temperature > 20 && temperature <= 30) {
      return const Color.fromRGBO(0, 255, 0, 1);
    } else if (temperature > 30 && temperature <= 35) {
      return const Color.fromRGBO(255, 255, 0, 1);
    } else {
      return const Color.fromRGBO(255, 0, 0, 1);
    }
  }

  Color get humidityStatusColor {
    if (humidity >= 0.3 && humidity <= 0.5) {
      return const Color.fromRGBO(0, 255, 0, 1);
    } else if ((humidity >= 0.2 && humidity < 0.3) ||
        (humidity > 0.5 && humidity <= 0.6)) {
      return const Color.fromRGBO(255, 255, 0, 1);
    } else {
      return const Color.fromRGBO(255, 0, 0, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 22, 22, 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularPercentIndicator(
                radius: (0.3 * constraints.maxWidth),
                lineWidth: 3.0,
                percent: temperature >= 0 && temperature <= 50
                    ? temperature / 50
                    : 0,
                center: Text(
                  "${temperature.round()}˚ C",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: temperatureStatusColor,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: const Color.fromRGBO(32, 32, 32, 1),
                progressColor: temperatureStatusColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularPercentIndicator(
                radius: (0.3 * constraints.maxWidth),
                lineWidth: 3.0,
                percent: humidity <= 1.0 && humidity >= 0.0 ? humidity : 0,
                center: Text(
                  "${(humidity * 100).round()} %",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: humidityStatusColor,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: const Color.fromRGBO(32, 32, 32, 1),
                progressColor: humidityStatusColor,
              ),
            ),
            const Text(
              'Sensors',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
