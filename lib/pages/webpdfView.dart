import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewExample extends StatefulWidget {
  String url;
  WebViewExample({Key? key, required this.url}) : super(key: key);

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    webViewController?.loadUrl(
        urlRequest: URLRequest(url: Uri.parse(widget.url)));
  }

  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
      ),
      body: InAppWebView(
        onWebViewCreated: (controller) async {
          webViewController = controller;
          print(await controller.getUrl());
        },
      ),
    );
  }
}
