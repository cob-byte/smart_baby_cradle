import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/pages/edit_cover.dart';
import 'package:smart_baby_cradle/pages/edit_image.dart';
import 'package:smart_baby_cradle/pages/edit_name.dart';
import 'package:smart_baby_cradle/pages/edit_device.dart';
import '../pages/change_password.dart';
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

  @override
  void initState() {
    super.initState();
    _futureUser = _userData.getUser(); // get the user data in initState
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
                                currentTheme.colorScheme.primary
                                    .withOpacity(.95),
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
                                    fontSize: 30, fontFamily: 'OpenSans'),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(user.email),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            buildUserInfoDisplay(
                                user.name, 'Name', EditNameFormPage()),
                            buildUserInfoDisplay(
                                user.device, 'Device ID', EditDeviceFormPage()),
                            SizedBox(
                              height: 15,
                            ),
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
                                backgroundColor: Theme.of(context)
                                    .primaryColor, // Use your desired color
                                foregroundColor: Colors
                                    .white, // Set text/icon color to white
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
