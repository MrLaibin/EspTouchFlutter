import 'dart:async';

import 'package:flutter/services.dart';

class EsptouchFlutter {
  static const MethodChannel _channel = const MethodChannel('esptouch_flutter');

  static Future<Map?> connectWifi(
    String mSsid,
    String mBssid,
    String pwd, {
    devCount: "1",
    modelGroup: false,
  }) async {
    final Map? version = await _channel.invokeMethod('connectWifi', {
      'mSsid': mSsid,
      'mBssid': mBssid,
      'pwd': pwd,
      'devCount': devCount,
      'modelGroup': modelGroup
    });
    return version;
  }
  static cancelConfig(){
    final Map? version = await _channel.invokeMethod('getWifiInfo');
    return version;
  }

  static Future<Map?> get wifiInfo async {
    final Map? version = await _channel.invokeMethod('getWifiInfo');
    return version;
  }
}
