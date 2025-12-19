import 'package:flutter/material.dart';
import 'services/game_data_manager.dart';
import 'screens/world_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameDataManager().init();
  runApp(const MyApp());
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Weaver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver],
      home: const WorldMapScreen(),
    );
  }
}


