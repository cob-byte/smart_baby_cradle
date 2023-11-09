import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:smart_baby_cradle/user/user_data.dart';
import 'package:smart_baby_cradle/widgets/appbar_widget.dart';

import '../services/auth_service.dart';
import '../user/user.dart';

// This class handles the Page to edit the Device ID Section of the User Profile.
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

  @override
  void dispose() {
    deviceController.dispose();
    super.dispose();
  }

  Future<bool> updateUserValue(String device) async {
    // Get the current device ID
    User user = await _userData.getUser();
    String currentDeviceID = user.device;

    // Check if the new device ID is the same as the current one
    if (device.trim() == currentDeviceID) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No changes were made.'),
          backgroundColor: Colors.blue,
        ),
      );
      return false;  // Return false to indicate no change
    }

    // If the device ID is different
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
    return FutureBuilder<User>(
      future: _userData.getUser(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          User user = snapshot.data!;
          deviceController.text = user.device;
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
                          "What's Your Device ID?",
                          style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        )),
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: SizedBox(
                          height: 100,
                          width: 320,
                          child: TextFormField(
                            // Handles Form Validation
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Device ID';
                              } else if (isAlpha(value)) {
                                return 'Only Numbers Please';
                              }
                              return null;
                            },
                            controller: deviceController,
                            decoration: const InputDecoration(
                              labelText: 'Your Device ID',
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 150),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: 320,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  bool deviceIDExists = await updateUserValue(deviceController.text);
                                  if (deviceIDExists) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              child: const Text(
                                'Update',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          )),
                    ),
                  ]),
              ),
            ),
          );
        }
      },
    );
  }
}