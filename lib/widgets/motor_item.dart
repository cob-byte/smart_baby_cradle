import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../services/controller_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

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
  String _sliderLabel = "Low";

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    return Theme(
      data: currentTheme,
      child: SingleChildScrollView(
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
                    height: 150,
                    width: constraints.maxWidth * 0.65,
                    child: _buttonStatus == 1
                        ? Transform.scale(
                            scale: 1.5,
                            child: Image.asset('assets/image/motor_on.png'),
                          )
                        : Transform.scale(
                            scale: 1.5,
                            child: Image.asset('assets/image/motor_off.png'),
                          ),
                  ),
                ),
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
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: currentTheme.colorScheme
                        .primary, // Active/Filled part of the slider
                    inactiveTrackColor: Color.fromARGB(255, 255, 255,
                        254), // Inactive/Unfilled part. of the slider
                    thumbColor: currentTheme
                        .colorScheme.onError, // The circle that you drag
                    valueIndicatorColor: Color.fromARGB(255, 36, 2,
                        2), // Color of the value indicator (the tooltip)
                  ),
                  child: Slider(
                    min: 1.0,
                    max: 3.0,
                    value: _sliderValue,
                    onChanged: (newValue) {
                      setState(() {
                        _sliderValue = newValue;
                        if (_sliderValue == 1.0) {
                          _sliderLabel = "Low";
                        } else if (_sliderValue > 1.0 && _sliderValue <= 2.0) {
                          _sliderLabel = "Medium";
                        } else if (_sliderValue > 2.0 && _sliderValue <= 3.0) {
                          _sliderLabel = "High";
                        }
                      });
                      _motorController.updateItem(
                          directory, _buttonStatus, _sliderValue);
                    },
                    divisions: 2,
                    label: _sliderLabel,
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
