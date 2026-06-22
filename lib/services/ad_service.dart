import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'game_data_manager.dart';

/// Centralised AdMob integration: initialisation, consent (UMP), banners,
/// interstitials and rewarded ads.
///
/// IMPORTANT: the IDs below are Google's official *test* unit IDs. Replace them
/// with your real AdMob unit IDs before publishing (see the `_TODO_REAL_IDS`
/// markers). The AdMob *app* IDs also live in AndroidManifest.xml and
/// ios/Runner/Info.plist and must be replaced there too.
class AdService {
  AdService._internal();
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;

  bool _initialized = false;

  // --- Ad unit IDs (TEST). _TODO_REAL_IDS: replace before release. ---
  static String get _bannerUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-3940256099942544/6300978111';

  static String get _interstitialUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';

  static String get _rewardedUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  /// Number of level completions since the last interstitial.
  int _completionsSinceInterstitial = 0;

  /// Show an interstitial after this many level completions.
  static const int interstitialEveryNCompletions = 3;

  bool get _adsAllowed => !GameDataManager().removeAds;

  /// Initialises the Mobile Ads SDK after gathering UMP consent. Safe to call
  /// multiple times.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _gatherConsent();
      await MobileAds.instance.initialize();
      if (_adsAllowed) {
        _loadInterstitial();
        _loadRewarded();
      }
    } catch (e) {
      debugPrint('AdService init failed: $e');
    }
  }

  /// Requests (and, if required, shows) the UMP consent form. Failures are
  /// non-fatal: ads simply fall back to non-personalised behaviour.
  Future<void> _gatherConsent() async {
    try {
      final params = ConsentRequestParameters();
      final completer = await _requestConsentInfoUpdate(params);
      if (!completer) return;
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await _loadAndShowConsentFormIfRequired();
      }
    } catch (e) {
      debugPrint('Consent gathering failed: $e');
    }
  }

  Future<bool> _requestConsentInfoUpdate(ConsentRequestParameters params) {
    final c = Completer<bool>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () => c.complete(true),
      (error) {
        debugPrint('Consent info update error: ${error.message}');
        c.complete(false);
      },
    );
    return c.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() {
    final c = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error != null) {
        debugPrint('Consent form error: ${error.message}');
      }
      c.complete();
    });
    return c.future;
  }

  // --- Banner ---
  /// Creates and loads a new anchored banner. Returns null when ads are
  /// disabled (purchased "remove ads"). Caller owns disposal.
  BannerAd? createBanner({void Function()? onLoaded}) {
    if (!_adsAllowed) return null;
    final ad = BannerAd(
      adUnitId: _bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    );
    ad.load();
    return ad;
  }

  // --- Interstitial ---
  void _loadInterstitial() {
    if (!_adsAllowed) return;
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: ${error.message}');
          _interstitial = null;
        },
      ),
    );
  }

  /// Records a level completion and shows an interstitial once the cadence is
  /// reached (and ads are allowed). Returns true if an interstitial was actually
  /// shown (so callers can avoid stacking another popup on top of it).
  Future<bool> onLevelCompleted() async {
    if (!_adsAllowed) return false;
    _completionsSinceInterstitial++;
    if (_completionsSinceInterstitial < interstitialEveryNCompletions) return false;
    _completionsSinceInterstitial = 0;
    return _showInterstitial();
  }

  /// Returns true if the interstitial was shown and dismissed; false if there
  /// was no ad ready to show.
  Future<bool> _showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return false;
    }
    final c = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
        if (!c.isCompleted) c.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
        if (!c.isCompleted) c.complete(false);
      },
    );
    await ad.show();
    return c.future;
  }

  // --- Rewarded ---
  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed: ${error.message}');
          _rewarded = null;
        },
      ),
    );
  }

  bool get isRewardedReady => _rewarded != null;

  /// Shows a rewarded ad. Calls [onReward] exactly once if the user earns the
  /// reward. Returns true if the reward was granted.
  Future<bool> showRewarded({required void Function() onReward}) async {
    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    _rewarded = null;
    bool earned = false;
    final c = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        if (!c.isCompleted) c.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewarded();
        if (!c.isCompleted) c.complete(false);
      },
    );
    await ad.show(onUserEarnedReward: (_, __) {
      earned = true;
      onReward();
    });
    return c.future;
  }

  /// Called after a successful "remove ads" purchase to tear down active ads.
  void onAdsRemoved() {
    _interstitial?.dispose();
    _interstitial = null;
    _rewarded?.dispose();
    _rewarded = null;
  }
}
