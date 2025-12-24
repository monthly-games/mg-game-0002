import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';

/// Tutorial scene - interactive guide for new players
class TutorialScene extends Component with HasGameRef {
  final WidgetRef ref;

  // Tutorial state
  int _currentStep = 0;
  final List<TutorialStep> _tutorialSteps = [];

  // UI Components
  late GameButton _backButton;
  late GameButton _prevButton;
  late GameButton _nextButton;
  late GameButton _skipButton;

  TutorialScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeTutorialSteps();
    await _setupUI();
  }

  /// Initialize tutorial steps
  void _initializeTutorialSteps() {
    _tutorialSteps.addAll([
      TutorialStep(
        title: 'Welcome to Cat Alchemy Workshop!',
        description: 'You are an alchemist running a magical workshop with your cat companion. Your goal is to craft potions, fulfill orders, and grow your business!',
        icon: '🏠',
        tips: [
          'This is your workshop hub',
          'All game features are accessible from here',
          'Your cat will help you gather materials',
        ],
      ),
      TutorialStep(
        title: 'Resources',
        description: 'You have two main currencies: Gold (💰) and Gems (💎). Gold is earned from selling potions and completing orders. Gems are premium currency for special upgrades.',
        icon: '💰',
        tips: [
          'Gold: Common currency for crafting and upgrades',
          'Gems: Premium currency for special items',
          'Workshop Level: Unlocks new features',
        ],
      ),
      TutorialStep(
        title: 'Gathering Materials',
        description: 'Send your cat to gather herbs, flowers, and magical ingredients. Different locations yield different materials!',
        icon: '🌿',
        tips: [
          'Click "Gathering" to send your cat',
          'Each location has unique materials',
          'Gathering takes time - check back later',
          'Upgrade gathering efficiency for faster collection',
        ],
      ),
      TutorialStep(
        title: 'Crafting Potions',
        description: 'Combine materials to create magical potions. Each potion requires specific ingredients and crafting time.',
        icon: '🔨',
        tips: [
          'Click "Crafting" to start brewing',
          'Select a recipe and required materials',
          'Wait for crafting to complete',
          'Higher tier potions sell for more gold',
        ],
      ),
      TutorialStep(
        title: 'Inventory Management',
        description: 'Your inventory can hold materials and crafted potions. Organize and manage your items efficiently!',
        icon: '🎒',
        tips: [
          'Check inventory for materials and potions',
          'Filter by type: All/Materials/Potions',
          'Sort by name, quantity, or value',
          'Upgrade inventory slots for more storage',
        ],
      ),
      TutorialStep(
        title: 'Recipe Codex',
        description: 'Discover new recipes by crafting and experimenting. The codex tracks all known and unknown recipes.',
        icon: '📖',
        tips: [
          'View all discovered recipes',
          'Locked recipes show tier hints',
          'Craft lower tier potions to unlock higher tiers',
          'Each recipe shows required materials',
        ],
      ),
      TutorialStep(
        title: 'Customer Orders',
        description: 'Customers will request specific potions. Complete orders to earn gold, reputation, and special rewards!',
        icon: '📜',
        tips: [
          'New orders appear regularly',
          'Each order has a deadline',
          'Complete orders for rewards',
          'Higher reputation unlocks better orders',
        ],
      ),
      TutorialStep(
        title: 'Shop',
        description: 'Purchase materials, recipes, and special items from the shop. New items become available as you progress.',
        icon: '🛒',
        tips: [
          'Buy materials when gathering is slow',
          'Purchase rare recipes',
          'Special items unlock new features',
          'Check shop regularly for deals',
        ],
      ),
      TutorialStep(
        title: 'Workshop Upgrades',
        description: 'Upgrade your workshop to improve efficiency, increase storage, and unlock new capabilities.',
        icon: '⬆️',
        tips: [
          'Upgrade production speed',
          'Increase inventory and storage',
          'Unlock auto-collection features',
          'Improve crafting quality',
        ],
      ),
      TutorialStep(
        title: 'Your Cat Companion',
        description: 'Your cat is more than just cute! Feed, pet, and play with your cat to improve their gathering abilities.',
        icon: '🐱',
        tips: [
          'Feed your cat for energy',
          'Pet for happiness bonus',
          'Play minigames for rewards',
          'Higher happiness = better gathering',
        ],
      ),
      TutorialStep(
        title: 'Achievements',
        description: 'Complete achievements to earn rewards and track your progress. Achievements span crafting, gathering, and social activities.',
        icon: '🏆',
        tips: [
          'Track your accomplishments',
          'Claim rewards when completed',
          'Four categories: Crafting, Gathering, Social, Progression',
          'Achievements give gold, gems, and experience',
        ],
      ),
      TutorialStep(
        title: 'Tips for Success',
        description: 'Master the art of alchemy with these expert tips!',
        icon: '✨',
        tips: [
          'Balance gathering and crafting',
          'Complete daily orders for steady income',
          'Upgrade strategically - focus on bottlenecks',
          'Keep your cat happy for efficiency',
          'Save gems for important upgrades',
          'Experiment with recipes to discover new potions',
        ],
      ),
      TutorialStep(
        title: "You're Ready!",
        description: 'You now know the basics of running your Cat Alchemy Workshop. Time to start your journey as a master alchemist!',
        icon: '🎓',
        tips: [
          'Start by gathering basic materials',
          'Craft your first potion',
          'Complete your first order',
          'Upgrade your workshop when ready',
          'Have fun and experiment!',
        ],
      ),
    ]);
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Back button
    _backButton = GameButton(
      text: '← Back',
      onPressed: _navigateBack,
      position: Vector2(20, 20),
      size: Vector2(120, 50),
      fontSize: 18,
      backgroundColor: const Color(0xFF808080), // Gray
    );
    add(_backButton);

    // Skip button
    _skipButton = GameButton(
      text: 'Skip Tutorial',
      onPressed: _skipTutorial,
      position: Vector2(size.x - 160, 20),
      size: Vector2(140, 50),
      fontSize: 16,
      backgroundColor: const Color(0xFF696969), // Dim gray
    );
    add(_skipButton);

    // Navigation buttons at bottom
    final bottomY = size.y - 80;
    final centerX = size.x / 2;

    _prevButton = GameButton(
      text: '← Previous',
      onPressed: _previousStep,
      position: Vector2(centerX - 220, bottomY),
      size: Vector2(140, 60),
      fontSize: 18,
      backgroundColor: const Color(0xFF4169E1), // Royal blue
    );
    add(_prevButton);

    _nextButton = GameButton(
      text: 'Next →',
      onPressed: _nextStep,
      position: Vector2(centerX + 80, bottomY),
      size: Vector2(140, 60),
      fontSize: 18,
      backgroundColor: const Color(0xFF228B22), // Forest green
    );
    add(_nextButton);

    _updateNavigationButtons();
  }

  /// Navigate to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _updateNavigationButtons();
    }
  }

  /// Navigate to next step
  void _nextStep() {
    if (_currentStep < _tutorialSteps.length - 1) {
      _currentStep++;
      _updateNavigationButtons();
    } else {
      _completeTutorial();
    }
  }

  /// Update navigation button states
  void _updateNavigationButtons() {
    // Update button visibility/appearance based on current step
    _prevButton.isVisible = _currentStep > 0;

    // Change next button text on last step
    if (_currentStep == _tutorialSteps.length - 1) {
      _nextButton.text = 'Finish! ✓';
    } else {
      _nextButton.text = 'Next →';
    }
  }

  /// Skip tutorial
  void _skipTutorial() {
    _navigateBack();
  }

  /// Complete tutorial
  void _completeTutorial() {
    // TODO: Mark tutorial as completed in game state
    _navigateBack();
  }

  /// Navigate back to home
  void _navigateBack() {
    if (gameRef is CatAlchemyGame) {
      (gameRef as CatAlchemyGame).navigateTo('home');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final size = gameRef.size;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFFF8DC), // Cornsilk
    );

    // Draw current tutorial step
    if (_currentStep >= 0 && _currentStep < _tutorialSteps.length) {
      _drawTutorialStep(canvas, _tutorialSteps[_currentStep]);
    }

    // Draw progress indicator
    _drawProgressIndicator(canvas);
  }

  /// Draw tutorial step content
  void _drawTutorialStep(Canvas canvas, TutorialStep step) {
    final size = gameRef.size;
    final centerX = size.x / 2;
    final startY = 120.0;

    // Icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: step.icon,
        style: const TextStyle(fontSize: 80),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(centerX - iconPainter.width / 2, startY),
    );

    // Title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: step.title,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513), // Saddle brown
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout(maxWidth: size.x - 80);
    titlePainter.paint(
      canvas,
      Offset(centerX - titlePainter.width / 2, startY + 120),
    );

    // Description
    final descPainter = TextPainter(
      text: TextSpan(
        text: step.description,
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFF333333),
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    descPainter.layout(maxWidth: size.x - 100);
    descPainter.paint(
      canvas,
      Offset(centerX - descPainter.width / 2, startY + 180),
    );

    // Tips box
    final tipsY = startY + 180 + descPainter.height + 40;
    _drawTipsBox(canvas, step.tips, tipsY);
  }

  /// Draw tips box
  void _drawTipsBox(Canvas canvas, List<String> tips, double startY) {
    final size = gameRef.size;
    final centerX = size.x / 2;
    final boxWidth = size.x - 100.0;
    final boxX = centerX - boxWidth / 2;

    // Calculate box height
    double boxHeight = 60.0; // Base padding
    for (final tip in tips) {
      final tipPainter = TextPainter(
        text: TextSpan(
          text: tip,
          style: const TextStyle(fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      );
      tipPainter.layout(maxWidth: boxWidth - 80);
      boxHeight += tipPainter.height + 20;
    }

    // Tips box background
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxX, startY, boxWidth, boxHeight),
      const Radius.circular(15),
    );
    canvas.drawRRect(
      boxRect,
      Paint()..color = const Color(0xFFFFFACD), // Lemon chiffon
    );
    canvas.drawRRect(
      boxRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFDAA520) // Goldenrod
        ..strokeWidth = 3,
    );

    // Tips header
    final headerPainter = TextPainter(
      text: const TextSpan(
        text: '💡 Tips:',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF8C00), // Dark orange
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    headerPainter.layout();
    headerPainter.paint(
      canvas,
      Offset(boxX + 20, startY + 15),
    );

    // Draw tips
    double currentY = startY + 50;
    for (final tip in tips) {
      // Bullet point
      final bulletPainter = TextPainter(
        text: const TextSpan(
          text: '•',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFFFF8C00),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      bulletPainter.layout();
      bulletPainter.paint(canvas, Offset(boxX + 30, currentY));

      // Tip text
      final tipPainter = TextPainter(
        text: TextSpan(
          text: tip,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
            height: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tipPainter.layout(maxWidth: boxWidth - 80);
      tipPainter.paint(canvas, Offset(boxX + 55, currentY));

      currentY += tipPainter.height + 20;
    }
  }

  /// Draw progress indicator
  void _drawProgressIndicator(Canvas canvas) {
    final size = gameRef.size;
    final centerX = size.x / 2;
    final indicatorY = size.y - 160.0;

    // Progress text
    final progressText = '${_currentStep + 1} / ${_tutorialSteps.length}';
    final textPainter = TextPainter(
      text: TextSpan(
        text: progressText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4169E1), // Royal blue
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, indicatorY - 30),
    );

    // Progress bar
    final barWidth = 300.0;
    final barHeight = 12.0;
    final barX = centerX - barWidth / 2;

    // Background bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, indicatorY, barWidth, barHeight),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFD3D3D3), // Light gray
    );

    // Progress bar fill
    final progress = (_currentStep + 1) / _tutorialSteps.length;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, indicatorY, barWidth * progress, barHeight),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF228B22), // Forest green
    );

    // Dots for each step
    final dotSpacing = barWidth / (_tutorialSteps.length - 1);
    for (int i = 0; i < _tutorialSteps.length; i++) {
      final dotX = barX + (i * dotSpacing);
      final dotColor = i <= _currentStep
          ? const Color(0xFF228B22) // Green (completed)
          : const Color(0xFFD3D3D3); // Gray (not completed)

      canvas.drawCircle(
        Offset(dotX, indicatorY + barHeight / 2),
        6,
        Paint()..color = dotColor,
      );
      canvas.drawCircle(
        Offset(dotX, indicatorY + barHeight / 2),
        6,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF808080)
          ..strokeWidth = 2,
      );
    }
  }
}

/// Tutorial step data
class TutorialStep {
  final String title;
  final String description;
  final String icon;
  final List<String> tips;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.tips,
  });
}
