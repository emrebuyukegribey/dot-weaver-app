// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Dot Weaver';

  @override
  String get settingsTitle => 'PARAMÈTRES';

  @override
  String get sectionMonetization => 'PREMIUM';

  @override
  String get sectionPreferences => 'PRÉFÉRENCES';

  @override
  String get sectionAbout => 'À PROPOS';

  @override
  String get sectionAccount => 'COMPTE';

  @override
  String get removeAds => 'Supprimer les pubs';

  @override
  String removeAdsWithPrice(String price) {
    return 'Supprimer les pubs  •  $price';
  }

  @override
  String get adsRemovedThanks => 'Pubs supprimées. Merci !';

  @override
  String get buy => 'Acheter';

  @override
  String get restore => 'Restaurer';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get version => 'Version';

  @override
  String get deviceId => 'ID de l\'appareil';

  @override
  String get deviceIdCopied => 'ID de l\'appareil copié.';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get changeUsername => 'Changer de nom d\'utilisateur';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get usernameUpdated => 'Nom d\'utilisateur mis à jour.';

  @override
  String get usernameTaken => 'Ce nom est déjà pris.';

  @override
  String get usernameInvalid => '3–16 lettres, chiffres ou _';

  @override
  String get usernameOffline => 'Impossible de joindre le serveur. Réessayez.';

  @override
  String get leaderboard => 'Classement';

  @override
  String get leaderboardTitle => 'CLASSEMENT';

  @override
  String get yourRank => 'Ton rang';

  @override
  String get rank => 'Rang';

  @override
  String get player => 'Joueur';

  @override
  String get stars => 'Étoiles';

  @override
  String get leaderboardEmpty =>
      'Aucun joueur pour l\'instant. Sois le premier !';

  @override
  String get leaderboardOffline =>
      'Impossible de charger le classement. Vérifie ta connexion.';

  @override
  String get you => 'Toi';

  @override
  String get retry => 'Réessayer';

  @override
  String get locked => 'VERROUILLÉ';

  @override
  String get comingSoon => 'BIENTÔT';

  @override
  String get levelLocked =>
      'Niveau verrouillé ! Termine les niveaux précédents.';

  @override
  String islandUnlockNeed(int count, String island) {
    return 'Termine $count niveau(x) de plus pour débloquer $island';
  }

  @override
  String islandUnlockPrev(String island) {
    return 'Termine les îles précédentes pour débloquer $island';
  }

  @override
  String get removeAdsPromoTitle => 'SANS PUB';

  @override
  String get removeAdsPromoSubtitle =>
      'Profite de Dot Weaver sans bannières ni interruptions.';

  @override
  String get benefitNoBanner => 'Supprime la bannière du bas';

  @override
  String get benefitNoInterstitial =>
      'Pas de pub plein écran entre les niveaux';

  @override
  String get benefitOneTime => 'Achat unique, pour toujours';

  @override
  String get benefitOffline => 'Joue hors ligne, à tout moment';

  @override
  String get maybeLater => 'Plus tard';

  @override
  String get purchaseCouldNotStart =>
      'Impossible de lancer l\'achat. Réessayez.';

  @override
  String get storeUnavailable => 'La boutique est indisponible pour le moment.';

  @override
  String get restoreRequested =>
      'Restauration demandée. Les achats seront mis à jour automatiquement.';

  @override
  String get couldNotOpenPrivacy =>
      'Impossible d\'ouvrir la politique de confidentialité.';

  @override
  String get levelLabel => 'NIVEAU';

  @override
  String get levelComplete => 'NIVEAU TERMINÉ !';

  @override
  String timeLeft(String time) {
    return 'Temps restant : $time';
  }

  @override
  String get continueButton => 'CONTINUER';

  @override
  String get islandComplete => 'ÎLE TERMINÉE !';

  @override
  String nextIslandUnlocking(String island) {
    return 'Déblocage de l\'île suivante :\n$island';
  }

  @override
  String get timesUp => 'TEMPS ÉCOULÉ !';

  @override
  String get watchAdContinue => 'REGARDER UNE PUB  +30s';

  @override
  String get noAdAvailable => 'Aucune pub disponible pour l\'instant';

  @override
  String get restart => 'RECOMMENCER';

  @override
  String get failed => 'ÉCHEC !';

  @override
  String get failReasonOperation => 'Résultat incorrect ou grille incomplète !';

  @override
  String get failReasonPath => 'Le chemin est incorrect !';

  @override
  String get playAgain => 'REJOUER';

  @override
  String get tutorialSwipe => 'Glisse pour relier les nombres';
}
