import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:smart_baby_cradle/user/user_data.dart';
import 'package:smart_baby_cradle/widgets/appbar_widget.dart';

import '../services/status_service.dart';
import '../widgets/wrapper.dart';

class ChangePassFormPage extends StatefulWidget {
  const ChangePassFormPage({Key? key}) : super(key: key);

  @override
  ChangePassFormPageState createState() {
    return ChangePassFormPageState();
  }
}

class ChangePassFormPageState extends State<ChangePassFormPage> {
  final _formKey = GlobalKey<FormState>();
  final currentPass = TextEditingController();
  final newPass = TextEditingController();
  final cNewPass = TextEditingController();
  bool _obscureText = true;
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  bool _isLoading = false;

  @override
  void dispose() {
    currentPass.dispose();
    newPass.dispose();
    cNewPass.dispose();
    super.dispose();
  }

  Future<bool> validateCurrentPassword(String currentPassword) async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;

      // Create a credential
      final credential = EmailAuthProvider.credential(
        email: user!.email.toString(),
        password: currentPassword,
      );

      // Reauthenticate the user
      await user.reauthenticateWithCredential(credential);

      // If no error is thrown, the password is correct
      return true;
    } catch (e) {
      // If an error is thrown, the password is incorrect
      return false;
    }
  }

  Future<bool> updateUserValue(String currentPassword, String newPassword) async {
    if (await validateCurrentPassword(currentPassword)) {
      // The current password is correct, update the password
      final user = FirebaseAuth.instance.currentUser;
      await user?.updatePassword(newPassword);
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The current password is incorrect'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 320,
                child: const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: SizedBox(
                  height: 100,
                  width: 320,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                    controller: currentPass,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 100,
                  width: 320,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                    controller: newPass,
                    obscureText: _obscureText1,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText1 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText1 = !_obscureText1;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 100,
                  width: 320,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm the new password';
                      } else if (value != newPass.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    controller: cNewPass,
                    obscureText: _obscureText2,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText2 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText2 = !_obscureText2;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 320,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          bool isCurrentPasswordCorrect = await validateCurrentPassword(currentPass.text);

                          setState(() {
                            _isLoading = false;
                          });

                          if (isCurrentPasswordCorrect) {
                            bool success = await updateUserValue(
                              currentPass.text,
                              newPass.text,
                            );
                            if (success) {
                              auth.signOut().then((_) {
                                Navigator.of(context).pushReplacementNamed(Wrapper.routeName);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Password successfully changed'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('The current password is incorrect'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : const Text(
                        'Update Password',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}