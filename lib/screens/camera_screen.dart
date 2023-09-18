import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraScreen extends StatefulWidget {
  static const routeName = '/camera';

  const CameraScreen({Key? key}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}


class CameraScreenState extends State<CameraScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Camera Screen',
          style: TextStyle(
            fontFamily: 'Poppins-Bold',
            fontSize: 25,
            fontStyle: FontStyle.normal,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        backgroundColor: const Color.fromRGBO(22, 22, 22, 1),
      ),
      body: WebView(
        initialUrl: 'https://www.google.com/',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController){
          _controller.complete(webViewController);
        },
      ),
    );
  }
}
