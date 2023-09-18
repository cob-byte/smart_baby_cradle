import 'package:flutter/material.dart';
import '../util/color.dart';

class HeaderLogo extends StatelessWidget {
  final Size deviceSize;
  const HeaderLogo(this.deviceSize, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'Baby\'s Cradle Monitor',
          style: TextStyle(
            fontFamily: 'Bold',
            fontSize: 20,
            color: colorText,
          ),
        ),
        SizedBox(
          width: deviceSize.width*0.5,
          height: deviceSize.width*0.5,
          child: Image.asset('assets/image/cradle.png'),
        ),
      ],
    );
  }
}
