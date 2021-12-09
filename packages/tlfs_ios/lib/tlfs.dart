
import 'dart:async';

import 'package:flutter/services.dart';

class Tlfs {
  static const MethodChannel _channel = MethodChannel('tlfs');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
