import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CameraScreen extends StatefulWidget {
  static const routeName = '/camera';

  const CameraScreen({Key? key}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  final Completer<InAppWebViewController> _controller =
  Completer<InAppWebViewController>();

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
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse('http://192.168.254.183:8888/'),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: true,
            allowFileAccessFromFileURLs: true,
          ),
          android: AndroidInAppWebViewOptions(
            mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
        ),
        onWebViewCreated: (InAppWebViewController webViewController) {
          _controller.complete(webViewController);
        },
        onLoadError: (controller, url, code, message) {
          // Show dialog when an error occurs.
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Camera Livestream Not Found'),
              content: Text('Please reboot the device or check your internet connection.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Go Back'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
      ),
    );
  }
}
