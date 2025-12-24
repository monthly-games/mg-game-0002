import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/game_state.dart';
import 'game/cat_alchemy_game.dart';
import 'providers/game_providers.dart';
import 'ui/hud/mg_idle_hud.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for data persistence
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(GameStateAdapter());

  // Open game state box
  await Hive.openBox<GameState>('gameState');

  runApp(
    const ProviderScope(
      child: CatAlchemyApp(),
    ),
  );
}

class CatAlchemyApp extends StatelessWidget {
  const CatAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '고양이 연금술 공방',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5E6D3), // Warm cream
        fontFamily: 'Pretendard', // TODO: Add font to pubspec
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Main game screen with Flame game widget
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late CatAlchemyGame _game;

  @override
  void initState() {
    super.initState();
    _game = CatAlchemyGame(ref);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: GameWidget<CatAlchemyGame>(
        game: _game,
        overlayBuilderMap: {
          'HUD': (BuildContext context, CatAlchemyGame game) {
            return MGIdleHud(
              gold: gameState.gold,
              gems: gameState.gems,
              workshopLevel: gameState.workshopLevel,
              onSettings: () => game.navigateTo('settings'),
              onTutorial: () => game.navigateTo('tutorial'),
              onCollection: () => game.navigateTo('collection'),
              onPrestige: () => game.navigateTo('prestige'),
              onEvents: () => game.navigateTo('events'),
            );
          },
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}
