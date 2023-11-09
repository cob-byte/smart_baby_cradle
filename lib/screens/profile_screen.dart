import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/pages/edit_image.dart';
import 'package:smart_baby_cradle/pages/edit_name.dart';
import 'package:smart_baby_cradle/pages/edit_device.dart';
import '../pages/change_password.dart';
import '../services/status_service.dart';
import '../theme/girl_theme.dart';
import '../theme_provider.dart';
import '../user/user.dart';
import '../widgets/display_image_widget.dart';
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

    return FutureBuilder<User>(
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
                style: TextStyle(
                  fontFamily: 'Poppins-Bold',
                  fontSize: 25,
                  fontStyle: FontStyle.normal,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              backgroundColor: const Color.fromRGBO(22, 22, 22, 1),
            ),
            body: Container(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              "https://thumbs.dreamstime.com/z/baby-seamless-pattern-gender-neutral-design-element-nursery-fabric-wallpaper-wrapping-paper-vector-illustration-flat-159228703.jpg"
                          ),
                          fit: BoxFit.cover,
                        )
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: height / 1.4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(45.0),
                          topRight: Radius.circular(45.0),
                        ),
                      ),
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
                            style: TextStyle(fontSize: 30, fontFamily: 'OpenSans'),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(user.email),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        buildUserInfoDisplay(user.name, 'Name', EditNameFormPage()),
                        buildUserInfoDisplay(user.device, 'Device ID', EditDeviceFormPage()),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Route route = MaterialPageRoute(builder: (context) => ChangePassFormPage());
                            Navigator.push(context, route).then(onGoBack);
                          },
                          child: Text('Change Password'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            themeProvider.currentTheme = girlTheme;
                            auth.signOut().then((_) {
                              Navigator.of(context).pushReplacementNamed(Wrapper.routeName);
                            });
                          },
                          child: Text('Log Out'),
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
    );
  }

  // Widget builds the display item with the proper formatting to display the user's info
  Widget buildUserInfoDisplay(String getValue, String title, Widget editPage) =>
      Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: 1,
              ),
              Container(
                  width: 350,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ))),
                  child: Row(children: [
                    Expanded(
                        child: TextButton(
                            onPressed: () {
                              navigateSecondPage(editPage);
                            },
                            child: Text(
                              getValue,
                              style: TextStyle(fontSize: 16, height: 1.4),
                            ))),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.grey,
                      size: 40.0,
                    )
                  ]))
            ],
          ));

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