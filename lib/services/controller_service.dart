import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class ControllerService {

  final FirebaseDatabase database = FirebaseDatabase.instance ;


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

  Future getStatusOnce(String directory) async {
    Completer completer = Completer();

    FirebaseDatabase.instance
        .ref()
        .child(directory)
        .once()
        .then((DataSnapshot snapshot) {
      completer.complete(snapshot.value);
    } as FutureOr Function(DatabaseEvent value));

    return completer.future;
  }


  Future<void> updateItem(String directory ,int status,double level)async{
     await database.ref().child(directory).update({
      'level': level.toInt(),
      'run': status,
    });
  }
 
}