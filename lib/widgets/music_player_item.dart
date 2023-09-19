import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import '../screens/music_player_screen.dart';

class MusicPlayerItem extends StatelessWidget {
  final AssetsAudioPlayer assetsAudioPlayer;

  MusicPlayerItem(this.assetsAudioPlayer);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 202, 212, 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
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
                width: constraints.maxWidth * 0.65,
                child: Image.asset('assets/image/babymusic.png'),
              ),
            ),
            const FittedBox(
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
          ],
        ),
      ),
    );
  }
}
