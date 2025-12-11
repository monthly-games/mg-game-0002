import 'package:mg_common_game/core/systems/rpg/item_data.dart';

class ItemRegistry {
  static final Map<String, ItemData> _items = {
    'herb': ItemData(
      id: 'herb',
      name: 'Herb',
      description: 'A common medicinal herb.',
    ),
    'water': ItemData(id: 'water', name: 'Water', description: 'Fresh water.'),
    'fire_stone': ItemData(
      id: 'fire_stone',
      name: 'Fire Stone',
      description: 'Warm to the touch.',
    ),
    'potion_health': ItemData(
      id: 'potion_health',
      name: 'Health Potion',
      description: 'Restores vitality.',
    ),
    'bomb_fire': ItemData(
      id: 'bomb_fire',
      name: 'Fire Bomb',
      description: 'Explosive.',
    ),
  };

  static ItemData getItem(String id) {
    return _items[id] ?? ItemData(id: id, name: 'Unknown Item');
  }
}
