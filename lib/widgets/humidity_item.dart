import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../services/status_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class HumidityItem extends StatefulWidget {
  final double humidity;
  final bool isRaspberryPiOn;
  const HumidityItem(this.humidity, this.isRaspberryPiOn, {Key? key}) : super(key: key);
  @override
  HumidityItemState createState() => HumidityItemState();
}

class HumidityItemState extends State<HumidityItem> {
  final StatusService _humidityStatus = StatusService();
  StreamSubscription? _subscription;
  static const String directory = 'Status/Humidity';
  late double _humidityLevel = widget.humidity;

  Color get humidityStatus {
    if(widget.isRaspberryPiOn == false){
      return Colors.grey;
    }
    else if (_humidityLevel >= 0.3 && _humidityLevel <= 0.5) {
      return const Color.fromARGB(255, 8, 230, 41);
    } else if ((_humidityLevel >= 0.2 && _humidityLevel < 0.3) ||
        (_humidityLevel > 0.5 && _humidityLevel <= 0.6)) {
      return const Color.fromRGBO(255, 204, 0, 1);
    } else {
      return const Color.fromRGBO(204, 0, 0, 1);
    }
  }

  @override
  void initState() {
    _humidityStatus
        .getStatusStream(directory, _updateTemp)
        .then((StreamSubscription s) => _subscription = s);
    super.initState();
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription?.cancel();
    }
    super.dispose();
  }

  _updateTemp(DatabaseEvent event) {
    setState(() {
      _humidityLevel = double.parse(event.snapshot.value as String) / 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          color: currentTheme.colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(),
          boxShadow: [
            // Add box shadow here
            BoxShadow(
              color: Color.fromARGB(255, 106, 106, 106)
                  .withOpacity(0.5), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset:
                  Offset(0, 3), // Offset in the positive direction of y-axis
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircularPercentIndicator(
                  radius: (0.38 * constraints.maxWidth),
                  lineWidth: 4.0,
                  percent: _humidityLevel <= 1.0 && _humidityLevel >= 0.0
                      ? _humidityLevel
                      : 0,
                  center: Text(
                    "${(_humidityLevel * 100).round()} %",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                      color: humidityStatus,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: const Color.fromRGBO(32, 32, 32, 1),
                  progressColor: humidityStatus,
                ),
              ),
              const Text(
                'Humidity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
