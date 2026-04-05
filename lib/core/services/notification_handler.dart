import 'package:cihcahul_plus/core/utils/logger.dart';
import 'package:flutter/services.dart';

const platform = MethodChannel('app.channel.notifications');

Future<void> showNotification({
  required String title,
  required String text,
  required int delay,
}) async {
  await platform.invokeMethod('showNotification', {
    "title": title,
    "text": text,
    "delay": delay,
  });
  Log.info("show Notificaiton is working");
}
