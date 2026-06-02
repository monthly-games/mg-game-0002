import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/core/models/recipe.dart';

void main() {
  group('Recipe Model', () {
    late Recipe recipe;

    setUp(() {
      recipe = Recipe(
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
        discoveryBonus: DiscoveryBonus(gold: 100, exp: 50, gems: 5),
      );
    });

    group('canCraft', () {
      test('returns true when all ingredients available', () {
        final inventory = {
          'grass': 5,
          'water_clear': 3,
        };

        expect(recipe.canCraft(inventory), isTrue);
      });

      test('returns true when exact ingredients available', () {
        final inventory = {
          'grass': 2,
          'water_clear': 1,
        };

        expect(recipe.canCraft(inventory), isTrue);
      });

      test('returns false when ingredient missing', () {
        final inventory = {
          'grass': 2,
          // water_clear missing
        };

        expect(recipe.canCraft(inventory), isFalse);
      });

      test('returns false when ingredient insufficient', () {
        final inventory = {
          'grass': 1, // Need 2
          'water_clear': 1,
        };

        expect(recipe.canCraft(inventory), isFalse);
      });

      test('returns false when inventory empty', () {
        final inventory = <String, int>{};

        expect(recipe.canCraft(inventory), isFalse);
      });
    });

    group('getMissingIngredients', () {
      test('returns empty map when all ingredients available', () {
        final inventory = {
          'grass': 5,
          'water_clear': 3,
        };

        final missing = recipe.getMissingIngredients(inventory);

        expect(missing, isEmpty);
      });

      test('returns missing ingredients with amounts', () {
        final inventory = {
          'grass': 1, // Need 2, missing 1
          'water_clear': 0, // Need 1, missing 1
        };

        final missing = recipe.getMissingIngredients(inventory);

        expect(missing['grass'], 1);
        expect(missing['water_clear'], 1);
      });

      test('returns all ingredients when inventory empty', () {
        final inventory = <String, int>{};

        final missing = recipe.getMissingIngredients(inventory);

        expect(missing['grass'], 2);
        expect(missing['water_clear'], 1);
      });

      test('returns only missing ingredients', () {
        final inventory = {
          'grass': 5, // Sufficient
          'water_clear': 0, // Missing
        };

        final missing = recipe.getMissingIngredients(inventory);

        expect(missing.containsKey('grass'), isFalse);
        expect(missing['water_clear'], 1);
      });
    });

    group('craftDuration', () {
      test('returns correct duration', () {
        expect(recipe.craftDuration, Duration(seconds: 5));
      });

      test('converts seconds to duration', () {
        final longRecipe = Recipe(
          id: 'potion_mana',
          name: 'Mana Potion',
          tier: 2,
          category: 'potion',
          icon: 'potion_mana.png',
          description: 'Restores mana',
          ingredients: [Ingredient(id: 'grass', amount: 1)],
          craftTime: 300, // 5 minutes
          result: CraftResult(id: 'potion_mana', amount: 1),
          sellPrice: 100,
          discoveryBonus: DiscoveryBonus(gold: 200, exp: 100),
        );

        expect(longRecipe.craftDuration, Duration(minutes: 5));
      });
    });

    group('equality', () {
      test('recipes with same id are equal', () {
        final recipe2 = Recipe(
          id: 'potion_health',
          name: 'Different Name',
          tier: 2,
          category: 'bomb',
          icon: 'different.png',
          description: 'Different',
          ingredients: [Ingredient(id: 'different', amount: 1)],
          craftTime: 10,
          result: CraftResult(id: 'different', amount: 1),
          sellPrice: 100,
          discoveryBonus: DiscoveryBonus(gold: 200, exp: 100),
        );

        expect(recipe, recipe2);
      });

      test('recipes with different id are not equal', () {
        final recipe2 = Recipe(
          id: 'potion_mana',
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

        expect(recipe, isNot(recipe2));
      });

      test('recipe equals itself', () {
        expect(recipe, recipe);
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON', () {
        final json = recipe.toJson();

        expect(json['id'], 'potion_health');
        expect(json['name'], 'Health Potion');
        expect(json['tier'], 1);
        expect(json['category'], 'potion');
        expect(json['craftTime'], 5);
        expect(json['sellPrice'], 50);
        expect(json['isLegendary'], false);
      });

      test('deserializes from JSON', () {
        final json = recipe.toJson();
        final deserialized = Recipe.fromJson(json);

        expect(deserialized.id, recipe.id);
        expect(deserialized.name, recipe.name);
        expect(deserialized.tier, recipe.tier);
        expect(deserialized.category, recipe.category);
        expect(deserialized.craftTime, recipe.craftTime);
        expect(deserialized.sellPrice, recipe.sellPrice);
      });

      test('preserves ingredients in JSON', () {
        final json = recipe.toJson();
        final deserialized = Recipe.fromJson(json);

        expect(deserialized.ingredients.length, 2);
        expect(deserialized.ingredients[0].id, 'grass');
        expect(deserialized.ingredients[0].amount, 2);
        expect(deserialized.ingredients[1].id, 'water_clear');
        expect(deserialized.ingredients[1].amount, 1);
      });

      test('preserves result in JSON', () {
        final json = recipe.toJson();
        final deserialized = Recipe.fromJson(json);

        expect(deserialized.result.id, 'potion_health');
        expect(deserialized.result.amount, 1);
      });

      test('preserves discovery bonus in JSON', () {
        final json = recipe.toJson();
        final deserialized = Recipe.fromJson(json);

        expect(deserialized.discoveryBonus.gold, 100);
        expect(deserialized.discoveryBonus.exp, 50);
        expect(deserialized.discoveryBonus.gems, 5);
      });

      test('handles optional pattern field', () {
        final recipeWithPattern = Recipe(
          id: 'puzzle_potion',
          name: 'Puzzle Potion',
          tier: 2,
          category: 'potion',
          icon: 'puzzle.png',
          description: 'Requires puzzle',
          ingredients: [Ingredient(id: 'grass', amount: 1)],
          craftTime: 10,
          result: CraftResult(id: 'puzzle_potion', amount: 1),
          sellPrice: 100,
          discoveryBonus: DiscoveryBonus(gold: 200, exp: 100),
          pattern: ['X', 'XX', 'X'],
        );

        final json = recipeWithPattern.toJson();
        final deserialized = Recipe.fromJson(json);

        expect(deserialized.pattern, ['X', 'XX', 'X']);
      });

      test('handles legendary flag', () {
        final legendaryRecipe = Recipe(
          id: 'legendary_potion',
          name: 'Legendary Potion',
          tier: 5,
          category: 'potion',
          icon: 'legendary.png',
          description: 'Legendary',
          ingredients: [Ingredient(id: 'rare_material', amount: 1)],
          craftTime: 60,
          result: CraftResult(id: 'legendary_potion', amount: 1),
          sellPrice: 1000,
          discoveryBonus: DiscoveryBonus(gold: 5000, exp: 1000),
          isLegendary: true,
        );

        final json = legendaryRecipe.toJson();
        final deserialized = Recipe.fromJson(json);

        expect(deserialized.isLegendary, isTrue);
      });
    });

    group('Ingredient', () {
      test('creates ingredient with id and amount', () {
        final ingredient = Ingredient(id: 'grass', amount: 2);

        expect(ingredient.id, 'grass');
        expect(ingredient.amount, 2);
      });

      test('serializes ingredient to JSON', () {
        final ingredient = Ingredient(id: 'grass', amount: 2);
        final json = ingredient.toJson();

        expect(json['id'], 'grass');
        expect(json['amount'], 2);
      });

      test('deserializes ingredient from JSON', () {
        final json = {'id': 'grass', 'amount': 2};
        final ingredient = Ingredient.fromJson(json);

        expect(ingredient.id, 'grass');
        expect(ingredient.amount, 2);
      });

      test('toString returns formatted string', () {
        final ingredient = Ingredient(id: 'grass', amount: 2);

        expect(ingredient.toString(), 'grass×2');
      });
    });

    group('CraftResult', () {
      test('creates result with id and amount', () {
        final result = CraftResult(id: 'potion_health', amount: 1);

        expect(result.id, 'potion_health');
        expect(result.amount, 1);
      });

      test('serializes result to JSON', () {
        final result = CraftResult(id: 'potion_health', amount: 1);
        final json = result.toJson();

        expect(json['id'], 'potion_health');
        expect(json['amount'], 1);
      });

      test('deserializes result from JSON', () {
        final json = {'id': 'potion_health', 'amount': 1};
        final result = CraftResult.fromJson(json);

        expect(result.id, 'potion_health');
        expect(result.amount, 1);
      });
    });

    group('DiscoveryBonus', () {
      test('creates bonus with gold and exp', () {
        final bonus = DiscoveryBonus(gold: 100, exp: 50);

        expect(bonus.gold, 100);
        expect(bonus.exp, 50);
        expect(bonus.gems, isNull);
      });

      test('creates bonus with optional gems', () {
        final bonus = DiscoveryBonus(gold: 100, exp: 50, gems: 5);

        expect(bonus.gold, 100);
        expect(bonus.exp, 50);
        expect(bonus.gems, 5);
      });

      test('serializes bonus to JSON', () {
        final bonus = DiscoveryBonus(gold: 100, exp: 50, gems: 5);
        final json = bonus.toJson();

        expect(json['gold'], 100);
        expect(json['exp'], 50);
        expect(json['gems'], 5);
      });

      test('serializes bonus without gems', () {
        final bonus = DiscoveryBonus(gold: 100, exp: 50);
        final json = bonus.toJson();

        expect(json['gold'], 100);
        expect(json['exp'], 50);
        expect(json.containsKey('gems'), isFalse);
      });

      test('deserializes bonus from JSON', () {
        final json = {'gold': 100, 'exp': 50, 'gems': 5};
        final bonus = DiscoveryBonus.fromJson(json);

        expect(bonus.gold, 100);
        expect(bonus.exp, 50);
        expect(bonus.gems, 5);
      });

      test('deserializes bonus without gems', () {
        final json = {'gold': 100, 'exp': 50};
        final bonus = DiscoveryBonus.fromJson(json);

        expect(bonus.gold, 100);
        expect(bonus.exp, 50);
        expect(bonus.gems, isNull);
      });
    });
  });
}
