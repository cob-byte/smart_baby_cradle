import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';


import '../screens/auth_screen.dart.dart';
import '../screens/home_screen.dart';

class Wrapper extends StatelessWidget {
  static const routeName = '/wrapper';

  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<String?>(context);
    if(user == null){
      return const AuthScreen();
    }
    else{
      return HomeScreen(assetsAudioPlayer: assetsAudioPlayer);
    }
  }
}
