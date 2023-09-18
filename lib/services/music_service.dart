import 'package:firebase_database/firebase_database.dart';

class MusicService{


  final DatabaseReference database =
      FirebaseDatabase.instance.ref().child('Music');

  Future<void> updateFirebaseSong(bool isPlaying, int songIndex) async {
    if (isPlaying == true) {
      database.update({'song': songIndex + 1});
    } else if (isPlaying == false) {
      database.update({'song': 0});
    }
  }

  Future<void> updateFirebaseVolume(double vol) async {
    database.update({'volume': vol.toStringAsFixed(1)});
  }
}