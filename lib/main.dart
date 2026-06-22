import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'services/ad_service.dart';
import 'services/api_service.dart';
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
  // Initialise monetization after the first frame so the UI appears instantly.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initMonetization();
  });
}

Future<void> _initMonetization() async {
  // iOS App Tracking Transparency must be requested before initialising ads.
  if (Platform.isIOS) {
    try {
      final status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (_) {
      // Non-fatal: continue without tracking authorization.
    }
  }
  await PurchaseService().initialize();
  await AdService().initialize();
  // Heartbeat (fire-and-forget, offline-safe): reports stats and applies any
  // server-granted entitlement. If premium is granted, PurchaseService.adsRemoved
  // fires and the banner/interstitials are torn down — so we don't block ad init.
  ApiService().heartbeat();
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


