import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:smart_baby_cradle/user/user_data.dart';
import 'package:smart_baby_cradle/widgets/appbar_widget.dart';

import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import '../user/user.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class EditNameFormPage extends StatefulWidget {
  const EditNameFormPage({Key? key}) : super(key: key);

  @override
  EditNameFormPageState createState() {
    return EditNameFormPageState();
  }
}

class EditNameFormPageState extends State<EditNameFormPage> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final secondNameController = TextEditingController();
  final UserData _userData = UserData();
  final AuthService _auth = AuthService();
  User? user;

  @override
  void initState() {
    super.initState();

    _userData.getUser().then((userData) {
      if (userData != null) {
        setState(() {
          user = userData;
          firstNameController.text = user!.fname;
          secondNameController.text = user!.lname;
        });
      }
    });
  }

  @override
  @override
  void dispose() {
    firstNameController.dispose();
    secondNameController.dispose();
    super.dispose();
  }

  Future<bool> updateUserValue(String firstName, String secondName) async {
    var currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String? currentName = currentUser.displayName;
      String newName = "${firstName.trim()} ${secondName.trim()}";

      if (newName == currentName) {
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

      await currentUser.updateDisplayName(newName);
      await _auth.saveFullName(firstName, secondName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Name Updated Successfully'),
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
            'Edit Name',
            style: currentTheme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: currentTheme.appBarTheme.backgroundColor,
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
                        "What's Your Name?",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: currentTheme.colorScheme.surface,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 16, 0),
                          child: SizedBox(
                            height: 100,
                            width: 150,
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                } else if (!isAlpha(value)) {
                                  return 'Only Letters Please';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                labelStyle: TextStyle(
                                    color: currentTheme.colorScheme.surface,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: currentTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: currentTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: currentTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              controller: firstNameController,
                              style: TextStyle(
                                  color: currentTheme.colorScheme.surface),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 16, 0),
                          child: SizedBox(
                            height: 100,
                            width: 150,
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                } else if (!isAlpha(value)) {
                                  return 'Only Letters Please';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                labelStyle: TextStyle(
                                    color: currentTheme.colorScheme.surface,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: currentTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: currentTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: currentTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              controller: secondNameController,
                              style: TextStyle(
                                  color: currentTheme.colorScheme.surface),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  isAlpha(firstNameController.text +
                                      secondNameController.text)) {
                                bool nameUpdated = await updateUserValue(
                                  firstNameController.text,
                                  secondNameController.text,
                                );
                                if (nameUpdated) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                            icon: Icon(Icons.update),
                            label: Text(
                              'Update',
                              style: TextStyle(fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
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
