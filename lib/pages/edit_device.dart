import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:smart_baby_cradle/user/user_data.dart';
import 'package:smart_baby_cradle/widgets/appbar_widget.dart';

import '../services/auth_service.dart';
import '../user/user.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class EditDeviceFormPage extends StatefulWidget {
  const EditDeviceFormPage({Key? key}) : super(key: key);

  @override
  EditDeviceFormPageState createState() {
    return EditDeviceFormPageState();
  }
}

class EditDeviceFormPageState extends State<EditDeviceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final deviceController = TextEditingController();
  final UserData _userData = UserData();
  final AuthService _auth = AuthService();
  late User _user; // Declare a variable to store the user data

  @override
  void initState() {
    super.initState();
    _userData.getUser().then((user) {
      if (user != null) {
        setState(() {
          _user = user;
          deviceController.text = user.device;
        });
      }
    });
  }

  @override
  void dispose() {
    deviceController.dispose();
    super.dispose();
  }

  Future<bool> updateUserValue(String device) async {
    String currentDeviceID = _user.device;

    if (device.trim() == currentDeviceID) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No changes were made.'),
          backgroundColor: Colors.blue,
        ),
      );
      return false;
    }

    final deviceIDExists = await _auth.checkDeviceIDExists(device.trim());
    if (deviceIDExists) {
      await _auth.saveDeviceID(device.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device ID Updated Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please try again with a valid Device ID.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return deviceIDExists;
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
            'Edit Device ID',
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
                        "What's Your Device ID?",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: SizedBox(
                        height: 100,
                        width: 330,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Device ID';
                            } else if (isAlpha(value)) {
                              return 'Only Numbers Please';
                            }
                            return null;
                          },
                          controller: deviceController,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: 'Your Device ID',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                bool deviceIDExists =
                                await updateUserValue(deviceController.text);
                                if (deviceIDExists) {
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
                              backgroundColor:
                              Theme.of(context).primaryColor,
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