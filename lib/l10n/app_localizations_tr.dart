// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Dot Weaver';

  @override
  String get settingsTitle => 'AYARLAR';

  @override
  String get sectionMonetization => 'PREMIUM';

  @override
  String get sectionPreferences => 'TERCİHLER';

  @override
  String get sectionAbout => 'HAKKINDA';

  @override
  String get sectionAccount => 'HESAP';

  @override
  String get removeAds => 'Reklamları Kaldır';

  @override
  String removeAdsWithPrice(String price) {
    return 'Reklamları Kaldır  •  $price';
  }

  @override
  String get adsRemovedThanks => 'Reklamlar kaldırıldı. Teşekkürler!';

  @override
  String get buy => 'Satın Al';

  @override
  String get restore => 'Geri Yükle';

  @override
  String get soundEffects => 'Ses efektleri';

  @override
  String get privacyPolicy => 'Gizlilik politikası';

  @override
  String get version => 'Sürüm';

  @override
  String get deviceId => 'Cihaz Kimliği';

  @override
  String get deviceIdCopied => 'Cihaz kimliği kopyalandı.';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Cihaz dili';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get username => 'Kullanıcı adı';

  @override
  String get changeUsername => 'Kullanıcı adını değiştir';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get usernameUpdated => 'Kullanıcı adı güncellendi.';

  @override
  String get usernameTaken => 'Bu ad alınmış.';

  @override
  String get usernameInvalid => '3–16 harf, rakam veya _';

  @override
  String get usernameOffline => 'Sunucuya ulaşılamadı. Tekrar deneyin.';

  @override
  String get leaderboard => 'Lider Tablosu';

  @override
  String get leaderboardTitle => 'LİDER TABLOSU';

  @override
  String get yourRank => 'Sıran';

  @override
  String get rank => 'Sıra';

  @override
  String get player => 'Oyuncu';

  @override
  String get stars => 'Yıldız';

  @override
  String get leaderboardEmpty => 'Henüz oyuncu yok. İlk sen ol!';

  @override
  String get leaderboardOffline =>
      'Lider tablosu yüklenemedi. Bağlantını kontrol et.';

  @override
  String get you => 'Sen';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get locked => 'KİLİTLİ';

  @override
  String get comingSoon => 'YAKINDA';

  @override
  String get levelLocked => 'Seviye kilitli! Önceki seviyeleri tamamla.';

  @override
  String islandUnlockNeed(int count, String island) {
    return '$island kilidini açmak için $count seviye daha tamamla';
  }

  @override
  String islandUnlockPrev(String island) {
    return '$island kilidini açmak için önceki adaları tamamla';
  }

  @override
  String get removeAdsPromoTitle => 'REKLAMSIZ OYNA';

  @override
  String get removeAdsPromoSubtitle =>
      'Dot Weaver\'ı banner ve kesinti olmadan oyna.';

  @override
  String get benefitNoBanner => 'Alttaki banner kalksın';

  @override
  String get benefitNoInterstitial => 'Seviyeler arası tam ekran reklam yok';

  @override
  String get benefitOneTime => 'Tek seferlik, kalıcı satın alma';

  @override
  String get benefitOffline => 'İstediğin zaman çevrimdışı oyna';

  @override
  String get maybeLater => 'Belki sonra';

  @override
  String get purchaseCouldNotStart =>
      'Satın alma başlatılamadı. Lütfen tekrar deneyin.';

  @override
  String get storeUnavailable => 'Mağaza şu an kullanılamıyor.';

  @override
  String get restoreRequested =>
      'Geri yükleme istendi. Satın alımlar otomatik güncellenecek.';

  @override
  String get couldNotOpenPrivacy => 'Gizlilik politikası açılamadı.';

  @override
  String get levelLabel => 'BÖLÜM';

  @override
  String get levelComplete => 'BÖLÜM TAMAMLANDI!';

  @override
  String timeLeft(String time) {
    return 'Kalan Süre: $time';
  }

  @override
  String get continueButton => 'DEVAM';

  @override
  String get islandComplete => 'ADA TAMAMLANDI!';

  @override
  String nextIslandUnlocking(String island) {
    return 'Sıradaki ada açılıyor:\n$island';
  }

  @override
  String get timesUp => 'SÜRE DOLDU!';

  @override
  String get watchAdContinue => 'REKLAM İZLE  +30sn';

  @override
  String get noAdAvailable => 'Şu an reklam yok';

  @override
  String get restart => 'YENİDEN BAŞLAT';

  @override
  String get failed => 'BAŞARISIZ!';

  @override
  String get failReasonOperation => 'Yanlış sonuç veya tablo dolu değil!';

  @override
  String get failReasonPath => 'Yol hatalı!';

  @override
  String get playAgain => 'TEKRAR OYNA';

  @override
  String get tutorialSwipe => 'Sayıları bağlamak için kaydır';

  @override
  String get almostThereTitle => 'Neredeyse oldu!';

  @override
  String get almostThereBody =>
      'Tüm noktalar bağlandı ama bazı kareler boş kaldı. Yeniden başlayıp tekrar dene.';

  @override
  String get undo => 'Geri al';
}
