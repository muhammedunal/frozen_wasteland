import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/constants.dart';
import 'screens/menu_screen.dart';
import 'storage/game_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — the game is designed for a 384x832 portrait viewport.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive + register adapters + open the save box.
  await GameStorage.init();

  runApp(const ProviderScope(child: FrozenWastelandApp()));
}

/// Root application widget.
class FrozenWastelandApp extends StatelessWidget {
  const FrozenWastelandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frozen Wasteland',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: GameConstants.primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: GameConstants.backgroundColor,
      ),
      home: const _Bootstrap(),
    );
  }
}

/// Displays a brief loading screen, then routes to the main menu.
///
/// Use this hook to preload assets, open Hive boxes, or fetch remote config
/// before the player reaches the menu.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    // Place asset preloading / box opening here. Simulated splash delay:
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }
        return const MenuScreen();
      },
    );
  }
}

/// A minimal animated loading screen shown during bootstrap.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ac_unit, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Frozen Wasteland',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
