import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../services/status_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class TemperatureItem extends StatefulWidget {
  final double temp;
  final bool isRaspberryPiOn;

  const TemperatureItem(this.temp, this.isRaspberryPiOn, {Key? key})
      : super(key: key);
  @override
  _TemperatureItemState createState() =>
      _TemperatureItemState(temp, isRaspberryPiOn);
}

class _TemperatureItemState extends State<TemperatureItem> {
  final StatusService _tempStatus = StatusService();
  StreamSubscription? _subscription;
  static const String directory = 'Status/Temperature';
  double _temp;
  final bool _isRaspberryPiOn;

  _TemperatureItemState(this._temp, this._isRaspberryPiOn);

  Color get tempStatusColor {
    if (!_isRaspberryPiOn) {
      return Colors.grey;
    } else if (_temp <= 15) {
      return const Color.fromRGBO(0, 102, 204, 1); // Light Blue
    } else if (_temp <= 20) {
      return const Color.fromRGBO(255, 204, 0, 1); // Gold/Yellow
    } else if (_temp <= 30) {
      return Color.fromARGB(255, 8, 230, 41); // Green
    } else if (_temp <= 35) {
      return const Color.fromRGBO(255, 153, 51, 1); // Orange
    } else {
      return const Color.fromRGBO(204, 0, 0, 1); // Red
    }
  }

  @override
  void initState() {
    _tempStatus
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
      _temp = double.parse(event.snapshot.value as String);
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
                  percent: _temp >= 0 && _temp <= 50 ? _temp / 50 : 0,
                  center: Text(
                    "${_temp.round()}˚ C",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                      color: tempStatusColor,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: const Color.fromRGBO(32, 32, 32, 1),
                  progressColor: tempStatusColor,
                ),
              ),
              const Text(
                'Temperature',
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
