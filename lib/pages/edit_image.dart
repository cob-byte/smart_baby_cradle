import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smart_baby_cradle/user/user_data.dart';
import 'package:path_provider/path_provider.dart';
import '../theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:smart_baby_cradle/widgets/appbar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;

import '../user/user.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage({Key? key}) : super(key: key);

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final UserData _userData = UserData();
  firebase_auth.User? user;
  DatabaseReference? userRef;
  String? userId;
  DatabaseReference? userIDRef;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      userRef = _databaseRef.child("users");
      userId = user!.uid;
      userIDRef = userRef!.child(userId!);
    }
  }

  Future<File?> _cropImage(String imagePath) async {
    try {
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop',
            cropGridColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop'),
        ],
      );

      if (cropped != null) {
        print(cropped.path);
        return File(cropped.path);
      } else {
        print('Image cropping canceled or failed.');
        return null; // Return null if cropping was canceled or failed
      }
    } catch (e) {
      print('Error during image cropping: $e');
      return null;
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Edit Display Photo',
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      backgroundColor: Theme.of(context)
          .appBarTheme
          .backgroundColor, // Set the background color here
      // Other properties like actions, leading, etc.
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLocalImage = false;

    return FutureBuilder(
      future: _userData.getUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          User user = snapshot.data;
          return Scaffold(
            appBar: buildAppBar(context),
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 330,
                        child: const Text(
                          "Upload new display photo:",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: SizedBox(
                          width: 330,
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return GestureDetector(
                                onTap: () async {
                                  final image = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (image == null) return;

                                  try {
                                    File? croppedImage =
                                    await _cropImage(image.path);
                                    if (croppedImage != null) {
                                      setState(() {
                                        user.image = croppedImage.path;
                                        isLocalImage = true;
                                      });
                                    }
                                  } catch (e) {
                                    print('Error during image cropping: $e');
                                  }
                                },
                                child: isLocalImage
                                    ? Image.file(File(user.image))
                                    : Image.network(user.image),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: 330,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  if (user.image == "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ficon-library.com%2Fimages%2Fparents-icon-png%2Fparents-icon-png-29.jpg&f=1&nofb=1&ipt=32bdb228ab6cd050a3160cbf8738136974020ab4dd717166a91bbf6db07c9287&ipo=images") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error,
                                                color: Colors.white),
                                            SizedBox(width: 8),
                                            Text(
                                                "Please select an image to upload for the profile picture."),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  final location =
                                  await getApplicationDocumentsDirectory();
                                  final name = basename(user.image);
                                  final imageFile =
                                  File('${location.path}/$name');
                                  final newImage = await File(user.image)
                                      .copy(imageFile.path);

                                  // Use the user's UID as the file name
                                  firebase_storage.Reference storageReference =
                                  firebase_storage.FirebaseStorage.instance
                                      .ref()
                                      .child('users/${userId}');
                                  firebase_storage.UploadTask uploadTask =
                                  storageReference
                                      .putFile(File(user.image));
                                  await uploadTask;

                                  String imageUrl =
                                  await storageReference.getDownloadURL();
                                  await userIDRef
                                      ?.child('imageURL')
                                      .set(imageUrl);
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                              'Display Image Updated Successfully'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  // Show an error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                              'An error occurred. Please try again.'),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.upload),
                              label: Text(
                                'Upload',
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
                ),
                Positioned(
                  bottom: -60,
                  right: -60,
                  child: Image(
                    image: AssetImage('assets/image/cradle_bg.png'),
                    width: 210,
                    height: 210,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
