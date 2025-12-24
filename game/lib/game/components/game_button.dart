import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// Reusable game button component
class GameButton extends PositionComponent with TapCallbacks {
  String text;
  final VoidCallback onPressed;
  Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final bool enabled;

  bool _isPressed = false;

  GameButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF8B6914), // Dark goldenrod
    this.textColor = const Color(0xFFFFF8DC), // Cornsilk
    this.fontSize = 20,
    this.enabled = true,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  bool _visible = true;

  bool get isVisible => _visible;
  set isVisible(bool visible) => _visible = visible;

  @override
  void render(Canvas canvas) {
    if (!_visible) return;
    super.render(canvas);

    // Button background
    final rect = size.toRect();
    final bgColor = enabled
        ? (_isPressed ? backgroundColor.withOpacity(0.8) : backgroundColor)
        : backgroundColor.withOpacity(0.5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = bgColor,
    );

    // Button border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color =
            const Color(0xFF5D4E37) // Dark brown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Button text
    final textPaint = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: enabled ? textColor : textColor.withOpacity(0.5),
      ),
    );

    textPaint.render(
      canvas,
      text,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_visible) return;
    if (enabled) {
      _isPressed = true;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (enabled && _isPressed) {
      _isPressed = false;
      onPressed();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}

/// Icon button variant
class GameIconButton extends PositionComponent with TapCallbacks {
  final String iconText; // Simple emoji/text icon
  final VoidCallback onPressed;
  final Color backgroundColor;
  final bool enabled;

  bool _isPressed = false;

  GameIconButton({
    required this.iconText,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF8B6914),
    this.enabled = true,
    required Vector2 position,
    required double size,
  }) : super(
         position: position,
         size: Vector2.all(size),
         anchor: Anchor.center,
       );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Button background (circular)
    final radius = size.x / 2;
    final center = Offset(radius, radius);
    final bgColor = enabled
        ? (_isPressed ? backgroundColor.withOpacity(0.8) : backgroundColor)
        : backgroundColor.withOpacity(0.5);

    canvas.drawCircle(center, radius, Paint()..color = bgColor);

    // Button border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF5D4E37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Icon text
    final textPaint = TextPaint(
      style: TextStyle(
        fontSize: size.x * 0.5,
        color: enabled
            ? const Color(0xFFFFF8DC)
            : const Color(0xFFFFF8DC).withOpacity(0.5),
      ),
    );

    textPaint.render(
      canvas,
      iconText,
      Vector2(radius, radius),
      anchor: Anchor.center,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (enabled) {
      _isPressed = true;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (enabled && _isPressed) {
      _isPressed = false;
      onPressed();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}
