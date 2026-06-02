import 'package:flutter_test/flutter_test.dart';
import 'package:mg_common_game/core/systems/rpg/inventory_system.dart';
import 'package:mg_common_game/core/systems/rpg/item_data.dart';
import 'package:mg_common_game/features/crafting/logic/crafting_manager.dart';
import 'package:mg_common_game/features/crafting/logic/recipe.dart';

void main() {
  group('Cat Alchemy Crafting Test', () {
    late InventorySystem inventory;
    late CraftingManager crafting;

    setUp(() {
      inventory = InventorySystem(capacity: 20);
      crafting = CraftingManager(inventory);
    });

    test('Basic Recipe Crafting Flow', () async {
      // 1. Define Recipe (Potion = Herb + Water)
      final potionRecipe = Recipe(
        id: 'potion_health',
        inputs: {'herb': 1, 'water': 1},
        outputs: {'potion_health': 1},
        durationSeconds: 1, // Quick for test
      );

      // 2. Add Ingredients
      inventory.addItem(ItemData(id: 'herb', name: 'Herb'), 5);
      inventory.addItem(ItemData(id: 'water', name: 'Water'), 5);

      expect(inventory.getItemCount('herb'), 5);
      expect(inventory.getItemCount('water'), 5);

      // 3. Start Craft
      expect(crafting.canCraft(potionRecipe), isTrue);
      final job = crafting.startCraft(potionRecipe);

      expect(job, isNotNull);
      expect(inventory.getItemCount('herb'), 4); // Consumed
      expect(inventory.getItemCount('water'), 4); // Consumed

      // 4. Wait for finish
      // Since CraftingJob uses DateTime.now(), we can't easily mock time without a wrapper or delay.
      // For this integration test, we wait 1.1 seconds.
      await Future.delayed(const Duration(milliseconds: 1100));

      expect(job!.isFinished, isTrue);

      // 5. Claim
      final claimed = crafting.claim(job);
      expect(claimed, isTrue);

      // 6. Verify Output
      expect(inventory.getItemCount('potion_health'), 1);
    });
  });
}
