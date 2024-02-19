import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hycop_light/hycop.dart';

class MyDeviceInfo {
  static String deviceName = '';
  static Future<String> getDeviceName() async {
    if (deviceName.isNotEmpty) {
      return deviceName;
    }
    try {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.model} (${androidInfo.device})';
        return deviceName;
      } else if (Platform.isIOS) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.utsname.machine ?? 'Unknown'; // 예: "John's iPhone"
        return deviceName;
      } else {
        deviceName = 'Unknown OS';
        return deviceName;
      }
    } catch (e) {
      logger.severe('An unexpected exception occurred: $e');
      return 'Unknown';
    }
  }
}
