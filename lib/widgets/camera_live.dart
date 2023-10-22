import 'package:flutter/material.dart';

import '../screens/camera_screen.dart';
import 'package:provider/provider.dart';

import '../services/status_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class CameraLiveItem extends StatelessWidget {
  final bool isRaspberryPiOn;

  const CameraLiveItem({Key? key, required this.isRaspberryPiOn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          color: currentTheme.colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(),
          boxShadow: [
            // Add box shadow here
            BoxShadow(
              color: Color.fromARGB(255, 106, 106, 106)
                  .withOpacity(0.5), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset:
                  Offset(0, 3), // Offset in the positive direction of y-axis
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(CameraScreen.routeName);
                },
                child: SizedBox(
                  //width: constraints.maxWidth * 0.65,
                  child: isRaspberryPiOn
                      ? Image.asset('assets/image/livestream.png')
                      : Image.asset('assets/image/live_dis.png'), // A
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(bottom: 5.0), // Add space below the text
                child: FittedBox(
                  child: Text(
                    'Camera',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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
