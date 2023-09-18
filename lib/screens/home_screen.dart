import 'dart:async';
import 'dart:convert';

import '../widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

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

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  final AssetsAudioPlayer assetsAudioPlayer;

  const HomeScreen({Key? key, required this.assetsAudioPlayer}) : super(key: key);

  @override
    HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final StatusService _home = StatusService();
  final AuthService auth = AuthService();
  final musicService = MusicService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  AssetsAudioPlayer get assetsAudioPlayer => widget.assetsAudioPlayer;

  final _logger = Logger('FCM');

  @override
  void initState() {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Baby Actions',
          style: TextStyle(
            fontFamily: 'Poppins-Bold',
            fontSize: 25,
            fontStyle: FontStyle.normal,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(22, 22, 22, 0.6),
      ),
      extendBodyBehindAppBar: true,
      drawer: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: const Color.fromRGBO(22, 22, 22,0.5) ),
        child: AppDrawer(assetsAudioPlayer),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 120),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffb92b27),
              Color(0xff1565C0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder(
          future: _home.getStatusOnce(""),
          builder: (BuildContext context, AsyncSnapshot future) {
            if (future.hasError) {
              return const Center(
                child: Text(
                  "Error Occurred, Please log out and try again",
                  style: TextStyle(color: Colors.white),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1 / 1),
                children: <Widget>[
                  MotorItem(run: motor['run'], level: motor['level'].toDouble()),
                  FanItem(fan['run'], fan['level'].toDouble()),
                  TemperatureItem(double.parse(status['Temperature'])),
                  HumidityItem(double.parse(status['Humidity']) / 100),
                  SoundDetectorItem(sound['detected']),
                  const CameraLiveItem(),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
