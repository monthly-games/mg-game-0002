import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../components/dialog_box.dart';
import '../cat_alchemy_game.dart';

/// Home scene - main workshop view
class HomeScene extends Component with HasGameReference {
  final WidgetRef ref;

  // UI Components
  late TextComponent _goldText;
  late TextComponent _gemsText;
  late TextComponent _workshopLevelText;
  late GameButton _settingsButton;
  late GameButton _tutorialButton;
  late GameButton _collectionButton;
  late GameButton _leaderboardButton;
  late GameButton _eventsButton;

  HomeScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setupUI();
    _checkOfflineRewards();
  }

  void _checkOfflineRewards() {
    if (game is CatAlchemyGame) {
      final catGame = game as CatAlchemyGame;
      if (catGame.offlineRewards != null && catGame.offlineRewards!.isNotEmpty) {
        final rewards = catGame.offlineRewards!;
        catGame.offlineRewards = null; // Consume

        String message = 'While you were away:\n\n';
        rewards.forEach((id, qty) {
          message += '• $id: $qty\n';
        });

        add(
          DialogBox(
            title: 'Welcome Back!',
            message: message,
            buttons: [
              DialogButton(
                text: 'Collect',
                onPressed: () {
                  remove(children.whereType<DialogBox>().first);
                },
              ),
            ],
            onClose: () => remove(children.whereType<DialogBox>().first),
            position: game.size / 2,
            size: Vector2(400, 300),
          ),
        );
      }
    }
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final gameState = ref.read(gameStateProvider);

    // Gold display
    _goldText = TextComponent(
      text: 'Gold: ${gameState.gold}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: MGColors.gold, // Gold color
        ),
      ),
      position: Vector2(20, 20),
    );
    add(_goldText);

    // Gems display
    _gemsText = TextComponent(
      text: 'Gems: ${gameState.gems}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9370DB), // Medium purple
        ),
      ),
      position: Vector2(20, 60),
    );
    add(_gemsText);

    // Workshop level
    _workshopLevelText = TextComponent(
      text: 'Workshop Lv.${gameState.workshopLevel}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          color: MGColors.warning, // Saddle brown
        ),
      ),
      position: Vector2(20, 100),
    );
    add(_workshopLevelText);

    // Settings button (top right)
    final size = game.size;
    _settingsButton = GameButton(
      text: '⚙️',
      onPressed: () => _navigateTo('settings'),
      position: Vector2(size.x - 70, 20),
      size: Vector2(50, 50),
      fontSize: 24,
      backgroundColor: MGColors.common, // Gray
    );
    add(_settingsButton);

    // Tutorial button (top right, left of settings)
    _tutorialButton = GameButton(
      text: '❓',
      onPressed: () => _navigateTo('tutorial'),
      position: Vector2(size.x - 130, 20),
      size: Vector2(50, 50),
      fontSize: 24,
      backgroundColor: MGColors.info, // Royal blue
    );
    add(_tutorialButton);

    // Collection button (top right, left of tutorial)
    _collectionButton = GameButton(
      text: '📚',
      onPressed: () => _navigateTo('collection'),
      position: Vector2(size.x - 190, 20),
      size: Vector2(50, 50),
      fontSize: 24,
      backgroundColor: const Color(0xFF9370DB), // Medium purple
    );
    add(_collectionButton);

    // Prestige button (top right, left of collection)
    _leaderboardButton = GameButton(
      text: '✨',
      onPressed: () => _navigateTo('prestige'),
      position: Vector2(size.x - 250, 20),
      size: Vector2(50, 50),
      fontSize: 24,
      backgroundColor: MGColors.gem, // Purple
    );
    add(_leaderboardButton);

    // Events button (top right, left of leaderboard)
    _eventsButton = GameButton(
      text: '🎪',
      onPressed: () => _navigateTo('events'),
      position: Vector2(size.x - 310, 20),
      size: Vector2(50, 50),
      fontSize: 24,
      backgroundColor: const Color(0xFFFF1493), // Deep pink
    );
    add(_eventsButton);

    // Navigation buttons
    _addNavigationButtons();
  }

  /// Add navigation buttons to different scenes
  void _addNavigationButtons() {
    final size = game.size;
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // Crafting button
    final craftingButton = GameButton(
      text: '🔨 Crafting',
      onPressed: () => _navigateTo('crafting'),
      position: Vector2(centerX - 180, centerY),
      size: Vector2(160, 70),
      fontSize: 22,
    );
    add(craftingButton);

    // Gathering button
    final gatheringButton = GameButton(
      text: '🌿 Gathering',
      onPressed: () => _navigateTo('gathering'),
      position: Vector2(centerX + 20, centerY),
      size: Vector2(160, 70),
      fontSize: 22,
    );
    add(gatheringButton);

    // Shop button
    final shopButton = GameButton(
      text: '🛒 Shop',
      onPressed: () => _navigateTo('shop'),
      position: Vector2(centerX - 180, centerY + 100),
      size: Vector2(160, 70),
      fontSize: 22,
    );
    add(shopButton);

    // Orders button
    final ordersButton = GameButton(
      text: '📜 Orders',
      onPressed: () => _navigateTo('orders'),
      position: Vector2(centerX + 20, centerY + 100),
      size: Vector2(160, 70),
      fontSize: 22,
    );
    add(ordersButton);

    // Inventory button
    final inventoryButton = GameButton(
      text: '🎒 Inventory',
      onPressed: () => _navigateTo('inventory'),
      position: Vector2(centerX - 180, centerY - 100),
      size: Vector2(160, 70),
      fontSize: 22,
      backgroundColor: MGColors.warning, // Golden brown
    );
    add(inventoryButton);

    // Recipes button
    final recipesButton = GameButton(
      text: '📖 Recipes',
      onPressed: () => _navigateTo('recipes'),
      position: Vector2(centerX + 20, centerY - 100),
      size: Vector2(160, 70),
      fontSize: 22,
      backgroundColor: MGColors.warning, // Golden brown
    );
    add(recipesButton);

    // Upgrade button
    final upgradeButton = GameButton(
      text: '⬆️ Upgrade',
      onPressed: () => _navigateTo('upgrade'),
      position: Vector2(centerX - 260, centerY + 200),
      size: Vector2(150, 70),
      fontSize: 20,
      backgroundColor: MGColors.info, // Royal blue
    );
    add(upgradeButton);

    // Achievements button
    final achievementsButton = GameButton(
      text: '🏆 Achievements',
      onPressed: () => _navigateTo('achievements'),
      position: Vector2(centerX - 90, centerY + 200),
      size: Vector2(180, 70),
      fontSize: 20,
      backgroundColor: MGColors.gold, // Gold
    );
    add(achievementsButton);

    // Cat button (center bottom)
    final catButton = GameButton(
      text: '🐱 Cat',
      onPressed: () => _navigateTo('cat'),
      position: Vector2(centerX + 110, centerY + 200),
      size: Vector2(150, 70),
      fontSize: 22,
      backgroundColor: MGColors.warning, // Dark orange
    );
    add(catButton);
  }

  /// Navigate to a scene
  void _navigateTo(String sceneName) {
    if (game is CatAlchemyGame) {
      (game as CatAlchemyGame).navigateTo(sceneName);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update UI with current game state
    final gameState = ref.read(gameStateProvider);
    _goldText.text = 'Gold: ${gameState.gold}';
    _gemsText.text = 'Gems: ${gameState.gems}';
    _workshopLevelText.text = 'Workshop Lv.${gameState.workshopLevel}';
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background
    final size = game.size;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = MGColors.textHighEmphasis, // Warm cream
    );

    // TODO: Draw workshop background
    // TODO: Draw crafting table
    // TODO: Draw shelves with potions
  }
}
