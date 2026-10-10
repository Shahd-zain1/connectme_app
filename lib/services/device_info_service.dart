import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

// Wraps device_info_plus so callers get the same simple model/OS pair
// regardless of platform.
class DeviceInfoService {
  final _deviceInfoPlugin = DeviceInfoPlugin();

  Future<({String modelName, String osVersion})> getDeviceInfo() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      return (
        modelName: '${info.manufacturer} ${info.model}',
        osVersion: 'Android ${info.version.release} (SDK ${info.version.sdkInt})',
      );
    }

    if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;
      return (
        modelName: info.utsname.machine,
        osVersion: '${info.systemName} ${info.systemVersion}',
      );
    }

    return (modelName: 'Unknown device', osVersion: 'Unknown OS');
  }
}
