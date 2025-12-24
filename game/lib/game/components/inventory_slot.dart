import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// Inventory slot component for displaying items
class InventorySlot extends PositionComponent with TapCallbacks {
  final String? itemId;
  final int amount;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isEmpty;

  InventorySlot({
    this.itemId,
    this.amount = 0,
    this.onTap,
    this.isSelected = false,
    required Vector2 position,
    required double size,
  })  : isEmpty = itemId == null || amount == 0,
        super(
          position: position,
          size: Vector2.all(size),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = size.toRect();

    // Slot background
    final bgColor = isSelected
        ? const Color(0xFFFFD700) // Gold when selected
        : const Color(0xFFD4B896); // Light tan

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = bgColor.withOpacity(isEmpty ? 0.5 : 1.0),
    );

    // Slot border
    final borderColor = isSelected
        ? const Color(0xFF8B6914) // Dark goldenrod
        : const Color(0xFFA0826D); // Light brown

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (!isEmpty && itemId != null) {
      // Item icon (placeholder - will be replaced with actual sprite)
      final iconSize = size.x * 0.6;
      final iconPos = Vector2(size.x / 2, size.y / 2 - 5);

      final iconPaint = TextPaint(
        style: TextStyle(
          fontSize: iconSize * 0.8,
          color: const Color(0xFF8B4513),
        ),
      );

      // Use item ID as placeholder icon
      final iconText = _getItemIcon(itemId!);
      iconPaint.render(
        canvas,
        iconText,
        iconPos,
        anchor: Anchor.center,
      );

      // Amount text
      if (amount > 1) {
        final amountText = TextPaint(
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F4F4F), // Dark slate gray
            shadows: [
              Shadow(
                color: Colors.white,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        );

        amountText.render(
          canvas,
          amount.toString(),
          Vector2(size.x - 8, size.y - 8),
          anchor: Anchor.bottomRight,
        );
      }
    }
  }

  /// Get placeholder icon for item (will be replaced with actual sprites)
  String _getItemIcon(String itemId) {
    // Temporary emoji icons based on item type
    if (itemId.contains('grass')) return '🌿';
    if (itemId.contains('water')) return '💧';
    if (itemId.contains('stone')) return '🪨';
    if (itemId.contains('branch')) return '🪵';
    if (itemId.contains('ember')) return '🔥';
    if (itemId.contains('dew')) return '💎';
    if (itemId.contains('pollen')) return '✨';
    if (itemId.contains('crystal')) return '💠';
    if (itemId.contains('moonlight')) return '🌙';
    if (itemId.contains('stardust')) return '⭐';
    if (itemId.contains('spirit')) return '👻';
    if (itemId.contains('dragon')) return '🐉';
    if (itemId.contains('phoenix')) return '🔥';
    if (itemId.contains('time')) return '⏳';
    if (itemId.contains('world_tree')) return '🌳';
    if (itemId.contains('mana')) return '🔮';
    if (itemId.contains('potion')) return '🧪';
    return '📦';
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!isEmpty && onTap != null) {
      onTap!();
    }
  }
}

/// Grid of inventory slots
class InventoryGrid extends PositionComponent {
  final Map<String, int> items;
  final int columns;
  final int rows;
  final double slotSize;
  final double spacing;
  final Function(String itemId)? onItemTap;
  final String? selectedItemId;

  InventoryGrid({
    required this.items,
    required this.columns,
    required this.rows,
    this.slotSize = 64,
    this.spacing = 8,
    this.onItemTap,
    this.selectedItemId,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildGrid();
  }

  void _buildGrid() {
    removeAll(children);

    final itemList = items.entries.toList();
    int itemIndex = 0;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final slotPos = Vector2(
          col * (slotSize + spacing) + slotSize / 2,
          row * (slotSize + spacing) + slotSize / 2,
        );

        String? itemId;
        int amount = 0;

        if (itemIndex < itemList.length) {
          itemId = itemList[itemIndex].key;
          amount = itemList[itemIndex].value;
          itemIndex++;
        }

        final slot = InventorySlot(
          itemId: itemId,
          amount: amount,
          position: slotPos,
          size: slotSize,
          isSelected: itemId == selectedItemId,
          onTap: itemId != null && onItemTap != null
              ? () => onItemTap!(itemId!)
              : null,
        );

        add(slot);
      }
    }
  }

  /// Update grid with new items
  void updateItems(Map<String, int> newItems, {String? newSelectedId}) {
    items.clear();
    items.addAll(newItems);
    _buildGrid();
  }
}
