import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:smart_baby_cradle/user/user_data.dart';
import 'package:smart_baby_cradle/widgets/appbar_widget.dart';

import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import '../user/user.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class EditAgeFormPage extends StatefulWidget {
  const EditAgeFormPage({Key? key}) : super(key: key);

  @override
  EditAgeFormPageState createState() {
    return EditAgeFormPageState();
  }
}

class EditAgeFormPageState extends State<EditAgeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final UserData _userData = UserData();
  final AuthService _auth = AuthService();
  late User _user; // Declare a variable to store the user data
  int _selectedAgeIndex = 0;
  List<String> _ageChoices = [
    'Newborn',
    '1 Month',
    '2 Months',
    '3 Months',
    '4 Months',
    '5 Months',
    '6 Months',
    '7 Months',
    '8 Months',
    '9 Months',
    '10 Months',
    '11 Months',
    '1 Year Old'
  ];

  @override
  void initState() {
    super.initState();
    _userData.getUser().then((user) {
      if (user != null) {
        setState(() {
          _user = user;
          _selectedAgeIndex = user.age;
        });
      }
    });
  }

  Future<bool> saveAge(int ageIndex) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
      final userRef = _databaseRef.child("users");
      final userId = currentUser.uid;
      final userIDRef = userRef.child(userId);

      // Get the current age from Firebase
      var currentAgeEvent = await userIDRef.child('age').once();
      int? currentAge = currentAgeEvent.snapshot.value as int?;

      // If the new age is the same as the current age, show a message and return false
      if (ageIndex == currentAge) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Text('No changes were made.'),
              ],
            ),
            backgroundColor: Colors.blue,
          ),
        );
        return false;
      }

      // Set the age for the user
      await userIDRef.child('age').set(ageIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Age Updated Successfully'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Age',
            style: currentTheme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: currentTheme.appBarTheme.backgroundColor,
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                // Save the selected age index to Firebase
                await _auth.saveAge(_selectedAgeIndex);
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                currentTheme.colorScheme.primary.withOpacity(1),
                currentTheme.colorScheme.secondary.withOpacity(1),
                currentTheme.colorScheme.surface.withOpacity(1),
                currentTheme.colorScheme.surface.withOpacity(1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Positioned(
                  bottom: -60,
                  right: -60,
                  child: Image(
                    image: AssetImage('assets/image/cradle_bg.png'),
                    width: 250,
                    height: 250,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    SizedBox(
                      width: 330,
                      child: Text(
                        "What's Your Baby's Age?",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 250,  // Set the height
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedAgeIndex = index;
                          });
                        },
                        children: _ageChoices.map((age) => Text(age)).toList(),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}