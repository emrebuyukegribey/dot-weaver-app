// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dot Weaver';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get sectionMonetization => 'PREMIUM';

  @override
  String get sectionPreferences => 'PREFERENCES';

  @override
  String get sectionAbout => 'ABOUT';

  @override
  String get sectionAccount => 'ACCOUNT';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String removeAdsWithPrice(String price) {
    return 'Remove Ads  •  $price';
  }

  @override
  String get adsRemovedThanks => 'Ads removed. Thank you!';

  @override
  String get buy => 'Buy';

  @override
  String get restore => 'Restore';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get version => 'Version';

  @override
  String get deviceId => 'Device ID';

  @override
  String get deviceIdCopied => 'Device ID copied.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get username => 'Username';

  @override
  String get changeUsername => 'Change username';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get usernameUpdated => 'Username updated.';

  @override
  String get usernameTaken => 'That name is taken.';

  @override
  String get usernameInvalid => '3–16 letters, digits or _';

  @override
  String get usernameOffline => 'Couldn\'t reach the server. Try again.';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get leaderboardTitle => 'LEADERBOARD';

  @override
  String get yourRank => 'Your rank';

  @override
  String get rank => 'Rank';

  @override
  String get player => 'Player';

  @override
  String get stars => 'Stars';

  @override
  String get leaderboardEmpty => 'No players yet. Be the first!';

  @override
  String get leaderboardOffline =>
      'Couldn\'t load the leaderboard. Check your connection.';

  @override
  String get you => 'You';

  @override
  String get retry => 'Retry';

  @override
  String get locked => 'LOCKED';

  @override
  String get comingSoon => 'COMING SOON';

  @override
  String get levelLocked => 'Level Locked! Complete previous levels.';

  @override
  String islandUnlockNeed(int count, String island) {
    return 'Complete $count more level(s) to unlock $island';
  }

  @override
  String islandUnlockPrev(String island) {
    return 'Complete previous islands to unlock $island';
  }

  @override
  String get removeAdsPromoTitle => 'GO AD-FREE';

  @override
  String get removeAdsPromoSubtitle =>
      'Enjoy Dot Weaver with no banners and no interruptions.';

  @override
  String get benefitNoBanner => 'Remove the bottom banner';

  @override
  String get benefitNoInterstitial => 'No full-screen ads between levels';

  @override
  String get benefitOneTime => 'One-time purchase, forever';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get purchaseCouldNotStart =>
      'Purchase could not be started. Please try again.';

  @override
  String get storeUnavailable => 'Store is unavailable right now.';

  @override
  String get restoreRequested =>
      'Restore requested. Purchases will update automatically.';

  @override
  String get couldNotOpenPrivacy => 'Could not open the privacy policy.';

  @override
  String get levelLabel => 'LEVEL';

  @override
  String get levelComplete => 'LEVEL COMPLETE!';

  @override
  String timeLeft(String time) {
    return 'Time Left: $time';
  }

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get islandComplete => 'ISLAND COMPLETE!';

  @override
  String nextIslandUnlocking(String island) {
    return 'Next island unlocking:\n$island';
  }

  @override
  String get timesUp => 'TIME\'S UP!';

  @override
  String get watchAdContinue => 'WATCH AD  +30s';

  @override
  String get noAdAvailable => 'No ad available right now';

  @override
  String get restart => 'RESTART';

  @override
  String get failed => 'FAILED!';

  @override
  String get failReasonOperation => 'Wrong result or grid not full!';

  @override
  String get failReasonPath => 'Path is incorrect!';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get tutorialSwipe => 'Swipe to Connect Numbers';
}
