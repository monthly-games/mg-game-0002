import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/core/managers/idle_production_manager.dart';
import 'package:cat_alchemy/core/models/material.dart';
import 'package:cat_alchemy/core/models/game_state.dart';

void main() {
  group('IdleProductionManager', () {
    late GameState gameState;
    late IdleProductionManager manager;
    late List<Material> testMaterials;

    setUp(() {
      gameState = GameState.initial();
      manager = IdleProductionManager(gameState);

      testMaterials = [
        Material(
          id: 'grass',
          name: 'Grass',
          tier: 1,
          icon: 'grass.png',
          description: 'Grass',
          productionRate: 2.0, // 2 per hour
          maxStorage: 100,
          category: 'plant',
        ),
        Material(
          id: 'water_clear',
          name: 'Clear Water',
          tier: 1,
          icon: 'water.png',
          description: 'Water',
          productionRate: 1.5, // 1.5 per hour
          maxStorage: 100,
          category: 'liquid',
        ),
        Material(
          id: 'stone',
          name: 'Stone',
          tier: 1,
          icon: 'stone.png',
          description: 'Stone',
          productionRate: 1.0, // 1 per hour
          maxStorage: 50,
          category: 'mineral',
        ),
        Material(
          id: 'special_item',
          name: 'Special Item',
          tier: 3,
          icon: 'special.png',
          description: 'Special',
          productionRate: 0.0, // Not idle produced
          maxStorage: 10,
          category: 'special',
        ),
      ];
    });

    group('initializeResources', () {
      test('registers idle-produced materials', () {
        manager.initializeResources(testMaterials);

        final resources = manager.getAllResources();

        expect(resources.containsKey('grass'), isTrue);
        expect(resources.containsKey('water_clear'), isTrue);
        expect(resources.containsKey('stone'), isTrue);
      });

      test('skips non-idle-produced materials', () {
        manager.initializeResources(testMaterials);

        final resources = manager.getAllResources();

        expect(resources.containsKey('special_item'), isFalse);
      });

      test('registers correct production rates', () {
        manager.initializeResources(testMaterials);

        final resources = manager.getAllResources();

        expect(resources['grass']!.baseProductionRate, 2.0);
        expect(resources['water_clear']!.baseProductionRate, 1.5);
        expect(resources['stone']!.baseProductionRate, 1.0);
      });

      test('registers correct max storage', () {
        manager.initializeResources(testMaterials);

        final resources = manager.getAllResources();

        expect(resources['grass']!.maxStorage, 100);
        expect(resources['water_clear']!.maxStorage, 100);
        expect(resources['stone']!.maxStorage, 50);
      });
    });

    group('setProductionModifier', () {
      test('sets modifier for specific material', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 1.5); // 50% boost

        final rate = manager.getProductionRate('grass');

        expect(rate, 3.0); // 2.0 * 1.5
      });

      test('applies different modifiers to different materials', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 2.0);
        manager.setProductionModifier('water_clear', 0.5);

        expect(manager.getProductionRate('grass'), 4.0); // 2.0 * 2.0
        expect(manager.getProductionRate('water_clear'), 0.75); // 1.5 * 0.5
      });

      test('handles zero modifier', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 0.0);

        expect(manager.getProductionRate('grass'), 0.0);
      });

      test('handles high modifiers', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 10.0);

        expect(manager.getProductionRate('grass'), 20.0);
      });
    });

    group('setGlobalMultiplier', () {
      test('applies global multiplier to all materials', () {
        manager.initializeResources(testMaterials);
        manager.setGlobalMultiplier(2.0); // 2x multiplier

        expect(manager.getProductionRate('grass'), 4.0); // 2.0 * 2.0
        expect(manager.getProductionRate('water_clear'), 3.0); // 1.5 * 2.0
        expect(manager.getProductionRate('stone'), 2.0); // 1.0 * 2.0
      });

      test('stacks with individual modifiers', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 1.5);
        manager.setGlobalMultiplier(2.0);

        // 2.0 * 1.5 * 2.0 = 6.0
        expect(manager.getProductionRate('grass'), 6.0);
      });

      test('handles zero global multiplier', () {
        manager.initializeResources(testMaterials);
        manager.setGlobalMultiplier(0.0);

        expect(manager.getProductionRate('grass'), 0.0);
        expect(manager.getProductionRate('water_clear'), 0.0);
      });
    });

    group('getProductionRate', () {
      test('returns correct rate for material', () {
        manager.initializeResources(testMaterials);

        expect(manager.getProductionRate('grass'), 2.0);
        expect(manager.getProductionRate('water_clear'), 1.5);
        expect(manager.getProductionRate('stone'), 1.0);
      });

      test('returns 0 for non-existent material', () {
        manager.initializeResources(testMaterials);

        expect(manager.getProductionRate('nonexistent'), 0.0);
      });

      test('returns 0 for non-idle-produced material', () {
        manager.initializeResources(testMaterials);

        expect(manager.getProductionRate('special_item'), 0.0);
      });
    });

    group('estimateProduction', () {
      test('estimates production for 1 hour', () {
        manager.initializeResources(testMaterials);

        final estimate = manager.estimateProduction('grass', Duration(hours: 1));

        expect(estimate, 2); // 2 per hour
      });

      test('estimates production for 8 hours', () {
        manager.initializeResources(testMaterials);

        final estimate = manager.estimateProduction('grass', Duration(hours: 8));

        expect(estimate, 16); // 2 * 8
      });

      test('estimates production for 30 minutes', () {
        manager.initializeResources(testMaterials);

        final estimate = manager.estimateProduction('grass', Duration(minutes: 30));

        expect(estimate, 1); // 2 * 0.5 = 1
      });

      test('applies modifiers to estimate', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 2.0);

        final estimate = manager.estimateProduction('grass', Duration(hours: 1));

        expect(estimate, 4); // (2.0 * 2.0) * 1 hour
      });

      test('applies global multiplier to estimate', () {
        manager.initializeResources(testMaterials);
        manager.setGlobalMultiplier(2.0);

        final estimate = manager.estimateProduction('grass', Duration(hours: 1));

        expect(estimate, 4); // (2.0 * 2.0) * 1 hour
      });

      test('returns 0 for non-existent material', () {
        manager.initializeResources(testMaterials);

        final estimate = manager.estimateProduction('nonexistent', Duration(hours: 1));

        expect(estimate, 0);
      });
    });

    group('calculateOfflineProduction', () {
      test('calculates rewards for offline time', () {
        manager.initializeResources(testMaterials);

        // Simulate 8 hours offline
        gameState.lastLoginTime = DateTime.now().subtract(Duration(hours: 8));

        final rewards = manager.calculateOfflineProduction();

        expect(rewards.containsKey('grass'), isTrue);
        expect(rewards['grass']!, greaterThan(0));
      });

      test('adds rewards to inventory', () {
        manager.initializeResources(testMaterials);

        final initialGrass = gameState.getInventoryAmount('grass');

        gameState.lastLoginTime = DateTime.now().subtract(Duration(hours: 8));
        manager.calculateOfflineProduction();

        final finalGrass = gameState.getInventoryAmount('grass');

        expect(finalGrass, greaterThan(initialGrass));
      });

      test('respects max storage limits', () {
        manager.initializeResources(testMaterials);

        // Add lots of grass to inventory
        gameState.addToInventory('grass', 95); // Now at 105 (exceeds 100 max)

        gameState.lastLoginTime = DateTime.now().subtract(Duration(hours: 8));
        manager.calculateOfflineProduction();

        // Should cap at max storage
        final finalAmount = gameState.getInventoryAmount('grass');
        expect(finalAmount, lessThanOrEqualTo(100));
      });

      test('handles multiple materials', () {
        manager.initializeResources(testMaterials);

        gameState.lastLoginTime = DateTime.now().subtract(Duration(hours: 8));
        final rewards = manager.calculateOfflineProduction();

        expect(rewards.containsKey('grass'), isTrue);
        expect(rewards.containsKey('water_clear'), isTrue);
        expect(rewards.containsKey('stone'), isTrue);
      });

      test('returns empty map for no offline time', () {
        manager.initializeResources(testMaterials);

        gameState.lastLoginTime = DateTime.now();
        final rewards = manager.calculateOfflineProduction();

        // Should have minimal or no rewards
        expect(rewards.isEmpty, isTrue);
      });

      test('handles 24+ hour offline time', () {
        manager.initializeResources(testMaterials);

        gameState.lastLoginTime = DateTime.now().subtract(Duration(days: 1));
        final rewards = manager.calculateOfflineProduction();

        expect(rewards.containsKey('grass'), isTrue);
        expect(rewards['grass']!, 16); // Capped at 8 hours: 2 * 8
      });
    });

    group('getAllResources', () {
      test('returns all registered resources', () {
        manager.initializeResources(testMaterials);

        final resources = manager.getAllResources();

        expect(resources.length, 3); // grass, water_clear, stone
        expect(resources.containsKey('grass'), isTrue);
        expect(resources.containsKey('water_clear'), isTrue);
        expect(resources.containsKey('stone'), isTrue);
      });

      test('returns empty map before initialization', () {
        final resources = manager.getAllResources();

        expect(resources, isEmpty);
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 1.5);
        manager.setGlobalMultiplier(2.0);

        final json = manager.toJson();

        expect(json, isA<Map<String, dynamic>>());
      });

      test('deserializes from JSON', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 1.5);
        manager.setGlobalMultiplier(2.0);

        final json = manager.toJson();

        final newManager = IdleProductionManager(GameState.initial());
        newManager.fromJson(json);

        // Verify state is restored
        expect(newManager.getProductionRate('grass'), 6.0); // 2.0 * 1.5 * 2.0
      });

      test('round-trip serialization preserves data', () {
        manager.initializeResources(testMaterials);
        manager.setProductionModifier('grass', 1.5);
        manager.setGlobalMultiplier(2.0);

        final json1 = manager.toJson();

        final newManager = IdleProductionManager(GameState.initial());
        newManager.fromJson(json1);
        final json2 = newManager.toJson();

        expect(json1, json2);
      });
    });

    group('offline reward cap (8 hours)', () {
      test('caps offline rewards at 8 hours', () {
        manager.initializeResources(testMaterials);

        // Simulate 24 hours offline
        gameState.lastLoginTime = DateTime.now().subtract(Duration(hours: 24));

        final rewards = manager.calculateOfflineProduction();

        // Should be capped at 8 hours worth
        // grass: 2 per hour * 8 = 16
        expect(rewards['grass'], lessThanOrEqualTo(16));
      });

      test('allows full rewards for less than 8 hours', () {
        manager.initializeResources(testMaterials);

        // Simulate 4 hours offline
        gameState.lastLoginTime = DateTime.now().subtract(Duration(hours: 4));

        final rewards = manager.calculateOfflineProduction();

        // grass: 2 per hour * 4 = 8
        expect(rewards['grass'], 8);
      });

      test('handles exactly 8 hours offline', () {
        manager.initializeResources(testMaterials);

        gameState.lastLoginTime = DateTime.now().subtract(Duration(hours: 8));

        final rewards = manager.calculateOfflineProduction();

        // grass: 2 per hour * 8 = 16
        expect(rewards['grass'], 16);
      });
    });

    group('production with modifiers', () {
      test('combines individual and global modifiers correctly', () {
        manager.initializeResources(testMaterials);

        manager.setProductionModifier('grass', 1.5); // 50% boost
        manager.setGlobalMultiplier(2.0); // 2x global

        // Expected: 2.0 * 1.5 * 2.0 = 6.0
        expect(manager.getProductionRate('grass'), 6.0);

        final estimate = manager.estimateProduction('grass', Duration(hours: 1));
        expect(estimate, 6);
      });

      test('handles zero individual modifier', () {
        manager.initializeResources(testMaterials);

        manager.setProductionModifier('grass', 0.0);
        manager.setGlobalMultiplier(2.0);

        expect(manager.getProductionRate('grass'), 0.0);
      });

      test('handles zero global multiplier', () {
        manager.initializeResources(testMaterials);

        manager.setProductionModifier('grass', 2.0);
        manager.setGlobalMultiplier(0.0);

        expect(manager.getProductionRate('grass'), 0.0);
      });
    });
  });
}
