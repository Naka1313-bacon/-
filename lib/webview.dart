import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:read_aloud/timer.dart';

/// WebViewアプリの状態を持つStatefulWidget
class WebViewApp extends StatefulWidget {
  /// WebViewAppのコンストラクタ///
  final String id;
  final String name;
  const WebViewApp({Key? key, required this.id, required this.name})
      : super(key: key);

  /// 状態オブジェクトを作成
  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

/// WebViewAppの状態を管理するStateクラス
class _WebViewAppState extends State<WebViewApp> {
  /// WebViewControllerオブジェクト
  late final WebViewController controller;

  /// 初期状態を設定
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://aozora.binb.jp/reader/main.html?cid=${widget.id}'),
      );
  }

  /// アプリのUIを構築
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
          CountDown(),
        ],
      ),
    );
  }
}
