import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../services/status_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class SoundDetectorItem extends StatefulWidget {
  final String sound;
  const SoundDetectorItem(this.sound, {Key? key}) : super(key: key);
  @override
  _SoundDetectorItemState createState() => _SoundDetectorItemState(sound);
}

class _SoundDetectorItemState extends State<SoundDetectorItem> {
  final StatusService _soundStatus = StatusService();
  StreamSubscription? _subscription;
  static const String directory = 'Sound Detection/detected';
  String _sound;
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  _SoundDetectorItemState(this._sound);

  @override
  void initState() {
    _soundStatus
        .getStatusStream(directory, _updateSound)
        .then((StreamSubscription s) => _subscription = s);
    super.initState();
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription?.cancel();
    }
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  _updateSound(DatabaseEvent event) {
    setState(() {
      _sound = event.snapshot.value as String;
    });
    if (_sound == 'yes') {
      assetsAudioPlayer.open(Audio("assets/audios/Baby01.mp3"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          color: currentTheme.colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(),
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                width: constraints.maxWidth * 0.6,
                child: _sound == 'yes'
                    ? Image.asset('assets/image/listen_on.png')
                    : Image.asset('assets/image/listen_off.png'),
              ),
              const FittedBox(
                child: Text(
                  'Sound Detector',
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
      ),
    );
  }
}
