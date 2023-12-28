import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as authT;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/pages/edit_cover.dart';
import 'package:smart_baby_cradle/pages/edit_image.dart';
import 'package:smart_baby_cradle/pages/edit_name.dart';
import 'package:smart_baby_cradle/pages/edit_device.dart';
import '../pages/change_password.dart';
import '../pages/edit_age.dart';
import '../services/auth_service.dart';
import '../services/status_service.dart';
import '../theme/girl_theme.dart';
import '../theme_provider.dart';
import '../user/user.dart';
import '../widgets/display_image_widget.dart';
import '../widgets/display_cover_widget.dart';
import '../user/user_data.dart';
import '../widgets/wrapper.dart';

// This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class Profile extends StatefulWidget {
  static const routeName = '/profile';

  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  final UserData _userData = UserData();
  Future<User>? _futureUser;
  int _selectedAgeIndex = 0;

  List<String> ageStrings = [
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
    _futureUser = _userData.getUser(); // get the user data in initState
  }

  String getAgeString(int age) {
    if (age >= 0 && age < ageStrings.length) {
      return ageStrings[age];
    } else {
      return 'Invalid age';
    }
  }

  Future<bool> _checkIfGoogleUser() async {
    final authT.FirebaseAuth _auth = authT.FirebaseAuth.instance;
    authT.User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      for (authT.UserInfo userInfo in firebaseUser.providerData) {
        if (userInfo.providerId == 'google.com') {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> saveAge(int ageIndex) async {
    final currentUser = authT.FirebaseAuth.instance.currentUser;
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

  void _showPicker(BuildContext ctx) {
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => CupertinoActionSheet(
        actions: [
          Container(
            height: 250,
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 30,
              scrollController: FixedExtentScrollController(initialItem: 0),
              children: ageStrings.map((age) => Text(age)).toList(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedAgeIndex = index;
                });
              },
            ),
          ),
        ],
        message: CupertinoActionSheetAction(
          child: Text(
            'Save',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text('Confirm'),
                content: Text('Are you sure you want to save?'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                      'No',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      'Yes',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      saveAge(_selectedAgeIndex).then((_) {
                        Navigator.pop(ctx); // Close the picker
                        setState(() {
                          _futureUser = _userData.getUser(); // Create a new Future
                        });
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
        data: currentTheme,
        child: FutureBuilder<User>(
          future: _futureUser,
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              User user = snapshot.data!;
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Profile Screen',
                    style: currentTheme.appBarTheme.titleTextStyle,
                  ),
                  backgroundColor: currentTheme.appBarTheme.backgroundColor,
                ),
                body: Container(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        top: 0, // Adjust the top position as needed
                        child: Container(
                          width: MediaQuery.of(context)
                              .size
                              .width, // Set the width to fill the screen
                          height: height / 4, // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                          ),
                          child: ClipRRect(
                            child: InkWell(
                              onTap: () {
                                navigateSecondPage(EditCoverPhotoPage());
                              },
                              child: DisplayCoverPhoto(
                                coverPhotoPath: user.coverPhoto,
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: height / 1.4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                currentTheme.colorScheme.primary.withOpacity(1),
                                currentTheme.colorScheme.primary.withOpacity(1),
                                currentTheme.colorScheme.secondary
                                    .withOpacity(1),
                                currentTheme.colorScheme.surface.withOpacity(1),
                                currentTheme.colorScheme.surface.withOpacity(1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60.0),
                              topRight: Radius.circular(60.0),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -60,
                        right: -50,
                        child: Image(
                          image: AssetImage('assets/image/cradle_bg.png'),
                          width: 200,
                          height: 200,
                        ),
                      ),
                      Positioned(
                        top: height / 10.5,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: height / 5,
                              width: height / 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: () {
                                  navigateSecondPage(EditImagePage());
                                },
                                child: DisplayImage(
                                  imagePath: user.image,
                                  onPressed: () {},
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'OpenSans',
                                  color: currentTheme.colorScheme.surface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'OpenSans',
                                    color: currentTheme.colorScheme.surface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            buildUserInfoDisplay(
                                user.name, 'Name', EditNameFormPage()),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Device ID',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: 350,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1,
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                user.device,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  height: 1.4,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  _showPicker(context);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Baby\'s Age',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: 350,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1,
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                getAgeString(user.age),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  height: 1.4,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Icon(
                                              Icons.edit_square,
                                              color: Theme.of(context).primaryColor,
                                              size: 20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            if(!user.isGoogleUser)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Route route = MaterialPageRoute(
                                    builder: (context) => ChangePassFormPage(),
                                  );
                                  Navigator.push(context, route).then(onGoBack);
                                },
                                icon: Icon(Icons.lock),
                                label: Text('Change Password'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ElevatedButton.icon(
                              onPressed: () {
                                themeProvider.currentTheme = girlTheme;
                                auth.signOut().then((_) {
                                  Navigator.of(context)
                                      .pushReplacementNamed(Wrapper.routeName);
                                });
                              },
                              icon: Icon(Icons.exit_to_app),
                              label: Text('Log Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .primaryColor, // Use your desired color
                                foregroundColor: Colors
                                    .white, // Set text/icon color to white
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ));
  }

  // Widget builds the display item with the proper formatting to display the user's info
  Widget buildUserInfoDisplay(String getValue, String title, Widget editPage) =>
      Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () {
            navigateSecondPage(editPage);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 350,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          getValue,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.edit_square,
                        color: Theme.of(context).primaryColor,
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  // Refreshes the Page after updating user info.
  FutureOr onGoBack(dynamic value) {
    setState(() {
      _futureUser = _userData.getUser(); // update the future
    });
  }

  // Handles navigation and prompts refresh.
  void navigateSecondPage(Widget editForm) {
    Route route = MaterialPageRoute(builder: (context) => editForm);
    Navigator.push(context, route).then(onGoBack);
  }
}
