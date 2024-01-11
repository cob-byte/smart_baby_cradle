import 'package:connectivity/connectivity.dart';
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
            child: Text(
              "Okay",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
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
      UserCredential?
          userCredential; // Declare a nullable variable to store the user credential
      if (_authMode == AuthMode.login) {
        try {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (connectivityResult == ConnectivityResult.none) {
            _showError('No internet connection', 'Please connect to the internet to log in.');
          }
          else {
            userCredential = await _auth.signInWithEmailAndPassword(
                _authData['email']!, _authData['password']!);
          }
        } catch (e) {
          if (e is FirebaseAuthException) {
            print(e.code);
            if (e.code == 'user-not-found') {
              _showError('Account does not exist', 'Please sign up');
            } else if (e.code == 'wrong-password' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
              _showError('Invalid credentials', 'Please try again');
            } else if (e.code == 'too-many-requests'){
              _showError('Too many requests', 'Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.');
            } else{
              _showError('An error occurred', 'Please try again');
            }
          } else {
            _showError('An error occurred', 'Please try again');
          }
        }
      }
      else {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          _showError('No internet connection', 'Please connect to the internet to log in.');
        }
        else {
          // Check if the deviceID already exists in the "devices" node
          final deviceIDExists =
          await _auth.checkDeviceIDExists(_authData['deviceID']!);
          if (deviceIDExists) {
            try {
              userCredential = await _auth.registerWithEmailAndPassword(
                  _authData['email']!, _authData['password']!);
              await _auth.saveDeviceID(_authData['deviceID']!);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'email-already-in-use') {
                _showError('Email is already in use',
                    'The email address is already in use by another account.');
              }
            } catch (e) {
              print(e);
            }
          } else {
            _showError('Device ID Does Not Exist',
                'Please try again with a valid Device ID.');
          }

          if (userCredential != null &&
              userCredential.user != null &&
              _authData['fName'] != null &&
              _authData['lName'] != null) {
            String fullName = _authData['fName']! + ' ' + _authData['lName']!;
            await userCredential.user!.updateDisplayName(fullName);
            await _auth.saveFullName(_authData['fName']!, _authData['lName']!);
          }
        }
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
                      if (value?.trim().isEmpty == true) {
                        return 'E-mail is required!';
                      }
                      else if(value?.contains('@') != true){
                        return 'Invalid email format. Please enter a valid email';
                      }
                      else {
                        String pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(pattern);
                        if (!regex.hasMatch(value!)) {
                          return 'Invalid email format. Please enter a valid email';
                        }
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
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).primaryColor,
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
                      if (_authMode == AuthMode.login) {
                        if (value?.trim().isEmpty == true) {
                          return 'Password is required!';
                        }
                        else if ((value?.length ?? 0) < 6) {
                          return 'Password is too short!';
                        }
                      }
                      else {
                        if (value?.trim().isEmpty == true) {
                          return 'Password is required!';
                        } else if ((value?.length ?? 0) < 6) {
                          return 'Password is too short. Please enter at least 6 characters';
                        } else if (!RegExp(r'(?=.*[a-z])').hasMatch(value!)) {
                          return 'Password must contain a mix of uppercase and lowercase letters.';
                        } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                          return 'Password must contain a mix of uppercase and lowercase letters.';
                        } else if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                          return 'Password must contain at least one numeric character';
                        } else if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
                          return 'Password must contain at least one special character';
                        }
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
                                _obscureText1
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText1 = !_obscureText1;
                                });
                              },
                            ),
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
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
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          validator: _authMode == AuthMode.signUp
                              ? (value) {
                                  value = value!.trim(); // Trim the input
                                  if (value.isEmpty) {
                                    return 'First Name is required';
                                  } else if (value.length < 2) {
                                    return 'First Name must be at least 2 characters long';
                                  } else if (value.length > 25) {
                                    return 'First Name must be less than 25 characters long';
                                  } else if (!RegExp(r'^[a-zA-Z ]+$')
                                      .hasMatch(value)) {
                                    return 'First Name must only contain alphabetic characters';
                                  }
                                  return null;
                                }
                              : null,
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
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          validator: _authMode == AuthMode.signUp
                              ? (value) {
                                  value = value!.trim(); // Trim the input
                                  if (value.isEmpty) {
                                    return 'Last Name is required';
                                  } else if (value.length < 2) {
                                    return 'Last Name must be at least 2 characters long';
                                  } else if (value.length > 25) {
                                    return 'Last Name must be less than 25 characters long';
                                  } else if (!RegExp(r'^[a-zA-Z ]+$')
                                      .hasMatch(value)) {
                                    return 'Last Name must only contain alphabetic characters';
                                  }
                                  return null;
                                }
                              : null,
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
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
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
                                }
                              : null,
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
                        foregroundColor: Theme.of(context)
                            .primaryTextTheme
                            .labelLarge
                            ?.color,
                      ),
                      child: Text(
                          _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP'),
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
                  _authMode == AuthMode.login
                      ? TextButton(
                          onPressed: _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 4),
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text('Forgot password?'),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
