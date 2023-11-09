import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:smart_baby_cradle/theme/boy_theme.dart';
import 'package:smart_baby_cradle/theme/girl_theme.dart';
import 'package:smart_baby_cradle/theme_provider.dart';
import 'package:smart_baby_cradle/screens/wake_up_times_screen.dart';
import 'package:smart_baby_cradle/screens/sleep_score_screen.dart';

import 'services/auth_service.dart';
import './services/music_service.dart';
import './screens/home_screen.dart';
import './screens/auth_screen.dart.dart';
import './screens/camera_Screen.dart';
import './screens/music_player_screen.dart';
import './screens/sleep_analysis_screen.dart';
import './screens/reset_password_screen.dart';
import './screens/profile_screen.dart';
import './widgets/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Provide the ThemeProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final musicService = MusicService();
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  final List<Audio> audios = [
    Audio("assets/audios/JohnsonsBaby.mp3"),
    Audio("assets/audios/LullabyGoodnight.mp3"),
    Audio("assets/audios/PrettyLittleHorses.mp3"),
    Audio("assets/audios/RockabyeBaby.mp3"),
    Audio("assets/audios/Twinkle.mp3"),
    Audio("assets/audios/Nap Time.mp3"),
    Audio("assets/audios/Butterfly.mp3"),
    Audio("assets/audios/Baby Bear.mp3"),
    Audio("assets/audios/If You're Sleepy.mp3"),
    Audio("assets/audios/Hush Little Baby.mp3"),
  ];

  @override
  void initState() {
    assetsAudioPlayer.open(
        Playlist(
          audios: audios,
        ),
        autoStart: false);
    super.initState();
  }

  bool isGirlTheme = true; // Initialize with girl theme

  void toggleTheme() {
    setState(() {
      isGirlTheme = !isGirlTheme;
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.toggleTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<String?>.value(
      value: AuthService().user,
      initialData: '',
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Baby Monitor',
            theme: themeProvider.currentTheme, // Use the selected theme
            home: Wrapper(),
            routes: <String, WidgetBuilder>{
              Wrapper.routeName: (ctx) => Wrapper(),
              ResetPass.routeName: (ctx) => ResetPass(),
              AuthScreen.routeName: (ctx) => const AuthScreen(),
              HomeScreen.routeName: (ctx) =>
                  HomeScreen(assetsAudioPlayer: assetsAudioPlayer),
              CameraScreen.routeName: (ctx) => const CameraScreen(),
              Profile.routeName: (ctx) => const Profile(),
              SleepAnalysisScreen.routeName: (ctx) => SleepAnalysisScreen(),
              MusicPlayerScreen.routeName: (ctx) =>
                  MusicPlayerScreen(assetsAudioPlayer),
              SleepScoreScreen.routeName: (ctx) => SleepScoreScreen(100),
              WakeUpTimesScreen.routeName: (ctx) => WakeUpTimesScreen(),
            },
          );
        },
      ),
    );
  }
}
