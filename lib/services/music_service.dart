import 'package:firebase_database/firebase_database.dart';

class MusicService{

  final DatabaseReference database =
      FirebaseDatabase.instance.ref().child("devices").child("202010377").child("Music");

  Future<String?> getFirebaseVolume() async {
    DatabaseEvent event = await database.child('volume').once();
    DataSnapshot snapshot = event.snapshot;
    return snapshot.value as String?;
  }

  Future<bool?> getFirebasePause() async {
    DatabaseEvent event = await database.child('pause').once();
    DataSnapshot snapshot = event.snapshot;
    return snapshot.value as bool?;
  }

  Future<bool?> getFirebaseLooping() async {
    DatabaseEvent event = await database.child('isLooping').once();
    DataSnapshot snapshot = event.snapshot;
    return snapshot.value as bool?;
  }

  Future<void> updateFirebaseSong(int songIndex) async {
      await database.update({'song': songIndex + 1});
  }

  Future<void> updateFirebasePause(bool isPlaying) async {
    await database.update({'pause': !isPlaying});
  }

  Future<void> updateFirebaseLooping(bool isLooping) async {
    database.update({'isLooping': isLooping});
  }

  Future<void> updateFirebaseVolume(double vol) async {
    database.update({'volume': vol.toStringAsFixed(1)});
  }
}