import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

Future<void> configureWebViewController(WebViewController controller) async {
  final androidController = controller.platform as AndroidWebViewController;
  await androidController.setMixedContentMode(MixedContentMode.alwaysAllow);

  final cookieManager = WebViewCookieManager();
  final androidCookieManager =
      cookieManager.platform as AndroidWebViewCookieManager;
  await androidCookieManager.setAcceptThirdPartyCookies(
    androidController,
    true,
  );
}
