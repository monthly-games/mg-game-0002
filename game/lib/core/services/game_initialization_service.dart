import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';

/// Service for initializing game systems on startup
class GameInitializationService {
  final Ref _ref;

  GameInitializationService(this._ref);

  /// Initialize all game systems
  Future<void> initialize() async {
    // 1. Initialize data repository
    final repository = _ref.read(gameRepositoryProvider);
    await repository.initialize();

    // 2. Initialize game state
    final gameStateNotifier = _ref.read(gameStateProvider.notifier);
    await gameStateNotifier.initialize();

    // 3. Check for new day and reset daily counters
    gameStateNotifier.checkAndResetDaily();

    // 4. Initialize idle production system
    await _initializeIdleProduction();

    // 5. Process offline rewards
    await _processOfflineRewards();

    // 6. Start crafting auto-check
    _startCraftingAutoCheck();
  }

  /// Initialize idle production with materials
  Future<void> _initializeIdleProduction() async {
    final repository = _ref.read(gameRepositoryProvider);
    final idleManager = _ref.read(idleProductionManagerProvider);

    // Get all materials
    final materials = await repository.getAllMaterials();

    // Initialize idle resources
    idleManager.initializeResources(materials);

    // Apply global multiplier based on workshop level
    final gameState = _ref.read(gameStateProvider);
    final workshopMultiplier = _calculateWorkshopMultiplier(
      gameState.workshopLevel,
    );
    idleManager.setGlobalMultiplier(workshopMultiplier);

    // Apply cat skill bonuses
    final catLevel = gameState.catLevel;
    if (catLevel >= 3) {
      // Cat skill: +10% production at level 3
      idleManager.setGlobalMultiplier(workshopMultiplier * 1.1);
    }
    if (catLevel >= 7) {
      // Cat skill: +20% production at level 7
      idleManager.setGlobalMultiplier(workshopMultiplier * 1.2);
    }
  }

  /// Calculate workshop production multiplier
  double _calculateWorkshopMultiplier(int workshopLevel) {
    // Base: 1.0
    // Each workshop level: +5%
    return 1.0 + (workshopLevel - 1) * 0.05;
  }

  /// Process offline rewards
  Future<void> _processOfflineRewards() async {
    final idleManager = _ref.read(idleProductionManagerProvider);
    final craftingManager = _ref.read(craftingGameManagerProvider);

    // Calculate offline production
    final productionRewards = idleManager.calculateOfflineProduction();

    // Process offline crafting
    craftingManager.processOfflineCrafting();

    // Show offline rewards UI if there are rewards
    if (productionRewards.isNotEmpty) {
      // TODO: Show offline rewards popup
      print('Offline rewards: $productionRewards');
    }
  }

  /// Start crafting auto-check timer
  void _startCraftingAutoCheck() {
    final craftingManager = _ref.read(craftingGameManagerProvider);
    craftingManager.startAutoCheck();
  }

  /// Cleanup on app close
  void dispose() {
    final craftingManager = _ref.read(craftingGameManagerProvider);
    craftingManager.stopAutoCheck();
  }
}

/// Provider for game initialization service
final gameInitializationServiceProvider = Provider<GameInitializationService>((ref) {
  return GameInitializationService(ref);
});
