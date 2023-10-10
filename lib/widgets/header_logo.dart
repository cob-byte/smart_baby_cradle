import 'package:flutter/material.dart';
import '../util/color.dart';

class HeaderLogo extends StatelessWidget {
  final Size deviceSize;
  const HeaderLogo(this.deviceSize, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding:
              EdgeInsets.only(top: 20.0), // Adjust the top padding as needed
          child: Text(
            'Smart Baby Cradle',
            style: TextStyle(
              fontFamily: 'Regular',
              fontSize: 35,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: deviceSize.width * 0.8, // Increase the width as needed
          height: deviceSize.width * 0.7, // Increase the height as needed
          child: FittedBox(
            fit: BoxFit
                .contain, // This property ensures the image scales to fit the box
            child: Image.asset('assets/image/sbc-Cradle.png'),
          ),
        ),
      ],
    );
  }
}
