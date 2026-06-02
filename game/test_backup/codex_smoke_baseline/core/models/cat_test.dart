import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/core/models/cat.dart';

void main() {
  group('Cat Model', () {
    late Cat cat;

    setUp(() {
      cat = Cat(
        id: 'cat_001',
        name: 'Whiskers',
        description: 'A curious cat',
        appearance: 'orange_tabby',
        maxLevel: 10,
        skills: [
          CatSkill(
            level: 1,
            type: 'passive',
            name: 'Basic Production',
            description: '+10% production',
            effect: CatSkillEffect(type: CatSkillType.productionRate, value: 0.1),
          ),
          CatSkill(
            level: 5,
            type: 'passive',
            name: 'Enhanced Production',
            description: '+20% production',
            effect: CatSkillEffect(type: CatSkillType.productionRate, value: 0.2),
          ),
        ],
        trustLevels: [
          TrustLevel(level: 1, requiredTrust: 0),
          TrustLevel(level: 2, requiredTrust: 100),
          TrustLevel(level: 3, requiredTrust: 300),
          TrustLevel(level: 5, requiredTrust: 1000),
        ],
        interactions: {
          'pet': CatInteraction(
            trustGain: 10,
            dailyLimit: 5,
            messages: ['Purr!', 'Meow!'],
          ),
          'play': CatInteraction(
            trustGain: 20,
            cooldown: 3600,
            messages: ['Pounce!', 'Chase!'],
          ),
        },
        idleAnimations: ['idle_1', 'idle_2', 'idle_3'],
      );
    });

    group('creation', () {
      test('creates cat with all fields', () {
        expect(cat.id, 'cat_001');
        expect(cat.name, 'Whiskers');
        expect(cat.description, 'A curious cat');
        expect(cat.appearance, 'orange_tabby');
        expect(cat.maxLevel, 10);
        expect(cat.skills.length, 2);
        expect(cat.trustLevels.length, 4);
        expect(cat.interactions.length, 2);
        expect(cat.idleAnimations.length, 3);
      });
    });

    group('getSkillForLevel', () {
      test('returns skill for specific level', () {
        final skill = cat.getSkillForLevel(1);

        expect(skill, isNotNull);
        expect(skill!.level, 1);
        expect(skill.name, 'Basic Production');
      });

      test('returns null for non-existent level', () {
        final skill = cat.getSkillForLevel(3);

        expect(skill, isNull);
      });

      test('returns correct skill for higher level', () {
        final skill = cat.getSkillForLevel(5);

        expect(skill, isNotNull);
        expect(skill!.level, 5);
        expect(skill.name, 'Enhanced Production');
      });
    });

    group('getUnlockedSkills', () {
      test('returns all skills up to level', () {
        final skills = cat.getUnlockedSkills(5);

        expect(skills.length, 2);
        expect(skills[0].level, 1);
        expect(skills[1].level, 5);
      });

      test('returns only level 1 skill for level 1', () {
        final skills = cat.getUnlockedSkills(1);

        expect(skills.length, 1);
        expect(skills[0].level, 1);
      });

      test('returns empty list for level 0', () {
        final skills = cat.getUnlockedSkills(0);

        expect(skills, isEmpty);
      });

      test('returns all skills for high level', () {
        final skills = cat.getUnlockedSkills(10);

        expect(skills.length, 2);
      });
    });

    group('getTrustRequirement', () {
      test('returns trust requirement for level', () {
        expect(cat.getTrustRequirement(1), 0);
        expect(cat.getTrustRequirement(2), 100);
        expect(cat.getTrustRequirement(3), 300);
        expect(cat.getTrustRequirement(5), 1000);
      });

      test('returns 0 for non-existent level', () {
        expect(cat.getTrustRequirement(4), 0);
        expect(cat.getTrustRequirement(10), 0);
      });
    });

    group('calculateLevel', () {
      test('returns level 1 for 0 trust', () {
        expect(cat.calculateLevel(0), 1);
      });

      test('returns level 2 for 100+ trust', () {
        expect(cat.calculateLevel(100), 2);
        expect(cat.calculateLevel(150), 2);
      });

      test('returns level 3 for 300+ trust', () {
        expect(cat.calculateLevel(300), 3);
        expect(cat.calculateLevel(500), 3);
      });

      test('returns level 5 for 1000+ trust', () {
        expect(cat.calculateLevel(1000), 5);
        expect(cat.calculateLevel(2000), 5);
      });

      test('returns highest level for very high trust', () {
        expect(cat.calculateLevel(10000), 5);
      });

      test('handles trust just below threshold', () {
        expect(cat.calculateLevel(99), 1);
        expect(cat.calculateLevel(299), 2);
        expect(cat.calculateLevel(999), 3);
      });
    });

    group('CatSkill', () {
      test('creates skill with all fields', () {
        final skill = CatSkill(
          level: 1,
          type: 'passive',
          name: 'Test Skill',
          description: 'Test',
          effect: CatSkillEffect(type: CatSkillType.productionRate, value: 0.1),
        );

        expect(skill.level, 1);
        expect(skill.type, 'passive');
        expect(skill.name, 'Test Skill');
        expect(skill.description, 'Test');
      });

      test('isPassive returns true for passive skills', () {
        final skill = CatSkill(
          level: 1,
          type: 'passive',
          name: 'Passive Skill',
          description: 'Passive',
          effect: CatSkillEffect(type: CatSkillType.productionRate, value: 0.1),
        );

        expect(skill.isPassive, isTrue);
        expect(skill.isActive, isFalse);
      });

      test('isActive returns true for active skills', () {
        final skill = CatSkill(
          level: 1,
          type: 'active',
          name: 'Active Skill',
          description: 'Active',
          effect: CatSkillEffect(type: CatSkillType.craftTime, value: 0.5),
        );

        expect(skill.isActive, isTrue);
        expect(skill.isPassive, isFalse);
      });

      test('serializes skill to JSON', () {
        final skill = cat.skills[0];
        final json = skill.toJson();

        expect(json['level'], 1);
        expect(json['type'], 'passive');
        expect(json['name'], 'Basic Production');
      });

      test('deserializes skill from JSON', () {
        final skill = cat.skills[0];
        final json = skill.toJson();
        final deserialized = CatSkill.fromJson(json);

        expect(deserialized.level, skill.level);
        expect(deserialized.type, skill.type);
        expect(deserialized.name, skill.name);
      });
    });

    group('CatSkillEffect', () {
      test('creates effect with type and value', () {
        final effect = CatSkillEffect(
          type: CatSkillType.productionRate,
          value: 0.1,
        );

        expect(effect.type, CatSkillType.productionRate);
        expect(effect.value, 0.1);
      });

      test('supports all skill types', () {
        final types = [
          CatSkillType.productionRate,
          CatSkillType.craftTime,
          CatSkillType.sellPrice,
          CatSkillType.queueSize,
          CatSkillType.reputation,
          CatSkillType.luckyCraft,
        ];

        for (final type in types) {
          final effect = CatSkillEffect(type: type, value: 0.5);
          expect(effect.type, type);
        }
      });

      test('serializes effect to JSON', () {
        final effect = CatSkillEffect(
          type: CatSkillType.productionRate,
          value: 0.1,
        );
        final json = effect.toJson();

        expect(json['type'], 'productionRate');
        expect(json['value'], 0.1);
      });

      test('deserializes effect from JSON', () {
        final effect = CatSkillEffect(
          type: CatSkillType.productionRate,
          value: 0.1,
        );
        final json = effect.toJson();
        final deserialized = CatSkillEffect.fromJson(json);

        expect(deserialized.type, effect.type);
        expect(deserialized.value, effect.value);
      });
    });

    group('TrustLevel', () {
      test('creates trust level with level and requirement', () {
        final trustLevel = TrustLevel(level: 2, requiredTrust: 100);

        expect(trustLevel.level, 2);
        expect(trustLevel.requiredTrust, 100);
      });

      test('serializes to JSON', () {
        final trustLevel = TrustLevel(level: 2, requiredTrust: 100);
        final json = trustLevel.toJson();

        expect(json['level'], 2);
        expect(json['requiredTrust'], 100);
      });

      test('deserializes from JSON', () {
        final json = {'level': 2, 'requiredTrust': 100};
        final trustLevel = TrustLevel.fromJson(json);

        expect(trustLevel.level, 2);
        expect(trustLevel.requiredTrust, 100);
      });
    });

    group('CatInteraction', () {
      test('creates interaction with trust gain', () {
        final interaction = CatInteraction(
          trustGain: 10,
          messages: ['Purr!'],
        );

        expect(interaction.trustGain, 10);
        expect(interaction.messages, ['Purr!']);
        expect(interaction.dailyLimit, isNull);
        expect(interaction.cooldown, isNull);
        expect(interaction.cost, isNull);
      });

      test('creates interaction with all optional fields', () {
        final interaction = CatInteraction(
          trustGain: 20,
          dailyLimit: 5,
          cooldown: 3600,
          cost: 'gold:100',
          messages: ['Pounce!', 'Chase!'],
        );

        expect(interaction.trustGain, 20);
        expect(interaction.dailyLimit, 5);
        expect(interaction.cooldown, 3600);
        expect(interaction.cost, 'gold:100');
        expect(interaction.messages.length, 2);
      });

      test('serializes interaction to JSON', () {
        final interaction = cat.interactions['pet']!;
        final json = interaction.toJson();

        expect(json['trustGain'], 10);
        expect(json['dailyLimit'], 5);
        expect(json['messages'], ['Purr!', 'Meow!']);
      });

      test('deserializes interaction from JSON', () {
        final interaction = cat.interactions['pet']!;
        final json = interaction.toJson();
        final deserialized = CatInteraction.fromJson(json);

        expect(deserialized.trustGain, interaction.trustGain);
        expect(deserialized.dailyLimit, interaction.dailyLimit);
        expect(deserialized.messages, interaction.messages);
      });
    });

    group('JSON serialization', () {
      test('serializes cat to JSON', () {
        final json = cat.toJson();

        expect(json['id'], 'cat_001');
        expect(json['name'], 'Whiskers');
        expect(json['maxLevel'], 10);
        expect(json['skills'], isA<List>());
        expect(json['trustLevels'], isA<List>());
        expect(json['interactions'], isA<Map>());
      });

      test('deserializes cat from JSON', () {
        final json = cat.toJson();
        final deserialized = Cat.fromJson(json);

        expect(deserialized.id, cat.id);
        expect(deserialized.name, cat.name);
        expect(deserialized.maxLevel, cat.maxLevel);
        expect(deserialized.skills.length, cat.skills.length);
        expect(deserialized.trustLevels.length, cat.trustLevels.length);
      });

      test('round-trip serialization preserves data', () {
        final json = cat.toJson();
        final deserialized = Cat.fromJson(json);
        final json2 = deserialized.toJson();

        expect(json, json2);
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        expect(cat.toString(), 'Cat(cat_001: Whiskers, Lv.10)');
      });
    });
  });
}
