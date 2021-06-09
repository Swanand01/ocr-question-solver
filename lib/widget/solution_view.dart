import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SolutionView extends StatelessWidget {
  SolutionView({Key key, this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Solution"),
        ),
        body: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
