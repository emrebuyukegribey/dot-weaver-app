import 'package:flutter/widgets.dart';

import 'game_data_manager.dart';

/// Holds the active locale override so the whole app can rebuild live when the
/// user changes the language in Settings. A null value means "follow the device
/// locale". Persisted via [GameDataManager].
class LocaleController {
  LocaleController._internal();
  static final LocaleController _instance = LocaleController._internal();
  factory LocaleController() => _instance;

  final ValueNotifier<Locale?> locale =
      ValueNotifier<Locale?>(_localeFromCode(GameDataManager().localeCode));

  static Locale? _localeFromCode(String? code) =>
      (code == null || code.isEmpty) ? null : Locale(code);

  /// [code] = 'en' / 'tr', or null to follow the device locale.
  Future<void> setLocale(String? code) async {
    await GameDataManager().setLocaleCode(code);
    locale.value = _localeFromCode(code);
  }
}
