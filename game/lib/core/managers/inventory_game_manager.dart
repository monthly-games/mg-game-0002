import 'package:mg_common_game/mg_common_game.dart';
import '../models/game_state.dart';

/// Manages inventory system with integration to GameState
class InventoryGameManager {
  final InventoryManager _inventoryManager;
  final GameState _gameState;

  InventoryGameManager(this._gameState)
    : _inventoryManager = InventoryManager(maxSlots: 100, maxStackSize: 999) {
    // Sync existing inventory from game state
    _syncFromGameState();
  }

  /// Sync inventory from game state
  void _syncFromGameState() {
    for (final entry in _gameState.inventory.entries) {
      _inventoryManager.addItem(entry.key, entry.value);
    }
  }

  /// Sync inventory back to game state
  void _syncToGameState() {
    _gameState.inventory.clear();
    for (final item in _inventoryManager.items.values) {
      _gameState.inventory[item.id] = item.amount;
    }
  }

  /// Add item to inventory
  InventoryResult addItem(
    String itemId,
    int amount, {
    Map<String, dynamic>? metadata,
  }) {
    final result = _inventoryManager.addItem(
      itemId,
      amount,
      metadata: metadata,
    );

    if (result.success) {
      _syncToGameState();
    }

    return result;
  }

  /// Remove item from inventory
  InventoryResult removeItem(String itemId, int amount) {
    final result = _inventoryManager.removeItem(itemId, amount);

    if (result.success) {
      _syncToGameState();
    }

    return result;
  }

  /// Remove all of an item
  InventoryResult removeAllItem(String itemId) {
    final result = _inventoryManager.removeAllItem(itemId);

    if (result.success) {
      _syncToGameState();
    }

    return result;
  }

  /// Check if has item
  bool hasItem(String itemId, [int amount = 1]) {
    return _inventoryManager.hasItem(itemId, amount);
  }

  /// Get item amount
  int getAmount(String itemId) {
    return _inventoryManager.getAmount(itemId);
  }

  /// Get item
  InventoryItem? getItem(String itemId) {
    return _inventoryManager.getItem(itemId);
  }

  /// Get all items
  Map<String, InventoryItem> get items => _inventoryManager.items;

  /// Get sorted items
  /// Get sorted items
  List<InventoryItem> getSortedItems({
    int Function(InventoryItem a, InventoryItem b)? comparator,
  }) {
    return _inventoryManager.getSortedItems(comparator: comparator);
  }

  /// Filter items
  List<InventoryItem> filterItems(bool Function(InventoryItem) predicate) {
    return _inventoryManager.filterItems(predicate);
  }

  /// Get items by category
  List<InventoryItem> getItemsByCategory(String category) {
    return _inventoryManager.getItemsByCategory(category);
  }

  /// Get slot count
  int get slotCount => _inventoryManager.slotCount;

  /// Get available slots
  int get availableSlots => _inventoryManager.availableSlots;

  /// Check if inventory is full
  bool get isFull => _inventoryManager.isFull;

  /// Get total item count
  int get totalItemCount => _inventoryManager.totalItemCount;

  /// Get storage percentage
  double get storagePercentage => _inventoryManager.storagePercentage;

  /// Check if can add item
  bool canAddItem(String itemId, int amount) {
    return _inventoryManager.canAddItem(itemId, amount);
  }

  /// Batch add items
  Map<String, InventoryResult> addItems(Map<String, int> itemsToAdd) {
    final results = _inventoryManager.addItems(itemsToAdd);

    // Check if any succeeded
    if (results.values.any((r) => r.success)) {
      _syncToGameState();
    }

    return results;
  }

  /// Batch remove items
  Map<String, InventoryResult> removeItems(Map<String, int> itemsToRemove) {
    final results = _inventoryManager.removeItems(itemsToRemove);

    // Check if any succeeded
    if (results.values.any((r) => r.success)) {
      _syncToGameState();
    }

    return results;
  }

  /// Clear inventory
  void clear() {
    _inventoryManager.clear();
    _syncToGameState();
  }

  /// Set max slots (from upgrades)
  void setMaxSlots(int slots) {
    _inventoryManager.setMaxSlots(slots);
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return _inventoryManager.toJson();
  }

  /// Deserialize from JSON
  void fromJson(Map<String, dynamic> json) {
    _inventoryManager.fromJson(json);
    _syncToGameState();
  }

  @override
  String toString() {
    return _inventoryManager.toString();
  }
}
