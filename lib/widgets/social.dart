import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Social extends StatelessWidget {
  const Social({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 226, 165, 104),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              FontAwesomeIcons.facebookF,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 226, 165, 104),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              FontAwesomeIcons.google,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
