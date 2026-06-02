import 'package:cat_alchemy/core/models/seasonal_event.dart';

/// Seasonal events data for Cat Alchemy Workshop
/// Defines all seasonal events with their dates, rewards, and special content
class SeasonalEventsData {
  /// Get all seasonal events
  static List<SeasonalEvent> getAllEvents(int year) {
    return [
      _springBlossomEvent(year),
      _summerFestivalEvent(year),
      _autumnHarvestEvent(year),
      _winterWonderlandEvent(year),
      _anniversaryEvent(year),
    ];
  }

  /// Spring Blossom Event (March 20 - April 10)
  static SeasonalEvent _springBlossomEvent(int year) {
    return SeasonalEvent(
      id: 'spring_blossom_$year',
      name: 'Spring Blossom Festival',
      description:
          'Celebrate the arrival of spring with special flower-themed potions and limited-time cats!',
      theme: 'spring',
      startTime: DateTime(year, 3, 20),
      endTime: DateTime(year, 4, 10, 23, 59, 59),
      specialMaterialIds: [
        'cherry_blossom',
        'spring_water',
        'morning_dew',
        'flower_essence',
      ],
      specialRecipeIds: [
        'blossom_healing_potion',
        'spring_renewal_elixir',
        'flower_power_bomb',
        'cherry_blossom_tea',
      ],
      limitedCatIds: ['sakura_cat', 'butterfly_cat'],
      bannerAsset: 'assets/images/ui/events/spring_banner.png',
      themeMusicAsset: 'assets/audio/bgm/event_spring.mp3',
      rewards: const EventRewards(
        currencyName: 'Blossom Petals',
        milestoneRewards: {
          '100': {'gold': 500, 'gems': 10},
          '300': {
            'gold': 1000,
            'special_material': 'cherry_blossom',
            'amount': 5,
          },
          '500': {
            'gold': 2000,
            'gems': 25,
            'cat_fragment': 'sakura_cat',
            'amount': 10,
          },
          '1000': {
            'gold': 5000,
            'gems': 50,
            'special_recipe': 'blossom_healing_potion',
          },
          '2000': {'gold': 10000, 'gems': 100, 'special_cat': 'sakura_cat'},
        },
        maxEventPoints: 2500,
      ),
      quests: const [
        EventQuest(
          id: 'spring_craft_1',
          title: 'Blossom Brewer',
          description: 'Craft 5 flower-themed potions',
          type: 'craft',
          targets: {'blossom_healing_potion': 5},
          eventPoints: 50,
          rewards: {'gold': 200, 'blossom_petals': 20},
        ),
        EventQuest(
          id: 'spring_gather_1',
          title: 'Spring Gatherer',
          description: 'Gather 10 cherry blossoms',
          type: 'gather',
          targets: {'cherry_blossom': 10},
          eventPoints: 30,
          rewards: {'gold': 100, 'blossom_petals': 10},
        ),
        EventQuest(
          id: 'spring_sell_1',
          title: 'Flower Salesman',
          description: 'Sell 3 spring-themed potions',
          type: 'sell',
          targets: {'blossom_healing_potion': 3},
          eventPoints: 40,
          rewards: {'gold': 300, 'blossom_petals': 15},
        ),
        EventQuest(
          id: 'spring_special_1',
          title: 'Cat Friendship',
          description: 'Pet cats 20 times during the event',
          type: 'special',
          targets: {'cat_pet': 20},
          eventPoints: 25,
          rewards: {'gold': 150, 'blossom_petals': 10},
        ),
      ],
    );
  }

  /// Summer Festival Event (July 15 - August 5)
  static SeasonalEvent _summerFestivalEvent(int year) {
    return SeasonalEvent(
      id: 'summer_festival_$year',
      name: 'Summer Firework Festival',
      description:
          'Enjoy the summer heat with explosive potions and festival cats!',
      theme: 'summer',
      startTime: DateTime(year, 7, 15),
      endTime: DateTime(year, 8, 5, 23, 59, 59),
      specialMaterialIds: [
        'firework_spark',
        'summer_sun',
        'tropical_fruit',
        'sea_shell',
      ],
      specialRecipeIds: [
        'firework_bomb',
        'summer_cool_drink',
        'tropical_potion',
        'sun_screen_elixir',
      ],
      limitedCatIds: ['firework_cat', 'beach_cat'],
      bannerAsset: 'assets/images/ui/events/summer_banner.png',
      themeMusicAsset: 'assets/audio/bgm/event_summer.mp3',
      rewards: const EventRewards(
        currencyName: 'Firework Sparks',
        milestoneRewards: {
          '100': {'gold': 500, 'gems': 10},
          '300': {
            'gold': 1000,
            'special_material': 'firework_spark',
            'amount': 5,
          },
          '500': {
            'gold': 2000,
            'gems': 25,
            'cat_fragment': 'firework_cat',
            'amount': 10,
          },
          '1000': {'gold': 5000, 'gems': 50, 'special_recipe': 'firework_bomb'},
          '2000': {'gold': 10000, 'gems': 100, 'special_cat': 'firework_cat'},
        },
        maxEventPoints: 2500,
      ),
      quests: const [
        EventQuest(
          id: 'summer_craft_1',
          title: 'Pyrotechnic Expert',
          description: 'Craft 10 firework bombs',
          type: 'craft',
          targets: {'firework_bomb': 10},
          eventPoints: 60,
          rewards: {'gold': 300, 'firework_sparks': 25},
        ),
        EventQuest(
          id: 'summer_gather_1',
          title: 'Beach Comber',
          description: 'Gather 15 sea shells',
          type: 'gather',
          targets: {'sea_shell': 15},
          eventPoints: 35,
          rewards: {'gold': 150, 'firework_sparks': 12},
        ),
        EventQuest(
          id: 'summer_sell_1',
          title: 'Summer Vendor',
          description: 'Sell 5 summer-themed potions',
          type: 'sell',
          targets: {'summer_cool_drink': 5},
          eventPoints: 50,
          rewards: {'gold': 400, 'firework_sparks': 20},
        ),
      ],
    );
  }

  /// Autumn Harvest Event (October 1 - October 21)
  static SeasonalEvent _autumnHarvestEvent(int year) {
    return SeasonalEvent(
      id: 'autumn_harvest_$year',
      name: 'Autumn Harvest Festival',
      description:
          'Celebrate the harvest season with pumpkin potions and cozy cats!',
      theme: 'autumn',
      startTime: DateTime(year, 10, 1),
      endTime: DateTime(year, 10, 21, 23, 59, 59),
      specialMaterialIds: [
        'pumpkin',
        'autumn_leaf',
        'harvest_moon',
        'cinnamon_spice',
      ],
      specialRecipeIds: [
        'pumpkin_pie_potion',
        'autumn_comfort_elixir',
        'harvest_bomb',
        'spiced_cider',
      ],
      limitedCatIds: ['pumpkin_cat', 'maple_cat'],
      bannerAsset: 'assets/images/ui/events/autumn_banner.png',
      themeMusicAsset: 'assets/audio/bgm/event_autumn.mp3',
      rewards: const EventRewards(
        currencyName: 'Harvest Coins',
        milestoneRewards: {
          '100': {'gold': 500, 'gems': 10},
          '300': {'gold': 1000, 'special_material': 'pumpkin', 'amount': 5},
          '500': {
            'gold': 2000,
            'gems': 25,
            'cat_fragment': 'pumpkin_cat',
            'amount': 10,
          },
          '1000': {
            'gold': 5000,
            'gems': 50,
            'special_recipe': 'pumpkin_pie_potion',
          },
          '2000': {'gold': 10000, 'gems': 100, 'special_cat': 'pumpkin_cat'},
        },
        maxEventPoints: 2500,
      ),
      quests: const [
        EventQuest(
          id: 'autumn_craft_1',
          title: 'Pumpkin Master',
          description: 'Craft 8 pumpkin pie potions',
          type: 'craft',
          targets: {'pumpkin_pie_potion': 8},
          eventPoints: 55,
          rewards: {'gold': 250, 'harvest_coins': 22},
        ),
        EventQuest(
          id: 'autumn_gather_1',
          title: 'Leaf Collector',
          description: 'Gather 12 autumn leaves',
          type: 'gather',
          targets: {'autumn_leaf': 12},
          eventPoints: 32,
          rewards: {'gold': 120, 'harvest_coins': 11},
        ),
        EventQuest(
          id: 'autumn_sell_1',
          title: 'Harvest Sales',
          description: 'Sell 4 autumn-themed potions',
          type: 'sell',
          targets: {'autumn_comfort_elixir': 4},
          eventPoints: 45,
          rewards: {'gold': 350, 'harvest_coins': 18},
        ),
      ],
    );
  }

  /// Winter Wonderland Event (December 15 - January 5)
  static SeasonalEvent _winterWonderlandEvent(int year) {
    return SeasonalEvent(
      id: 'winter_wonderland_${year}_${year + 1}',
      name: 'Winter Wonderland Festival',
      description:
          'Experience the magic of winter with frozen potions and festive cats!',
      theme: 'winter',
      startTime: DateTime(year, 12, 15),
      endTime: DateTime(year + 1, 1, 5, 23, 59, 59),
      specialMaterialIds: [
        'snowflake',
        'ice_crystal',
        'winter_berry',
        'candy_cane',
      ],
      specialRecipeIds: [
        'frozen_fire_potion',
        'winter_warm_elixir',
        'snowflake_bomb',
        'holiday_candy',
      ],
      limitedCatIds: ['snowflake_cat', 'reindeer_cat'],
      bannerAsset: 'assets/images/ui/events/winter_banner.png',
      themeMusicAsset: 'assets/audio/bgm/event_winter.mp3',
      rewards: const EventRewards(
        currencyName: 'Snowflakes',
        milestoneRewards: {
          '100': {'gold': 500, 'gems': 10},
          '300': {'gold': 1000, 'special_material': 'snowflake', 'amount': 5},
          '500': {
            'gold': 2000,
            'gems': 25,
            'cat_fragment': 'snowflake_cat',
            'amount': 10,
          },
          '1000': {
            'gold': 5000,
            'gems': 50,
            'special_recipe': 'frozen_fire_potion',
          },
          '2000': {'gold': 10000, 'gems': 100, 'special_cat': 'snowflake_cat'},
        },
        maxEventPoints: 2500,
      ),
      quests: const [
        EventQuest(
          id: 'winter_craft_1',
          title: 'Ice Alchemist',
          description: 'Craft 6 frozen fire potions',
          type: 'craft',
          targets: {'frozen_fire_potion': 6},
          eventPoints: 50,
          rewards: {'gold': 200, 'snowflakes': 20},
        ),
        EventQuest(
          id: 'winter_gather_1',
          title: 'Snowflake Hunter',
          description: 'Gather 8 snowflakes',
          type: 'gather',
          targets: {'snowflake': 8},
          eventPoints: 28,
          rewards: {'gold': 100, 'snowflakes': 9},
        ),
        EventQuest(
          id: 'winter_sell_1',
          title: 'Winter Merchant',
          description: 'Sell 3 winter-themed potions',
          type: 'sell',
          targets: {'winter_warm_elixir': 3},
          eventPoints: 40,
          rewards: {'gold': 300, 'snowflakes': 15},
        ),
      ],
    );
  }

  /// Anniversary Event (Date varies by launch date)
  static SeasonalEvent _anniversaryEvent(int year) {
    return SeasonalEvent(
      id: 'anniversary_$year',
      name: 'Cat Alchemy Anniversary',
      description:
          'Celebrate another year of alchemical adventures with special rewards!',
      theme: 'special',
      startTime: DateTime(year, 6, 1),
      endTime: DateTime(year, 6, 15, 23, 59, 59),
      specialMaterialIds: [
        'anniversary_cake',
        'celebration_confetti',
        'golden_egg',
        'memory_crystal',
      ],
      specialRecipeIds: [
        'celebration_potion',
        'anniversary_elixir',
        'golden_craft_bomb',
        'memory_recall_potion',
      ],
      limitedCatIds: ['golden_cat', 'party_cat'],
      bannerAsset: 'assets/images/ui/events/anniversary_banner.png',
      themeMusicAsset: 'assets/audio/bgm/event_anniversary.mp3',
      rewards: const EventRewards(
        currencyName: 'Anniversary Stars',
        milestoneRewards: {
          '100': {'gold': 1000, 'gems': 25},
          '300': {
            'gold': 2000,
            'special_material': 'anniversary_cake',
            'amount': 3,
          },
          '500': {
            'gold': 5000,
            'gems': 50,
            'cat_fragment': 'golden_cat',
            'amount': 15,
          },
          '1000': {
            'gold': 10000,
            'gems': 100,
            'special_recipe': 'celebration_potion',
          },
          '2000': {'gold': 20000, 'gems': 200, 'special_cat': 'golden_cat'},
        },
        maxEventPoints: 3000,
      ),
      quests: const [
        EventQuest(
          id: 'anniversary_craft_1',
          title: 'Master Crafter',
          description: 'Craft any 20 potions',
          type: 'craft',
          targets: {'any_potion': 20},
          eventPoints: 80,
          rewards: {'gold': 500, 'anniversary_stars': 30},
        ),
        EventQuest(
          id: 'anniversary_special_1',
          title: 'Loyal Friend',
          description: 'Reach max trust level with any cat',
          type: 'special',
          targets: {'max_trust_cat': 1},
          eventPoints: 100,
          rewards: {'gold': 1000, 'anniversary_stars': 50},
        ),
        EventQuest(
          id: 'anniversary_gather_1',
          title: 'Resource Collector',
          description: 'Gather 50 of any material',
          type: 'gather',
          targets: {'any_material': 50},
          eventPoints: 60,
          rewards: {'gold': 400, 'anniversary_stars': 25},
        ),
      ],
    );
  }
}
