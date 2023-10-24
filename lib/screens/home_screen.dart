import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_baby_cradle/theme/boy_theme.dart';
import 'package:smart_baby_cradle/theme/girl_theme.dart';

import '../widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../util/color.dart';
import '../services/status_service.dart';
import '../services/auth_service.dart';
import '../services/music_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/motor_item.dart';
import '../widgets/camera_live.dart';
import '../widgets/fan_item.dart';
import '../widgets/humidity_item.dart';
import '../widgets/temperature_item.dart';
import '../widgets/sound_detector_item.dart';
import '../widgets/music_player_item.dart';
import '../widgets/sleep_analysis_item.dart';
import 'package:smart_baby_cradle/theme_provider.dart';
import 'package:smart_baby_cradle/theme/greyscale_theme.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  final AssetsAudioPlayer assetsAudioPlayer;

  const HomeScreen({Key? key, required this.assetsAudioPlayer})
      : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AuthService auth = AuthService();
  final musicService = MusicService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  late DatabaseReference _rootRef, _timestampRef;
  late ThemeProvider themeProvider;
  final StatusService _home = StatusService();
  String? newDeviceID, deviceID;

  AssetsAudioPlayer get assetsAudioPlayer => widget.assetsAudioPlayer;

  final _logger = Logger('FCM');
  bool isRaspberryPiOn = true;
  Timer? _timer;

  Future<void> checkDeviceID() async {
    deviceID = await auth.getDeviceID();
    if (deviceID == null) {
      String? validationMessage;
      final controller = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text('Enter Your Device ID'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Device ID',
                      errorText: validationMessage,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) {
                      setState(() {
                        validationMessage = 'Device ID is required';
                      });
                    } else {
                      final deviceIDExists = await auth.checkDeviceIDExists(controller.text.trim());
                      if (deviceIDExists) {
                        auth.saveDeviceID(controller.text.trim());
                        Navigator.of(ctx).pop();
                        initState();
                      } else {
                        setState(() {
                          validationMessage = 'Device ID Does Not Exist';
                        });
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    else{
      _rootRef = FirebaseDatabase.instance.ref().child("devices").child(deviceID!);
      _timestampRef = _rootRef.child("timestamp");
    }
  }

  void checkLoginStatus() {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (isLoggedIn) {
      checkDeviceID();
    }
  }

  @override
  void initState() {
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Initialize the root reference with a dummy value (it will be updated in checkDeviceID)
    fetchDeviceID();
    checkLoginStatus();

    _fcm.getToken().then((token) => _logger.info(token));
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.info("onMessage: ${message.data}");
      final snackbar = SnackBar(
        content: Text(message.notification?.title ?? "No Title"),
        action: SnackBarAction(
          label: 'Go',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        _logger.info("onMessageOpenedApp: $message");
      }
    });
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _logger.info("onLaunch: $message");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }

  bool isGirlTheme = true; // Initialize with girl theme

  void toggleTheme() {
    setState(() {
      isGirlTheme = !isGirlTheme; // Toggle the theme locally
      themeProvider.toggleTheme(); // Toggle the theme in the provider
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    if (deviceID == null) {
      return Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard ✨',
            style: currentTheme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: currentTheme.appBarTheme.backgroundColor,
          actions: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    isRaspberryPiOn ? Icons.wifi : Icons.wifi_off,
                    color: isRaspberryPiOn ? Colors.green : Colors.red,
                  ),
                ),
                if (isRaspberryPiOn)
                  IconButton(
                    icon: Icon(
                      isGirlTheme ? Icons.female : Icons.male,
                      color: Colors.white,
                    ),
                    onPressed: toggleTheme,
                  ),
              ],
            ),
          ],
        ),

        //extendBodyBehindAppBar: true,
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: currentTheme.colorScheme.onInverseSurface,
          ),
          child: AppDrawer(
            assetsAudioPlayer,
            isRaspberryPiOn
          ),
        ),
        body: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentTheme.colorScheme.primary,
                    currentTheme.colorScheme.secondary,
                    currentTheme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Image in the lower right corner
            Positioned(
              bottom: -100, // Adjust the position as needed
              right: -100, // Adjust the position as needed
              child: isRaspberryPiOn
                  ? Image.asset(
                'assets/image/cradle_bg.png',
                width: 400,
                height: 350,
              )
                  : Image.asset(
                'assets/image/bg_off.png',
                width: 400,
                height: 350,
              ),
            ),
            FutureBuilder(
              future: _home.getStatusOnce(_rootRef, ""),
              builder: (BuildContext context, AsyncSnapshot future) {
                if (future.hasError) {
                  return Center(
                    child: Text(
                      "Error Occurred, Please log out and try again",
                      style: TextStyle(
                        color: currentTheme.colorScheme.onError,
                      ),
                    ),
                  );
                }
                if (future.hasData) {
                  final homeData = future.data.value;
                  final status = homeData['Status'];
                  final motor = homeData['Motor'];
                  final fan = homeData['Fan'];
                  final sound = homeData['Sound Detection'];
                  return GridView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1 / 1.28,
                    ),
                    children: <Widget>[
                    IgnorePointer(
                      ignoring: !isRaspberryPiOn,
                      child: MotorItem(
                        run: motor['run'],
                        level: motor['level'].toDouble(),
                        isRaspberryPiOn: isRaspberryPiOn,
                      ),
                    ),
                    IgnorePointer(
                      ignoring: !isRaspberryPiOn,
                      child: FanItem(
                        fan['run'],
                        fan['level'].toDouble(),
                        isRaspberryPiOn,
                      ),
                    ),
                    IgnorePointer(
                      ignoring: !isRaspberryPiOn,
                      child: TemperatureItem(
                        double.parse(status['Temperature']),
                        isRaspberryPiOn,
                      ),
                    ),
                    IgnorePointer(
                      ignoring: !isRaspberryPiOn,
                      child: HumidityItem(double.parse(status['Humidity']) / 100, isRaspberryPiOn),
                    ),
                    IgnorePointer(
                      ignoring: !isRaspberryPiOn,
                      child: SoundDetectorItem(sound['detected'], isRaspberryPiOn),
                    ),
                    IgnorePointer(
                     ignoring: !isRaspberryPiOn,
                      child: CameraLiveItem(isRaspberryPiOn: isRaspberryPiOn),
                    ),
                    IgnorePointer(
                      ignoring: !isRaspberryPiOn,
                      child: MusicPlayerItem(
                          widget.assetsAudioPlayer,
                          isRaspberryPiOn,
                        ),
                    ),
                    IgnorePointer(
                      ignoring: !isRaspberryPiOn,
                      child: SleepAnalysisItem(isRaspberryPiOn: isRaspberryPiOn),
                    ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchDeviceID() async {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (isLoggedIn) {
      deviceID = await auth.getDeviceID();
      _rootRef =
          FirebaseDatabase.instance.ref().child("devices").child(deviceID!);
      _timestampRef = _rootRef.child("timestamp");

      // Periodically check the timestamp and determine Raspberry Pi status
      _timer = Timer.periodic(Duration(seconds: 5), (timer) {
        _timestampRef.once().then((DatabaseEvent event) async {
          DataSnapshot snapshot = event.snapshot;
          if (snapshot.value != null) {
            int currentTimestamp = snapshot.value as int;
            DateTime currentDateTime = DateTime.now();
            DateTime timestampDateTime = DateTime.fromMillisecondsSinceEpoch(
                currentTimestamp * 1000);

            int timeDiff = currentDateTime
                .difference(timestampDateTime)
                .inSeconds;

            if (timeDiff > 20) {
              // Raspberry Pi is considered offline
              if (mounted) {
                setState(() {
                  isRaspberryPiOn = false;
                  themeProvider.setRaspberryPiStatus(isRaspberryPiOn);
                });
              }

              // Update the values for 'Fan', 'Motor', 'Music', and 'Sound Detection'
              await _rootRef.child("Fan").update({
                "level": 1,
                "run": 0,
                "auto": false,
              });

              await _rootRef.child("Motor").update({
                "level": 1,
                "run": 0,
              });

              await _rootRef.child("Music").update({
                "song": 1,
                "pause": true,
                "isLooping": false,
              });

              await _rootRef.child("Sound Detection").update({
                "detected": "no",
              });
            } else {
              // Raspberry Pi is online
              if (mounted) {
                setState(() {
                  isRaspberryPiOn = true;
                  themeProvider.setRaspberryPiStatus(isRaspberryPiOn);
                  if(themeProvider.currentTheme == greyscaleTheme){
                    themeProvider.currentTheme = girlTheme;
                  }
                });
              }
            }
          }
        });
      });
    }
    setState(() {});
  }
}
