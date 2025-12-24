import 'dart:math';
import 'package:mg_common_game/mg_common_game.dart';
import 'package:mg_common_game/systems/progression/prestige_manager.dart';
import '../models/recipe.dart';
import '../models/game_state.dart';

/// Manages crafting system for the game
class CraftingGameManager {
  final CraftingManager _craftingManager = CraftingManager();
  final GameState _gameState;
  final PrestigeManager _prestigeManager;

  CraftingGameManager(this._gameState, this._prestigeManager) {
    // Set initial queue size from game state
    final maxSize = _gameState.getMaxCraftingQueueSize();
    _craftingManager.setMaxQueueSize(maxSize);
  }

  /// Start crafting a recipe
  CraftingResult startCrafting(Recipe recipe) {
    // Check if player has discovered this recipe
    if (!_gameState.isRecipeDiscovered(recipe.id)) {
      return CraftingResult.failure('Recipe not discovered');
    }

    // Check if player has ingredients
    if (!recipe.canCraft(_gameState.inventory)) {
      return CraftingResult.failure('Not enough ingredients');
    }

    // Consume ingredients
    for (final ingredient in recipe.ingredients) {
      final success = _gameState.removeFromInventory(
        ingredient.id,
        ingredient.amount,
      );
      if (!success) {
        return CraftingResult.failure('Failed to consume ingredients');
      }
    }

    // Start crafting
    final speedMultiplier = _prestigeManager.getPrestigeMultiplier(
      'craft_speed',
    );
    final duration = (recipe.craftDuration.inSeconds / speedMultiplier).round();

    final result = _craftingManager.startCrafting(
      recipeId: recipe.id,
      baseCraftTime: Duration(seconds: duration),
      result: {recipe.id: 1}, // One crafted item
    );

    return result;
  }

  /// Collect completed crafting job
  void collectCompleted(String jobId) {
    final result = _craftingManager.collectCompleted(jobId);
    if (result != null) {
      final doubleChance = _prestigeManager.getPrestigeMultiplier('luck') - 1.0;
      final random = Random();

      // Add crafted items to inventory
      for (final entry in result.entries) {
        int amount = entry.value;
        if (random.nextDouble() < doubleChance) {
          amount *= 2; // Double!
          // Could add visual feedback callback here
        }
        _gameState.addToInventory(entry.key, amount);
      }
    }
  }

  /// Collect all completed jobs
  void collectAllCompleted() {
    // Note: This iterates all completed jobs inside CraftingManager and returns aggregate
    // We lose per-job granularity for luck rolling if we use collectAllCompleted directly.
    // Instead we should iterate ourselves if possible, or apply luck to total.
    // Applying to total:
    final results = _craftingManager.collectAllCompleted();

    final doubleChance = _prestigeManager.getPrestigeMultiplier('luck') - 1.0;
    final random = Random();

    // Add all crafted items to inventory
    for (final entry in results.entries) {
      int amount = entry.value;
      // Simple statistical approximation for bulk collect
      // If chance is 0.1, we add amount * 0.1 extra items?
      // Or roll 'amount' times? Rolling loop is safer.
      int bonus = 0;
      for (int i = 0; i < amount; i++) {
        if (random.nextDouble() < doubleChance) bonus++;
      }

      _gameState.addToInventory(entry.key, amount + bonus);
    }
  }

  /// Process offline crafting
  void processOfflineCrafting() {
    final results = _craftingManager.processOfflineCrafting(
      _gameState.lastLoginTime,
    );

    // Add completed items to inventory
    for (final entry in results.entries) {
      _gameState.addToInventory(entry.key, entry.value);
    }
  }

  /// Set craft time modifier (from cat skills, upgrades)
  void setCraftTimeModifier(double modifier) {
    _craftingManager.setCraftTimeModifier(modifier);
  }

  /// Update max queue size (when cat levels up or workshop upgrades)
  void updateMaxQueueSize() {
    final maxSize = _gameState.getMaxCraftingQueueSize();
    _craftingManager.setMaxQueueSize(maxSize);
  }

  /// Instant complete a job (premium feature)
  void instantComplete(String jobId) {
    final result = _craftingManager.instantComplete(jobId);
    if (result != null) {
      // Add crafted items to inventory
      for (final entry in result.entries) {
        _gameState.addToInventory(entry.key, entry.value);
      }
    }
  }

  /// Cancel crafting job (refund ingredients)
  bool cancelJob(String jobId, Recipe recipe) {
    final success = _craftingManager.cancelJob(jobId);

    if (success) {
      // Refund ingredients
      for (final ingredient in recipe.ingredients) {
        _gameState.addToInventory(ingredient.id, ingredient.amount);
      }
    }

    return success;
  }

  /// Get current queue
  List<CraftingJob> get queue => _craftingManager.queue;

  /// Get queue size
  int get queueSize => _craftingManager.queueSize;

  /// Get max queue size
  int get maxQueueSize => _craftingManager.maxQueueSize;

  /// Check if queue is full
  bool get isQueueFull => _craftingManager.isQueueFull;

  /// Get completed jobs
  List<CraftingJob> getCompletedJobs() {
    return _craftingManager.getCompletedJobs();
  }

  /// Get time until next completion
  Duration? getTimeUntilNextCompletion() {
    return _craftingManager.getTimeUntilNextCompletion();
  }

  /// Start auto-check for completions
  void startAutoCheck() {
    _craftingManager.startAutoCheck();

    // Set completion callback
    _craftingManager.onCraftingComplete = (job) {
      // Auto-collect completed items
      collectCompleted(job.id);
    };
  }

  /// Stop auto-check
  void stopAutoCheck() {
    _craftingManager.stopAutoCheck();
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return _craftingManager.toJson();
  }

  /// Deserialize from JSON
  void fromJson(Map<String, dynamic> json) {
    _craftingManager.fromJson(json);
  }
}
