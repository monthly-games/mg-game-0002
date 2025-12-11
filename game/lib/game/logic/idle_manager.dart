import 'dart:async';
import 'package:mg_common_game/core/systems/rpg/inventory_system.dart';
import 'package:mg_common_game/core/systems/rpg/item_data.dart';

class IdleManager {
  final InventorySystem _inventory;
  Timer? _timer;

  // Config: Resource generation rate (seconds)
  static const int generationInterval = 5;

  IdleManager(this._inventory);

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: generationInterval), (_) {
      _generateResources();
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void _generateResources() {
    // Logic: Cats find Herbs and Water automatically
    // In a real game, this would depend on assigned cats.
    // For prototype: +1 Herb, +1 Water.

    // We construct ItemData locally. In real app, use a Registry.
    final herb = ItemData(id: 'herb', name: 'Herb');
    final water = ItemData(id: 'water', name: 'Water');

    _inventory.addItem(herb, 1);
    _inventory.addItem(water, 1);

    // Optional: Notify or Log?
    // Inventory stream will handle UI updates.
  }
}
