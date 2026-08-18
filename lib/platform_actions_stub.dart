import 'package:flutter/services.dart';

Future<bool> sendEmail({
  required String to,
  required String subject,
  required String body,
}) async {
  try {
    final ok = await const MethodChannel('tinatrip').invokeMethod<bool>('sendEmail', {
      'to': to,
      'subject': subject,
      'body': body,
    });
    return ok ?? false;
  } catch (_) {
    return false;
  }
}

Future<bool> openExternalUrl(String url) async {
  try {
    final ok = await const MethodChannel('tinatrip')
        .invokeMethod<bool>('openUrl', {'url': url});
    return ok ?? false;
  } catch (_) {
    return false;
  }
}

Future<bool> dialNumber(String number) async {
  try {
    final ok = await const MethodChannel('tinatrip')
        .invokeMethod<bool>('dial', {'number': number});
    return ok ?? false;
  } catch (_) {
    return false;
  }
}
