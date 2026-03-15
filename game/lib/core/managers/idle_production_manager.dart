import 'package:mg_common_game/mg_common_game.dart';
import '../models/material.dart';
import '../models/game_state.dart';

/// Manages idle production for materials
///
/// Uses inline resource management (migrated from deprecated IdleManager).
class IdleProductionManager {
  final Map<String, IdleResource> _resources = {};
  final Map<String, double> _resourceModifiers = {};
  double _globalModifier = 1.0;
  final GameState _gameState;

  static const double maxOfflineHours = 8.0;

  IdleProductionManager(this._gameState);

  /// Initialize idle resources from material data
  void initializeResources(List<Material> materials) {
    for (final material in materials) {
      if (material.isIdleProduced) {
        _resources[material.id] = IdleResource(
          id: material.id,
          name: material.name,
          tier: material.tier,
          baseProductionRate: material.productionRate,
          maxStorage: material.maxStorage,
        );
      }
    }
  }

  /// Set production modifier for a material (from upgrades, cat skills)
  void setProductionModifier(String materialId, double modifier) {
    _resourceModifiers[materialId] = modifier;
  }

  /// Set global production multiplier (from workshop level)
  void setGlobalMultiplier(double multiplier) {
    _globalModifier = multiplier;
  }

  double _getProductionModifier(String resourceId) {
    return _resourceModifiers[resourceId] ?? 1.0;
  }

  double _getTotalModifier(String resourceId) {
    return _globalModifier * _getProductionModifier(resourceId);
  }

  /// Calculate and apply offline production rewards
  Map<String, int> calculateOfflineProduction() {
    final offlineTime = DateTime.now().difference(_gameState.lastLoginTime);
    final cappedHours =
        (offlineTime.inSeconds / 3600.0).clamp(0.0, maxOfflineHours);
    final cappedDuration = Duration(seconds: (cappedHours * 3600).toInt());

    final rewards = <String, int>{};
    for (final resource in _resources.values) {
      if (!resource.isProducing) continue;
      final produced = resource.calculateProduction(
        cappedDuration,
        modifier: _getTotalModifier(resource.id),
      );
      if (produced > 0) {
        final added = resource.addProduction(produced);
        rewards[resource.id] = added;
      }
    }
    for (final resource in _resources.values) {
      resource.updateTime();
    }

    final adjustedRewards = <String, int>{};
    for (final entry in rewards.entries) {
      final resource = _resources[entry.key];
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
    final resource = _resources[materialId];
    if (resource == null) return 0.0;
    return resource.getProductionRate(_globalModifier);
  }

  /// Get estimated production for next duration
  int estimateProduction(String materialId, Duration duration) {
    final resource = _resources[materialId];
    if (resource == null) return 0;

    final modifier = _getProductionModifier(materialId);
    return resource.calculateProduction(
      duration,
      modifier: modifier * _globalModifier,
    );
  }

  /// Get all idle resources
  Map<String, IdleResource> getAllResources() {
    return _resources;
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'resources':
          _resources.map((key, value) => MapEntry(key, value.toJson())),
      'globalModifier': _globalModifier,
      'productionModifiers': {
        for (final id in _resources.keys) id: _getProductionModifier(id),
      },
    };
  }

  /// Deserialize from JSON
  void fromJson(Map<String, dynamic> json) {
    if (json['globalModifier'] != null) {
      _globalModifier = (json['globalModifier'] as num).toDouble();
    }

    if (json['resources'] != null) {
      final resourcesJson = json['resources'] as Map<String, dynamic>;
      for (final entry in resourcesJson.entries) {
        final resource = _resources[entry.key];
        if (resource != null) {
          final stateJson = entry.value as Map<String, dynamic>;
          resource.currentAmount = stateJson['currentAmount'] as int? ?? 0;
          resource.lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(
            stateJson['lastUpdateTime'] as int? ??
                DateTime.now().millisecondsSinceEpoch,
          );
          resource.isProducing = stateJson['isProducing'] as bool? ?? true;
        }
      }
    }

    final modifiersJson = json['productionModifiers'];
    if (modifiersJson is Map) {
      for (final entry in modifiersJson.entries) {
        _resourceModifiers[entry.key as String] =
            (entry.value as num).toDouble();
      }
    }
  }
}
