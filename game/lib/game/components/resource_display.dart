import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Resource display component (gold, gems, materials)
class ResourceDisplay extends PositionComponent {
  final String iconText; // Emoji or text icon
  int _amount;
  final Color iconColor;
  final Color textColor;
  final double fontSize;

  ResourceDisplay({
    required this.iconText,
    required int amount,
    this.iconColor = const Color(0xFFFFD700), // Gold
    this.textColor = const Color(0xFF2F4F4F), // Dark slate gray
    this.fontSize = 20,
    required Vector2 position,
  })  : _amount = amount,
        super(
          position: position,
          size: Vector2(150, 40),
          anchor: Anchor.topLeft,
        );

  /// Get current amount
  int get amount => _amount;

  /// Set amount
  set amount(int value) {
    _amount = value;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background
    final rect = size.toRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      Paint()..color = const Color(0xFFD4B896).withOpacity(0.8), // Light tan
    );

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      Paint()
        ..color = const Color(0xFF8B6914) // Dark goldenrod
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Icon
    final iconPaint = TextPaint(
      style: TextStyle(
        fontSize: fontSize * 1.2,
        color: iconColor,
      ),
    );

    iconPaint.render(
      canvas,
      iconText,
      Vector2(10, size.y / 2),
      anchor: Anchor.centerLeft,
    );

    // Amount text
    final amountPaint = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    final formattedAmount = _formatNumber(_amount);
    amountPaint.render(
      canvas,
      formattedAmount,
      Vector2(size.x - 10, size.y / 2),
      anchor: Anchor.centerRight,
    );
  }

  /// Format large numbers (1000 -> 1K, 1000000 -> 1M)
  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// Compact resource display (icon + number, no background)
class CompactResourceDisplay extends PositionComponent {
  final String iconText;
  int _amount;
  final double iconSize;

  CompactResourceDisplay({
    required this.iconText,
    required int amount,
    this.iconSize = 24,
    required Vector2 position,
  })  : _amount = amount,
        super(
          position: position,
          size: Vector2(100, 30),
          anchor: Anchor.centerLeft,
        );

  int get amount => _amount;
  set amount(int value) => _amount = value;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Icon
    final iconPaint = TextPaint(
      style: TextStyle(fontSize: iconSize),
    );

    iconPaint.render(
      canvas,
      iconText,
      Vector2(0, size.y / 2),
      anchor: Anchor.centerLeft,
    );

    // Amount
    final amountPaint = TextPaint(
      style: TextStyle(
        fontSize: iconSize * 0.8,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFF8DC), // Cornsilk
        shadows: const [
          Shadow(
            color: Color(0xFF2F4F4F),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );

    amountPaint.render(
      canvas,
      _amount.toString(),
      Vector2(iconSize + 5, size.y / 2),
      anchor: Anchor.centerLeft,
    );
  }
}

/// Resource panel with multiple resources
class ResourcePanel extends PositionComponent {
  final Map<String, ResourcePanelItem> items;
  final bool vertical;
  final double spacing;

  ResourcePanel({
    required this.items,
    this.vertical = false,
    this.spacing = 10,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildPanel();
  }

  void _buildPanel() {
    removeAll(children);

    double offset = 0;
    for (final entry in items.entries) {
      final item = entry.value;
      final display = ResourceDisplay(
        iconText: item.icon,
        amount: item.amount,
        iconColor: item.color,
        position: vertical ? Vector2(0, offset) : Vector2(offset, 0),
      );

      add(display);

      offset += (vertical ? 40 : 150) + spacing;
    }
  }

  /// Update resource amounts
  void updateAmounts(Map<String, int> newAmounts) {
    for (final entry in newAmounts.entries) {
      if (items.containsKey(entry.key)) {
        items[entry.key]!.amount = entry.value;
      }
    }
    _buildPanel();
  }
}

/// Resource panel item configuration
class ResourcePanelItem {
  final String icon;
  int amount;
  final Color color;

  ResourcePanelItem({
    required this.icon,
    required this.amount,
    this.color = const Color(0xFFFFD700),
  });
}
