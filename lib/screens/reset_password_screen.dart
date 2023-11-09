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
        content: Text(message),
        backgroundColor: Colors.red,
      ));
    }

    void _showSuccessSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ));
    }

    Future<void> _resetPassword() async {
      final email = _emailController.text.trim();

      if (email.isEmpty || !email.contains('@')) {
        _showErrorSnackbar('Invalid email address');
        return;
      }

      try {
        await _auth.sendPasswordResetEmail(email: email);
        _showSuccessSnackbar('Password reset email sent. Please check your inbox.');
      } catch (error) {
        _showErrorSnackbar('Password reset failed. Please try again.');
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
                      height: 225,
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
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _resetPassword,
                            child: Text('Reset Password'),
                          ),
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
