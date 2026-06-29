// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Dot Weaver';

  @override
  String get settingsTitle => 'IMPOSTAZIONI';

  @override
  String get sectionMonetization => 'PREMIUM';

  @override
  String get sectionPreferences => 'PREFERENZE';

  @override
  String get sectionAbout => 'INFORMAZIONI';

  @override
  String get sectionAccount => 'ACCOUNT';

  @override
  String get removeAds => 'Rimuovi pubblicità';

  @override
  String removeAdsWithPrice(String price) {
    return 'Rimuovi pubblicità  •  $price';
  }

  @override
  String get adsRemovedThanks => 'Pubblicità rimossa. Grazie!';

  @override
  String get buy => 'Acquista';

  @override
  String get restore => 'Ripristina';

  @override
  String get soundEffects => 'Effetti sonori';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get version => 'Versione';

  @override
  String get deviceId => 'ID dispositivo';

  @override
  String get deviceIdCopied => 'ID dispositivo copiato.';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Predefinita di sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get username => 'Nome utente';

  @override
  String get changeUsername => 'Cambia nome utente';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get usernameUpdated => 'Nome utente aggiornato.';

  @override
  String get usernameTaken => 'Questo nome è già in uso.';

  @override
  String get usernameInvalid => '3–16 lettere, cifre o _';

  @override
  String get usernameOffline => 'Impossibile raggiungere il server. Riprova.';

  @override
  String get leaderboard => 'Classifica';

  @override
  String get leaderboardTitle => 'CLASSIFICA';

  @override
  String get yourRank => 'La tua posizione';

  @override
  String get rank => 'Posizione';

  @override
  String get player => 'Giocatore';

  @override
  String get stars => 'Stelle';

  @override
  String get leaderboardEmpty => 'Ancora nessun giocatore. Sii il primo!';

  @override
  String get leaderboardOffline =>
      'Impossibile caricare la classifica. Controlla la connessione.';

  @override
  String get you => 'Tu';

  @override
  String get retry => 'Riprova';

  @override
  String get locked => 'BLOCCATO';

  @override
  String get comingSoon => 'PROSSIMAMENTE';

  @override
  String get levelLocked => 'Livello bloccato! Completa i livelli precedenti.';

  @override
  String islandUnlockNeed(int count, String island) {
    return 'Completa altri $count livello/i per sbloccare $island';
  }

  @override
  String islandUnlockPrev(String island) {
    return 'Completa le isole precedenti per sbloccare $island';
  }

  @override
  String get removeAdsPromoTitle => 'SENZA PUBBLICITÀ';

  @override
  String get removeAdsPromoSubtitle =>
      'Goditi Dot Weaver senza banner né interruzioni.';

  @override
  String get benefitNoBanner => 'Rimuove il banner in basso';

  @override
  String get benefitNoInterstitial =>
      'Nessuna pubblicità a schermo intero tra i livelli';

  @override
  String get benefitOneTime => 'Acquisto unico, per sempre';

  @override
  String get benefitOffline => 'Gioca offline, quando vuoi';

  @override
  String get maybeLater => 'Forse più tardi';

  @override
  String get purchaseCouldNotStart =>
      'Impossibile avviare l\'acquisto. Riprova.';

  @override
  String get storeUnavailable => 'Lo store non è disponibile al momento.';

  @override
  String get restoreRequested =>
      'Ripristino richiesto. Gli acquisti si aggiorneranno automaticamente.';

  @override
  String get couldNotOpenPrivacy =>
      'Impossibile aprire l\'informativa sulla privacy.';

  @override
  String get levelLabel => 'LIVELLO';

  @override
  String get levelComplete => 'LIVELLO COMPLETATO!';

  @override
  String timeLeft(String time) {
    return 'Tempo rimasto: $time';
  }

  @override
  String get continueButton => 'CONTINUA';

  @override
  String get islandComplete => 'ISOLA COMPLETATA!';

  @override
  String nextIslandUnlocking(String island) {
    return 'Sblocco della prossima isola:\n$island';
  }

  @override
  String get timesUp => 'TEMPO SCADUTO!';

  @override
  String get watchAdContinue => 'GUARDA UN ANNUNCIO  +30s';

  @override
  String get noAdAvailable => 'Nessun annuncio disponibile ora';

  @override
  String get restart => 'RICOMINCIA';

  @override
  String get failed => 'FALLITO!';

  @override
  String get failReasonOperation => 'Risultato errato o griglia non piena!';

  @override
  String get failReasonPath => 'Il percorso non è corretto!';

  @override
  String get playAgain => 'GIOCA ANCORA';

  @override
  String get tutorialSwipe => 'Scorri per collegare i numeri';

  @override
  String get almostThereTitle => 'Quasi fatto!';

  @override
  String get almostThereBody =>
      'Tutti i punti sono collegati ma alcune caselle sono ancora vuote. Ricomincia e riprova.';

  @override
  String get undo => 'Annulla';
}
