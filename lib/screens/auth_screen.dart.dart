import 'package:flutter/material.dart';
import '../widgets/header_logo.dart';
import '../widgets/auth_card.dart';
import '../widgets/social.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Linear gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(255, 202, 212, 1),
                  Color.fromRGBO(246, 227, 209, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Background image (placed on the lower right)
          Positioned(
            bottom: -130,
            right: -20,
            child: Image.asset(
              'assets/image/bg_cradle.png', // Replace with your image asset path
              width: deviceSize.width * 0.4, // Adjust the width as needed
              height: deviceSize.height * 0.5, // Adjust the height as needed
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
