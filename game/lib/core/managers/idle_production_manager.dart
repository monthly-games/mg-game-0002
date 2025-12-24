import 'package:mg_common_game/mg_common_game.dart';
import '../models/material.dart';
import '../models/game_state.dart';

/// Manages idle production for materials
class IdleProductionManager {
  final IdleManager _idleManager;
  final GameState _gameState;

  IdleProductionManager(this._gameState) : _idleManager = IdleManager();

  /// Initialize idle resources from material data
  void initializeResources(List<Material> materials) {
    for (final material in materials) {
      if (material.isIdleProduced) {
        _idleManager.registerResource(
          IdleResource(
            id: material.id,
            name: material.name,
            tier: material.tier,
            baseProductionRate: material.productionRate,
            maxStorage: material.maxStorage,
          ),
        );
      }
    }
  }

  /// Set production modifier for a material (from upgrades, cat skills)
  void setProductionModifier(String materialId, double modifier) {
    _idleManager.setProductionModifier(materialId, modifier);
  }

  /// Set global production multiplier (from workshop level)
  void setGlobalMultiplier(double multiplier) {
    _idleManager.setGlobalModifier(multiplier);
  }

  /// Calculate and apply offline production rewards
  Map<String, int> calculateOfflineProduction() {
    final offlineTime = DateTime.now().difference(_gameState.lastLoginTime);
    final rewards = _idleManager.calculateOfflineRewards(offlineTime);

    // Add rewards to inventory
    for (final entry in rewards.entries) {
      _gameState.addToInventory(entry.key, entry.value);
    }

    return rewards;
  }

  /// Get current production rate for a material (items per hour)
  double getProductionRate(String materialId) {
    return _idleManager.getProductionRate(materialId);
  }

  /// Get estimated production for next duration
  int estimateProduction(String materialId, Duration duration) {
    final resource = _idleManager.getResource(materialId);
    if (resource == null) return 0;

    final modifier = _idleManager.getProductionModifier(materialId);
    return resource.calculateProduction(
      duration,
      modifier: modifier * _idleManager.globalModifier,
    );
  }

  /// Get all idle resources
  Map<String, IdleResource> getAllResources() {
    return _idleManager.resources;
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return _idleManager.toJson();
  }

  /// Deserialize from JSON
  void fromJson(Map<String, dynamic> json) {
    _idleManager.fromJson(json);
  }
}
