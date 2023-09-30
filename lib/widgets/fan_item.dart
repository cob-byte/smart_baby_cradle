import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../services/controller_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

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
  String _sliderLabel = "Low";

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
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> valueMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        _buttonStatus = valueMap['run'];
        _sliderValue = (valueMap['level']).toDouble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Theme(
          data: currentTheme,
          child: Container(
            decoration: BoxDecoration(
              color: currentTheme.colorScheme.inverseSurface,
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
                      _fanController.updateItem(
                          directory, _buttonStatus, _sliderValue);
                      setState(() {});
                    },
                    child: SizedBox(
                      height: 150,
                      width: constraints.maxWidth * 0.65,
                      child: _buttonStatus == 1
                          ? Transform.scale(
                              scale: 1.5, // Adjust the scale factor as needed
                              child: Image.asset('assets/image/fan_on.png'),
                            )
                          : Transform.scale(
                              scale: 1.5, // Adjust the scale factor as needed
                              child: Image.asset('assets/image/fan_off.png'),
                            ),
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
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor:
                          Colors.blue, // Active/Filled part of the slider
                      inactiveTrackColor: Color.fromARGB(255, 255, 255,
                          254), // Inactive/Unfilled part. of the slider
                      thumbColor: Colors.red, // The circle that you drag
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
      ),
    );
  }
}
