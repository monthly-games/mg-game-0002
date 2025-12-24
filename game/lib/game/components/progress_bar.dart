import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Progress bar component for crafting, gathering, etc.
class ProgressBar extends PositionComponent {
  double _progress; // 0.0 to 1.0
  final Color fillColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool showPercentage;
  final double height;

  ProgressBar({
    required Vector2 position,
    required Vector2 size,
    double progress = 0.0,
    this.fillColor = const Color(0xFF8B6914), // Dark goldenrod
    this.backgroundColor = const Color(0xFFD4B896), // Light tan
    this.borderColor = const Color(0xFF5D4E37), // Dark brown
    this.showPercentage = true,
    this.height = 20,
  })  : _progress = progress.clamp(0.0, 1.0),
        super(
          position: position,
          size: size,
          anchor: Anchor.topLeft,
        );

  /// Get current progress
  double get progress => _progress;

  /// Set progress (0.0 to 1.0)
  set progress(double value) {
    _progress = value.clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, height);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = backgroundColor,
    );

    // Fill
    if (_progress > 0) {
      final fillRect = Rect.fromLTWH(0, 0, size.x * _progress, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(10)),
        Paint()..color = fillColor,
      );
    }

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Percentage text
    if (showPercentage) {
      final textPaint = TextPaint(
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

      textPaint.render(
        canvas,
        '${(_progress * 100).toInt()}%',
        Vector2(size.x / 2, height / 2),
        anchor: Anchor.center,
      );
    }
  }
}

/// Timer progress bar with countdown text
class TimerProgressBar extends PositionComponent {
  Duration _remaining;
  final Duration total;
  final Color fillColor;
  final Color backgroundColor;
  final Color borderColor;
  final double height;

  TimerProgressBar({
    required Vector2 position,
    required Vector2 size,
    required Duration remaining,
    required this.total,
    this.fillColor = const Color(0xFF4169E1), // Royal blue
    this.backgroundColor = const Color(0xFFD4B896),
    this.borderColor = const Color(0xFF5D4E37),
    this.height = 24,
  })  : _remaining = remaining,
        super(
          position: position,
          size: size,
          anchor: Anchor.topLeft,
        );

  /// Get remaining time
  Duration get remaining => _remaining;

  /// Set remaining time
  set remaining(Duration value) {
    _remaining = value;
  }

  /// Get progress (0.0 = complete, 1.0 = just started)
  double get progress {
    if (total.inMilliseconds == 0) return 0.0;
    return (_remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Countdown
    if (_remaining > Duration.zero) {
      _remaining -= Duration(milliseconds: (dt * 1000).round());
      if (_remaining < Duration.zero) {
        _remaining = Duration.zero;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, height);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = backgroundColor,
    );

    // Fill (reverse progress - fills from full to empty)
    if (progress > 0) {
      final fillRect = Rect.fromLTWH(0, 0, size.x * progress, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(10)),
        Paint()..color = fillColor,
      );
    }

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Time text
    final timeText = _formatDuration(_remaining);
    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFF8DC), // Cornsilk
        shadows: [
          Shadow(
            color: Color(0xFF2F4F4F),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );

    textPaint.render(
      canvas,
      timeText,
      Vector2(size.x / 2, height / 2),
      anchor: Anchor.center,
    );
  }

  /// Format duration to readable string (MM:SS or HH:MM:SS)
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }
}
