import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/reset_password_screen.dart';
import '../services/auth_service.dart';

enum AuthMode { signUp, login }

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'fName': '',
    'lName': '',
    'deviceID': '',
  };
  var _isLoading = false;
  bool _obscureText = true;
  bool _obscureText1 = true;
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> _forgotPassword() async {
    Navigator.of(context).pushNamed(ResetPass.routeName);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential? userCredential; // Declare a nullable variable to store the user credential
      if (_authMode == AuthMode.login) {
        userCredential = await _auth.signInWithEmailAndPassword(
            _authData['email']!, _authData['password']!);
      } else {
        // Check if the deviceID already exists in the "devices" node
        final deviceIDExists =
          await _auth.checkDeviceIDExists(_authData['deviceID']!);
        if (deviceIDExists) {
          userCredential = await _auth.registerWithEmailAndPassword(
              _authData['email']!, _authData['password']!);
          await _auth.saveDeviceID(_authData['deviceID']!);
        } else {
          _showError('Device ID Does Not Exist',
              'Please try again with a valid Device ID.');
        }
      }
      if (userCredential != null && userCredential.user != null && _authData['fName'] != null && _authData['lName'] != null) {
        String fullName = _authData['fName']! + ' ' + _authData['lName']!;
        await userCredential.user!.updateDisplayName(fullName);
        await _auth.saveFullName(_authData['fName']!, _authData['lName']!);
      }
      setState(() {
        _isLoading = false;
      });
    } on PlatformException catch (error) {
      _showError(error.code, error.message!);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      _showError('Error occurred', 'Please try again');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          height: _authMode == AuthMode.signUp ? 510 : 305,
          constraints: BoxConstraints(
            minHeight: _authMode == AuthMode.signUp ? 320 : 260,
          ),
          width: deviceSize.width * 0.75,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      labelStyle:
                      TextStyle(color: Theme.of(context).primaryColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty == true ||
                          value?.contains('@') != true) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _authData['email'] = value;
                      }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                      labelStyle:
                      TextStyle(color: Theme.of(context).primaryColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureText,
                    controller: _passwordController,
                    validator: (value) {
                      if (value?.isEmpty == true || (value?.length ?? 0) < 5) {
                        return 'Password is too short!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _authData['password'] = value;
                      }
                    },
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.signUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
                    ),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.signUp,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
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
                            labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          obscureText: _obscureText1,
                          validator: _authMode == AuthMode.signUp
                              ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.signUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
                    ),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.signUp,
                          decoration:
                          const InputDecoration(labelText: 'First Name'),
                          validator: _authMode == AuthMode.signUp
                              ? (value) {
                            value = value!.trim(); // Trim the input
                            if (value.isEmpty) {
                              return 'First Name is required';
                            } else if (value.length < 2) {
                              return 'First Name must be at least 2 characters long';
                            } else if (value.length > 25) {
                              return 'First Name must be less than 25 characters long';
                            } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                              return 'First Name must only contain alphabetic characters';
                            }
                            return null;
                          }: null,
                          onSaved: (value) {
                            if (value != null) {
                              _authData['fName'] = value;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.signUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
                    ),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.signUp,
                          decoration:
                          const InputDecoration(labelText: 'Last Name'),
                          validator: _authMode == AuthMode.signUp
                              ? (value) {
                            value = value!.trim(); // Trim the input
                            if (value.isEmpty) {
                              return 'Last Name is required';
                            } else if (value.length < 2) {
                              return 'Last Name must be at least 2 characters long';
                            } else if (value.length > 25) {
                              return 'Last Name must be less than 25 characters long';
                            } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                              return 'Last Name must only contain alphabetic characters';
                            }
                            return null;
                          }: null,
                          onSaved: (value) {
                            if (value != null) {
                              _authData['lName'] = value;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.signUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
                    ),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.signUp,
                          decoration: InputDecoration(
                            labelText: 'Device ID',
                            labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          validator: _authMode == AuthMode.signUp
                              ? (value) {
                            if (value!.isEmpty) {
                              return 'Device ID is required';
                            }
                            return null;
                          }: null,
                          onSaved: (value) {
                            if (value != null) {
                              _authData['deviceID'] = value;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor:
                        Theme.of(context).primaryTextTheme.labelLarge?.color,
                      ),
                      child:
                      Text(_authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP'),
                    ),
                  TextButton(
                    onPressed: _switchAuthMode,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 4),
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                        '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  ),
                  _authMode == AuthMode.login ? TextButton(
                    onPressed: _forgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text('Forgot password?'),
                  ) : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}