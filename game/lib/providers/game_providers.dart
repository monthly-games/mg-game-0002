import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mg_common_game/systems/progression/prestige_manager.dart'; // Add this import
import '../data/sources/game_data_source.dart';
import '../data/repositories/game_repository.dart';
import '../core/models/game_state.dart';
import '../core/models/material.dart';
import '../core/models/recipe.dart';
import '../core/models/cat.dart';
import '../core/models/npc.dart';
import '../core/managers/idle_production_manager.dart';
import '../core/managers/crafting_game_manager.dart';
import '../core/managers/inventory_game_manager.dart';

// ========== Data Source & Repository ==========

/// Game data source provider (singleton)
final gameDataSourceProvider = Provider<GameDataSource>((ref) {
  return GameDataSource();
});

/// Game repository provider
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final dataSource = ref.watch(gameDataSourceProvider);
  return GameRepository(dataSource);
});

// ========== Game State ==========

/// Game state notifier
class GameStateNotifier extends StateNotifier<GameState> {
  static const String _boxName = 'gameState';
  static const String _stateKey = 'current';

  GameStateNotifier() : super(GameState.initial());

  /// Load saved state or create new one
  Future<void> initialize() async {
    try {
      final box = await Hive.openBox<GameState>(_boxName);
      final savedState = box.get(_stateKey);

      if (savedState != null) {
        state = savedState;
        print('Loaded saved game state');
      } else {
        state = GameState.initial();
        await save(); // Save initial state
        print('Created new game state');
      }
    } catch (e) {
      print('Error loading game state: $e');
      state = GameState.initial();
    }
  }

  /// Save current state
  Future<void> save() async {
    try {
      final box = await Hive.openBox<GameState>(_boxName);
      await box.put(_stateKey, state);
    } catch (e) {
      print('Error saving game state: $e');
    }
  }

  /// Delete saved state (reset game)
  Future<void> reset() async {
    try {
      final box = await Hive.openBox<GameState>(_boxName);
      await box.delete(_stateKey);
      state = GameState.initial();
      await save();
      print('Game state reset');
    } catch (e) {
      print('Error resetting game state: $e');
    }
  }

  // ========== Gold & Gems ==========

  void addGold(int amount) {
    state = GameState(
      gold: state.gold + amount,
      gems: state.gems,
      workshopLevel: state.workshopLevel,
      reputation: state.reputation,
      playerExp: state.playerExp,
      inventory: state.inventory,
      discoveredRecipes: state.discoveredRecipes,
      lastLoginTime: state.lastLoginTime,
      catState: state.catState,
      craftingQueue: state.craftingQueue,
      activeOrders: state.activeOrders,
      dailyInteractions: state.dailyInteractions,
      tutorialCompleted: state.tutorialCompleted,
    );
    save();
  }

  void addGems(int amount) {
    state = GameState(
      gold: state.gold,
      gems: state.gems + amount,
      workshopLevel: state.workshopLevel,
      reputation: state.reputation,
      playerExp: state.playerExp,
      inventory: state.inventory,
      discoveredRecipes: state.discoveredRecipes,
      lastLoginTime: state.lastLoginTime,
      catState: state.catState,
      craftingQueue: state.craftingQueue,
      activeOrders: state.activeOrders,
      dailyInteractions: state.dailyInteractions,
      tutorialCompleted: state.tutorialCompleted,
    );
    save();
  }

  bool spendGold(int amount) {
    if (state.gold < amount) return false;

    state = GameState(
      gold: state.gold - amount,
      gems: state.gems,
      workshopLevel: state.workshopLevel,
      reputation: state.reputation,
      playerExp: state.playerExp,
      inventory: state.inventory,
      discoveredRecipes: state.discoveredRecipes,
      lastLoginTime: state.lastLoginTime,
      catState: state.catState,
      craftingQueue: state.craftingQueue,
      activeOrders: state.activeOrders,
      dailyInteractions: state.dailyInteractions,
      tutorialCompleted: state.tutorialCompleted,
    );
    save();
    return true;
  }

  // ========== Inventory ==========

  void addToInventory(String itemId, int amount) {
    state.addToInventory(itemId, amount);
    state = GameState(
      gold: state.gold,
      gems: state.gems,
      workshopLevel: state.workshopLevel,
      reputation: state.reputation,
      playerExp: state.playerExp,
      inventory: Map.from(state.inventory),
      discoveredRecipes: state.discoveredRecipes,
      lastLoginTime: state.lastLoginTime,
      catState: state.catState,
      craftingQueue: state.craftingQueue,
      activeOrders: state.activeOrders,
      dailyInteractions: state.dailyInteractions,
      tutorialCompleted: state.tutorialCompleted,
    );
    save();
  }

  bool removeFromInventory(String itemId, int amount) {
    if (!state.removeFromInventory(itemId, amount)) return false;

    state = GameState(
      gold: state.gold,
      gems: state.gems,
      workshopLevel: state.workshopLevel,
      reputation: state.reputation,
      playerExp: state.playerExp,
      inventory: Map.from(state.inventory),
      discoveredRecipes: state.discoveredRecipes,
      lastLoginTime: state.lastLoginTime,
      catState: state.catState,
      craftingQueue: state.craftingQueue,
      activeOrders: state.activeOrders,
      dailyInteractions: state.dailyInteractions,
      tutorialCompleted: state.tutorialCompleted,
    );
    save();
    return true;
  }

  // ========== Recipe Discovery ==========

  void discoverRecipe(String recipeId, {int goldBonus = 0, int expBonus = 0}) {
    state.discoverRecipe(recipeId);

    state = GameState(
      gold: state.gold + goldBonus,
      gems: state.gems,
      workshopLevel: state.workshopLevel,
      reputation: state.reputation,
      playerExp: state.playerExp + expBonus,
      inventory: state.inventory,
      discoveredRecipes: List.from(state.discoveredRecipes),
      lastLoginTime: state.lastLoginTime,
      catState: state.catState,
      craftingQueue: state.craftingQueue,
      activeOrders: state.activeOrders,
      dailyInteractions: state.dailyInteractions,
      tutorialCompleted: state.tutorialCompleted,
    );
    save();
  }

  // ========== Workshop ==========

  void upgradeWorkshop() {
    state = GameState(
      gold: state.gold,
      gems: state.gems,
      workshopLevel: state.workshopLevel + 1,
      reputation: state.reputation,
      playerExp: state.playerExp,
      inventory: state.inventory,
      discoveredRecipes: state.discoveredRecipes,
      lastLoginTime: state.lastLoginTime,
      catState: state.catState,
      craftingQueue: state.craftingQueue,
      activeOrders: state.activeOrders,
      dailyInteractions: state.dailyInteractions,
      tutorialCompleted: state.tutorialCompleted,
    );
    save();
  }

  // ========== Cat ==========

  void addCatTrust(int amount) {
    state.addCatTrust(amount);
    // Recalculate level based on trust
    // TODO: Get cat data and calculate level

    state = GameState(
      gold: state.gold,
      gems: state.gems,
      workshopLevel: state.workshopLevel,
      reputation: state.reputation,
      playerExp: state.playerExp,
      inventory: state.inventory,
      discoveredRecipes: state.discoveredRecipes,
      lastLoginTime: state.lastLoginTime,
      catState: Map.from(state.catState),
      craftingQueue: state.craftingQueue,
      activeOrders: state.activeOrders,
      dailyInteractions: state.dailyInteractions,
      tutorialCompleted: state.tutorialCompleted,
    );
    save();
  }

  void petCat() {
    state.incrementPetCount();
    addCatTrust(1);
  }

  void playCat() {
    state.incrementPlayCount();
    addCatTrust(10);
  }

  // ========== Daily Reset ==========

  void checkAndResetDaily() {
    if (state.isNewDay()) {
      state.resetDailyCounters();
      state.updateLastLoginTime();
      save();
    }
  }
}

/// Game state provider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((
  ref,
) {
  return GameStateNotifier();
});

// ========== Static Game Data Providers ==========

/// All materials provider
final materialsProvider = FutureProvider<List<Material>>((ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  return await repository.getAllMaterials();
});

/// All recipes provider
final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  return await repository.getAllRecipes();
});

/// Cat data provider
final catDataProvider = FutureProvider<Cat>((ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  return await repository.getCatData();
});

/// All NPCs provider
final npcsProvider = FutureProvider<List<NPC>>((ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  return await repository.getAllNPCs();
});

// ========== Computed Providers ==========

/// Unlocked materials provider (based on workshop level)
final unlockedMaterialsProvider = FutureProvider<List<Material>>((ref) async {
  final gameState = ref.watch(gameStateProvider);
  final repository = ref.watch(gameRepositoryProvider);

  return await repository.getUnlockedMaterials(gameState.workshopLevel);
});

/// Discovered recipes provider
final discoveredRecipesProvider = Provider<List<String>>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.discoveredRecipes;
});

/// Unlocked NPCs provider
final unlockedNPCsProvider = FutureProvider<List<NPC>>((ref) async {
  final gameState = ref.watch(gameStateProvider);
  final repository = ref.watch(gameRepositoryProvider);

  return await repository.getUnlockedNPCs(gameState.workshopLevel);
});

/// Player inventory provider
final inventoryProvider = Provider<Map<String, int>>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.inventory;
});

/// Cat level provider
final catLevelProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.catLevel;
});

/// Cat trust provider
final catTrustProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.catTrust;
});

// ========== Game Managers ==========

/// Idle production manager provider
final idleProductionManagerProvider = Provider<IdleProductionManager>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return IdleProductionManager(gameState);
});

/// Crafting game manager provider
final craftingGameManagerProvider = Provider<CraftingGameManager>((ref) {
  final gameState = ref.watch(gameStateProvider);
  final prestigeManager = ref.watch(prestigeManagerProvider);
  return CraftingGameManager(gameState, prestigeManager);
});

/// Inventory game manager provider
final inventoryGameManagerProvider = Provider<InventoryGameManager>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return InventoryGameManager(gameState);
});

// ========== Prestige Manager ==========

/// Prestige Manager Provider
final prestigeManagerProvider = Provider<PrestigeManager>((ref) {
  final manager = PrestigeManager();

  // Register default upgrades for Alchemy Game
  manager.registerPrestigeUpgrade(
    PrestigeUpgrade(
      id: 'gold_boost',
      name: 'Midas Touch',
      description: 'Increases gold gained from sales by 10%',
      maxLevel: 50,
      costPerLevel: 1, // 1 point per level
      bonusPerLevel: 0.1, // +10%
    ),
  );

  manager.registerPrestigeUpgrade(
    PrestigeUpgrade(
      id: 'craft_speed',
      name: 'Time Warp',
      description: 'Increases crafting speed by 5%',
      maxLevel: 20,
      costPerLevel: 2,
      bonusPerLevel: 0.05, // +5%
    ),
  );

  manager.registerPrestigeUpgrade(
    PrestigeUpgrade(
      id: 'luck',
      name: 'Alchemist\'s Luck',
      description: 'Chance to craft double items by 2%',
      maxLevel: 25,
      costPerLevel: 5,
      bonusPerLevel: 0.02, // +2%
    ),
  );

  // Load saved data
  manager.loadPrestigeData();

  return manager;
});
