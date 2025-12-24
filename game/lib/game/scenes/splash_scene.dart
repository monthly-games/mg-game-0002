import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/game_initialization_service.dart';
import '../cat_alchemy_game.dart';

/// Splash screen scene - shows logo and loads game data
class SplashScene extends Component with HasGameRef {
  final WidgetRef ref;
  bool _isInitialized = false;
  double _loadingProgress = 0.0;

  SplashScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeGame();
  }

  /// Initialize game systems
  Future<void> _initializeGame() async {
    try {
      // Show loading progress
      _updateProgress(0.1, 'Loading game data...');

      // Initialize game initialization service
      final initService = ref.read(gameInitializationServiceProvider);

      _updateProgress(0.3, 'Initializing systems...');

      // Initialize all systems
      await initService.initialize();

      _updateProgress(0.8, 'Calculating offline rewards...');

      // Small delay to show splash
      await Future.delayed(const Duration(milliseconds: 500));

      _updateProgress(1.0, 'Ready!');

      // Mark as initialized
      _isInitialized = true;

      // Transition to home scene after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      _transitionToHome();
    } catch (e) {
      print('Error initializing game: $e');
      // TODO: Show error screen
    }
  }

  /// Update loading progress
  void _updateProgress(double progress, String message) {
    _loadingProgress = progress;
    print('[$message] Progress: ${(_loadingProgress * 100).toStringAsFixed(0)}%');
  }

  /// Transition to home scene
  void _transitionToHome() {
    // Get game instance and navigate
    if (gameRef is CatAlchemyGame) {
      (gameRef as CatAlchemyGame).navigateTo('home');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Simple splash screen rendering
    // TODO: Replace with actual logo and styled loading bar

    final size = gameRef.size;
    final center = size / 2;

    // Background color
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFF5E6D3), // Warm cream color
    );

    // Title text
    final titlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFF8B4513), // Saddle brown
      ),
    );

    titlePaint.render(
      canvas,
      '고양이 연금술 공방',
      Vector2(center.x, center.y - 100),
      anchor: Anchor.center,
    );

    // Subtitle
    final subtitlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 20,
        color: Color(0xFFA0826D), // Light brown
      ),
    );

    subtitlePaint.render(
      canvas,
      'Cat Alchemy Workshop',
      Vector2(center.x, center.y - 50),
      anchor: Anchor.center,
    );

    // Loading bar
    if (!_isInitialized) {
      final barWidth = 300.0;
      final barHeight = 20.0;
      final barX = center.x - barWidth / 2;
      final barY = center.y + 50;

      // Bar background
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth, barHeight),
          const Radius.circular(10),
        ),
        Paint()..color = const Color(0xFFD4B896), // Light tan
      );

      // Bar fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth * _loadingProgress, barHeight),
          const Radius.circular(10),
        ),
        Paint()..color = const Color(0xFF8B6914), // Dark goldenrod
      );

      // Loading percentage text
      final progressText = TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF8B4513),
        ),
      );

      progressText.render(
        canvas,
        '${(_loadingProgress * 100).toInt()}%',
        Vector2(center.x, barY + barHeight + 30),
        anchor: Anchor.center,
      );
    }
  }
}
