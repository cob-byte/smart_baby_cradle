import 'package:flutter/material.dart';

import '../screens/camera_screen.dart';
import 'package:provider/provider.dart';

import '../services/status_service.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class CameraLiveItem extends StatelessWidget {
  const CameraLiveItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          color: currentTheme.colorScheme.onSurfaceVariant,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(),
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
                    width: constraints.maxWidth * 0.65,
                    child: Image.asset(
                      'assets/image/livestream.png',
                    )),
              ),
              const FittedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}
