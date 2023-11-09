import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:smart_baby_cradle/user/user_data.dart';
import 'package:smart_baby_cradle/widgets/appbar_widget.dart';

import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import '../user/user.dart';

// This class handles the Page to edit the Name Section of the User Profile.
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

  @override
  void dispose() {
    firstNameController.dispose();
    secondNameController.dispose();
    super.dispose();
  }

  Future<bool> updateUserValue(String firstName, String secondName) async {
    var user = auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? currentName = user.displayName;
      String newName = "${firstName.trim()} ${secondName.trim()}";

      // Check if the new name is the same as the current one
      if (newName == currentName) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No changes were made.'),
            backgroundColor: Colors.blue,
          ),
        );
        return false;
      }

      // If the name is different
      await user.updateDisplayName(newName);
      await _auth.saveFullName(firstName, secondName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name Updated Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: FutureBuilder<User>(
        future: _userData.getUser(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          // the function that returns a widget based on the snapshot
          if (snapshot.hasData) {
            User user = snapshot.data!;
            firstNameController.text = user.fname;
            secondNameController.text = user.lname;
            return Form(
              key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: 330,
                        child: const Text(
                          "What's Your Name?",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 40, 16, 0),
                            child: SizedBox(
                                height: 100,
                                width: 150,
                                child: TextFormField(
                                  // Handles Form Validation for First Name
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    } else if (!isAlpha(value)) {
                                      return 'Only Letters Please';
                                    }
                                    return null;
                                  },
                                  decoration:
                                  InputDecoration(labelText: 'First Name'),
                                  controller: firstNameController,
                                ))),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 40, 16, 0),
                            child: SizedBox(
                                height: 100,
                                width: 150,
                                child: TextFormField(
                                  // Handles Form Validation for Last Name
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    } else if (!isAlpha(value)) {
                                      return 'Only Letters Please';
                                    }
                                    return null;
                                  },
                                  decoration:
                                  const InputDecoration(labelText: 'Last Name'),
                                  controller: secondNameController,
                                )))
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 150),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: 330,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate() &&
                                      isAlpha(firstNameController.text + secondNameController.text)) {
                                    bool nameUpdated = await updateUserValue(firstNameController.text, secondNameController.text);
                                    if (nameUpdated) {
                                      Navigator.pop(context);
                                    }
                                  }
                                },

                                child: const Text(
                                  'Update',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            )))
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // if the Future is completed with an error
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          } else {
            // if the Future is still loading
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
