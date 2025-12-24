import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'game_button.dart';

/// Dialog box component for popups and messages
class DialogBox extends PositionComponent {
  final String title;
  final String message;
  final List<DialogButton> buttons;
  final VoidCallback? onClose;

  DialogBox({
    required this.title,
    required this.message,
    required this.buttons,
    this.onClose,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add buttons
    final buttonY = size.y - 80;
    final buttonSpacing = 20.0;
    final totalButtonWidth =
        buttons.length * 150.0 + (buttons.length - 1) * buttonSpacing;
    var buttonX = (size.x - totalButtonWidth) / 2;

    for (final button in buttons) {
      final gameButton = GameButton(
        text: button.text,
        onPressed: () {
          button.onPressed();
          if (button.closeOnPress) {
            onClose?.call();
          }
        },
        position: Vector2(buttonX + 75, buttonY),
        size: Vector2(150, 50),
        backgroundColor: button.color,
      );

      buttonX += 150 + buttonSpacing;
      add(gameButton);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = size.toRect();

    // Semi-transparent background overlay (for dimming)
    // Note: This should be rendered before the dialog in the scene

    // Dialog background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      Paint()..color = const Color(0xFFF5E6D3), // Warm cream
    );

    // Dialog border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      Paint()
        ..color =
            const Color(0xFF8B4513) // Saddle brown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Title background bar
    final titleBarRect = Rect.fromLTWH(0, 0, size.x, 60);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        titleBarRect,
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFF8B6914), // Dark goldenrod
    );

    // Title text
    final titlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFF8DC), // Cornsilk
      ),
    );

    titlePaint.render(
      canvas,
      title,
      Vector2(size.x / 2, 30),
      anchor: Anchor.center,
    );

    // Message text (word wrap)
    final messagePaint = TextPaint(
      style: const TextStyle(
        fontSize: 18,
        color: Color(0xFF5D4E37), // Dark brown
        height: 1.5,
      ),
    );

    final lines = _wrapText(message, size.x - 40, messagePaint);
    var messageY = 90.0;

    for (final line in lines) {
      messagePaint.render(
        canvas,
        line,
        Vector2(size.x / 2, messageY),
        anchor: Anchor.center,
      );
      messageY += 28;
    }
  }

  /// Simple word wrap for message text
  List<String> _wrapText(String text, double maxWidth, TextPaint paint) {
    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      final textWidth = _measureTextWidth(testLine, paint);

      if (textWidth <= maxWidth) {
        currentLine = testLine;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  /// Measure text width (approximate)
  double _measureTextWidth(String text, TextPaint paint) {
    // Rough approximation: average character width * length
    return text.length * (paint.style.fontSize ?? 18) * 0.6;
  }
}

/// Dialog button configuration
class DialogButton {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool closeOnPress;

  DialogButton({
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF8B6914), // Dark goldenrod
    this.closeOnPress = true,
  });
}

/// Confirmation dialog
class ConfirmDialog extends DialogBox {
  ConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onClose,
    required Vector2 position,
  }) : super(
         title: title,
         message: message,
         buttons: [
           DialogButton(
             text: 'Cancel',
             onPressed: onCancel ?? () {},
             color: const Color(0xFF808080), // Gray
           ),
           DialogButton(
             text: 'Confirm',
             onPressed: onConfirm,
             color: const Color(0xFF228B22), // Forest green
           ),
         ],
         onClose: onClose,
         position: position,
         size: Vector2(500, 300),
       );
}

/// Info dialog (single OK button)
class InfoDialog extends DialogBox {
  InfoDialog({
    required String title,
    required String message,
    VoidCallback? onOk,
    VoidCallback? onClose,
    required Vector2 position,
  }) : super(
         title: title,
         message: message,
         buttons: [
           DialogButton(
             text: 'OK',
             onPressed: onOk ?? () {},
             color: const Color(0xFF8B6914),
           ),
         ],
         onClose: onClose,
         position: position,
         size: Vector2(450, 250),
       );
}

/// Reward dialog (shows offline rewards, recipe discovery, etc.)
class RewardDialog extends DialogBox {
  final Map<String, int> rewards;

  RewardDialog({
    required String title,
    required this.rewards,
    VoidCallback? onCollect,
    VoidCallback? onClose,
    required Vector2 position,
  }) : super(
         title: title,
         message: _buildRewardMessage(rewards),
         buttons: [
           DialogButton(
             text: 'Collect',
             onPressed: onCollect ?? () {},
             color: const Color(0xFFFFD700), // Gold
           ),
         ],
         onClose: onClose,
         position: position,
         size: Vector2(500, 400),
       );

  static String _buildRewardMessage(Map<String, int> rewards) {
    if (rewards.isEmpty) return 'No rewards to collect.';

    final items = rewards.entries
        .map((e) => '${e.key}: +${e.value}')
        .join('\n');
    return 'You received:\n\n$items';
  }
}
