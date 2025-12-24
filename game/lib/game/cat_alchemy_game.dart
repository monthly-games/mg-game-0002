import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scenes/splash_scene.dart';
import 'scenes/home_scene.dart';
import 'scenes/crafting_scene.dart';
import 'scenes/gathering_scene.dart';
import 'scenes/shop_scene.dart';
import 'scenes/orders_scene.dart';
import 'scenes/cat_scene.dart';
import 'scenes/inventory_scene.dart';
import 'scenes/recipes_scene.dart';
import 'scenes/upgrade_scene.dart';
import 'scenes/achievements_scene.dart';
import 'scenes/settings_scene.dart';
import 'scenes/tutorial_scene.dart';
import 'scenes/collection_scene.dart';
import 'scenes/leaderboard_scene.dart';
import 'scenes/events_scene.dart';
import 'scenes/puzzle_scene.dart';
import 'scenes/prestige_scene.dart';
import '../core/models/recipe.dart';
import '../providers/game_providers.dart';

/// Main game class for Cat Alchemy Workshop
class CatAlchemyGame extends FlameGame {
  final WidgetRef ref;

  // Current scene
  String _currentScene = 'splash';

  // Shared state for navigation
  Recipe? selectedRecipe;

  CatAlchemyGame(this.ref);

  // Offline rewards to show
  Map<String, int>? offlineRewards;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate offline rewards
    final idleManager = ref.read(idleProductionManagerProvider);
    offlineRewards = idleManager.calculateOfflineProduction();

    // Update login time
    ref.read(gameStateProvider.notifier).checkAndResetDaily();
    // Force update last login time if checkAndResetDaily didn't (it only updates if new day)
    // Actually we should update lastLoginTime every session start?
    // GameStateNotifier.checkAndResetDaily docs says "Update last login time" inside.
    // But only if isNewDay().
    // We should explicitly update it here to mark "now" as the start of this session.
    ref.read(gameStateProvider).updateLastLoginTime();
    ref.read(gameStateProvider).save(); // Save the new time

    // Load splash scene
    await _loadScene('splash');
  }

  /// Load a scene by name
  Future<void> _loadScene(String sceneName) async {
    // Remove all current components
    removeAll(children);

    _currentScene = sceneName;

    switch (sceneName) {
      case 'splash':
        final splashScene = SplashScene(ref);
        await add(splashScene);
        break;

      case 'home':
        final homeScene = HomeScene(ref);
        await add(homeScene);
        break;

      case 'crafting':
        final craftingScene = CraftingScene(ref);
        await add(craftingScene);
        break;

      case 'gathering':
        final gatheringScene = GatheringScene(ref);
        await add(gatheringScene);
        break;

      case 'shop':
        final shopScene = ShopScene(ref);
        await add(shopScene);
        break;

      case 'orders':
        final ordersScene = OrdersScene(ref);
        await add(ordersScene);
        break;

      case 'cat':
        final catScene = CatScene(ref);
        await add(catScene);
        break;

      case 'inventory':
        final inventoryScene = InventoryScene(ref);
        await add(inventoryScene);
        break;

      case 'recipes':
        final recipesScene = RecipesScene(ref);
        await add(recipesScene);
        break;

      case 'upgrade':
        final upgradeScene = UpgradeScene(ref);
        await add(upgradeScene);
        break;

      case 'achievements':
        final achievementsScene = AchievementsScene(ref);
        await add(achievementsScene);
        break;

      case 'settings':
        final settingsScene = SettingsScene(ref);
        await add(settingsScene);
        break;

      case 'tutorial':
        final tutorialScene = TutorialScene(ref);
        await add(tutorialScene);
        break;

      case 'collection':
        final collectionScene = CollectionScene(ref);
        await add(collectionScene);
        break;

      case 'leaderboard':
        final leaderboardScene = LeaderboardScene(ref);
        await add(leaderboardScene);
        break;

      case 'events':
        final eventsScene = EventsScene(ref);
        await add(eventsScene);
        break;

      case 'puzzle':
        if (selectedRecipe != null) {
          final puzzleScene = PuzzleScene(ref, selectedRecipe!);
          await add(puzzleScene);
        } else {
          print("Error: No recipe selected for puzzle");
          _loadScene('crafting');
        }
        break;

      case 'prestige':
        final prestigeScene = PrestigeScene(ref);
        await add(prestigeScene);
        break;

      default:
        print('Unknown scene: $sceneName');
    }
  }

  /// Navigate to a scene
  void navigateTo(String sceneName) {
    _loadScene(sceneName);
  }

  /// Get current scene name
  String get currentScene => _currentScene;
}
