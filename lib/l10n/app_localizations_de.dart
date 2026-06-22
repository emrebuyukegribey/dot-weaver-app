// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Dot Weaver';

  @override
  String get settingsTitle => 'EINSTELLUNGEN';

  @override
  String get sectionMonetization => 'PREMIUM';

  @override
  String get sectionPreferences => 'EINSTELLUNGEN';

  @override
  String get sectionAbout => 'ÜBER';

  @override
  String get sectionAccount => 'KONTO';

  @override
  String get removeAds => 'Werbung entfernen';

  @override
  String removeAdsWithPrice(String price) {
    return 'Werbung entfernen  •  $price';
  }

  @override
  String get adsRemovedThanks => 'Werbung entfernt. Danke!';

  @override
  String get buy => 'Kaufen';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get privacyPolicy => 'Datenschutz';

  @override
  String get version => 'Version';

  @override
  String get deviceId => 'Geräte-ID';

  @override
  String get deviceIdCopied => 'Geräte-ID kopiert.';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get username => 'Benutzername';

  @override
  String get changeUsername => 'Benutzernamen ändern';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get usernameUpdated => 'Benutzername aktualisiert.';

  @override
  String get usernameTaken => 'Dieser Name ist bereits vergeben.';

  @override
  String get usernameInvalid => '3–16 Buchstaben, Ziffern oder _';

  @override
  String get usernameOffline =>
      'Server nicht erreichbar. Bitte erneut versuchen.';

  @override
  String get leaderboard => 'Bestenliste';

  @override
  String get leaderboardTitle => 'BESTENLISTE';

  @override
  String get yourRank => 'Dein Rang';

  @override
  String get rank => 'Rang';

  @override
  String get player => 'Spieler';

  @override
  String get stars => 'Sterne';

  @override
  String get leaderboardEmpty => 'Noch keine Spieler. Sei der Erste!';

  @override
  String get leaderboardOffline =>
      'Bestenliste konnte nicht geladen werden. Prüfe deine Verbindung.';

  @override
  String get you => 'Du';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get locked => 'GESPERRT';

  @override
  String get comingSoon => 'DEMNÄCHST';

  @override
  String get levelLocked => 'Level gesperrt! Schließe die vorherigen Level ab.';

  @override
  String islandUnlockNeed(int count, String island) {
    return 'Schließe $count weitere(s) Level ab, um $island freizuschalten';
  }

  @override
  String islandUnlockPrev(String island) {
    return 'Schließe die vorherigen Inseln ab, um $island freizuschalten';
  }

  @override
  String get removeAdsPromoTitle => 'WERBEFREI';

  @override
  String get removeAdsPromoSubtitle =>
      'Genieße Dot Weaver ohne Banner und Unterbrechungen.';

  @override
  String get benefitNoBanner => 'Entfernt das Banner unten';

  @override
  String get benefitNoInterstitial => 'Keine Vollbildwerbung zwischen Leveln';

  @override
  String get benefitOneTime => 'Einmaliger Kauf, für immer';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get purchaseCouldNotStart =>
      'Kauf konnte nicht gestartet werden. Bitte erneut versuchen.';

  @override
  String get storeUnavailable => 'Der Store ist gerade nicht verfügbar.';

  @override
  String get restoreRequested =>
      'Wiederherstellung angefordert. Käufe werden automatisch aktualisiert.';

  @override
  String get couldNotOpenPrivacy =>
      'Datenschutzerklärung konnte nicht geöffnet werden.';

  @override
  String get levelLabel => 'LEVEL';

  @override
  String get levelComplete => 'LEVEL GESCHAFFT!';

  @override
  String timeLeft(String time) {
    return 'Verbleibende Zeit: $time';
  }

  @override
  String get continueButton => 'WEITER';

  @override
  String get islandComplete => 'INSEL ABGESCHLOSSEN!';

  @override
  String nextIslandUnlocking(String island) {
    return 'Nächste Insel wird freigeschaltet:\n$island';
  }

  @override
  String get timesUp => 'ZEIT ABGELAUFEN!';

  @override
  String get watchAdContinue => 'WERBUNG ANSEHEN  +30s';

  @override
  String get noAdAvailable => 'Gerade keine Werbung verfügbar';

  @override
  String get restart => 'NEU STARTEN';

  @override
  String get failed => 'FEHLGESCHLAGEN!';

  @override
  String get failReasonOperation => 'Falsches Ergebnis oder Gitter nicht voll!';

  @override
  String get failReasonPath => 'Der Pfad ist falsch!';

  @override
  String get playAgain => 'NOCHMAL SPIELEN';

  @override
  String get tutorialSwipe => 'Wische, um Zahlen zu verbinden';
}
