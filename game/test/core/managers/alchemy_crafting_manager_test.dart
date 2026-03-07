import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/core/managers/alchemy_crafting_manager.dart';
import 'package:cat_alchemy/core/models/recipe.dart';
import 'package:cat_alchemy/core/models/game_state.dart';

void main() {
  group('AlchemyCraftingManager', () {
    late GameState gameState;
    late AlchemyCraftingManager manager;
    late Recipe testRecipe;

    setUp(() {
      gameState = GameState.initial();
      manager = AlchemyCraftingManager(gameState);

      // Create test recipe
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

      // Discover recipe
      gameState.discoverRecipe(testRecipe.id);
    });

    group('startCrafting', () {
      test('queues crafting job when ingredients available', () {
        expect(gameState.getInventoryAmount('grass'), 10);
        expect(gameState.getInventoryAmount('water_clear'), 10);

        final result = manager.startCrafting(testRecipe);

        expect(result.success, isTrue);
        expect(result.jobId, isNotNull);
        expect(manager.queueSize, 1);
        expect(gameState.getInventoryAmount('grass'), 8); // 10 - 2
        expect(gameState.getInventoryAmount('water_clear'), 9); // 10 - 1
      });

      test('fails when recipe not discovered', () {
        final undiscoveredRecipe = Recipe(
          id: 'unknown_potion',
          name: 'Unknown Potion',
          tier: 2,
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
        expect(result.message, 'Recipe not discovered');
      });

      test('fails when ingredients insufficient', () {
        gameState.removeFromInventory('grass', 9); // Leave only 1

        final result = manager.startCrafting(testRecipe);

        expect(result.success, isFalse);
        expect(result.message, 'Not enough ingredients');
      });

      test('fails when queue is full', () {
        manager.updateMaxQueueSize();
        final maxSize = manager.maxQueueSize;

        // Fill queue
        for (int i = 0; i < maxSize; i++) {
          final result = manager.startCrafting(testRecipe);
          expect(result.success, isTrue);
        }

        // Try to add one more
        final result = manager.startCrafting(testRecipe);
        expect(result.success, isFalse);
        expect(result.message, 'Crafting queue is full');
      });

      test('applies craft time modifier', () {
        manager.setCraftTimeModifier(0.5); // 50% faster

        final result = manager.startCrafting(testRecipe);
        expect(result.success, isTrue);

        final job = manager.queue.first;
        // Original: 5 seconds, with 0.5 modifier: 2.5 seconds
        expect(job.craftDuration.inMilliseconds, 2500);
      });
    });

    group('collectCompleted', () {
      test('returns null when job not completed', () {
        final result = manager.startCrafting(testRecipe);
        expect(result.success, isTrue);

        final jobId = result.jobId!;
        final collected = manager.collectCompleted(jobId);

        expect(collected, isNull);
      });

      test('collects completed job with quality', () async {
        final result = manager.startCrafting(testRecipe);
        expect(result.success, isTrue);

        final jobId = result.jobId!;

        // Wait for completion
        await Future.delayed(Duration(seconds: 6));

        final collected = manager.collectCompleted(jobId);

        expect(collected, isNotNull);
        expect(collected!.success, isTrue);
        expect(collected.quality, isNotNull);
        expect(manager.queueSize, 0);
      });

      test('quality affects output amount', () async {
        manager.setLuckModifier(0.0); // No luck modifier

        final result = manager.startCrafting(testRecipe);
        final jobId = result.jobId!;

        await Future.delayed(Duration(seconds: 6));

        final collected = manager.collectCompleted(jobId);

        expect(collected, isNotNull);
        final quality = collected!.quality;
        final amount = collected.outputAmount!;

        if (quality == CraftQuality.critical) {
          expect(amount, 2); // 1 * 1.5 = 1.5 ceil = 2
        } else if (quality == CraftQuality.normal) {
          expect(amount, 1);
        } else if (quality == CraftQuality.failure) {
          expect(amount, 1); // max(1 * 0.5 floor, 1) = 1
        }
      });

      test('adds crafted items to inventory', () async {
        final result = manager.startCrafting(testRecipe);
        final jobId = result.jobId!;

        expect(gameState.getInventoryAmount('potion_health'), 0);

        await Future.delayed(Duration(seconds: 6));

        manager.collectCompleted(jobId);

        expect(gameState.getInventoryAmount('potion_health'), greaterThan(0));
      });
    });

    group('collectAllCompleted', () {
      test('collects all completed jobs', () async {
        // Queue 2 jobs
        final result1 = manager.startCrafting(testRecipe);
        final result2 = manager.startCrafting(testRecipe);

        expect(manager.queueSize, 2);

        await Future.delayed(Duration(seconds: 6));

        final results = manager.collectAllCompleted();

        expect(results.length, 2);
        expect(manager.queueSize, 0);
      });

      test('only collects completed jobs', () async {
        final result1 = manager.startCrafting(testRecipe);

        // Create second recipe with longer duration
        final longRecipe = Recipe(
          id: 'potion_mana',
          name: 'Mana Potion',
          tier: 2,
          category: 'potion',
          icon: 'potion_mana.png',
          description: 'Restores mana',
          ingredients: [Ingredient(id: 'grass', amount: 1)],
          craftTime: 30,
          result: CraftResult(id: 'potion_mana', amount: 1),
          sellPrice: 100,
          discoveryBonus: DiscoveryBonus(gold: 200, exp: 100),
        );
        gameState.discoverRecipe(longRecipe.id);

        final result2 = manager.startCrafting(longRecipe);

        expect(manager.queueSize, 2);

        await Future.delayed(Duration(seconds: 6));

        final results = manager.collectAllCompleted();

        // Only first job should be completed
        expect(results.length, 1);
        expect(manager.queueSize, 1);
      });
    });

    group('processOfflineCrafting', () {
      test('completes jobs that finished offline', () async {
        final result = manager.startCrafting(testRecipe);
        final jobId = result.jobId!;

        // Simulate offline time
        gameState.lastLoginTime = DateTime.now().subtract(Duration(seconds: 10));

        final results = manager.processOfflineCrafting(gameState.lastLoginTime);

        expect(results.length, 1);
        expect(manager.queueSize, 0);
      });

      test('adds offline rewards to inventory', () async {
        final result = manager.startCrafting(testRecipe);

        gameState.lastLoginTime = DateTime.now().subtract(Duration(seconds: 10));

        final initialAmount = gameState.getInventoryAmount('potion_health');

        manager.processOfflineCrafting(gameState.lastLoginTime);

        final finalAmount = gameState.getInventoryAmount('potion_health');
        expect(finalAmount, greaterThan(initialAmount));
      });
    });

    group('cancelJob', () {
      test('cancels job and refunds ingredients', () {
        final result = manager.startCrafting(testRecipe);
        final jobId = result.jobId!;

        expect(gameState.getInventoryAmount('grass'), 8);
        expect(gameState.getInventoryAmount('water_clear'), 9);

        final cancelled = manager.cancelJob(jobId, testRecipe);

        expect(cancelled, isTrue);
        expect(manager.queueSize, 0);
        expect(gameState.getInventoryAmount('grass'), 10);
        expect(gameState.getInventoryAmount('water_clear'), 10);
      });

      test('returns false for non-existent job', () {
        final cancelled = manager.cancelJob('non_existent', testRecipe);
        expect(cancelled, isFalse);
      });
    });

    group('instantComplete', () {
      test('instantly completes job', () {
        final result = manager.startCrafting(testRecipe);
        final jobId = result.jobId!;

        expect(manager.queueSize, 1);

        final completed = manager.instantComplete(jobId);

        expect(completed, isNotNull);
        expect(completed!.success, isTrue);
        expect(manager.queueSize, 0);
      });

      test('adds items to inventory', () {
        final result = manager.startCrafting(testRecipe);
        final jobId = result.jobId!;

        expect(gameState.getInventoryAmount('potion_health'), 0);

        manager.instantComplete(jobId);

        expect(gameState.getInventoryAmount('potion_health'), greaterThan(0));
      });
    });

    group('luck modifier', () {
      test('increases critical chance', () {
        manager.setLuckModifier(1.0); // +5% critical per luck point

        // Run multiple crafts to check distribution
        int criticalCount = 0;
        for (int i = 0; i < 10; i++) {
          final result = manager.startCrafting(testRecipe);
          if (result.success) {
            final job = manager.queue.last;
            job.calculateQuality(1.0);
            if (job.quality == CraftQuality.critical) {
              criticalCount++;
            }
          }
        }

        // With luck modifier, should have more criticals
        expect(criticalCount, greaterThan(0));
      });

      test('reduces failure chance', () {
        manager.setLuckModifier(1.0);

        int failureCount = 0;
        for (int i = 0; i < 10; i++) {
          final result = manager.startCrafting(testRecipe);
          if (result.success) {
            final job = manager.queue.last;
            job.calculateQuality(1.0);
            if (job.quality == CraftQuality.failure) {
              failureCount++;
            }
          }
        }

        // With luck modifier, should have fewer failures
        expect(failureCount, lessThan(2)); // At least 5% minimum
      });
    });

    group('queue management', () {
      test('returns unmodifiable queue', () {
        manager.startCrafting(testRecipe);

        final queue = manager.queue;
        expect(() => queue.add(AlchemyCraftingJob(
          id: 'test',
          recipeId: 'test',
          startTime: DateTime.now(),
          craftDuration: Duration(seconds: 5),
          baseResult: {'test': 1},
        )), throwsUnsupportedError);
      });

      test('getCompletedJobs returns only completed', () async {
        manager.startCrafting(testRecipe);

        await Future.delayed(Duration(seconds: 6));

        final completed = manager.getCompletedJobs();
        expect(completed.length, 1);
      });

      test('getTimeUntilNextCompletion returns correct duration', () {
        manager.startCrafting(testRecipe);

        final timeUntil = manager.getTimeUntilNextCompletion();
        expect(timeUntil, isNotNull);
        expect(timeUntil!.inSeconds, lessThanOrEqualTo(5));
      });

      test('getTimeUntilNextCompletion returns null when queue empty', () {
        final timeUntil = manager.getTimeUntilNextCompletion();
        expect(timeUntil, isNull);
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON', () {
        manager.startCrafting(testRecipe);

        final json = manager.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['queue'], isA<List>());
        expect(json['maxQueueSize'], isA<int>());
        expect(json['luckModifier'], isA<double>());
        expect(json['craftTimeModifier'], isA<double>());
      });

      test('deserializes from JSON', () {
        manager.startCrafting(testRecipe);
        final originalJson = manager.toJson();

        final newManager = AlchemyCraftingManager(GameState.initial());
        newManager.fromJson(originalJson);

        expect(newManager.queueSize, manager.queueSize);
        expect(newManager.maxQueueSize, manager.maxQueueSize);
      });
    });
  });
}
