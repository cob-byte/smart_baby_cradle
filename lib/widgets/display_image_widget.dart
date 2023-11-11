import 'dart:io';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  // Constructor
  const DisplayImage({
    Key? key,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Center(
        child: Stack(children: [
      buildImage(currentTheme.primaryColor),
      Positioned(
        child: buildEditIcon(context),
        right: 4,
        top: 10,
      )
    ]));
  }

  // Builds Profile Image
  Widget buildImage(Color color) {
    final image = imagePath.contains('https://')
        ? NetworkImage(imagePath)
        : FileImage(File(imagePath));

    return CircleAvatar(
      radius: 75,
      backgroundColor: color,
      child: CircleAvatar(
        backgroundImage: image as ImageProvider,
        radius: 70,
      ),
    );
  }

  // Builds Edit Icon on Profile Picture
  Widget buildEditIcon(context) => buildCircle(
      all: 8,
      child: Icon(
        Icons.edit,
        color: Theme.of(context).primaryColor,
        size: 20,
      ));

  // Builds/Makes Circle for Edit Icon on Profile Picture
  Widget buildCircle({
    required Widget child,
    required double all,
  }) =>
      ClipOval(
          child: Container(
        padding: EdgeInsets.all(all),
        color: Colors.white,
        child: child,
      ));
}
