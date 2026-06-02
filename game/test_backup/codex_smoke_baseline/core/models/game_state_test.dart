import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/core/models/game_state.dart';

void main() {
  group('GameState Model', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState.initial();
    });

    group('initial state', () {
      test('creates initial state with default values', () {
        expect(gameState.gold, 500);
        expect(gameState.gems, 50);
        expect(gameState.workshopLevel, 1);
        expect(gameState.reputation, 0);
        expect(gameState.playerExp, 0);
        expect(gameState.tutorialCompleted, isFalse);
      });

      test('has starting inventory', () {
        expect(gameState.getInventoryAmount('grass'), 10);
        expect(gameState.getInventoryAmount('water_clear'), 10);
        expect(gameState.getInventoryAmount('stone'), 5);
        expect(gameState.getInventoryAmount('branch'), 5);
      });

      test('has initial cat state', () {
        expect(gameState.catTrust, 0);
        expect(gameState.catLevel, 1);
        expect(gameState.petToday, 0);
        expect(gameState.playToday, 0);
      });

      test('has empty discovered recipes', () {
        expect(gameState.discoveredRecipes, isEmpty);
      });

      test('has empty crafting queue', () {
        expect(gameState.craftingQueue, isEmpty);
      });
    });

    group('inventory management', () {
      test('getInventoryAmount returns 0 for missing item', () {
        expect(gameState.getInventoryAmount('nonexistent'), 0);
      });

      test('addToInventory adds items', () {
        gameState.addToInventory('grass', 5);

        expect(gameState.getInventoryAmount('grass'), 15);
      });

      test('addToInventory creates new item', () {
        gameState.addToInventory('new_item', 10);

        expect(gameState.getInventoryAmount('new_item'), 10);
      });

      test('removeFromInventory removes items', () {
        expect(gameState.removeFromInventory('grass', 5), isTrue);
        expect(gameState.getInventoryAmount('grass'), 5);
      });

      test('removeFromInventory returns false when insufficient', () {
        expect(gameState.removeFromInventory('grass', 20), isFalse);
        expect(gameState.getInventoryAmount('grass'), 10);
      });

      test('removeFromInventory deletes item when amount reaches 0', () {
        gameState.removeFromInventory('grass', 10);

        expect(gameState.inventory.containsKey('grass'), isFalse);
      });

      test('removeFromInventory returns false for missing item', () {
        expect(gameState.removeFromInventory('nonexistent', 1), isFalse);
      });

      test('inventory map is mutable', () {
        gameState.inventory['custom_item'] = 100;

        expect(gameState.getInventoryAmount('custom_item'), 100);
      });
    });

    group('recipe discovery', () {
      test('isRecipeDiscovered returns false initially', () {
        expect(gameState.isRecipeDiscovered('potion_health'), isFalse);
      });

      test('discoverRecipe adds recipe', () {
        gameState.discoverRecipe('potion_health');

        expect(gameState.isRecipeDiscovered('potion_health'), isTrue);
      });

      test('discoverRecipe does not add duplicates', () {
        gameState.discoverRecipe('potion_health');
        gameState.discoverRecipe('potion_health');

        expect(gameState.discoveredRecipes.length, 1);
      });

      test('can discover multiple recipes', () {
        gameState.discoverRecipe('potion_health');
        gameState.discoverRecipe('potion_mana');
        gameState.discoverRecipe('bomb_fire');

        expect(gameState.discoveredRecipes.length, 3);
        expect(gameState.isRecipeDiscovered('potion_health'), isTrue);
        expect(gameState.isRecipeDiscovered('potion_mana'), isTrue);
        expect(gameState.isRecipeDiscovered('bomb_fire'), isTrue);
      });
    });

    group('cat trust and level', () {
      test('catTrust returns initial value', () {
        expect(gameState.catTrust, 0);
      });

      test('catLevel returns initial value', () {
        expect(gameState.catLevel, 1);
      });

      test('addCatTrust increases trust', () {
        gameState.addCatTrust(50);

        expect(gameState.catTrust, 50);
      });

      test('addCatTrust accumulates', () {
        gameState.addCatTrust(50);
        gameState.addCatTrust(30);

        expect(gameState.catTrust, 80);
      });

      test('updateCatLevel changes level', () {
        gameState.updateCatLevel(5);

        expect(gameState.catLevel, 5);
      });

      test('updateCatLevel overwrites previous level', () {
        gameState.updateCatLevel(5);
        gameState.updateCatLevel(3);

        expect(gameState.catLevel, 3);
      });
    });

    group('daily interactions', () {
      test('petToday returns initial value', () {
        expect(gameState.petToday, 0);
      });

      test('playToday returns initial value', () {
        expect(gameState.playToday, 0);
      });

      test('incrementPetCount increases pet count', () {
        gameState.incrementPetCount();

        expect(gameState.petToday, 1);
      });

      test('incrementPetCount accumulates', () {
        gameState.incrementPetCount();
        gameState.incrementPetCount();
        gameState.incrementPetCount();

        expect(gameState.petToday, 3);
      });

      test('incrementPlayCount increases play count', () {
        gameState.incrementPlayCount();

        expect(gameState.playToday, 1);
      });

      test('incrementPlayCount accumulates', () {
        gameState.incrementPlayCount();
        gameState.incrementPlayCount();

        expect(gameState.playToday, 2);
      });

      test('incrementPetCount updates lastPetTime', () {
        final before = DateTime.now();
        gameState.incrementPetCount();
        final after = DateTime.now();

        final lastPetTime = DateTime.fromMillisecondsSinceEpoch(
          gameState.catState['lastPetTime'] as int,
        );

        expect(lastPetTime.isAfter(before.subtract(Duration(seconds: 1))), isTrue);
        expect(lastPetTime.isBefore(after.add(Duration(seconds: 1))), isTrue);
      });
    });

    group('daily reset', () {
      test('resetDailyCounters clears pet and play counts', () {
        gameState.incrementPetCount();
        gameState.incrementPlayCount();

        gameState.resetDailyCounters();

        expect(gameState.petToday, 0);
        expect(gameState.playToday, 0);
      });

      test('resetDailyCounters clears daily interactions', () {
        gameState.dailyInteractions['pet'] = 5;
        gameState.dailyInteractions['play'] = 3;

        gameState.resetDailyCounters();

        expect(gameState.dailyInteractions, isEmpty);
      });

      test('isNewDay returns false for same day', () {
        gameState.lastLoginTime = DateTime.now();

        expect(gameState.isNewDay(), isFalse);
      });

      test('isNewDay returns true for different day', () {
        gameState.lastLoginTime = DateTime.now().subtract(Duration(days: 1));

        expect(gameState.isNewDay(), isTrue);
      });

      test('isNewDay returns true for different month', () {
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        gameState.lastLoginTime = lastMonth;

        expect(gameState.isNewDay(), isTrue);
      });

      test('isNewDay returns true for different year', () {
        final now = DateTime.now();
        final lastYear = DateTime(now.year - 1, now.month, now.day);
        gameState.lastLoginTime = lastYear;

        expect(gameState.isNewDay(), isTrue);
      });
    });

    group('login time', () {
      test('updateLastLoginTime sets current time', () {
        final before = DateTime.now();
        gameState.updateLastLoginTime();
        final after = DateTime.now();

        expect(gameState.lastLoginTime.isAfter(before.subtract(Duration(seconds: 1))), isTrue);
        expect(gameState.lastLoginTime.isBefore(after.add(Duration(seconds: 1))), isTrue);
      });

      test('getOfflineHours calculates correct duration', () {
        gameState.lastLoginTime = DateTime.now().subtract(Duration(hours: 8));

        final offlineHours = gameState.getOfflineHours();

        expect(offlineHours, greaterThanOrEqualTo(7.9));
        expect(offlineHours, lessThanOrEqualTo(8.1));
      });

      test('getOfflineHours returns 0 for recent login', () {
        gameState.lastLoginTime = DateTime.now();

        final offlineHours = gameState.getOfflineHours();

        expect(offlineHours, lessThan(0.01));
      });

      test('getOfflineHours handles long offline time', () {
        gameState.lastLoginTime = DateTime.now().subtract(Duration(days: 1));

        final offlineHours = gameState.getOfflineHours();

        expect(offlineHours, greaterThan(23));
        expect(offlineHours, lessThan(25));
      });
    });

    group('crafting queue', () {
      test('craftingQueueSize returns 0 initially', () {
        expect(gameState.craftingQueueSize, 0);
      });

      test('getMaxCraftingQueueSize returns base size', () {
        expect(gameState.getMaxCraftingQueueSize(), 3);
      });

      test('getMaxCraftingQueueSize increases with cat level', () {
        gameState.updateCatLevel(5);

        expect(gameState.getMaxCraftingQueueSize(), 4); // 3 + 1
      });

      test('getMaxCraftingQueueSize increases with workshop level', () {
        gameState.workshopLevel = 6;

        expect(gameState.getMaxCraftingQueueSize(), 4); // 3 + 1
      });

      test('getMaxCraftingQueueSize stacks bonuses', () {
        gameState.updateCatLevel(5);
        gameState.workshopLevel = 6;

        expect(gameState.getMaxCraftingQueueSize(), 5); // 3 + 1 + 1
      });

      test('canAddToCraftingQueue returns true when space available', () {
        expect(gameState.canAddToCraftingQueue(), isTrue);
      });

      test('canAddToCraftingQueue returns false when full', () {
        gameState.craftingQueue.add({'id': '1'});
        gameState.craftingQueue.add({'id': '2'});
        gameState.craftingQueue.add({'id': '3'});

        expect(gameState.canAddToCraftingQueue(), isFalse);
      });

      test('canAddToCraftingQueue respects max queue size', () {
        gameState.updateCatLevel(5); // Max size = 4

        gameState.craftingQueue.add({'id': '1'});
        gameState.craftingQueue.add({'id': '2'});
        gameState.craftingQueue.add({'id': '3'});
        gameState.craftingQueue.add({'id': '4'});

        expect(gameState.canAddToCraftingQueue(), isFalse);
      });
    });

    group('custom state', () {
      test('can set custom fields', () {
        gameState.gold = 1000;
        gameState.gems = 100;
        gameState.workshopLevel = 5;
        gameState.reputation = 500;
        gameState.playerExp = 1000;

        expect(gameState.gold, 1000);
        expect(gameState.gems, 100);
        expect(gameState.workshopLevel, 5);
        expect(gameState.reputation, 500);
        expect(gameState.playerExp, 1000);
      });

      test('can modify cat state directly', () {
        gameState.catState['custom_field'] = 'custom_value';

        expect(gameState.catState['custom_field'], 'custom_value');
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        gameState.workshopLevel = 5;
        gameState.gold = 1000;
        gameState.gems = 100;

        final str = gameState.toString();

        expect(str, contains('Level: 5'));
        expect(str, contains('Gold: 1000'));
        expect(str, contains('Gems: 100'));
      });
    });

    group('custom constructor', () {
      test('creates state with custom values', () {
        final custom = GameState(
          gold: 1000,
          gems: 200,
          workshopLevel: 5,
          reputation: 500,
          playerExp: 2000,
          inventory: {'grass': 50, 'stone': 30},
          discoveredRecipes: ['potion_health', 'potion_mana'],
          tutorialCompleted: true,
        );

        expect(custom.gold, 1000);
        expect(custom.gems, 200);
        expect(custom.workshopLevel, 5);
        expect(custom.reputation, 500);
        expect(custom.playerExp, 2000);
        expect(custom.getInventoryAmount('grass'), 50);
        expect(custom.getInventoryAmount('stone'), 30);
        expect(custom.discoveredRecipes.length, 2);
        expect(custom.tutorialCompleted, isTrue);
      });

      test('custom constructor with null values uses defaults', () {
        final custom = GameState(
          gold: 1000,
          gems: 200,
        );

        expect(custom.workshopLevel, 1);
        expect(custom.reputation, 0);
        expect(custom.inventory, isEmpty);
        expect(custom.discoveredRecipes, isEmpty);
      });
    });
  });
}
