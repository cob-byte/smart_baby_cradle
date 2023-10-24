import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  String? _userFormFirebase(User? user) {
    return user?.uid;
  }

  Stream<String?> get user {
    return _auth.authStateChanges().map((User? user) => _userFormFirebase(user));
  }

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveDeviceID(String deviceID) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _databaseRef.child("users");

      final userId = user.uid;

      final userIDRef = userRef.child(userId);

      // Set the deviceID for the user
      await userIDRef.child('deviceID').set(deviceID);
    }
  }

  Future<String?> getDeviceID() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _databaseRef.child("users");

      final userId = user.uid;

      final userIDRef = userRef.child(userId);

      DatabaseEvent event = await userIDRef.child('deviceID').once();
      DataSnapshot snapshot = event.snapshot;
      final deviceID = snapshot.value as String?;

      return deviceID;
    }
    return null; // User is not authenticated or deviceID not found
  }

  Future<bool> checkDeviceIDExists(String deviceID) async {
    // Get a reference to the "devices" node
    final devicesRef = _databaseRef.child("devices");

    // Check if the deviceID exists in the "devices" node
    DatabaseEvent event = await devicesRef.child(deviceID).once();
    DataSnapshot snapshot = event.snapshot;

    // If the snapshot value is not null, it means the deviceID exists
    return snapshot.value != null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}