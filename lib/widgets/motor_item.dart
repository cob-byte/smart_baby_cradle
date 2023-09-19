import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../services/controller_service.dart';

class MotorItem extends StatefulWidget {
  final int run;
  final double level;
  const MotorItem({Key? key, required this.run, required this.level})
      : super(key: key);

  @override
  MotorItemState createState() => MotorItemState();
}

class MotorItemState extends State<MotorItem> {
  final ControllerService _motorController = ControllerService();
  StreamSubscription? _subscription;
  static const String directory = 'Motor';
  late int _buttonStatus;
  late double _sliderValue;
  String? _sliderLabel;

  @override
  void initState() {
    super.initState();
    _buttonStatus = widget.run;
    _sliderValue = widget.level;
    _motorController
        .getStatusStream(directory, _onMotorChange)
        .then((StreamSubscription s) => _subscription = s);
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription?.cancel();
    }
    super.dispose();
  }

  _onMotorChange(DatabaseEvent event) {
    setState(() {
      Map<dynamic, dynamic> snapshotValue =
          event.snapshot.value as Map<dynamic, dynamic>;
      _buttonStatus = snapshotValue['run'];
      _sliderValue = (snapshotValue['level']).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 226, 211, 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (_buttonStatus == 1) {
                  _buttonStatus = 0;
                } else {
                  _buttonStatus = 1;
                }
                _motorController.updateItem(
                    directory, _buttonStatus, _sliderValue);
                setState(() {});
              },
              child: SizedBox(
                width: constraints.maxWidth * 0.65,
                child: _buttonStatus == 1
                    ? Transform.scale(
                        scale: 1.5, // Adjust the scale factor as needed
                        child: Image.asset('assets/image/motor_on.png'),
                      )
                    : Transform.scale(
                        scale: 1.5, // Adjust the scale factor as needed
                        child: Image.asset('assets/image/motor_off.png'),
                      ),
              ),
            ),
            /* Slider(
              min: 1.0,
              max: 3.0,
              value: _sliderValue,
              onChanged: (newValue) {
                setState(() {
                  _sliderValue = newValue;
                  if (_sliderValue == 1.0) {
                    _sliderLabel = "Low";
                  }
                  if (_sliderValue > 1.0 && _sliderValue <= 2.0) {
                    _sliderLabel = "Medium";
                  }
                  if (_sliderValue > 2.0 && _sliderValue <= 3.0) {
                    _sliderLabel = "High";
                  }
                });
                _motorController.updateItem(
                    directory, _buttonStatus, _sliderValue);
              },
              divisions: 2,
              label: _sliderLabel,
            ),*/
            const FittedBox(
              child: Text(
                'Motor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
