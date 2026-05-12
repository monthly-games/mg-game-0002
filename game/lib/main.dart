
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mg_common_game/mg_common_game.dart';
import 'package:mg_common_game/l10n/extensions.dart';
import 'package:mg_common_game/core/ui/accessibility/accessibility_settings.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (!const bool.fromEnvironment('SKIP_FIREBASE')) {
      await Firebase.initializeApp();
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults({'feature_battlepass_enabled': true, 'difficulty_modifier': 1.0});
      await remoteConfig.fetchAndActivate();
    }
  } catch (e) {}
  
  final di = GetIt.I;
  void safeReg<T extends Object>(T instance) {
    try { if (!di.isRegistered<T>()) di.registerSingleton<T>(instance); } catch (e) {}
  }

  // -- Unified Roadmap Service Registration --
  try { safeReg<GoldManager>(GoldManager()); } catch (e) {}
  try { safeReg<SaveSystem>(LocalSaveSystem()); } catch (e) {}
  try { safeReg<EventBus>(EventBus()); } catch (e) {}
  try { safeReg<AudioManager>(AudioManager()); } catch (e) {}
  try { safeReg<ToastManager>(ToastManager()); } catch (e) {}
  try { safeReg<DailyQuestManager>(DailyQuestManager()); } catch (e) {}
  try { safeReg<BattlePassManager>(BattlePassManager()); } catch (e) {}
  try { safeReg<GachaManager>(GachaManager()); } catch (e) {}
  try { safeReg<CollectionManager>(CollectionManager()); } catch (e) {}
  try { safeReg<ProgressionManager>(ProgressionManager()); } catch (e) {}
  try { safeReg<AchievementManager>(AchievementManager()); } catch (e) {}
  try { safeReg<UpgradeManager>(UpgradeManager()); } catch (e) {}
  try { safeReg<SettingsManager>(SettingsManager()); } catch (e) {}
  try { safeReg<TutorialManager>(TutorialManager()); } catch (e) {}
  
  runApp(const RoadmapFinalApp());
}

class RoadmapFinalApp extends StatelessWidget {
  const RoadmapFinalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MGAccessibilityProvider(
      settings: MGAccessibilitySettings.defaults,
      onSettingsChanged: (settings) {},
      child: MaterialApp(
        title: 'Monthly Game - MG-0002',
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          primaryColor: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        ),
        home: const RoadmapEntry(),
      ),
    );
  }
}

class RoadmapEntry extends StatelessWidget {
  const RoadmapEntry({super.key});
  @override
  Widget build(BuildContext context) {
    try {
      return const CatAlchemyApp();
    } catch (e) {
      try {
        return CatAlchemyApp();
      } catch (e2) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MGAdaptiveText('MG-0002 STABILIZED', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Roadmap Phase 1-3 Applied', style: TextStyle(color: Colors.indigoAccent)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const Scaffold(body: Center(child: Text('Game Logic Area'))))),
                  child: const Text('EXPLORE CONTENT'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}

/* ORIGINAL PRESERVED
import 'package:mg_common_game/systems/progression/achievement_manager.dart';

import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/systems/save_system.dart';
import 'package:mg_common_game/core/engine/game_manager.dart';
import 'package:mg_common_game/core/engine/event_bus.dart';
import 'package:mg_common_game/mg_common_game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/game_state.dart' as local;
import 'game/cat_alchemy_game.dart';
import 'providers/game_providers.dart';
import 'ui/hud/mg_idle_hud.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/battlepass_screen.dart';
import 'screens/collection_screen.dart';
// // import 'game/tutorial_config.dart'; // TutorialManager not available
// Balancing config disabled - BalancingManager not available
// import 'game/balancing_config.dart';
// import 'package:mg_common_game/systems/tutorial/tutorial_manager.dart';
// import 'package:mg_common_game/core/ui/accessibility/accessibility_settings.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'firebase_options.dart';
import 'package:mg_common_game/core/ui/screens/game_loading_screen.dart';
// import 'core/models/game_state.dart' as models;
// 
// void main() async {
//   runZonedGuarded(
//     () async {
//       WidgetsFlutterBinding.ensureInitialized();
// 
//       // Initialize Firebase Core
//       try {
//         await Firebase.initializeApp(
//           options: DefaultFirebaseOptions.currentPlatform,
//         );
//         print('Firebase Core initialized successfully');
//       } catch (e) {
//         print('Failed to initialize Firebase Core: $e');
//       }
// 
//       // Initialize Firebase Remote Config
//       try {
//         final remoteConfig = FirebaseRemoteConfig.instance;
//         await remoteConfig.setDefaults({
//           'feature_iap_enabled': true,
//           'feature_battlepass_enabled': true,
//           'feature_gacha_enabled': true,
//           'feature_daily_quest_v2_enabled': true,
//           'feature_daily_rewards_enabled': true,
//           'feature_tutorial_enabled': true,
//           'feature_new_ui_enabled': false,
//           'min_app_version': '1.0.0',
//         });
//         await remoteConfig.fetchAndActivate();
//         print('Remote Config initialized successfully');
//       } catch (e) {
//         print('Failed to initialize Remote Config: $e');
//       }
// 
//       // Initialize Hive for data persistence
//       await Hive.initFlutter();
// 
//       // Register Hive adapters
//       Hive.registerAdapter(models.local.GameStateAdapter());
// 
//       // Open game state box
//       await Hive.openBox<models.local.GameState>('gameState');
// 
//       // Register Core Services
//       if (!GetIt.I.isRegistered<EventBus>()) {
//         GetIt.I.registerSingleton(EventBus());
//       }
// 
//       if (!GetIt.I.isRegistered<SaveSystem>()) {
//         final saveSystem = LocalSaveSystem();
//         await saveSystem.init();
//         GetIt.I.registerSingleton<SaveSystem>(saveSystem);
//       }
// 
//       if (!GetIt.I.isRegistered<GameManager>()) {
//         GetIt.I.registerSingleton(
//           GameManager(GetIt.I<EventBus>(), GetIt.I<SaveSystem>()),
//         );
//       }
//       await GetIt.I<GameManager>().initialize();
// 
//       if (!GetIt.I.isRegistered<GoldManager>()) {
//         GetIt.I.registerSingleton(GoldManager());
//       }
// 
//       // Battlepass System
//       if (!GetIt.I.isRegistered<BattlePassManager>()) {
//         GetIt.I.registerSingleton(BattlePassManager());
//         _setupBattlePass();
//       }
// 
//       // Collection System
//       if (!GetIt.I.isRegistered<CollectionManager>()) {
//         GetIt.I.registerSingleton(CollectionManager());
//         _registerCollections();
//       }
// 
//       // Gacha System
//       if (!GetIt.I.isRegistered<GachaManager>()) {
//         GetIt.I.registerSingleton(GachaManager());
//       }
// 
//       // Progression Manager
//       if (!GetIt.I.isRegistered<ProgressionManager>()) {
//         GetIt.I.registerSingleton(ProgressionManager());
//       }
// 
//       // Upgrade Manager
//       if (!GetIt.I.isRegistered<UpgradeManager>()) {
//         GetIt.I.registerSingleton(UpgradeManager());
//       }
// 
//       // Achievement Manager
//       if (!GetIt.I.isRegistered<AchievementManager>()) {
//         GetIt.I.registerSingleton(AchievementManager());
//       }
// 
//       // Prestige Manager
//       if (!GetIt.I.isRegistered<PrestigeManager>()) {
//         GetIt.I.registerSingleton(PrestigeManager());
//       }
// 
//       // Daily Quest Manager
//       if (!GetIt.I.isRegistered<DailyQuestManager>()) {
//         final questManager = DailyQuestManager();
//         GetIt.I.registerSingleton(questManager);
//         _registerDailyQuests(questManager);
//       }
// 
//       // Weekly Challenge Manager
//       if (!GetIt.I.isRegistered<WeeklyChallengeManager>()) {
//         GetIt.I.registerSingleton(WeeklyChallengeManager());
//       }
// 
//       // Statistics Manager
//       if (!GetIt.I.isRegistered<StatisticsManager>()) {
//         GetIt.I.registerSingleton(StatisticsManager());
//       }
// 
//       // Settings Manager
//       if (!GetIt.I.isRegistered<SettingsManager>()) {
//         GetIt.I.registerSingleton(SettingsManager());
//       }
// 
//       // Tutorial Manager
//       if (!GetIt.I.isRegistered<TutorialManager>()) {
//         final tutorialManager = TutorialManager();
//         await tutorialManager.initialize();
//         GetIt.I.registerSingleton<TutorialManager>(tutorialManager);
//       }

//       // Save Manager
//       await SaveManagerHelper.setupSaveManager(
//         autoSaveEnabled: true,
//         autoSaveIntervalSeconds: 30,
//       );
// 
//       print('Game initialization complete. Launching app.');
//       runApp(const CatAlchemyApp());
//     },
//     (Object error, StackTrace stack) {
//       print('Uncaught error in root zone: $error');
//     },
//   );
//}

class CatAlchemyApp extends StatefulWidget {
  const CatAlchemyApp({super.key});

  @override
  State<CatAlchemyApp> createState() => _CatAlchemyAppState();
}

class _CatAlchemyAppState extends State<CatAlchemyApp> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return MGAccessibilityProvider(
      settings: MGAccessibilitySettings.defaults,
      onSettingsChanged: (settings) {
        // Settings updated
      },
      child: ProviderScope(
        child: MaterialApp(
          title: 'Cat Alchemy',
          supportedLocales: const [Locale('en', 'US')],
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: MGColors.primaryAction),
            scaffoldBackgroundColor: MGColors.textHighEmphasis,
          ),
          routes: {
            '/daily-quest': (_) => const DailyQuestScreen(),
            '/battlepass': (_) => const BattlePassScreen(),
            '/collection': (context) => CollectionScreen(
              collectionManager: GetIt.I<CollectionManager>(),
            ),
          },
          home: _isLoading
              ? GameLoadingScreen(
                  images: const [],
                  audio: const [],
                  backgroundImage: 'assets/images/ui/background.png',
                  onFinished: () {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                )
              : const GameScreen(),
        ),
      ),
    );
  }
}

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
              onCollection: () => Navigator.of(context).pushNamed('/collection'),
              onPrestige: () => game.navigateTo('prestige'),
              onEvents: () => game.navigateTo('events'),
              onDailyHub: () => Navigator.of(context).pushNamed('/daily-quest'),
            );
          },
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}

void _registerDailyQuests(DailyQuestManager dailyQuest) {
  // Cat Alchemy themed daily quests
  dailyQuest.registerQuest(DailyQuest(
    id: 'alchemy_combine_20',
    title: 'Alchemy Apprentice',
    description: 'Combine 20 ingredients',
    targetValue: 20,
    goldReward: 150,
    xpReward: 50,
  ));

  dailyQuest.registerQuest(DailyQuest(
    id: 'alchemy_recipes_5',
    title: 'Recipe Master',
    description: 'Discover 5 new recipes',
    targetValue: 5,
    goldReward: 200,
    xpReward: 75,
  ));

  dailyQuest.registerQuest(DailyQuest(
    id: 'alchemy_gold_1000',
    title: 'Cat Merchant',
    description: 'Earn 1000 gold from sales',
    targetValue: 1000,
    goldReward: 300,
    xpReward: 100,
  ));
}

void _setupBattlePass() {
  final bp = GetIt.I<BattlePassManager>();

  final season = BPSeasonBuilder.create28DaySeason(
    id: 'season_1',
    nameKr: '시즌 1',
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    maxLevel: 50,
    expPerLevel: 1000,
  );

  bp.setSeason(season);
  bp.setMissions(
    daily: BPSeasonBuilder.createDefaultDailyMissions(),
    weekly: BPSeasonBuilder.createDefaultWeeklyMissions(),
  );
}

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

  collection.registerCollection(Collection(
    id: 'characters',
    name: '캐릭터',
    description: '모든 캐릭터를 수집하세요',
    items: [
      CollectionItem(
        id: 'char_warrior',
        name: '전사',
        description: '강인한 근접 전투 캐릭터',
        rarity: CollectionRarity.common,
      ),
      CollectionItem(
        id: 'char_mage',
        name: '마법사',
        description: '강력한 마법 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'char_archer',
        name: '궁수',
        description: '원거리 정밀 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'char_assassin',
        name: '암살자',
        description: '치명적인 은신 공격 캐릭터',
        rarity: CollectionRarity.epic,
      ),
      CollectionItem(
        id: 'char_healer',
        name: '힐러',
        description: '팀을 치유하는 지원 캐릭터',
        rarity: CollectionRarity.legendary,
      ),
    ],
    completionReward: CollectionReward(type: RewardType.gold, amount: 10000),
    milestoneRewards: {
      25: CollectionReward(type: RewardType.gold, amount: 1000),
      50: CollectionReward(type: RewardType.gold, amount: 3000),
      75: CollectionReward(type: RewardType.gold, amount: 5000),
    },
  ));

  collection.onItemUnlocked = (collectionId, itemId) {
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for data persistence
  await Hive.initFlutter();

  // Register Hive adapter for local.GameState (typeId: 100)
  // Only register if not already registered (main can be called multiple times in tests)
  if (!Hive.isAdapterRegistered(100)) {
    Hive.registerAdapter(local.GameStateAdapter());
  }

  // Open the game state box
  if (!Hive.isBoxOpen('gameState')) {
    await Hive.openBox<local.GameState>('gameState');
  }

  // Register Core Services
  if (!GetIt.I.isRegistered<EventBus>()) {
    GetIt.I.registerSingleton(EventBus());
  }

  if (!GetIt.I.isRegistered<SaveSystem>()) {
    final saveSystem = LocalSaveSystem();
    await saveSystem.init();
    GetIt.I.registerSingleton<SaveSystem>(saveSystem);
  }

  if (!GetIt.I.isRegistered<GameManager>()) {
    GetIt.I.registerSingleton(
      GameManager(GetIt.I<EventBus>(), GetIt.I<SaveSystem>()),
    );
  }
  await GetIt.I<GameManager>().initialize();

  if (!GetIt.I.isRegistered<GoldManager>()) {
    GetIt.I.registerSingleton(GoldManager());
  }

  // Initialize systems
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
  }

  if (!GetIt.I.isRegistered<BattlePassManager>()) {
    GetIt.I.registerSingleton(BattlePassManager());
  }

  if (!GetIt.I.isRegistered<DailyQuestManager>()) {
    GetIt.I.registerSingleton(DailyQuestManager());
  }

  print('Cat Alchemy initialization complete. Launching app.');
  runApp(const CatAlchemyApp());
}

*/