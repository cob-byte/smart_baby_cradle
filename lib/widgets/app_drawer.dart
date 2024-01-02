import 'package:flutter/material.dart';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/theme/boy_theme.dart';
import 'package:smart_baby_cradle/theme/girl_theme.dart';

import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import './wrapper.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/music_player_screen.dart';
import '../services/music_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  final AuthService auth = AuthService();
  final bool isRaspberryPiOn;

  AppDrawer(
    this.isRaspberryPiOn,
  );

  get style => null;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            backgroundColor: currentTheme.colorScheme.inversePrimary,
            title: const Text(
              'MENU',
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
          IgnorePointer(
            ignoring:
                !isRaspberryPiOn, // Set to true if isRaspberryPiOn is false
            child: ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                'Livestream',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () =>
                  Navigator.of(context).pushNamed(CameraScreen.routeName),
            ),
          ),
          const Divider(color: Colors.white),
          IgnorePointer(
            ignoring:
                !isRaspberryPiOn, // Set to true if isRaspberryPiOn is false
            child: ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white),
              title: const Text(
                'Music Player',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.of(context)
                  .pushNamed(MusicPlayerScreen.routeName),
            ),
          ),
          const Divider(color: Colors.white),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () =>
                Navigator.of(context).pushNamed(Profile.routeName),
          ),
          const Divider(color: Colors.white),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              themeProvider.currentTheme = girlTheme;
              auth.signOut().then((_) {
                Navigator.of(context).pushReplacementNamed(Wrapper.routeName);
              });
            },
          ),
          // Add an Image widget at the bottom
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 10.0), // Adjust the padding as needed
                child: Opacity(
                  opacity:
                      0.8, // Adjust the opacity value between 0.0 (completely transparent) and 1.0 (fully visible)
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
