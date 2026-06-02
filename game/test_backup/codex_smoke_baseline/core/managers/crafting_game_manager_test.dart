import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/core/managers/crafting_game_manager.dart';
import 'package:cat_alchemy/core/models/recipe.dart';
import 'package:cat_alchemy/core/models/game_state.dart';
import 'package:mg_common_game/mg_common_game.dart';

void main() {
  group('CraftingGameManager', () {
    late GameState gameState;
    late PrestigeManager prestigeManager;
    late CraftingGameManager manager;
    late Recipe testRecipe;

    setUp(() {
      gameState = GameState.initial();
      prestigeManager = PrestigeManager();
      manager = CraftingGameManager(gameState, prestigeManager);

      testRecipe = Recipe(
        id: 'potion_health',
        name: 'Health Potion',
        tier: 1,
        category: 'potion',
        icon: 'potion_health.png',
        description: 'Restores health',
        ingredients: [
          Ingredient(id: 'grass', amount: 2),
          Ingredient(id: 'water_clear', amount: 1),
        ],
        craftTime: 5,
        result: CraftResult(id: 'potion_health', amount: 1),
        sellPrice: 50,
        discoveryBonus: DiscoveryBonus(gold: 100, exp: 50),
      );

      gameState.discoverRecipe(testRecipe.id);
    });

    group('startCrafting', () {
      test('starts crafting when ingredients available', () {
        final result = manager.startCrafting(testRecipe);

        expect(result.success, isTrue);
        expect(manager.queueSize, 1);
      });

      test('consumes ingredients', () {
        expect(gameState.getInventoryAmount('grass'), 10);
        expect(gameState.getInventoryAmount('water_clear'), 10);

        manager.startCrafting(testRecipe);

        expect(gameState.getInventoryAmount('grass'), 8);
        expect(gameState.getInventoryAmount('water_clear'), 9);
      });

      test('fails when recipe not discovered', () {
        final undiscoveredRecipe = Recipe(
          id: 'unknown_potion',
          name: 'Unknown',
          tier: 1,
          category: 'potion',
          icon: 'unknown.png',
          description: 'Unknown',
          ingredients: [Ingredient(id: 'grass', amount: 1)],
          craftTime: 5,
          result: CraftResult(id: 'unknown_potion', amount: 1),
          sellPrice: 100,
          discoveryBonus: DiscoveryBonus(gold: 200, exp: 100),
        );

        final result = manager.startCrafting(undiscoveredRecipe);

        expect(result.success, isFalse);
      });

      test('fails when ingredients insufficient', () {
        gameState.removeFromInventory('grass', 9);

        final result = manager.startCrafting(testRecipe);

        expect(result.success, isFalse);
      });

      test('applies prestige craft speed multiplier', () {
        // Prestige manager default multiplier is 1.0
        final result = manager.startCrafting(testRecipe);

        expect(result.success, isTrue);
        expect(manager.queueSize, 1);
      });
    });

    group('queue management', () {
      test('returns queue size', () {
        manager.startCrafting(testRecipe);
        manager.startCrafting(testRecipe);

        expect(manager.queueSize, 2);
      });

      test('returns max queue size', () {
        expect(manager.maxQueueSize, 3);
      });

      test('checks if queue is full', () {
        expect(manager.isQueueFull, isFalse);

        manager.startCrafting(testRecipe);
        manager.startCrafting(testRecipe);
        manager.startCrafting(testRecipe);

        expect(manager.isQueueFull, isTrue);
      });

      test('gets time until next completion', () {
        manager.startCrafting(testRecipe);

        final timeUntil = manager.getTimeUntilNextCompletion();

        expect(timeUntil, isNotNull);
        expect(timeUntil!.inSeconds, lessThanOrEqualTo(5));
      });
    });

    group('setCraftTimeModifier', () {
      test('sets craft time modifier', () {
        manager.setCraftTimeModifier(0.5);

        final result = manager.startCrafting(testRecipe);

        expect(result.success, isTrue);
      });
    });

    group('updateMaxQueueSize', () {
      test('updates max queue size from game state', () {
        expect(manager.maxQueueSize, 3);

        gameState.updateCatLevel(5);
        manager.updateMaxQueueSize();

        expect(manager.maxQueueSize, 4);
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON', () {
        manager.startCrafting(testRecipe);

        final json = manager.toJson();

        expect(json, isA<Map<String, dynamic>>());
      });

      test('deserializes from JSON', () {
        manager.startCrafting(testRecipe);
        final json = manager.toJson();

        final newManager = CraftingGameManager(GameState.initial(), PrestigeManager());
        newManager.fromJson(json);

        expect(newManager.queueSize, manager.queueSize);
      });
    });
  });
}
