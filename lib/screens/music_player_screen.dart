import 'dart:async';

import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:provider/provider.dart';

import '../services/controller_service.dart';
import '../theme/greyscale_theme.dart';
import '../widgets/app_drawer.dart';
import '../services/music_service.dart';
import '../theme/boy_theme.dart';
import '../theme/girl_theme.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

import 'package:firebase_database/firebase_database.dart';

class MusicPlayerScreen extends StatefulWidget {
  static const routeName = '/music-player';

  const MusicPlayerScreen(
      {Key? key,
  }) : super(key: key);

  @override
  MusicPlayerScreenState createState() => MusicPlayerScreenState();
}

class MusicPlayerScreenState extends State<MusicPlayerScreen> {
  String imageAsset = 'assets/image/JohnsonsBaby.jpg';
  int currentSongIndex = 1;
  bool isLooping = false;
  bool isPause = true;
  bool isMuted = false;
  double volume = 0.3;
  bool isRaspberryPiOn = true;
  late ThemeProvider themeProvider;
  final musicService = MusicService();
  final ControllerService _musicController = ControllerService();
  StreamSubscription? _subscription;
  static const String musicDirectory = 'Music';

  @override
  void initState() {
    super.initState();
    _musicController
        .getStatusStream(musicDirectory, _onMusicChange)
        .then((StreamSubscription s) => _subscription = s);
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription?.cancel();
    }
    super.dispose();
  }

  _onMusicChange(DatabaseEvent event) {
    setState(() {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> valueMap = event.snapshot.value as Map<dynamic, dynamic>;
        int newSongIndex = valueMap['song'] - 1;
        isLooping = valueMap['isLooping'];
        isPause = valueMap['pause'];
        isMuted = valueMap['muted'];
        volume = double.tryParse(valueMap['volume'] ?? '0.3') ?? 0.3;

        changeImage(newSongIndex);
      }
    });
  }

  void changeImage(int newSongIndex) {
    if (mounted) {
      currentSongIndex = newSongIndex;
      // Update the imageAsset based on the currentSongIndex
      switch (currentSongIndex) {
        case 0:
          imageAsset = 'assets/image/JohnsonsBaby.jpg';
          break;
        case 1:
          imageAsset = 'assets/image/LullabyGoodnight.jpg';
          break;
        case 2:
          imageAsset = 'assets/image/PrettyLittle.jpg';
          break;
        case 3:
          imageAsset = 'assets/image/RockabyeBaby.jpg';
          break;
        case 4:
          imageAsset = 'assets/image/Twinkle.png';
          break;
        case 5:
          imageAsset = 'assets/image/NapTime.png';
          break;
        case 6:
          imageAsset = 'assets/image/Beddy-byeButterfly.png';
          break;
        case 7:
          imageAsset = 'assets/image/BabyBear.png';
          break;
        case 8:
          imageAsset = 'assets/image/IfYouAreSleepy.png';
          break;
        case 9:
          imageAsset = 'assets/image/HushLittleBaby.png';
          break;
        default:
          // Handle the case for unknown song indexes
          imageAsset = 'assets/image/JohnsonsBaby.jpg';
          break;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    // Get the current theme here
    return Theme(
      data: currentTheme, // Apply the current theme to the entire subtree
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Music Player',
            style: TextStyle(
              fontFamily: 'Poppins-Bold',
              fontSize: 25,
              fontStyle: FontStyle.normal,
              color: Colors.white,
            ),
          ),
          backgroundColor: currentTheme.primaryColor,
        ),
        extendBodyBehindAppBar: true,
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: currentTheme.primaryColor,
          ),
          child: AppDrawer(
            isRaspberryPiOn,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
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
            width: size.width,
            height: size.height,
            child: ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: Color.fromRGBO(19, 19, 19, 0.822),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SizedBox(
                        width: size.width * 0.5,
                        height: size.height * 0.35,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            imageAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                isMuted ? Icons.volume_off : Icons.volume_up,
                                color: isMuted
                                    ? currentTheme.colorScheme.onSecondary
                                    : Colors.grey[550],
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() {
                                  isMuted = !isMuted;
                                });

                                musicService.updateFirebaseMuted(isMuted);
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(
                                    Icons.skip_previous,
                                    color: Colors.black,
                                    size: 40,
                                  ),
                                  onPressed: () async {
                                    // Decrement the currentSongIndex by 1
                                    currentSongIndex--;

                                    // Check if the currentSongIndex == 0, make it 9
                                    if (currentSongIndex == -1) {
                                      currentSongIndex = 9;
                                    }

                                    // Update Firebase with the new song index
                                    musicService.updateFirebaseSong(currentSongIndex);
                                  }
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: IconButton(
                                    icon: isPause
                                        ? Icon(Icons.play_arrow, color: Colors.black, size: 40)
                                        : Icon(Icons.pause, color: Colors.black, size: 40),
                                    onPressed: () {
                                      setState(() {
                                        isPause = !isPause;
                                      });

                                      // Update Firebase with the new pause value
                                      musicService.updateFirebasePause(isPause);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.skip_next,
                                    color: Colors.black,
                                    size: 40,
                                  ),
                                  onPressed: () async {
                                    // Increment the currentSongIndex by 1
                                    currentSongIndex++;

                                    // Check if the currentSongIndex is 10, reset it to 0
                                    if (currentSongIndex == 10) {
                                      currentSongIndex = 0;
                                    }

                                    // Update Firebase with the new song index
                                    musicService.updateFirebaseSong(currentSongIndex);
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.loop,
                                color: isLooping
                                    ? currentTheme.colorScheme.onSecondary
                                    : Colors.grey[550],
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() {
                                  isLooping = !isLooping;
                                });

                                musicService.updateFirebaseLooping(isLooping);
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.volume_down,
                            color: Colors.black,
                            size: 25,
                          ),
                          Slider(
                            min: 0.0,
                            max: 1.0,
                            onChanged: (newValue) {
                              setState(() {
                                volume = newValue;
                              });
                              musicService.updateFirebaseVolume(newValue);
                            },
                            value: isMuted ? 0.0 : volume,
                          ),
                          const Icon(
                            Icons.volume_up,
                            color: Colors.black,
                            size: 25,
                          ),
                        ],
                      ),
                      const Text(
                        'Control Baby\'s Room',
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(0);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundImage:
                            ExactAssetImage('assets/image/JohnsonsBaby.jpg')),
                    title: Text(
                      'Johnsons Baby',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(1);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage:
                          ExactAssetImage('assets/image/LullabyGoodnight.jpg'),
                    ),
                    title: Text(
                      'Lullaby Goodnight',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(2);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage:
                          ExactAssetImage('assets/image/PrettyLittle.jpg'),
                    ),
                    title: Text(
                      'Pretty Little Baby',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(3);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage:
                          ExactAssetImage('assets/image/RockabyeBaby.jpg'),
                    ),
                    title: Text(
                      'Rockabye Baby',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(4);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage:
                          ExactAssetImage('assets/image/Twinkle.png'),
                    ),
                    title: Text(
                      'Twinkle',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(5);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundImage:
                            ExactAssetImage('assets/image/NapTime.png')),
                    title: Text(
                      'Nap Time',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(6);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: ExactAssetImage(
                          'assets/image/Beddy-byeButterfly.png'),
                    ),
                    title: Text(
                      'Beddy-bye Butterfly',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(7);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundImage:
                            ExactAssetImage('assets/image/BabyBear.png')),
                    title: Text(
                      'Baby Bear',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(8);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundImage:
                            ExactAssetImage('assets/image/IfYouAreSleepy.png')),
                    title: Text(
                      'If You Are Sleepy',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    musicService.updateFirebaseSong(9);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundImage:
                            ExactAssetImage('assets/image/HushLittleBaby.png')),
                    title: Text(
                      'Hush Little Baby',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
