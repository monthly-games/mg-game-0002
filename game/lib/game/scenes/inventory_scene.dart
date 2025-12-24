import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../components/inventory_slot.dart';
import '../cat_alchemy_game.dart';

/// Inventory scene - dedicated inventory management
class InventoryScene extends Component with HasGameRef {
  final WidgetRef ref;

  // UI Components
  late TextComponent _titleText;
  late TextComponent _inventoryInfoText;
  late GameButton _backButton;
  late GameButton _sortButton;
  late GameButton _filterAllButton;
  late GameButton _filterMaterialsButton;
  late GameButton _filterPotionsButton;

  // Inventory display
  final List<InventorySlot> _inventorySlots = [];
  String _currentFilter = 'all'; // 'all', 'materials', 'potions'
  String _currentSort = 'default'; // 'default', 'name', 'quantity', 'value'

  // Constants
  static const int _slotsPerRow = 10;
  static const int _totalRows = 10;
  static const int _totalSlots = 100;
  static const double _slotSize = 60.0;
  static const double _slotSpacing = 8.0;

  InventoryScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setupUI();
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Title
    _titleText = TextComponent(
      text: 'Inventory',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513), // Saddle brown
        ),
      ),
      position: Vector2(size.x / 2, 40),
      anchor: Anchor.center,
    );
    add(_titleText);

    // Back button
    _backButton = GameButton(
      text: '← Back',
      onPressed: _goBack,
      position: Vector2(80, 40),
      size: Vector2(120, 50),
    );
    add(_backButton);

    // Inventory info (slots used)
    final gameState = ref.read(gameStateProvider);
    final usedSlots = gameState.inventory.length;
    _inventoryInfoText = TextComponent(
      text: 'Slots: $usedSlots / $_totalSlots',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 20, color: Color(0xFF5D4E37)),
      ),
      position: Vector2(size.x - 150, 40),
      anchor: Anchor.center,
    );
    add(_inventoryInfoText);

    // Filter buttons
    _addFilterButtons();

    // Sort button
    _sortButton = GameButton(
      text: 'Sort: Default',
      onPressed: _cycleSortMode,
      position: Vector2(size.x / 2 + 200, 100),
      size: Vector2(160, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFF8B6914),
    );
    add(_sortButton);

    // Build inventory grid
    _buildInventoryGrid();
  }

  /// Add filter buttons
  void _addFilterButtons() {
    final size = gameRef.size;
    final centerX = size.x / 2;

    // All filter
    _filterAllButton = GameButton(
      text: 'All',
      onPressed: () => _setFilter('all'),
      position: Vector2(centerX - 240, 100),
      size: Vector2(100, 45),
      fontSize: 18,
      backgroundColor: const Color(0xFF8B6914),
    );
    add(_filterAllButton);

    // Materials filter
    _filterMaterialsButton = GameButton(
      text: 'Materials',
      onPressed: () => _setFilter('materials'),
      position: Vector2(centerX - 120, 100),
      size: Vector2(120, 45),
      fontSize: 18,
      backgroundColor: const Color(0xFFD4B896),
    );
    add(_filterMaterialsButton);

    // Potions filter
    _filterPotionsButton = GameButton(
      text: 'Potions',
      onPressed: () => _setFilter('potions'),
      position: Vector2(centerX + 20, 100),
      size: Vector2(120, 45),
      fontSize: 18,
      backgroundColor: const Color(0xFFD4B896),
    );
    add(_filterPotionsButton);
  }

  /// Build inventory grid
  void _buildInventoryGrid() {
    final size = gameRef.size;
    final gameState = ref.read(gameStateProvider);

    // Get filtered and sorted items
    final items = _getFilteredSortedItems(gameState.inventory);

    // Calculate grid start position (centered)
    final gridWidth = _slotsPerRow * (_slotSize + _slotSpacing) - _slotSpacing;
    final gridStartX = (size.x - gridWidth) / 2;
    final gridStartY = 170.0;

    // Clear existing slots
    for (final slot in _inventorySlots) {
      if (slot.isMounted) {
        remove(slot);
      }
    }
    _inventorySlots.clear();

    // Create slots
    int slotIndex = 0;
    for (int row = 0; row < _totalRows; row++) {
      for (int col = 0; col < _slotsPerRow; col++) {
        final x = gridStartX + col * (_slotSize + _slotSpacing);
        final y = gridStartY + row * (_slotSize + _slotSpacing);

        String? itemId;
        int? quantity;

        // Fill with items if available
        if (slotIndex < items.length) {
          final entry = items[slotIndex];
          itemId = entry.key;
          quantity = entry.value;
        }

        final slot = InventorySlot(
          position: Vector2(x, y),
          size: _slotSize,
          itemId: itemId,
          amount: quantity ?? 0,
          onTap: itemId != null ? () => _onSlotTap(itemId!) : null,
        );

        add(slot);
        _inventorySlots.add(slot);
        slotIndex++;
      }
    }
  }

  /// Get filtered and sorted items
  List<MapEntry<String, int>> _getFilteredSortedItems(
    Map<String, int> inventory,
  ) {
    var items = inventory.entries.toList();

    // Apply filter
    if (_currentFilter != 'all') {
      items = items.where((entry) {
        final itemId = entry.key;

        if (_currentFilter == 'materials') {
          // Materials typically have IDs starting with 'mat_' or ending with '_herb', '_root', etc.
          return itemId.startsWith('mat_') ||
              itemId.contains('herb') ||
              itemId.contains('root') ||
              itemId.contains('grass') ||
              itemId.contains('flower') ||
              itemId.contains('crystal');
        } else if (_currentFilter == 'potions') {
          // Potions have IDs starting with 'potion_' or 'pot_'
          return itemId.startsWith('potion_') ||
              itemId.startsWith('pot_') ||
              itemId.contains('elixir') ||
              itemId.contains('brew');
        }

        return true;
      }).toList();
    }

    // Apply sort
    switch (_currentSort) {
      case 'name':
        items.sort((a, b) => a.key.compareTo(b.key));
        break;
      case 'quantity':
        items.sort((a, b) => b.value.compareTo(a.value)); // Descending
        break;
      case 'value':
        // TODO: Sort by item value when item data is available
        // For now, use name sort
        items.sort((a, b) => a.key.compareTo(b.key));
        break;
      case 'default':
      default:
        // Keep insertion order
        break;
    }

    return items;
  }

  /// Set filter mode
  void _setFilter(String filter) {
    _currentFilter = filter;

    // Update button colors
    _filterAllButton.backgroundColor = filter == 'all'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);
    _filterMaterialsButton.backgroundColor = filter == 'materials'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);
    _filterPotionsButton.backgroundColor = filter == 'potions'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);

    // Rebuild grid
    _buildInventoryGrid();
  }

  /// Cycle sort mode
  void _cycleSortMode() {
    switch (_currentSort) {
      case 'default':
        _currentSort = 'name';
        _sortButton.text = 'Sort: Name';
        break;
      case 'name':
        _currentSort = 'quantity';
        _sortButton.text = 'Sort: Quantity';
        break;
      case 'quantity':
        _currentSort = 'value';
        _sortButton.text = 'Sort: Value';
        break;
      case 'value':
        _currentSort = 'default';
        _sortButton.text = 'Sort: Default';
        break;
    }

    // Rebuild grid
    _buildInventoryGrid();
  }

  /// Handle slot tap
  void _onSlotTap(String itemId) {
    final gameState = ref.read(gameStateProvider);
    final quantity = gameState.inventory[itemId] ?? 0;

    // Show item details dialog
    _showItemDetails(itemId, quantity);
  }

  /// Show item details
  void _showItemDetails(String itemId, int quantity) {
    final size = gameRef.size;

    // Get item info (placeholder - would fetch from data in production)
    final itemName = _getItemDisplayName(itemId);
    final itemType = _getItemType(itemId);

    // Create dialog background
    final dialogBg = RectangleComponent(
      position: size / 2,
      size: Vector2(400, 300),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFE8D5B7),
    );
    add(dialogBg);

    // Item name
    final nameText = TextComponent(
      text: itemName,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: size / 2 + Vector2(0, -120),
      anchor: Anchor.center,
    );
    add(nameText);

    // Item type
    final typeText = TextComponent(
      text: 'Type: $itemType',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18, color: Color(0xFF5D4E37)),
      ),
      position: size / 2 + Vector2(0, -80),
      anchor: Anchor.center,
    );
    add(typeText);

    // Quantity
    final quantityText = TextComponent(
      text: 'Quantity: $quantity / 999',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18, color: Color(0xFF5D4E37)),
      ),
      position: size / 2 + Vector2(0, -40),
      anchor: Anchor.center,
    );
    add(quantityText);

    // Item ID (for debugging)
    final idText = TextComponent(
      text: 'ID: $itemId',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Color(0xFF808080)),
      ),
      position: size / 2 + Vector2(0, 0),
      anchor: Anchor.center,
    );
    add(idText);

    // Close button
    final closeButton = GameButton(
      text: 'Close',
      onPressed: () {
        remove(dialogBg);
        remove(nameText);
        remove(typeText);
        remove(quantityText);
        remove(idText);
      },
      position: size / 2 + Vector2(0, 80),
      size: Vector2(120, 50),
    );
    add(closeButton);
  }

  /// Get item display name (placeholder)
  String _getItemDisplayName(String itemId) {
    // Remove prefixes and format
    return itemId
        .replaceAll('mat_', '')
        .replaceAll('potion_', '')
        .replaceAll('pot_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  /// Get item type (placeholder)
  String _getItemType(String itemId) {
    if (itemId.startsWith('mat_') ||
        itemId.contains('herb') ||
        itemId.contains('root') ||
        itemId.contains('grass') ||
        itemId.contains('flower') ||
        itemId.contains('crystal')) {
      return 'Material';
    } else if (itemId.startsWith('potion_') ||
        itemId.startsWith('pot_') ||
        itemId.contains('elixir') ||
        itemId.contains('brew')) {
      return 'Potion';
    }
    return 'Item';
  }

  /// Update inventory info display
  void _updateInventoryInfo() {
    final gameState = ref.read(gameStateProvider);
    final usedSlots = gameState.inventory.length;
    _inventoryInfoText.text = 'Slots: $usedSlots / $_totalSlots';
  }

  /// Go back to home scene
  void _goBack() {
    if (gameRef is CatAlchemyGame) {
      (gameRef as CatAlchemyGame).navigateTo('home');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background
    final size = gameRef.size;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFF5E6D3), // Warm cream
    );

    // Grid background panel
    final gridWidth = _slotsPerRow * (_slotSize + _slotSpacing) + 20;
    final gridHeight = _totalRows * (_slotSize + _slotSpacing) + 20;
    final gridStartX = (size.x - gridWidth) / 2;
    final gridStartY = 160.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(gridStartX, gridStartY, gridWidth, gridHeight),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF8B6914).withOpacity(0.1),
    );
  }
}
