// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Dot Weaver';

  @override
  String get settingsTitle => 'DEFINIÇÕES';

  @override
  String get sectionMonetization => 'PREMIUM';

  @override
  String get sectionPreferences => 'PREFERÊNCIAS';

  @override
  String get sectionAbout => 'SOBRE';

  @override
  String get sectionAccount => 'CONTA';

  @override
  String get removeAds => 'Remover anúncios';

  @override
  String removeAdsWithPrice(String price) {
    return 'Remover anúncios  •  $price';
  }

  @override
  String get adsRemovedThanks => 'Anúncios removidos. Obrigado!';

  @override
  String get buy => 'Comprar';

  @override
  String get restore => 'Restaurar';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get version => 'Versão';

  @override
  String get deviceId => 'ID do dispositivo';

  @override
  String get deviceIdCopied => 'ID do dispositivo copiado.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get username => 'Nome de utilizador';

  @override
  String get changeUsername => 'Alterar nome de utilizador';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get usernameUpdated => 'Nome de utilizador atualizado.';

  @override
  String get usernameTaken => 'Esse nome já está em uso.';

  @override
  String get usernameInvalid => '3–16 letras, dígitos ou _';

  @override
  String get usernameOffline =>
      'Não foi possível contactar o servidor. Tenta novamente.';

  @override
  String get leaderboard => 'Classificação';

  @override
  String get leaderboardTitle => 'CLASSIFICAÇÃO';

  @override
  String get yourRank => 'A tua posição';

  @override
  String get rank => 'Posição';

  @override
  String get player => 'Jogador';

  @override
  String get stars => 'Estrelas';

  @override
  String get leaderboardEmpty => 'Ainda não há jogadores. Sê o primeiro!';

  @override
  String get leaderboardOffline =>
      'Não foi possível carregar a classificação. Verifica a tua ligação.';

  @override
  String get you => 'Tu';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get locked => 'BLOQUEADO';

  @override
  String get comingSoon => 'EM BREVE';

  @override
  String get levelLocked => 'Nível bloqueado! Completa os níveis anteriores.';

  @override
  String islandUnlockNeed(int count, String island) {
    return 'Completa mais $count nível(eis) para desbloquear $island';
  }

  @override
  String islandUnlockPrev(String island) {
    return 'Completa as ilhas anteriores para desbloquear $island';
  }

  @override
  String get removeAdsPromoTitle => 'SEM ANÚNCIOS';

  @override
  String get removeAdsPromoSubtitle =>
      'Aproveita o Dot Weaver sem banners nem interrupções.';

  @override
  String get benefitNoBanner => 'Remove o banner inferior';

  @override
  String get benefitNoInterstitial =>
      'Sem anúncios em ecrã inteiro entre níveis';

  @override
  String get benefitOneTime => 'Compra única, para sempre';

  @override
  String get maybeLater => 'Talvez mais tarde';

  @override
  String get purchaseCouldNotStart =>
      'Não foi possível iniciar a compra. Tenta novamente.';

  @override
  String get storeUnavailable => 'A loja está indisponível neste momento.';

  @override
  String get restoreRequested =>
      'Restauro solicitado. As compras serão atualizadas automaticamente.';

  @override
  String get couldNotOpenPrivacy =>
      'Não foi possível abrir a política de privacidade.';

  @override
  String get levelLabel => 'NÍVEL';

  @override
  String get levelComplete => 'NÍVEL CONCLUÍDO!';

  @override
  String timeLeft(String time) {
    return 'Tempo restante: $time';
  }

  @override
  String get continueButton => 'CONTINUAR';

  @override
  String get islandComplete => 'ILHA CONCLUÍDA!';

  @override
  String nextIslandUnlocking(String island) {
    return 'A desbloquear a próxima ilha:\n$island';
  }

  @override
  String get timesUp => 'TEMPO ESGOTADO!';

  @override
  String get watchAdContinue => 'VER ANÚNCIO  +30s';

  @override
  String get noAdAvailable => 'Sem anúncios disponíveis agora';

  @override
  String get restart => 'REINICIAR';

  @override
  String get failed => 'FALHOU!';

  @override
  String get failReasonOperation => 'Resultado errado ou grelha incompleta!';

  @override
  String get failReasonPath => 'O caminho está incorreto!';

  @override
  String get playAgain => 'JOGAR DE NOVO';

  @override
  String get tutorialSwipe => 'Desliza para ligar os números';
}
