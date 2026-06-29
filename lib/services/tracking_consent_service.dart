import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/widgets.dart';

/// Requests iOS App Tracking Transparency **after** the root UI is visible and
/// **before** any ad SDK initialisation. Apple requires the system dialog to
/// appear prior to collecting data used for cross-app tracking (e.g. IDFA via
/// AdMob). On Android this is a no-op.
class TrackingConsentService {
  TrackingConsentService._();
  static final TrackingConsentService instance = TrackingConsentService._();

  Future<void>? _requestFuture;
  bool _completed = false;

  bool get completed => _completed || !Platform.isIOS;

  /// Idempotent. Safe to call from [WorldMapScreen] once the first frame is on
  /// screen. Waits briefly so UIWindow is key (important on iPad review devices).
  Future<void> requestIfNeeded() {
    _requestFuture ??= _request();
    return _requestFuture!;
  }

  Future<void> _request() async {
    if (!Platform.isIOS) {
      _completed = true;
      return;
    }

    // Let the root route finish laying out (reviewers test on iPad).
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Present only while the app is in the foreground.
    final binding = WidgetsBinding.instance;
    for (int i = 0; i < 30; i++) {
      if (binding.lifecycleState == AppLifecycleState.resumed) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('ATT status (before): $status');

      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('ATT status (after request): $status');
      }
    } catch (e, st) {
      // Log but do not crash — ads fall back to non-personalised mode.
      debugPrint('ATT request failed: $e\n$st');
    }

    _completed = true;
  }
}
