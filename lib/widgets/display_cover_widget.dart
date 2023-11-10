import 'dart:io';
import 'package:flutter/material.dart';

class DisplayCoverPhoto extends StatelessWidget {
  final String coverPhotoPath;
  final VoidCallback onPressed;

  // Constructor
  const DisplayCoverPhoto({
    Key? key,
    required this.coverPhotoPath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Color.fromRGBO(64, 105, 225, 1);

    return Center(
      child: Stack(
        children: [
          buildCoverPhoto(color),
          Positioned(
            child: buildEditIcon(color),
            right: 4,
            top: 10,
          )
        ],
      ),
    );
  }

  // Builds Cover Photo
  Widget buildCoverPhoto(Color color) {
    final image = coverPhotoPath.contains('https://')
        ? NetworkImage(coverPhotoPath)
        : FileImage(File(coverPhotoPath));

    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Builds Edit Icon on Cover Photo
  Widget buildEditIcon(Color color) => buildCircle(
        all: 8,
        child: Icon(
          Icons.edit,
          color: color,
          size: 20,
        ),
      );

  // Builds/Makes Circle for Edit Icon on Cover Photo
  Widget buildCircle({
    required Widget child,
    required double all,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: Colors.white,
          child: child,
        ),
      );
}
