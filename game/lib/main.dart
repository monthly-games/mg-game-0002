import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/screens/seasonal_event_screen.dart';
import 'package:mg_common_game/core/ui/screens/tournament_screen.dart';
import 'package:mg_common_game/core/ui/screens/guild_war_screen.dart';
import 'package:mg_common_game/systems/events/seasonal_content_manager.dart';
import 'package:mg_common_game/systems/competitive/tournament_manager.dart';
import 'package:mg_common_game/systems/social/guild_war_manager.dart';
import 'package:mg_common_game/core/ui/screens/daily_hub_screen.dart';
import 'package:mg_common_game/systems/retention/daily_challenge_manager.dart';
import 'package:mg_common_game/systems/retention/streak_manager.dart';
import 'package:mg_common_game/systems/retention/login_rewards_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/systems/systems.dart';
import 'package:mg_common_game/systems/quests/daily_quest.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/game_state.dart';
import 'game/cat_alchemy_game.dart';
import 'providers/game_providers.dart';
import 'ui/hud/mg_idle_hud.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/battlepass_screen.dart';
import 'screens/collection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for data persistence
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(GameStateAdapter());

  // Open game state box
  await Hive.openBox<GameState>('gameState');

  // DailyQuest 시스템
  GetIt.I.registerSingleton(DailyQuestManager());
  // BattlePass 시스템
  GetIt.I.registerSingleton(BattlePassManager());
  // Collection 시스템
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
  // ── Retention Systems for DailyHub ────────────────────────
  if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
    GetIt.I.registerSingleton(LoginRewardsManager());
  }
  if (!GetIt.I.isRegistered<StreakManager>()) {
    GetIt.I.registerSingleton(StreakManager());
  }
  if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
    GetIt.I.registerSingleton(DailyChallengeManager());
}
  // ── P3 Engine Systems ─────────────────────────────────────
  if (!GetIt.I.isRegistered<GuildWarManager>()) {
    GetIt.I.registerSingleton(GuildWarManager());
  }
  if (!GetIt.I.isRegistered<TournamentManager>()) {
    GetIt.I.registerSingleton(TournamentManager());
  }
  if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
    GetIt.I.registerSingleton(SeasonalContentManager());
  }
    _registerCollections();
  }
  _setupBattlePass();
  _registerDailyQuests();
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
        colorScheme: ColorScheme.fromSeed(seedColor: MGColors.warning),
        scaffoldBackgroundColor: MGColors.textHighEmphasis, // Warm cream
        fontFamily: 'Pretendard', // TODO: Add font to pubspec
      ),
      routes: {
        '/daily-quest': (_) => const DailyQuestScreen(),
        '/battlepass': (_) => const BattlePassScreen(),
        '/daily-hub': (context) => DailyHubScreen(
          questManager: GetIt.I<DailyQuestManager>(),
          loginRewardsManager: GetIt.I<LoginRewardsManager>(),
          streakManager: GetIt.I<StreakManager>(),
          challengeManager: GetIt.I<DailyChallengeManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
        ),
      
        '/collection': (context) => CollectionScreen(
          collectionManager: GetIt.I<CollectionManager>(),
        ),
        '/guild-war': (context) => GuildWarScreen(
          guildWarManager: GetIt.I<GuildWarManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
        '/tournament': (context) => TournamentScreen(
          tournamentManager: GetIt.I<TournamentManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
        '/seasonal-event': (context) => SeasonalEventScreen(
          seasonalContentManager: GetIt.I<SeasonalContentManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
},
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
              onDailyHub: () => Navigator.of(context).pushNamed('/daily-hub'),
              onGuildWar: () {
                game.pauseEngine();
                Navigator.of(context).pushNamed('/guild-war').then((_) => game.resumeEngine());
              },
              onTournament: () {
                game.pauseEngine();
                Navigator.of(context).pushNamed('/tournament').then((_) => game.resumeEngine());
              },
              onSeasonalEvent: () {
                game.pauseEngine();
                Navigator.of(context).pushNamed('/seasonal-event').then((_) => game.resumeEngine());
              },
            );
          },
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}


void _registerDailyQuests() {
  final dailyQuest = GetIt.I<DailyQuestManager>();
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'collect_gold',
    title: '골드 모으기',
    description: '골드 1000 획득',
    targetValue: 1000,
    goldReward: 500,
    xpReward: 10,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'play_games',
    title: '게임 플레이',
    description: '게임 5판 플레이',
    targetValue: 5,
    goldReward: 300,
    xpReward: 5,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'level_up',
    title: '레벨업',
    description: '레벨 1 상승',
    targetValue: 1,
    goldReward: 200,
    xpReward: 3,
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

  // Characters 컬렉션
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

  // 아이템 해제 콜백 (햅틱 피드백)
  collection.onItemUnlocked = (collectionId, itemId) {
    // SettingsManager가 등록되어 있으면 햅틱 피드백
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}
