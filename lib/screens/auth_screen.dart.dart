import 'package:flutter/material.dart';
import '../widgets/header_logo.dart';
import '../widgets/auth_card.dart';
import '../widgets/social.dart';
import 'package:provider/provider.dart';
import 'package:smart_baby_cradle/theme_provider.dart';
import 'package:smart_baby_cradle/theme/boy_theme.dart';
import 'package:smart_baby_cradle/theme/girl_theme.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Theme(
      data: themeProvider.currentTheme,
      child: Scaffold(
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
            Positioned(
              bottom: -130,
              right: -20,
              child: Image.asset(
                'assets/image/bg_cradle.png',
                width: deviceSize.width * 0.4,
                height: deviceSize.height * 0.5,
              ),
            ),
            SingleChildScrollView(
              child: SizedBox(
                height: deviceSize.height,
                width: deviceSize.width,
                child: ListView(
                  children: <Widget>[
                    HeaderLogo(deviceSize),
                    const AuthCard(),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          color: Colors.black,
                          height: 2,
                          width: deviceSize.width * 0.2,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Login with',
                          style: TextStyle(
                            fontFamily: 'Medium',
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: deviceSize.width * 0.2,
                          color: Colors.black,
                          height: 2,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Social(),
                    TextButton(
                      onPressed: () {
                        themeProvider.toggleTheme(); // Toggle the theme
                      },
                      child: Column(
                        children: [
                          themeProvider.currentTheme == boyTheme
                              ? Image.asset(
                                  'assets/image/boy_icon (1).png',
                                  width: 120,
                                  height: 120,
                                )
                              : Image.asset(
                                  'assets/image/girl_icon (1).png',
                                  width: 120,
                                  height: 120,
                                ),
                        ],
                      ),
                    ),
                    const Spacer()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
