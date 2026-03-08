import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

// ============================================================
// Color Constants
// ============================================================
// Default colors for progress bars (game-specific palette)
const Color _defaultFillColor = MGColors.warning; // Dark goldenrod
const Color _defaultBackgroundColor = MGColors.textMediumEmphasis; // Light tan
const Color _defaultBorderColor = MGColors.border; // Dark brown
const Color _defaultTextColor = Color(0xFF2F4F4F); // Dark slate gray

const Color _timerFillColor = MGColors.info; // Royal blue
const Color _timerTextColor = Color(0xFFFFF8DC); // Cornsilk

/// Progress bar component for Flame game scenes
/// 
/// Uses Flame's PositionComponent for game engine integration.
/// Cannot be replaced with MGLinearProgress (Flutter widget) due to:
/// - Flame's canvas-based rendering pipeline
/// - Game loop integration (update/render cycle)
/// - Border/stroke styling not available in MGLinearProgress
/// 
/// For Flutter-based UI, use MGLinearProgress from mg_common_game.
/// See: ANALYSIS_MG_GAME_0002_PROGRESSBAR_REFACTOR.md
class ProgressBar extends PositionComponent {
  double _progress; // 0.0 to 1.0
  final Color fillColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool showPercentage;
  @override
  final double height;

  ProgressBar({
    required Vector2 position,
    required Vector2 size,
    double progress = 0.0,
    this.fillColor = _defaultFillColor,
    this.backgroundColor = _defaultBackgroundColor,
    this.borderColor = _defaultBorderColor,
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
          color: _defaultTextColor,
          shadows: [
            Shadow(
              color: MGColors.textHighEmphasis,
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
/// 
/// Extends ProgressBar with duration-based countdown logic.
/// Automatically decrements remaining time via game loop (update method).
/// 
/// Note: Cannot be replaced with MGLinearProgress due to:
/// - Requires game loop integration for countdown
/// - Uses canvas rendering for Flame compatibility
class TimerProgressBar extends PositionComponent {
  Duration _remaining;
  final Duration total;
  final Color fillColor;
  final Color backgroundColor;
  final Color borderColor;
  @override
  final double height;

  TimerProgressBar({
    required Vector2 position,
    required Vector2 size,
    required Duration remaining,
    required this.total,
    this.fillColor = _timerFillColor,
    this.backgroundColor = _defaultBackgroundColor,
    this.borderColor = _defaultBorderColor,
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
        color: _timerTextColor,
        shadows: [
          Shadow(
            color: _defaultTextColor,
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
