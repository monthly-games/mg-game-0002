import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../components/progress_bar.dart';
import '../cat_alchemy_game.dart';

/// Cat scene - interact with cat companion
class CatScene extends Component with HasGameRef {
  final WidgetRef ref;

  // UI Components
  late TextComponent _titleText;
  late TextComponent _catNameText;
  late TextComponent _catLevelText;
  late TextComponent _trustText;
  late GameButton _backButton;
  late ProgressBar _trustBar;

  CatScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setupUI();
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;
    final gameState = ref.read(gameStateProvider);

    // Title
    _titleText = TextComponent(
      text: 'Your Cat Companion',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF8C00), // Dark orange
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

    // Cat name (placeholder)
    _catNameText = TextComponent(
      text: '🐱 Whiskers',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          color: Color(0xFF8B4513),
        ),
      ),
      position: Vector2(size.x / 2, 150),
      anchor: Anchor.center,
    );
    add(_catNameText);

    // Cat level
    _catLevelText = TextComponent(
      text: 'Level ${gameState.catLevel}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: Vector2(size.x / 2, 220),
      anchor: Anchor.center,
    );
    add(_catLevelText);

    // Trust points
    _trustText = TextComponent(
      text: 'Trust: ${gameState.catTrust} / ${_getTrustForNextLevel(gameState.catLevel)}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Color(0xFF5D4E37),
        ),
      ),
      position: Vector2(size.x / 2, 270),
      anchor: Anchor.center,
    );
    add(_trustText);

    // Trust progress bar
    final trustProgress = gameState.catTrust / _getTrustForNextLevel(gameState.catLevel);
    _trustBar = ProgressBar(
      position: Vector2(size.x / 2 - 200, 310),
      size: Vector2(400, 30),
      progress: trustProgress.clamp(0.0, 1.0),
      fillColor: const Color(0xFFFF8C00), // Dark orange
    );
    add(_trustBar);

    // Interaction buttons
    _addInteractionButtons();

    // Cat skills info
    _addSkillsInfo();
  }

  /// Add interaction buttons
  void _addInteractionButtons() {
    final size = gameRef.size;
    final centerX = size.x / 2;

    // Pet button
    final petButton = GameButton(
      text: '🤚 Pet (+1 trust)',
      onPressed: _petCat,
      position: Vector2(centerX - 180, 400),
      size: Vector2(160, 70),
      fontSize: 18,
      backgroundColor: const Color(0xFFFF8C00),
    );
    add(petButton);

    // Treat button
    final treatButton = GameButton(
      text: '🍖 Treat (+5 trust)',
      onPressed: _giveTreat,
      position: Vector2(centerX + 20, 400),
      size: Vector2(160, 70),
      fontSize: 18,
      backgroundColor: const Color(0xFFFF8C00),
    );
    add(treatButton);

    // Play button
    final playButton = GameButton(
      text: '🎾 Play (+10 trust)',
      onPressed: _playCat,
      position: Vector2(centerX - 80, 490),
      size: Vector2(160, 70),
      fontSize: 18,
      backgroundColor: const Color(0xFFFF8C00),
    );
    add(playButton);
  }

  /// Add skills info
  void _addSkillsInfo() {
    final size = gameRef.size;
    final gameState = ref.read(gameStateProvider);

    final skillsTitle = TextComponent(
      text: 'Cat Skills:',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: Vector2(size.x / 2, 600),
      anchor: Anchor.center,
    );
    add(skillsTitle);

    // Show active skills based on level
    var skillY = 640.0;
    final skills = _getActiveSkills(gameState.catLevel);

    for (final skill in skills) {
      final skillText = TextComponent(
        text: '✓ $skill',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF228B22), // Forest green
          ),
        ),
        position: Vector2(size.x / 2, skillY),
        anchor: Anchor.center,
      );
      add(skillText);
      skillY += 30;
    }
  }

  /// Get trust required for next level
  int _getTrustForNextLevel(int currentLevel) {
    // Exponential growth: level 1->2 needs 100, 2->3 needs 200, etc.
    return 100 * currentLevel;
  }

  /// Get active skills for cat level
  List<String> _getActiveSkills(int level) {
    final skills = <String>[];

    if (level >= 1) skills.add('Companion (Always with you)');
    if (level >= 2) skills.add('+5% Production Speed');
    if (level >= 3) skills.add('+10% Production Speed');
    if (level >= 4) skills.add('+1 Crafting Queue Slot');
    if (level >= 5) skills.add('-10% Crafting Time');
    if (level >= 6) skills.add('+15% Production Speed');
    if (level >= 7) skills.add('-20% Crafting Time');
    if (level >= 8) skills.add('Auto-collect idle resources');
    if (level >= 9) skills.add('Auto-sell low-tier potions');
    if (level >= 10) skills.add('Legendary: +50% all bonuses');

    return skills;
  }

  /// Pet the cat
  void _petCat() {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    gameStateNotifier.petCat();

    _showMessage('+1 Trust! 😻');
    _updateUI();
  }

  /// Give treat to cat
  void _giveTreat() {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);

    // Cost: 10 gold
    if (!gameStateNotifier.spendGold(10)) {
      _showMessage('Not enough gold! (Need 10g)');
      return;
    }

    gameStateNotifier.addCatTrust(5);
    _showMessage('+5 Trust! Nom nom~ 😻');
    _updateUI();
  }

  /// Play with cat
  void _playCat() {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    gameStateNotifier.playCat();

    _showMessage('+10 Trust! Purrr~ 😻');
    _updateUI();
  }

  /// Update UI with current state
  void _updateUI() {
    final gameState = ref.read(gameStateProvider);

    _catLevelText.text = 'Level ${gameState.catLevel}';
    _trustText.text = 'Trust: ${gameState.catTrust} / ${_getTrustForNextLevel(gameState.catLevel)}';

    final trustProgress = gameState.catTrust / _getTrustForNextLevel(gameState.catLevel);
    _trustBar.progress = trustProgress.clamp(0.0, 1.0);

    // Check for level up
    if (trustProgress >= 1.0) {
      _showMessage('🎉 Cat leveled up! Level ${gameState.catLevel + 1}!');
      // TODO: Implement level up logic
    }
  }

  /// Show temporary message
  void _showMessage(String message) {
    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF8C00),
          shadows: [
            Shadow(
              color: Colors.white,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: gameRef.size / 2 + Vector2(0, -150),
      anchor: Anchor.center,
    );

    add(messageText);

    Future.delayed(const Duration(seconds: 2), () {
      if (messageText.isMounted) {
        remove(messageText);
      }
    });
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
      Paint()..color = const Color(0xFFFFF8DC), // Cornsilk (lighter background)
    );

    // Cat silhouette area (placeholder for cat image)
    final catArea = Rect.fromCenter(
      center: Offset(size.x / 2, 200),
      width: 200,
      height: 200,
    );

    canvas.drawCircle(
      catArea.center,
      100,
      Paint()..color = const Color(0xFFFFE4B5).withOpacity(0.5), // Moccasin
    );
  }
}
