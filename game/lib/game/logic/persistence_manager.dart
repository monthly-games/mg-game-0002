import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/core/systems/rpg/inventory_system.dart';
import 'package:mg_common_game/core/systems/save_system.dart';
import '../data/item_registry.dart';

class PersistenceManager {
  final SaveSystem _saveSystem;
  final InventorySystem _inventory;
  final GoldManager _goldManager;

  static const String _saveKey = 'cat_alchemy_save_v1';

  PersistenceManager(this._saveSystem, this._inventory, this._goldManager);

  Future<void> init() async {
    await _saveSystem.init();
    await _load();
  }

  Future<void> save() async {
    final data = {
      'gold': _goldManager.currentGold,
      'inventory': _inventory.slots
          .map((slot) => {'id': slot.item.id, 'qty': slot.quantity})
          .toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _saveSystem.save(_saveKey, data);
    print('Game Saved');
  }

  Future<void> _load() async {
    final data = await _saveSystem.load(_saveKey);
    if (data == null) return;

    // Load Gold
    final gold = data['gold'] as int? ?? 0;
    // Reset gold first? GoldManager adds logic.
    // If GoldManager starts at 0, we add difference?
    // Or we assume start at 0. GoldManager has no setter, only add/spend.
    // Hack: Add the loaded amount. (Assuming init is 0).
    if (_goldManager.currentGold > 0) {
      // If we already have gold (mock data?), careful.
      // Ideally reset.
    }
    _goldManager.addGold(gold - _goldManager.currentGold);

    // Load Inventory
    // InventorySystem doesn't have clear(), so we iterate slots?
    // InventorySystem starts empty usually.
    final invList = data['inventory'] as List<dynamic>? ?? [];
    for (final itemEntry in invList) {
      final id = itemEntry['id'] as String;
      final qty = itemEntry['qty'] as int;
      final item = ItemRegistry.getItem(id);
      _inventory.addItem(item, qty);
    }

    print('Game Loaded');
  }
}
