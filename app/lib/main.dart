import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temperature_studio/src/features/algorithm_lab/ui/algorithm_lab_page.dart';
import 'package:temperature_studio/src/features/kona_game/ui/kona_game_page.dart';
import 'package:temperature_studio/src/features/lunar_lander/ui/lunar_lander_page.dart';
import 'package:temperature_studio/src/features/sessions/ui/sessions_page.dart';
import 'package:temperature_studio/src/features/theremin/ui/theremin_page.dart';
import 'package:temperature_studio/src/ui/home/home_page.dart';
import 'package:temperature_studio/src/ui/theme/app_theme.dart';

void main() async {
  // Ensure Flutter binding is initialized if needed for plugins before runApp
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Studio',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const HomePage(),
        AlgorithmLabPage.routeName: (context) => const AlgorithmLabPage(),
        KonaGamePage.routeName: (context) => const KonaGamePage(),
        LunarLanderPage.routeName: (context) => const LunarLanderPage(),
        SessionsPage.routeName: (context) => const SessionsPage(),
        ThereminPage.routeName: (context) => const ThereminPage(),
      },
      initialRoute: '/',
    );
  }
}
