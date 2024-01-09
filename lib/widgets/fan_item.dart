import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../services/controller_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class FanItem extends StatefulWidget {
  final int run;
  final double level;
  final bool isRaspberryPiOn;
  final bool auto;
  const FanItem(this.run, this.level, this.auto, this.isRaspberryPiOn, {Key? key})
      : super(key: key);
  @override
  FanItemState createState() => FanItemState();
}

class FanItemState extends State<FanItem> {
  final ControllerService _fanController = ControllerService();
  StreamSubscription? _subscription;
  static const String directory = 'Fan';
  late int _buttonStatus;
  late double _sliderValue;
  String _sliderLabel = "Low";
  late bool _isManualMode; // Added to track manual/auto mode.
  late DatabaseReference _autoModeRef;

  @override
  void initState() {
    super.initState();
    _buttonStatus = widget.run; // Access the run value via widget property
    _sliderValue = widget.level;
    _isManualMode = widget.auto;
    _fanController
        .getStatusStream(directory, _onFanChange)
        .then((StreamSubscription s) => _subscription = s);

    _autoModeRef =
        FirebaseDatabase.instance.ref().child("devices/202010377/Fan/auto");
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
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> valueMap =
        event.snapshot.value as Map<dynamic, dynamic>;
        _buttonStatus = valueMap['run'];
        _sliderValue = (valueMap['level']).toDouble();
        _isManualMode = !(valueMap['auto'] ?? false);
      }
    });
  }

  String getFanLevel(double sliderValue) {
    if (sliderValue == 1.0) {
      return 'Low';
    } else if (sliderValue > 1.0 && sliderValue <= 2.0) {
      return 'Medium';
    } else if (sliderValue > 2.0 && sliderValue <= 3.0) {
      return 'High';
    } else {
      return 'Unknown';
    }
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
                  onTap: _isManualMode
                      ? () {
                          if (_buttonStatus == 1) {
                            _buttonStatus = 0;
                          } else {
                            _buttonStatus = 1;
                          }
                          _fanController.updateItem(
                              directory, _buttonStatus, _sliderValue);
                          setState(() {});
                        }
                      : null,
                  child: SizedBox(
                    height: _isManualMode ? 109.5 : 127,
                    width: constraints.maxWidth * 0.65,
                    child: widget.isRaspberryPiOn
                        ? (_buttonStatus == 1
                            ? Transform.scale(
                                scale: _isManualMode ? 1.10 : 1.10,
                                child: Image.asset('assets/image/fan_on.png'),
                              )
                            : Transform.scale(
                                scale: _isManualMode ? 1.10 : 1.10,
                                child: Image.asset('assets/image/fan_off.png'),
                              ))
                        : Transform.scale(
                            scale: 1.4,
                            child: Image.asset('assets/image/fan_dis.png')),
                  ),
                ),
                const Text(
                  'Fan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isManualMode = !_isManualMode;
                      // Update Motor/auto in the database based on _isManualMode
                      _autoModeRef.set(
                          !_isManualMode); // Set Motor/auto to _isManualMode
                      if (_isManualMode) {
                        // If switching to manual mode, set Fan/run to 0
                        _fanController.updateItem(directory, 0, _sliderValue);
                        _buttonStatus = 0; // Update the local button status
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isManualMode
                        ? currentTheme.colorScheme
                            .surfaceVariant // Use primary color for Manual mode
                        : currentTheme.colorScheme
                            .surfaceVariant, // Use secondary color for Auto mode
                  ),
                  child: Text(
                    _isManualMode ? "Manual" : "Auto",
                    style: TextStyle(
                      color: _isManualMode
                          ? currentTheme.colorScheme
                              .surface // Use text color for Manual mode
                          : currentTheme.colorScheme
                              .surface, // Use text color for Auto mode
                    ),
                  ),
                ),
                if (!_isManualMode)
                  Container(
                    margin: EdgeInsets.only(bottom: 8, top: 3),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Fan Level: ${getFanLevel(_sliderValue)}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (_isManualMode)
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: currentTheme.colorScheme.primary,
                      inactiveTrackColor: Color.fromARGB(255, 255, 255, 254),
                      thumbColor: currentTheme.colorScheme.onError,
                      valueIndicatorColor: Color.fromARGB(255, 36, 2, 2),
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
                          } else if (_sliderValue > 1.0 &&
                              _sliderValue <= 2.0) {
                            _sliderLabel = "Medium";
                          } else if (_sliderValue > 2.0 &&
                              _sliderValue <= 3.0) {
                            _sliderLabel = "High";
                          }
                          _fanController.updateItem(
                              directory, _buttonStatus, _sliderValue);
                        });
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
