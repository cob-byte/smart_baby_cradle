import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';

import 'user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  static User myUser = User(
    image:
        "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ficon-library.com%2Fimages%2Fparents-icon-png%2Fparents-icon-png-29.jpg&f=1&nofb=1&ipt=32bdb228ab6cd050a3160cbf8738136974020ab4dd717166a91bbf6db07c9287&ipo=images",
    coverPhoto:
        "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ficon-library.com%2Fimages%2Fparents-icon-png%2Fparents-icon-png-29.jpg&f=1&nofb=1&ipt=32bdb228ab6cd050a3160cbf8738136974020ab4dd717166a91bbf6db07c9287&ipo=images",
    name: 'Test Test',
    email: 'test.test@gmail.com',
    device: 'test',
    fname: 'test',
    lname: 'test',
  );

  Future<User> getUser() async {
    firebase_auth.User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      String uid = firebaseUser.uid;
      String email = firebaseUser.email ?? '';
      String name = firebaseUser.displayName ?? '';
      DataSnapshot snapshot =
          await _databaseRef.child('users').child(uid).get();
      if (snapshot.value != null && snapshot.value is Map) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);
        String device = data['deviceID'] ?? '';
        String fname = data['fname'] ?? '';
        String lname = data['lname'] ?? '';
        String image = data['imageURL'] ??
            'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ficon-library.com%2Fimages%2Fparents-icon-png%2Fparents-icon-png-29.jpg&f=1&nofb=1&ipt=32bdb228ab6cd050a3160cbf8738136974020ab4dd717166a91bbf6db07c9287&ipo=images';
        String coverPhoto = data['coverPhotoURL'] ??
            'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ficon-library.com%2Fimages%2Fparents-icon-png%2Fparents-icon-png-29.jpg&f=1&nofb=1&ipt=32bdb228ab6cd050a3160cbf8738136974020ab4dd717166a91bbf6db07c9287&ipo=images';

        return User(
          image: image,
          coverPhoto: coverPhoto,
          name: name,
          device: device,
          email: email,
          fname: fname,
          lname: lname,
        );
      }
    }
    throw Exception('No user logged in');
  }
}
