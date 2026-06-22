import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../config.dart';
import '../models/leaderboard.dart';
import 'device_id_service.dart';
import 'game_data_manager.dart';
import 'purchase_service.dart';

/// Talks to the Dot Weaver backend. The only call the app makes is a "heartbeat"
/// that reports progress and learns this device's premium entitlement.
///
/// Every call is best-effort and non-fatal: when offline (or the backend is
/// unreachable) it silently returns and the app keeps using cached state.
class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  String? _appVersion;

  Future<int> _levelsPlayed() async {
    int played = 0;
    GameDataManager.islandLevelCounts.forEach((islandId, count) {
      played += GameDataManager().getCompletedCount(islandId, count);
    });
    return played;
  }

  /// Reports stats and applies the entitlement the server returns. Safe to call
  /// on launch and after each level completion.
  Future<void> heartbeat() async {
    if (!AppConfig.backendEnabled) return;
    try {
      final deviceId = await DeviceIdService().getDeviceId();
      if (deviceId.isEmpty || deviceId == 'unavailable') return;

      _appVersion ??= (await PackageInfo.fromPlatform()).version;

      final res = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/api/v1/devices/heartbeat'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'deviceId': deviceId,
              'platform': Platform.isIOS ? 'ios' : 'android',
              'appVersion': _appVersion,
              'totalStars': GameDataManager().getTotalStars(),
              'levelsPlayed': await _levelsPlayed(),
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        await PurchaseService().applyRemoteEntitlement(data['premium'] == true);
        final name = data['username'];
        if (name is String && name.isNotEmpty) {
          await GameDataManager().setUsername(name);
        }
      }
    } catch (e) {
      // Offline / unreachable / timeout: keep cached entitlement, no-op.
      debugPrint('heartbeat skipped: $e');
    }
  }

  /// Fetches the global leaderboard (top players + the caller's rank). Returns
  /// null when offline / unreachable.
  Future<LeaderboardData?> fetchLeaderboard({int limit = 100}) async {
    if (!AppConfig.backendEnabled) return null;
    try {
      final deviceId = await DeviceIdService().getDeviceId();
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/api/v1/leaderboard?limit=$limit&deviceId=$deviceId',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return LeaderboardData.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('leaderboard fetch failed: $e');
    }
    return null;
  }

  /// Renames the player. Returns null on success, or an error code:
  /// 'taken' | 'invalid' | 'offline' | 'error'.
  Future<String?> setUsername(String name) async {
    if (!AppConfig.backendEnabled) return 'offline';
    try {
      final deviceId = await DeviceIdService().getDeviceId();
      final res = await http
          .put(
            Uri.parse('${AppConfig.apiBaseUrl}/api/v1/devices/$deviceId/username'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'username': name}),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final u = (jsonDecode(res.body) as Map<String, dynamic>)['username'] as String;
        await GameDataManager().setUsername(u);
        return null;
      }
      if (res.statusCode == 409) return 'taken';
      if (res.statusCode == 400) return 'invalid';
      return 'error';
    } catch (e) {
      debugPrint('setUsername failed: $e');
      return 'offline';
    }
  }
}
