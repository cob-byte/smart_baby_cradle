import 'package:flutter/material.dart';
import '../util/color.dart';

class HeaderLogo extends StatelessWidget {
  final Size deviceSize;
  const HeaderLogo(this.deviceSize, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          'Smart Baby Cradle',
          style: TextStyle(
            fontFamily: 'Regular',
            fontSize: 30,
            padding: EdgeInsets.all(10.0),
            color: Colors.black,
          ),
        ),
        SizedBox(
          width: deviceSize.width * 0.5,
          height: deviceSize.width * 0.5,
          child: Image.asset('assets/image/sbc-Cradle.png'),
        ),
      ],
    );
  }
}
