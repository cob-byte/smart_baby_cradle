import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../services/status_service.dart';
import '../theme_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:smart_baby_cradle/screens/wake_up_times_screen.dart';

void main() {
  runApp(MaterialApp(
    home: AutoTrackerScreen(),
  ));
}

class AutoTrackerScreen extends StatefulWidget {
  static const routeName = '/auto-tracking';

  @override
  _AutoTrackerScreenState createState() => _AutoTrackerScreenState();
}

class _AutoTrackerScreenState extends State<AutoTrackerScreen> with WidgetsBindingObserver {
  bool _faceDetection = false;
  bool _trackSleeping = false;
  bool _isTracking = false;
  String _downloadURL = '';
  String _lastUpdated = '';
  String _facing = '';
  String _confidence = '';
  String _status = '';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fetchTrackingData();
    _fetchValues();
    _getImage();

    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => _getImage());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    _timer?.cancel();
    return super.didPopRoute();
  }

  Future<void> _fetchValues() async {
    String? deviceID = await auth.getDeviceID();

    if (deviceID != null) {
      // Listen for changes in the Firebase database
      FirebaseDatabase.instance
          .ref()
          .child("devices")
          .child(deviceID)
          .child("track")
          .child("values")
          .onValue
          .listen((event) {
        var snapshot = event.snapshot;

        if (snapshot.value is Map) {
          Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _facing = map['facing'];
            _confidence = map['confidence'];
            _status = map['status'];
          });
        }
      });
    }
  }

  Future<void> _fetchTrackingData() async {
    String? deviceID = await auth.getDeviceID();

    if (deviceID != null) {
      // Listen for changes in the Firebase database
      FirebaseDatabase.instance
          .ref()
          .child("devices")
          .child(deviceID)
          .child("track")
          .onValue
          .listen((event) {
        var snapshot = event.snapshot;

        if (snapshot.value is Map) {
          Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _faceDetection = map['faceDetection'];
            _trackSleeping = map['trackSleeping'];
            _isTracking = map['isTracking'];
          });
        }
      });
    }
  }

  void _getImage() async {
    if(mounted) {
      firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref('images/tracked.jpg');

      // Get the download URL for the image
      String downloadURL = await ref.getDownloadURL();

      // Get the metadata of the image
      firebase_storage.FullMetadata metadata = await ref.getMetadata();

      // Get the 'updated' info from the metadata
      DateTime? updatedTime = metadata.updated;

      updatedTime = updatedTime?.add(Duration(days: -9));

      // Update the state
      setState(() {
        _downloadURL = downloadURL;
        _lastUpdated = updatedTime.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Auto Sleep Tracker',
            style: currentTheme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: currentTheme.appBarTheme.backgroundColor,
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      currentTheme.colorScheme.primary,
                      currentTheme.colorScheme.secondary,
                      currentTheme.colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -30,
              child: Image(
                image: AssetImage('assets/image/cradle_bg.png'),
                width: 300,
                height: 300,
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Configuration',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: Text('Face Detection', style: TextStyle(fontSize: 24)),
                            value: _faceDetection,
                            activeColor: Colors.pink,
                            onChanged: _isTracking ? null : (bool? value) {
                              setState(() {
                                _faceDetection = value ?? false;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          CheckboxListTile(
                            title: Text('Track Sleeping', style: TextStyle(fontSize: 24)),
                            value: _trackSleeping,
                            activeColor: Colors.pink,
                            onChanged: _isTracking ? null : (bool? value) {
                              setState(() {
                                _trackSleeping = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                      label: Text(
                        _isTracking ? 'Stop Tracking' : 'Start Tracking',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                      ),
                      onPressed: () async {
                        if (!_faceDetection && !_trackSleeping) {
                          // Show an error if no checkbox is checked
                          if (ScaffoldMessenger.of(context).mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.yellow,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Please check at least one option',
                                      style: TextStyle(color: Colors.white),  // Customize text color
                                    ),
                                  ],
                                ),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                          return;
                        }

                        String? deviceID = await auth.getDeviceID();
                        if (deviceID != null) {
                          setState(() {
                            _isTracking = !_isTracking;
                          });
                          // Update all the values in the database
                          await FirebaseDatabase.instance
                              .ref()
                              .child("devices")
                              .child(deviceID)
                              .child("track")
                              .set({
                            'faceDetection': _faceDetection,
                            'trackSleeping': _trackSleeping,
                            'isTracking': _isTracking,
                          });
                        } else {
                          print('Failed to get deviceID');
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Last Update: $_lastUpdated',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    if(_isTracking)...[
                      if(_trackSleeping && _faceDetection)...[
                        Text(
                          'Facing: $_facing',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Confidence: $_confidence',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Baby\'s Status: $_status',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]
                      else if(_faceDetection)...[
                        Text(
                          'Facing: $_facing',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Confidence: $_confidence',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]
                      else if(_trackSleeping)...[
                        Text(
                          'Baby\'s Status: $_status',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ],
                    SizedBox(height: 20),
                    _downloadURL == ''
                        ? Container(
                      width: 350,
                      height: 350,
                      color: Colors.black, // Placeholder color
                    )
                        : Image.network(_downloadURL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}