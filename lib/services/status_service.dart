import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import 'auth_service.dart';

final FirebaseDatabase database = FirebaseDatabase.instance ;
final AuthService auth = AuthService();
final String? deviceID = auth.getDeviceID() as String?;

class StatusService {
  Future<StreamSubscription<DatabaseEvent>> getStatusStream(String directory , Function(DatabaseEvent event) onData) async {
    StreamSubscription<DatabaseEvent> subscription = database
        .ref()
        .child("devices")
        .child("202010377")
        .child(directory)
        .onValue
        .listen((DatabaseEvent event) {
      onData(event);
    });

    return subscription;
  }

  Future<DataSnapshot> getStatusOnce(DatabaseReference rootRef, String directory) async {
    DatabaseEvent event = await rootRef
        .child(directory)
        .once();

    return event.snapshot;
  }
}
