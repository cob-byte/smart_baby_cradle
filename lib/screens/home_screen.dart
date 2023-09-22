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
import '../widgets/music_player_item.dart';
import '../theme/boy_theme.dart';
import '../theme/girl_theme.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  final AssetsAudioPlayer assetsAudioPlayer;

  const HomeScreen({Key? key, required this.assetsAudioPlayer})
      : super(key: key);

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

  bool isGirlTheme = true; // Initialize with girl theme

  void toggleTheme() {
    setState(() {
      isGirlTheme = !isGirlTheme; // Toggle the theme
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme =
        isGirlTheme ? girlTheme : boyTheme; // Select the current theme

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
            IconButton(
              icon: Icon(
                isGirlTheme ? Icons.female : Icons.male,
                color: Colors.white,
              ),
              onPressed: toggleTheme,
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: currentTheme.primaryColor,
          ),
          child: AppDrawer(
            assetsAudioPlayer,
            currentTheme: currentTheme,
            toggleTheme: toggleTheme,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 120),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                currentTheme.colorScheme.primary,
                currentTheme.colorScheme.secondary,
                currentTheme.colorScheme.tertiary,
                currentTheme.scaffoldBackgroundColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FutureBuilder(
            future: _home.getStatusOnce(""),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1 / 1,
                  ),
                  children: <Widget>[
                    MotorItem(
                      run: motor['run'],
                      level: motor['level'].toDouble(),
                    ),
                    FanItem(fan['run'], fan['level'].toDouble()),
                    TemperatureItem(double.parse(status['Temperature'])),
                    HumidityItem(double.parse(status['Humidity']) / 100),
                    SoundDetectorItem(sound['detected']),
                    CameraLiveItem(),
                    MusicPlayerItem(widget.assetsAudioPlayer),
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
      ),
    );
  }
}
