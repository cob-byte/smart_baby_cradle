import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/controller_service.dart';

class FanItem extends StatefulWidget {
  final int run;
  final double level;
  const FanItem(this.run, this.level, {Key? key}) : super(key: key);
  @override
  FanItemState createState() => FanItemState();
}

class FanItemState extends State<FanItem> {
  final ControllerService _fanController = ControllerService();
  StreamSubscription? _subscription;
  static const String directory = 'Fan';
  late int _buttonStatus;
  late double _sliderValue;
  String? _sliderLabel;

  @override
  void initState() {
    super.initState();
    _buttonStatus = widget.run; // Access the run value via widget property
    _sliderValue = widget.level; // Access the level value via widget property
    _fanController
        .getStatusStream(directory, _onFanChange)
        .then((StreamSubscription s) => _subscription = s);
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription?.cancel();
    }
    super.dispose();
  }

  _onFanChange(DatabaseEvent event) {
    setState(() {
      if(event.snapshot.value != null) {
        Map<dynamic, dynamic> valueMap = event.snapshot.value as Map<dynamic, dynamic>;
        _buttonStatus = valueMap['run'];
        _sliderValue = (valueMap['level']).toDouble();
      }
    });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (_buttonStatus == 1) {
                  _buttonStatus = 0;
                } else {
                  _buttonStatus = 1;
                }
                _fanController.updateItem(
                    directory, _buttonStatus, _sliderValue);
                setState(() {});
              },
              child: SizedBox(
                  width: constraints.maxWidth * 0.45,
                  child: _buttonStatus == 1
                      ? Image.asset(
                          'assets/image/fan_on.png',
                        )
                      : Image.asset(
                          'assets/image/fan_off.png',
                        )),
            ),
            Slider(
              min: 1.0,
              max: 3.0,
              value: _sliderValue,
              onChanged: (newValue) {
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
                _fanController.updateItem(
                    directory, _buttonStatus, _sliderValue);
                setState(() {});
              },
              divisions: 2,
              label: _sliderLabel,
            ),
            const FittedBox(
              child: Text(
                'Fan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
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
