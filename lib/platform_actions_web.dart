import 'dart:js_interop';
import 'dart:js_interop_unsafe';

void _open(String url) {
  globalContext.callMethod<JSAny?>('open'.toJS, url.toJS);
}

Future<bool> sendEmail({
  required String to,
  required String subject,
  required String body,
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: to,
    queryParameters: {'subject': subject, 'body': body},
  );
  _open(uri.toString());
  return true;
}

Future<bool> openExternalUrl(String url) async {
  _open(url);
  return true;
}

Future<bool> dialNumber(String number) async {
  _open('tel:$number');
  return true;
}
