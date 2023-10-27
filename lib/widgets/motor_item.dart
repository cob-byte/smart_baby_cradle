import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../services/controller_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class MotorItem extends StatefulWidget {
  final int run;
  final double level;
  final bool isRaspberryPiOn;
  const MotorItem(
      {Key? key,
        required this.run,
        required this.isRaspberryPiOn,
        required this.level})
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
      //_sliderValue = (snapshotValue['level']).toDouble();
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
              BoxShadow(
                color: Color.fromARGB(255, 106, 106, 106)
                    .withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
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
                    height: 200,
                    width: constraints.maxWidth * 0.65,
                    child: widget.isRaspberryPiOn
                        ? (_buttonStatus == 1
                        ? Transform.scale(
                      scale: 1.5,
                      child: Image.asset('assets/image/motor_on.png'),
                    )
                        : Transform.scale(
                      scale: 1.5,
                      child:
                      Image.asset('assets/image/motor_off.png'),
                    ))
                        : Transform.scale(
                        scale: 1.5,
                        child: Image.asset('assets/image/motor_dis.png')),
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
                SizedBox(height: 10),
                /*SliderTheme(
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
