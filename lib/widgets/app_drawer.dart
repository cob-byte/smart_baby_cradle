import 'package:flutter/material.dart';

import 'package:assets_audio_player/assets_audio_player.dart';

import '../services/auth_service.dart';
import './wrapper.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/music_player_screen.dart';
import '../services/music_service.dart';

class AppDrawer extends StatelessWidget {
  final AuthService auth = AuthService();
  final musicService = MusicService();
  final AssetsAudioPlayer assetsAudioPlayer;
  final ThemeData currentTheme; // Add this line to accept the theme
  final Function toggleTheme;

  AppDrawer(
    this.assetsAudioPlayer, {
    Key? key,
    required this.currentTheme,
    required this.toggleTheme,
  }) : super(key: key);

  get style => null;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            backgroundColor: currentTheme.appBarTheme.backgroundColor,
            title: const Text(
              'MENU ',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Bold',
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text(
              'Home',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(HomeScreen.routeName),
          ),
          const Divider(color: Colors.white),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white),
            title: const Text(
              'Camera',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () =>
                Navigator.of(context).pushNamed(CameraScreen.routeName),
          ),
          const Divider(color: Colors.white),
          ListTile(
            leading: const Icon(Icons.queue_music, color: Colors.white),
            title: const Text(
              'Music Player',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(MusicPlayerScreen.routeName),
          ),
          const Divider(color: Colors.white),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              if (assetsAudioPlayer.isPlaying.value) {
                assetsAudioPlayer.playlistPlayAtIndex(0);
                assetsAudioPlayer.pause();
                musicService.updateFirebaseSong(false, 1);
              }
              auth.signOut().then((_) {
                Navigator.of(context).pushReplacementNamed(Wrapper.routeName);
              });
            },
          ),
        ],
      ),
    );
  }
}
