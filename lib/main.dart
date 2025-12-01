import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/start_screen.dart';
import 'screens/level_selection_screen.dart';
import 'screens/game_screen.dart';
import 'screens/results_screen.dart';
import 'services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await ProgressService.initialize(prefs);
  runApp(HelsinkiMemoryApp());
}

class HelsinkiMemoryApp extends StatelessWidget {
  const HelsinkiMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helsinki Memory',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(),
        '/levels': (context) => LevelSelectScreen(),
        '/game': (context) => GameScreen(),
        '/result': (context) => ResultScreen(),
      },
    );
  }
}