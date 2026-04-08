import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/song.dart';
import 'services/database_service.dart';
import 'services/audio_player_service.dart';
import 'screens/main_screen.dart';
import 'theme.dart';

/// App entry point.
/// 1. Initialises Hive (local database).
/// 2. Registers the Song adapter.
/// 3. Creates services and wraps the app with Provider.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a phone-first experience.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Make the system UI match our dark theme.
  SystemChrome.setSystemUIOverlayStyle(const SystemUIOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.darkBg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // ── Hive setup ──────────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(SongAdapter());

  // ── Services ────────────────────────────────────────────────────────────
  final databaseService = DatabaseService();
  await databaseService.init();

  final audioPlayerService = AudioPlayerService(databaseService);

  // ── Run ─────────────────────────────────────────────────────────────────
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: databaseService),
        ChangeNotifierProvider.value(value: audioPlayerService),
      ],
      child: const MusicPlayerApp(),
    ),
  );
}

/// Root widget that applies the dark theme and launches the [MainScreen].
class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
