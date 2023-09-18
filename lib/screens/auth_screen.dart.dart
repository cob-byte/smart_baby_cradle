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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(73, 17, 15, 1),
                  Color.fromRGBO(8, 40, 75, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                        color: const Color(0xffe9eaec),
                        height: 2,
                        width: deviceSize.width * 0.2
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Social Contacts',
                        style: TextStyle(
                          fontFamily: 'Medium',
                          fontSize: 15,
                          color: Color(0xffe9eaec),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: deviceSize.width * 0.2,
                        color: const Color(0xffe9eaec),
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
