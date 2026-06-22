import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dot Weaver'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @sectionMonetization.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get sectionMonetization;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get sectionPreferences;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get sectionAbout;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get sectionAccount;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// No description provided for @removeAdsWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads  •  {price}'**
  String removeAdsWithPrice(String price);

  /// No description provided for @adsRemovedThanks.
  ///
  /// In en, this message translates to:
  /// **'Ads removed. Thank you!'**
  String get adsRemovedThanks;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @deviceIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Device ID copied.'**
  String get deviceIdCopied;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change username'**
  String get changeUsername;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @usernameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Username updated.'**
  String get usernameUpdated;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'That name is taken.'**
  String get usernameTaken;

  /// No description provided for @usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'3–16 letters, digits or _'**
  String get usernameInvalid;

  /// No description provided for @usernameOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Try again.'**
  String get usernameOffline;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD'**
  String get leaderboardTitle;

  /// No description provided for @yourRank.
  ///
  /// In en, this message translates to:
  /// **'Your rank'**
  String get yourRank;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No players yet. Be the first!'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the leaderboard. Check your connection.'**
  String get leaderboardOffline;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get locked;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingSoon;

  /// No description provided for @levelLocked.
  ///
  /// In en, this message translates to:
  /// **'Level Locked! Complete previous levels.'**
  String get levelLocked;

  /// No description provided for @islandUnlockNeed.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} more level(s) to unlock {island}'**
  String islandUnlockNeed(int count, String island);

  /// No description provided for @islandUnlockPrev.
  ///
  /// In en, this message translates to:
  /// **'Complete previous islands to unlock {island}'**
  String islandUnlockPrev(String island);

  /// No description provided for @removeAdsPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'GO AD-FREE'**
  String get removeAdsPromoTitle;

  /// No description provided for @removeAdsPromoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy Dot Weaver with no banners and no interruptions.'**
  String get removeAdsPromoSubtitle;

  /// No description provided for @benefitNoBanner.
  ///
  /// In en, this message translates to:
  /// **'Remove the bottom banner'**
  String get benefitNoBanner;

  /// No description provided for @benefitNoInterstitial.
  ///
  /// In en, this message translates to:
  /// **'No full-screen ads between levels'**
  String get benefitNoInterstitial;

  /// No description provided for @benefitOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase, forever'**
  String get benefitOneTime;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @purchaseCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Purchase could not be started. Please try again.'**
  String get purchaseCouldNotStart;

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store is unavailable right now.'**
  String get storeUnavailable;

  /// No description provided for @restoreRequested.
  ///
  /// In en, this message translates to:
  /// **'Restore requested. Purchases will update automatically.'**
  String get restoreRequested;

  /// No description provided for @couldNotOpenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Could not open the privacy policy.'**
  String get couldNotOpenPrivacy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
