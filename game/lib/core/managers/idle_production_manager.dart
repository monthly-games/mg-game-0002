import 'package:mg_common_game/mg_common_game.dart' hide GameState;
import '../models/material.dart';
import '../models/game_state.dart';

/// Manages idle production for materials
class IdleProductionManager {
  final IdleManager _idleManager;
  final GameState _gameState;

  IdleProductionManager(this._gameState) : _idleManager = IdleManager() {
    _idleManager.clear();
  }

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
    final adjustedRewards = <String, int>{};

    // Add rewards to inventory
    for (final entry in rewards.entries) {
      final resource = _idleManager.getResource(entry.key);
      if (resource == null) {
        _gameState.addToInventory(entry.key, entry.value);
        adjustedRewards[entry.key] = entry.value;
        continue;
      }

      final maxStorage = resource.maxStorage;
      final currentAmount = _gameState.getInventoryAmount(entry.key);

      if (currentAmount > maxStorage) {
        _gameState.inventory[entry.key] = maxStorage;
      }

      final clampedCurrent = _gameState.getInventoryAmount(entry.key);
      final addable = (maxStorage - clampedCurrent).clamp(0, entry.value);

      if (addable > 0) {
        _gameState.addToInventory(entry.key, addable);
      }

      adjustedRewards[entry.key] = addable;
    }

    return adjustedRewards;
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
    final json = _idleManager.toJson();
    json['productionModifiers'] = {
      for (final id in _idleManager.resources.keys)
        id: _idleManager.getProductionModifier(id),
    };
    return json;
  }

  /// Deserialize from JSON
  void fromJson(Map<String, dynamic> json) {
    _idleManager.fromJson(json);

    final modifiersJson = json['productionModifiers'];
    if (modifiersJson is Map) {
      for (final entry in modifiersJson.entries) {
        _idleManager.setProductionModifier(
          entry.key as String,
          (entry.value as num).toDouble(),
        );
      }
    }
  }
}
