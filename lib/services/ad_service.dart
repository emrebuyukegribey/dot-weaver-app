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
  Future<void>? _initFuture;

  /// Becomes true after [initialize] finishes. [AdBanner] waits on this so no
  /// ad request fires before ATT on iOS.
  final ValueNotifier<bool> ready = ValueNotifier(false);

  // --- Ad unit IDs (real, AdMob pub-5299037737635972). ---
  static String get _bannerUnitId => Platform.isIOS
      ? 'ca-app-pub-5299037737635972/2902219836'
      : 'ca-app-pub-5299037737635972/6406350573';

  static String get _interstitialUnitId => Platform.isIOS
      ? 'ca-app-pub-5299037737635972/9276056491'
      : 'ca-app-pub-5299037737635972/2000467635';

  static String get _rewardedUnitId => Platform.isIOS
      ? 'ca-app-pub-5299037737635972/2738834237'
      : 'ca-app-pub-5299037737635972/1617324250';

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  /// Number of level completions since the last interstitial.
  int _completionsSinceInterstitial = 0;

  /// Show an interstitial after this many level completions.
  static const int interstitialEveryNCompletions = 3;

  bool get _adsAllowed => !GameDataManager().adFree;

  /// Initialises the Mobile Ads SDK after gathering UMP consent. Call only after
  /// [TrackingConsentService.requestIfNeeded] on iOS. Safe to call multiple times.
  Future<void> initialize() async {
    if (_initialized) return;
    _initFuture ??= _doInitialize();
    await _initFuture;
  }

  Future<void> _doInitialize() async {
    try {
      await _gatherConsent();
      await MobileAds.instance.initialize();
      _initialized = true;
      ready.value = true;
      if (_adsAllowed) {
        _loadInterstitial();
        _loadRewarded();
      }
    } catch (e) {
      debugPrint('AdService init failed: $e');
      ready.value = true; // Unblock UI even if ads fail to init.
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
    if (!_initialized || !_adsAllowed) return null;
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
    if (!_adsAllowed) {
      rewardedReady.value = false;
      return;
    }
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          rewardedReady.value = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed: ${error.message}');
          _rewarded = null;
          rewardedReady.value = false;
        },
      ),
    );
  }

  bool get isRewardedReady => _rewarded != null;

  /// Fires when a rewarded ad becomes loadable (or is consumed / fails).
  final ValueNotifier<bool> rewardedReady = ValueNotifier(false);

  /// Shows a rewarded ad. Calls [onReward] exactly once if the user earns the
  /// reward. Returns true if the reward was granted.
  Future<bool> showRewarded({required void Function() onReward}) async {
    final ad = _rewarded;
    if (ad == null) {
      rewardedReady.value = false;
      _loadRewarded();
      return false;
    }
    _rewarded = null;
    rewardedReady.value = false;
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
    rewardedReady.value = false;
  }
}
