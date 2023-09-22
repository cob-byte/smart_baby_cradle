import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import '../widgets/app_drawer.dart';
import '../services/music_service.dart';
import '../theme/boy_theme.dart';
import '../theme/girl_theme.dart';

class MusicPlayerScreen extends StatefulWidget {
  static const routeName = '/music-player';
  final AssetsAudioPlayer assetsAudioPlayer;
  final Function toggleTheme;
  final ThemeData currentTheme;

  const MusicPlayerScreen(
    this.assetsAudioPlayer, {
    Key? key,
    required this.toggleTheme,
    required this.currentTheme,
  }) : super(key: key);

  @override
  MusicPlayerScreenState createState() => MusicPlayerScreenState();
}

class MusicPlayerScreenState extends State<MusicPlayerScreen> {
  String imageAsset = 'assets/image/JohnsonsBaby.jpg';
  bool isLooping = false;
  bool isMuted = false;
  double volume = 0.3;
  final musicService = MusicService();

  AssetsAudioPlayer get assetsAudioPlayer => widget.assetsAudioPlayer;

  @override
  void initState() {
    assetsAudioPlayer.isPlaying.listen((isPlaying) {
      assetsAudioPlayer.current.listen((songs) {
        changeImage(songs!);
        musicService.updateFirebaseSong(isPlaying, songs.index);
      });
    });
    musicService.updateFirebaseVolume(volume);

    super.initState();
  }

  void changeImage(Playing songs) {
    int songIndex = songs.index;
    if (songIndex == 0) {
      imageAsset = 'assets/image/JohnsonsBaby.jpg';
    }
    if (songIndex == 1) {
      imageAsset = 'assets/image/LullabyGoodnight.jpg';
    }
    if (songIndex == 2) {
      imageAsset = 'assets/image/PrettyLittle.jpg';
    }
    if (songIndex == 3) {
      imageAsset = 'assets/image/RockabyeBaby.jpg';
    }
    if (songIndex == 4) {
      imageAsset = 'assets/image/Twinkle.png';
    }
    if (songIndex == 5) {
      imageAsset = 'assets/image/NapTime.png';
    }
    if (songIndex == 6) {
      imageAsset = 'assets/image/Beddy-byeButterfly.png';
    }
    if (songIndex == 7) {
      imageAsset = 'assets/image/BabyBear.png';
    }
    if (songIndex == 8) {
      imageAsset = 'assets/image/IfYouAreSleepy.png';
    }
    if (songIndex == 9) {
      imageAsset = 'assets/image/HushLittleBaby.png';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentTheme = Theme.of(context);

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
            assetsAudioPlayer,
            currentTheme: currentTheme,
            toggleTheme: widget.toggleTheme,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
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
                                    ? Color.fromARGB(255, 192, 118, 129)
                                    : Colors.grey[550],
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() {
                                  isMuted = !isMuted;
                                });
                                if (isMuted) {
                                  assetsAudioPlayer.setVolume(0);
                                } else {
                                  assetsAudioPlayer.setVolume(volume);
                                }
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
                                  onPressed: () {
                                    assetsAudioPlayer.previous();
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: IconButton(
                                    icon: PlayerBuilder.isPlaying(
                                      player: assetsAudioPlayer,
                                      builder: (context, isPlaying) {
                                        return isPlaying
                                            ? const Icon(Icons.pause,
                                                color: Colors.black, size: 40)
                                            : const Icon(Icons.play_arrow,
                                                color: Colors.black, size: 40);
                                      },
                                    ),
                                    onPressed: () {
                                      assetsAudioPlayer.playOrPause();
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.skip_next,
                                    color: Colors.black,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    assetsAudioPlayer.next();
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.loop,
                                color: isLooping
                                    ? const Color.fromARGB(255, 192, 118, 129)
                                    : Colors.grey[550],
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() {
                                  isLooping = !isLooping;
                                });
                                assetsAudioPlayer.setLoopMode(isLooping
                                    ? LoopMode.single
                                    : LoopMode.none);
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
                              volume = newValue;
                              musicService.updateFirebaseVolume(volume);
                              setState(() {});
                            },
                            value: volume,
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
                    assetsAudioPlayer.playlistPlayAtIndex(0);
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
                    assetsAudioPlayer.playlistPlayAtIndex(1);
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
                    assetsAudioPlayer.playlistPlayAtIndex(2);
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
                    assetsAudioPlayer.playlistPlayAtIndex(3);
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
                    assetsAudioPlayer.playlistPlayAtIndex(4);
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
                    assetsAudioPlayer.playlistPlayAtIndex(5);
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
                    assetsAudioPlayer.playlistPlayAtIndex(6);
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
                    assetsAudioPlayer.playlistPlayAtIndex(7);
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
                    assetsAudioPlayer.playlistPlayAtIndex(8);
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
                    assetsAudioPlayer.playlistPlayAtIndex(9);
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
