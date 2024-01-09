import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

import '../widgets/header_logo.dart';

class ResetPass extends StatefulWidget {
  static const routeName = '/reset';

  const ResetPass({Key? key}) : super(key: key);

  @override
  ResetPassState createState() => ResetPassState();
}

class ResetPassState extends State<ResetPass> {
  final TextEditingController _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    void _showErrorSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ));
    }

    void _showSuccessSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ));
    }

    Future<void> _resetPassword() async {
      final email = _emailController.text.trim();
      if (email.trim().isEmpty == true) {
        _showErrorSnackbar('E-mail is required!');
      }
      else if(email.contains('@') != true){
        _showErrorSnackbar('Invalid email format. Please enter a valid email');
      }
      else {
        String pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(email)) {
          _showErrorSnackbar('Invalid email format. Please enter a valid email');
        }
      }

      try {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          _showErrorSnackbar('No internet connection. Please try again later.');
        }
        else{
          _auth.sendPasswordResetEmail(email: email);
          _showSuccessSnackbar(
              'Password reset email sent. Please check your inbox.');
        }
      } catch (error) {
        _showErrorSnackbar('Password reset unsuccessful. Please try again.');
      }
    }

    return Theme(
      data: themeProvider.currentTheme,
      child: GestureDetector(
        onTap: () {
          if (FocusScope.of(context).focusedChild is! MaterialButton) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Forgot Password'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.currentTheme.colorScheme.primary,
                      themeProvider.currentTheme.colorScheme.secondary,
                      themeProvider.currentTheme.colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              ListView(
                children: <Widget>[
                  HeaderLogo(deviceSize),
                  SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 8.0,
                    child: Container(
                      height: 200,
                      width: deviceSize.width * 0.75,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Enter your email to reset your password:',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              maximumSize: Size(200, 36),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.autorenew_rounded),
                                SizedBox(width: 8),
                                Text('Reset Password'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
