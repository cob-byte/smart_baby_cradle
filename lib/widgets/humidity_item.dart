import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../services/status_service.dart';

class HumidityItem extends StatefulWidget {
  final double humidity;
  const HumidityItem(this.humidity, {Key? key}) : super(key: key);
  @override
  HumidityItemState createState() => HumidityItemState();
}

class HumidityItemState extends State<HumidityItem> {
  final StatusService _humidityStatus = StatusService();
  StreamSubscription? _subscription;
  static const String directory = 'Status/Humidity';
  late double _humidityLevel = widget.humidity;

  Color get humidityStatus {
    if (_humidityLevel >= 0.3 && _humidityLevel <= 0.5) {
      return const Color.fromRGBO(0, 255, 0, 1);
    } else if ((_humidityLevel >= 0.2 && _humidityLevel < 0.3) ||
        (_humidityLevel > 0.5 && _humidityLevel <= 0.6)) {
      return const Color.fromRGBO(255, 255, 0, 1);
    } else {
      return const Color.fromRGBO(255, 0, 0, 1);
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
                percent: _humidityLevel <= 1.0 && _humidityLevel >= 0.0
                    ? _humidityLevel
                    : 0,
                center: Text(
                  "${(_humidityLevel * 100).round()} %",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
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
    );
  }
}
