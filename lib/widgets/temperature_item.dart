import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../services/status_service.dart';

class TemperatureItem extends StatefulWidget {
  final double temp;
  const TemperatureItem(this.temp, {Key? key}) : super(key: key);
  @override
  _TemperatureItemState createState() => _TemperatureItemState(temp);
}

class _TemperatureItemState extends State<TemperatureItem> {
  final StatusService _tempStatus = StatusService();
  StreamSubscription? _subscription;
  static const String directory = 'Status/Temperature';
  double _temp;

  _TemperatureItemState(this._temp);

  Color get tempStatusColor {
    if (_temp <= 15) {
      return const Color.fromRGBO(0, 0, 255, 1);
    } else if (_temp > 15 && _temp <= 20) {
      return const Color.fromRGBO(255, 255, 0, 1);
    } else if (_temp > 20 && _temp <= 30) {
      return const Color.fromRGBO(0, 255, 0, 1);
    } else if (_temp > 30 && _temp <= 35) {
      return const Color.fromRGBO(255, 255, 0, 1);
    } else {
      return const Color.fromRGBO(255, 0, 0, 1);
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
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(233, 116, 138, 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
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
                percent: _temp >= 0 && _temp <= 50 ? _temp / 50 : 0,
                center: Text(
                  "${_temp.round()}˚ C",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
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
    );
  }
}
