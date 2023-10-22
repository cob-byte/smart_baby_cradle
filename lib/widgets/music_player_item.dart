import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:provider/provider.dart';

import '../services/status_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';
import '../screens/music_player_screen.dart';

class MusicPlayerItem extends StatelessWidget {
  final AssetsAudioPlayer assetsAudioPlayer;
  final bool isRaspberryPiOn;

  MusicPlayerItem(this.assetsAudioPlayer, this.isRaspberryPiOn);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    return Theme(
      data: currentTheme,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(MusicPlayerScreen.routeName);
                },
                child: SizedBox(
                  child: Image.asset(
                    isRaspberryPiOn
                        ? 'assets/image/babymusic.png'
                        : 'assets/image/music_dis.png',
                  ),
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(bottom: 5.0), // Add space below the text
                child: FittedBox(
                  child: Text(
                    'Music',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
