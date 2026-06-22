import 'dart:io' show Platform;

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Returns a stable, device-unique identifier suitable for showing in Settings
/// (e.g. for support): the IDFV on iOS and ANDROID_ID on Android. The value is
/// cached after the first lookup.
class DeviceIdService {
  DeviceIdService._internal();
  static final DeviceIdService _instance = DeviceIdService._internal();
  factory DeviceIdService() => _instance;

  String? _cached;

  Future<String> getDeviceId() async {
    if (_cached != null) return _cached!;
    String id = '';
    try {
      if (Platform.isAndroid) {
        id = await const AndroidId().getId() ?? '';
      } else if (Platform.isIOS) {
        final info = await DeviceInfoPlugin().iosInfo;
        id = info.identifierForVendor ?? '';
      }
    } catch (e) {
      debugPrint('DeviceIdService failed: $e');
    }
    _cached = id.isEmpty ? 'unavailable' : id;
    return _cached!;
  }
}
