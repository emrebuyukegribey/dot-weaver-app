// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Dot Weaver';

  @override
  String get settingsTitle => 'AJUSTES';

  @override
  String get sectionMonetization => 'PREMIUM';

  @override
  String get sectionPreferences => 'PREFERENCIAS';

  @override
  String get sectionAbout => 'ACERCA DE';

  @override
  String get sectionAccount => 'CUENTA';

  @override
  String get removeAds => 'Quitar anuncios';

  @override
  String removeAdsWithPrice(String price) {
    return 'Quitar anuncios  •  $price';
  }

  @override
  String get adsRemovedThanks => 'Anuncios eliminados. ¡Gracias!';

  @override
  String get buy => 'Comprar';

  @override
  String get restore => 'Restaurar';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get version => 'Versión';

  @override
  String get deviceId => 'ID del dispositivo';

  @override
  String get deviceIdCopied => 'ID del dispositivo copiado.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get changeUsername => 'Cambiar nombre de usuario';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get usernameUpdated => 'Nombre de usuario actualizado.';

  @override
  String get usernameTaken => 'Ese nombre ya está en uso.';

  @override
  String get usernameInvalid => '3–16 letras, dígitos o _';

  @override
  String get usernameOffline =>
      'No se pudo conectar al servidor. Inténtalo de nuevo.';

  @override
  String get leaderboard => 'Clasificación';

  @override
  String get leaderboardTitle => 'CLASIFICACIÓN';

  @override
  String get yourRank => 'Tu puesto';

  @override
  String get rank => 'Puesto';

  @override
  String get player => 'Jugador';

  @override
  String get stars => 'Estrellas';

  @override
  String get leaderboardEmpty => 'Aún no hay jugadores. ¡Sé el primero!';

  @override
  String get leaderboardOffline =>
      'No se pudo cargar la clasificación. Revisa tu conexión.';

  @override
  String get you => 'Tú';

  @override
  String get retry => 'Reintentar';

  @override
  String get locked => 'BLOQUEADO';

  @override
  String get comingSoon => 'PRÓXIMAMENTE';

  @override
  String get levelLocked =>
      '¡Nivel bloqueado! Completa los niveles anteriores.';

  @override
  String islandUnlockNeed(int count, String island) {
    return 'Completa $count nivel(es) más para desbloquear $island';
  }

  @override
  String islandUnlockPrev(String island) {
    return 'Completa las islas anteriores para desbloquear $island';
  }

  @override
  String get removeAdsPromoTitle => 'SIN ANUNCIOS';

  @override
  String get removeAdsPromoSubtitle =>
      'Disfruta de Dot Weaver sin banners ni interrupciones.';

  @override
  String get benefitNoBanner => 'Quita el banner inferior';

  @override
  String get benefitNoInterstitial =>
      'Sin anuncios a pantalla completa entre niveles';

  @override
  String get benefitOneTime => 'Compra única, para siempre';

  @override
  String get benefitOffline => 'Juega sin conexión cuando quieras';

  @override
  String get maybeLater => 'Quizá más tarde';

  @override
  String get purchaseCouldNotStart =>
      'No se pudo iniciar la compra. Inténtalo de nuevo.';

  @override
  String get storeUnavailable =>
      'La tienda no está disponible en este momento.';

  @override
  String get restoreRequested =>
      'Restauración solicitada. Las compras se actualizarán automáticamente.';

  @override
  String get couldNotOpenPrivacy =>
      'No se pudo abrir la política de privacidad.';

  @override
  String get levelLabel => 'NIVEL';

  @override
  String get levelComplete => '¡NIVEL COMPLETADO!';

  @override
  String timeLeft(String time) {
    return 'Tiempo restante: $time';
  }

  @override
  String get continueButton => 'CONTINUAR';

  @override
  String get islandComplete => '¡ISLA COMPLETADA!';

  @override
  String nextIslandUnlocking(String island) {
    return 'Desbloqueando la siguiente isla:\n$island';
  }

  @override
  String get timesUp => '¡SE ACABÓ EL TIEMPO!';

  @override
  String get watchAdContinue => 'VER ANUNCIO  +30s';

  @override
  String get noAdAvailable => 'No hay anuncios disponibles ahora';

  @override
  String get restart => 'REINICIAR';

  @override
  String get failed => '¡FALLASTE!';

  @override
  String get failReasonOperation =>
      '¡Resultado incorrecto o cuadrícula incompleta!';

  @override
  String get failReasonPath => '¡El camino es incorrecto!';

  @override
  String get playAgain => 'JUGAR DE NUEVO';

  @override
  String get tutorialSwipe => 'Desliza para conectar los números';
}
