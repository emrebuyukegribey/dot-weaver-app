import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'services/game_data_manager.dart';
import 'services/level_generator.dart';
import 'services/locale_controller.dart';
import 'services/purchase_service.dart';
import 'services/sound_service.dart';
import 'screens/world_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameDataManager().init();
  // Load procedurally pre-generated level packs (Number 51-100, etc.).
  await LevelGenerator.init();
  // Pre-load sound effects (non-blocking for the UI; safe to fire-and-forget).
  SoundService().init();
  runApp(const MyApp());
  // IAP restore only — ads + ATT start from [WorldMapScreen] once UI is visible.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    PurchaseService().initialize();
  });
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController().locale,
      builder: (context, locale, _) => MaterialApp(
        onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObservers: [routeObserver],
        home: const WorldMapScreen(),
      ),
    );
  }
}


