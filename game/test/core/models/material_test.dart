import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/core/models/material.dart';

void main() {
  group('Material Model', () {
    late Material material;

    setUp(() {
      material = Material(
        id: 'grass',
        name: 'Grass',
        tier: 1,
        icon: 'grass.png',
        description: 'Common grass',
        productionRate: 2.0, // 2 items per hour
        maxStorage: 100,
        category: 'plant',
        unlockLevel: 1,
        obtainMethod: 'idle_production',
      );
    });

    group('creation', () {
      test('creates material with all fields', () {
        expect(material.id, 'grass');
        expect(material.name, 'Grass');
        expect(material.tier, 1);
        expect(material.icon, 'grass.png');
        expect(material.description, 'Common grass');
        expect(material.productionRate, 2.0);
        expect(material.maxStorage, 100);
        expect(material.category, 'plant');
        expect(material.unlockLevel, 1);
        expect(material.obtainMethod, 'idle_production');
      });

      test('creates material without optional fields', () {
        final simpleMaterial = Material(
          id: 'stone',
          name: 'Stone',
          tier: 1,
          icon: 'stone.png',
          description: 'Common stone',
          productionRate: 1.5,
          maxStorage: 50,
          category: 'mineral',
        );

        expect(simpleMaterial.unlockLevel, isNull);
        expect(simpleMaterial.obtainMethod, isNull);
      });
    });

    group('isUnlocked', () {
      test('returns true when workshop level >= unlock level', () {
        expect(material.isUnlocked(1), isTrue);
        expect(material.isUnlocked(5), isTrue);
        expect(material.isUnlocked(10), isTrue);
      });

      test('returns false when workshop level < unlock level', () {
        expect(material.isUnlocked(0), isFalse);
      });

      test('returns true when no unlock level specified', () {
        final unlockedMaterial = Material(
          id: 'water',
          name: 'Water',
          tier: 1,
          icon: 'water.png',
          description: 'Water',
          productionRate: 1.0,
          maxStorage: 100,
          category: 'liquid',
        );

        expect(unlockedMaterial.isUnlocked(0), isTrue);
        expect(unlockedMaterial.isUnlocked(1), isTrue);
      });

      test('handles high unlock levels', () {
        final rareMaterial = Material(
          id: 'rare_ore',
          name: 'Rare Ore',
          tier: 5,
          icon: 'rare_ore.png',
          description: 'Rare ore',
          productionRate: 0.5,
          maxStorage: 20,
          category: 'mineral',
          unlockLevel: 20,
        );

        expect(rareMaterial.isUnlocked(19), isFalse);
        expect(rareMaterial.isUnlocked(20), isTrue);
        expect(rareMaterial.isUnlocked(21), isTrue);
      });
    });

    group('isIdleProduced', () {
      test('returns true when production rate > 0', () {
        expect(material.isIdleProduced, isTrue);
      });

      test('returns false when production rate is 0', () {
        final nonIdleMaterial = Material(
          id: 'special_item',
          name: 'Special Item',
          tier: 3,
          icon: 'special.png',
          description: 'Special item',
          productionRate: 0.0,
          maxStorage: 10,
          category: 'special',
        );

        expect(nonIdleMaterial.isIdleProduced, isFalse);
      });

      test('returns true for very small production rates', () {
        final slowMaterial = Material(
          id: 'slow_material',
          name: 'Slow Material',
          tier: 4,
          icon: 'slow.png',
          description: 'Slow production',
          productionRate: 0.1,
          maxStorage: 50,
          category: 'rare',
        );

        expect(slowMaterial.isIdleProduced, isTrue);
      });
    });

    group('equality', () {
      test('materials with same id are equal', () {
        final material2 = Material(
          id: 'grass',
          name: 'Different Name',
          tier: 2,
          icon: 'different.png',
          description: 'Different',
          productionRate: 5.0,
          maxStorage: 200,
          category: 'different',
        );

        expect(material, material2);
      });

      test('materials with different id are not equal', () {
        final material2 = Material(
          id: 'stone',
          name: 'Grass',
          tier: 1,
          icon: 'grass.png',
          description: 'Common grass',
          productionRate: 2.0,
          maxStorage: 100,
          category: 'plant',
        );

        expect(material, isNot(material2));
      });

      test('material equals itself', () {
        expect(material, material);
      });
    });

    group('hashCode', () {
      test('same id produces same hash', () {
        final material2 = Material(
          id: 'grass',
          name: 'Different',
          tier: 2,
          icon: 'different.png',
          description: 'Different',
          productionRate: 5.0,
          maxStorage: 200,
          category: 'different',
        );

        expect(material.hashCode, material2.hashCode);
      });

      test('different id produces different hash', () {
        final material2 = Material(
          id: 'stone',
          name: 'Grass',
          tier: 1,
          icon: 'grass.png',
          description: 'Common grass',
          productionRate: 2.0,
          maxStorage: 100,
          category: 'plant',
        );

        expect(material.hashCode, isNot(material2.hashCode));
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON with all fields', () {
        final json = material.toJson();

        expect(json['id'], 'grass');
        expect(json['name'], 'Grass');
        expect(json['tier'], 1);
        expect(json['icon'], 'grass.png');
        expect(json['description'], 'Common grass');
        expect(json['productionRate'], 2.0);
        expect(json['maxStorage'], 100);
        expect(json['category'], 'plant');
        expect(json['unlockLevel'], 1);
        expect(json['obtainMethod'], 'idle_production');
      });

      test('serializes without optional fields', () {
        final simpleMaterial = Material(
          id: 'stone',
          name: 'Stone',
          tier: 1,
          icon: 'stone.png',
          description: 'Stone',
          productionRate: 1.5,
          maxStorage: 50,
          category: 'mineral',
        );

        final json = simpleMaterial.toJson();

        expect(json.containsKey('unlockLevel'), isFalse);
        expect(json.containsKey('obtainMethod'), isFalse);
      });

      test('deserializes from JSON', () {
        final json = material.toJson();
        final deserialized = Material.fromJson(json);

        expect(deserialized.id, material.id);
        expect(deserialized.name, material.name);
        expect(deserialized.tier, material.tier);
        expect(deserialized.icon, material.icon);
        expect(deserialized.description, material.description);
        expect(deserialized.productionRate, material.productionRate);
        expect(deserialized.maxStorage, material.maxStorage);
        expect(deserialized.category, material.category);
        expect(deserialized.unlockLevel, material.unlockLevel);
        expect(deserialized.obtainMethod, material.obtainMethod);
      });

      test('round-trip serialization preserves data', () {
        final json = material.toJson();
        final deserialized = Material.fromJson(json);
        final json2 = deserialized.toJson();

        expect(json, json2);
      });

      test('handles numeric production rate conversion', () {
        final json = {
          'id': 'grass',
          'name': 'Grass',
          'tier': 1,
          'icon': 'grass.png',
          'description': 'Grass',
          'productionRate': 2, // Integer instead of double
          'maxStorage': 100,
          'category': 'plant',
        };

        final material = Material.fromJson(json);
        expect(material.productionRate, 2.0);
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        expect(material.toString(), 'Material(grass: Grass)');
      });

      test('works for different materials', () {
        final stone = Material(
          id: 'stone',
          name: 'Stone',
          tier: 1,
          icon: 'stone.png',
          description: 'Stone',
          productionRate: 1.5,
          maxStorage: 50,
          category: 'mineral',
        );

        expect(stone.toString(), 'Material(stone: Stone)');
      });
    });

    group('production rates', () {
      test('handles zero production rate', () {
        final nonProducing = Material(
          id: 'special',
          name: 'Special',
          tier: 3,
          icon: 'special.png',
          description: 'Special',
          productionRate: 0.0,
          maxStorage: 10,
          category: 'special',
        );

        expect(nonProducing.productionRate, 0.0);
        expect(nonProducing.isIdleProduced, isFalse);
      });

      test('handles high production rates', () {
        final fastProducing = Material(
          id: 'fast_material',
          name: 'Fast Material',
          tier: 1,
          icon: 'fast.png',
          description: 'Fast',
          productionRate: 100.0,
          maxStorage: 1000,
          category: 'common',
        );

        expect(fastProducing.productionRate, 100.0);
        expect(fastProducing.isIdleProduced, isTrue);
      });

      test('handles fractional production rates', () {
        final slowProducing = Material(
          id: 'slow_material',
          name: 'Slow Material',
          tier: 4,
          icon: 'slow.png',
          description: 'Slow',
          productionRate: 0.25,
          maxStorage: 50,
          category: 'rare',
        );

        expect(slowProducing.productionRate, 0.25);
        expect(slowProducing.isIdleProduced, isTrue);
      });
    });

    group('tiers', () {
      test('handles different tier levels', () {
        for (int tier = 1; tier <= 5; tier++) {
          final tieredMaterial = Material(
            id: 'material_tier_$tier',
            name: 'Material Tier $tier',
            tier: tier,
            icon: 'tier_$tier.png',
            description: 'Tier $tier',
            productionRate: 1.0,
            maxStorage: 100,
            category: 'tiered',
          );

          expect(tieredMaterial.tier, tier);
        }
      });
    });

    group('categories', () {
      test('supports various categories', () {
        final categories = ['plant', 'mineral', 'liquid', 'special', 'rare'];

        for (final category in categories) {
          final material = Material(
            id: 'material_$category',
            name: 'Material $category',
            tier: 1,
            icon: '$category.png',
            description: category,
            productionRate: 1.0,
            maxStorage: 100,
            category: category,
          );

          expect(material.category, category);
        }
      });
    });
  });
}
