import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class StatusService {

  static final FirebaseDatabase database = FirebaseDatabase.instance ;

  Future<StreamSubscription<DatabaseEvent>> getStatusStream(String directory , Function(DatabaseEvent event) onData) async {
    StreamSubscription<DatabaseEvent> subscription = database
        .ref()
        .child(directory)
        .onValue
        .listen((DatabaseEvent event) {
      onData(event);
    });

    return subscription;
  }

  Future<DataSnapshot> getStatusOnce(String directory) async {
    DatabaseEvent event = await database
        .ref()
        .child(directory)
        .once();

    return event.snapshot;
  }
}
