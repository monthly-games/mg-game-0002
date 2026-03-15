import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';

/// Upgrade model
class UpgradeOption {
  final String id;
  final String name;
  final String description;
  final int baseCost;
  final int currentLevel;
  final int maxLevel;
  final String category;
  final String icon;

  UpgradeOption({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.currentLevel,
    required this.maxLevel,
    required this.category,
    required this.icon,
  });

  /// Calculate cost for next level
  int getCostForNextLevel() {
    // Exponential cost scaling: baseCost * (1.5 ^ currentLevel)
    return (baseCost * math.pow(1.5, currentLevel)).round();
  }

  /// Check if can be upgraded
  bool canUpgrade() {
    return currentLevel < maxLevel;
  }

  /// Get progress percentage
  double getProgress() {
    return currentLevel / maxLevel;
  }
}

/// Upgrade scene - workshop and system upgrades
class UpgradeScene extends Component with HasGameReference {
  final WidgetRef ref;

  // UI Components
  late TextComponent _titleText;
  late TextComponent _goldText;
  late TextComponent _gemsText;
  late GameButton _backButton;
  late GameButton _categoryWorkshopButton;
  late GameButton _categoryProductionButton;
  late GameButton _categoryCraftingButton;

  // Current category
  String _currentCategory = 'workshop'; // 'workshop', 'production', 'crafting'

  // Upgrades data
  List<UpgradeOption> _upgrades = [];

  UpgradeScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _loadUpgrades();
    await _setupUI();
  }

  /// Load upgrade options from game state
  void _loadUpgrades() {
    final gameState = ref.read(gameStateProvider);

    _upgrades = [
      // Workshop category
      UpgradeOption(
        id: 'workshop_level',
        name: 'Workshop Level',
        description: 'Unlock new recipes and features',
        baseCost: 100,
        currentLevel: gameState.workshopLevel,
        maxLevel: 10,
        category: 'workshop',
        icon: '🏭',
      ),
      UpgradeOption(
        id: 'inventory_slots',
        name: 'Inventory Slots',
        description: 'Increase max inventory capacity',
        baseCost: 200,
        currentLevel: 10, // Fixed at 100 slots for now
        maxLevel: 20,
        category: 'workshop',
        icon: '🎒',
      ),
      UpgradeOption(
        id: 'storage_capacity',
        name: 'Storage Capacity',
        description: 'Increase idle resource storage',
        baseCost: 150,
        currentLevel: 1,
        maxLevel: 10,
        category: 'workshop',
        icon: '📦',
      ),

      // Production category
      UpgradeOption(
        id: 'production_speed',
        name: 'Production Speed',
        description: '+10% idle production per level',
        baseCost: 300,
        currentLevel: 0,
        maxLevel: 10,
        category: 'production',
        icon: '⚡',
      ),
      UpgradeOption(
        id: 'gathering_efficiency',
        name: 'Gathering Efficiency',
        description: '+1 material per gather',
        baseCost: 250,
        currentLevel: 0,
        maxLevel: 5,
        category: 'production',
        icon: '🌿',
      ),
      UpgradeOption(
        id: 'auto_collect',
        name: 'Auto Collect',
        description: 'Automatically collect idle resources',
        baseCost: 1000,
        currentLevel: 0,
        maxLevel: 1,
        category: 'production',
        icon: '🤖',
      ),

      // Crafting category
      UpgradeOption(
        id: 'crafting_speed',
        name: 'Crafting Speed',
        description: '-5% crafting time per level',
        baseCost: 200,
        currentLevel: 0,
        maxLevel: 10,
        category: 'crafting',
        icon: '⏱',
      ),
      UpgradeOption(
        id: 'crafting_queue',
        name: 'Crafting Queue Slots',
        description: '+1 queue slot per level',
        baseCost: 500,
        currentLevel: 3, // Default 3 slots
        maxLevel: 8,
        category: 'crafting',
        icon: '📋',
      ),
      UpgradeOption(
        id: 'instant_craft',
        name: 'Instant Craft',
        description: 'Unlock instant craft with gems',
        baseCost: 1500,
        currentLevel: 0,
        maxLevel: 1,
        category: 'crafting',
        icon: '✨',
      ),
      UpgradeOption(
        id: 'quality_bonus',
        name: 'Quality Bonus',
        description: '+10% sell price per level',
        baseCost: 400,
        currentLevel: 0,
        maxLevel: 5,
        category: 'crafting',
        icon: '💎',
      ),
    ];
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = game.size;

    // Title
    _titleText = TextComponent(
      text: 'Workshop Upgrades',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: MGColors.warning, // Saddle brown
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

    // Resources display
    final gameState = ref.read(gameStateProvider);
    _goldText = TextComponent(
      text: '💰 ${gameState.gold}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: MGColors.gold, // Gold
        ),
      ),
      position: Vector2(size.x - 200, 30),
    );
    add(_goldText);

    _gemsText = TextComponent(
      text: '💎 ${gameState.gems}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9370DB), // Purple
        ),
      ),
      position: Vector2(size.x - 200, 60),
    );
    add(_gemsText);

    // Category buttons
    _addCategoryButtons();

    // Build upgrade cards
    _buildUpgradeCards();
  }

  /// Add category filter buttons
  void _addCategoryButtons() {
    final size = game.size;
    final centerX = size.x / 2;

    _categoryWorkshopButton = GameButton(
      text: '🏭 Workshop',
      onPressed: () => _setCategory('workshop'),
      position: Vector2(centerX - 220, 100),
      size: Vector2(140, 45),
      fontSize: 16,
      backgroundColor: MGColors.warning,
    );
    add(_categoryWorkshopButton);

    _categoryProductionButton = GameButton(
      text: '⚡ Production',
      onPressed: () => _setCategory('production'),
      position: Vector2(centerX - 60, 100),
      size: Vector2(140, 45),
      fontSize: 16,
      backgroundColor: MGColors.textMediumEmphasis,
    );
    add(_categoryProductionButton);

    _categoryCraftingButton = GameButton(
      text: '🔨 Crafting',
      onPressed: () => _setCategory('crafting'),
      position: Vector2(centerX + 100, 100),
      size: Vector2(140, 45),
      fontSize: 16,
      backgroundColor: MGColors.textMediumEmphasis,
    );
    add(_categoryCraftingButton);
  }

  /// Build upgrade cards
  void _buildUpgradeCards() {
    // Filter upgrades by category
    final categoryUpgrades = _upgrades
        .where((u) => u.category == _currentCategory)
        .toList();

    if (categoryUpgrades.isEmpty) {
      _showEmptyMessage();
      return;
    }

    // Build cards vertically
    var yPos = 170.0;
    for (final upgrade in categoryUpgrades) {
      _buildUpgradeCard(upgrade, Vector2(50, yPos));
      yPos += 140;
    }
  }

  /// Build a single upgrade card
  void _buildUpgradeCard(UpgradeOption upgrade, Vector2 position) {
    final gameState = ref.read(gameStateProvider);
    final cardSize = Vector2(game.size.x - 100, 120);

    // Card background
    final cardBg = RectangleComponent(
      position: position,
      size: cardSize,
      paint: Paint()..color = const Color(0xFFE8D5B7).withValues(alpha: 0.9),
    );
    add(cardBg);

    // Card border
    final borderColor = upgrade.canUpgrade()
        ? MGColors.warning
        : MGColors.common;
    final cardBorder = RectangleComponent(
      position: position,
      size: cardSize,
      paint: Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    add(cardBorder);

    // Icon
    final iconText = TextComponent(
      text: upgrade.icon,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 32),
      ),
      position: position + Vector2(30, 30),
    );
    add(iconText);

    // Name
    final nameText = TextComponent(
      text: upgrade.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: MGColors.warning,
        ),
      ),
      position: position + Vector2(80, 20),
    );
    add(nameText);

    // Description
    final descText = TextComponent(
      text: upgrade.description,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 14,
          color: MGColors.border,
        ),
      ),
      position: position + Vector2(80, 45),
    );
    add(descText);

    // Level progress
    final levelText = TextComponent(
      text: 'Level ${upgrade.currentLevel}/${upgrade.maxLevel}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: MGColors.info, // Royal blue
        ),
      ),
      position: position + Vector2(80, 70),
    );
    add(levelText);

    // Progress bar
    final progressBarBg = RectangleComponent(
      position: position + Vector2(80, 90),
      size: Vector2(200, 20),
      paint: Paint()..color = MGColors.textMediumEmphasis,
    );
    add(progressBarBg);

    final progressBarFill = RectangleComponent(
      position: position + Vector2(80, 90),
      size: Vector2(200 * upgrade.getProgress(), 20),
      paint: Paint()..color = MGColors.success, // Forest green
    );
    add(progressBarFill);

    // Upgrade button
    if (upgrade.canUpgrade()) {
      final cost = upgrade.getCostForNextLevel();
      final canAfford = gameState.gold >= cost;

      final upgradeButton = GameButton(
        text: 'Upgrade\n$cost💰',
        onPressed: canAfford ? () => _purchaseUpgrade(upgrade) : () {},
        position: position + Vector2(cardSize.x - 130, 30),
        size: Vector2(110, 70),
        fontSize: 14,
        enabled: canAfford,
        backgroundColor: canAfford
            ? MGColors.success
            : MGColors.common,
      );
      add(upgradeButton);
    } else {
      // Max level indicator
      final maxText = TextComponent(
        text: 'MAX',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MGColors.gold, // Gold
          ),
        ),
        position: position + Vector2(cardSize.x - 90, 60),
        anchor: Anchor.center,
      );
      add(maxText);
    }
  }

  /// Purchase upgrade
  void _purchaseUpgrade(UpgradeOption upgrade) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final cost = upgrade.getCostForNextLevel();

    // Check if can afford
    if (!gameStateNotifier.trySpendGold(cost)) {
      _showMessage('Not enough gold!');
      return;
    }

    // Apply upgrade based on ID
    switch (upgrade.id) {
      case 'workshop_level':
        // Upgrade workshop level
        // TODO: Implement workshop level upgrade in GameState
        _showMessage('Workshop upgraded to level ${upgrade.currentLevel + 1}!');
        break;

      case 'crafting_queue':
        // Increase queue size
        // TODO: Implement queue size upgrade
        _showMessage('Crafting queue expanded!');
        break;

      case 'crafting_speed':
        // Increase crafting speed
        // TODO: Apply crafting speed modifier
        _showMessage('Crafting speed increased!');
        break;

      case 'production_speed':
        // Increase production speed
        // TODO: Apply production speed modifier
        _showMessage('Production speed increased!');
        break;

      case 'gathering_efficiency':
        // Increase gathering yield
        _showMessage('Gathering efficiency improved!');
        break;

      case 'quality_bonus':
        // Increase sell price
        _showMessage('Quality bonus unlocked!');
        break;

      case 'auto_collect':
        // Enable auto-collect
        _showMessage('Auto-collect enabled!');
        break;

      case 'instant_craft':
        // Enable instant craft
        _showMessage('Instant craft unlocked!');
        break;

      default:
        _showMessage('Upgrade purchased!');
    }

    // Reload upgrades and refresh UI
    _loadUpgrades();
    _refreshUI();
  }

  /// Set category filter
  void _setCategory(String category) {
    _currentCategory = category;

    // Update button colors
    _categoryWorkshopButton.backgroundColor = category == 'workshop'
        ? MGColors.warning
        : MGColors.textMediumEmphasis;
    _categoryProductionButton.backgroundColor = category == 'production'
        ? MGColors.warning
        : MGColors.textMediumEmphasis;
    _categoryCraftingButton.backgroundColor = category == 'crafting'
        ? MGColors.warning
        : MGColors.textMediumEmphasis;

    // Rebuild upgrade cards
    _refreshUI();
  }

  /// Show empty message
  void _showEmptyMessage() {
    final size = game.size;

    final emptyText = TextComponent(
      text: 'No upgrades available in this category.',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: MGColors.warning,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(emptyText);
  }

  /// Show temporary message
  void _showMessage(String message) {
    final size = game.size;

    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: MGColors.success,
          shadows: [
            Shadow(
              color: MGColors.textHighEmphasis,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: size / 2 + Vector2(0, -150),
      anchor: Anchor.center,
    );

    add(messageText);

    Future.delayed(const Duration(seconds: 2), () {
      if (messageText.isMounted) {
        remove(messageText);
      }
    });
  }

  /// Refresh UI
  void _refreshUI() {
    // Remove all children except static UI
    final toKeep = [
      _titleText,
      _backButton,
      _goldText,
      _gemsText,
      _categoryWorkshopButton,
      _categoryProductionButton,
      _categoryCraftingButton,
    ];
    final toRemove = children.where((c) => !toKeep.contains(c));
    removeAll(toRemove);

    // Update resource displays
    final gameState = ref.read(gameStateProvider);
    _goldText.text = '💰 ${gameState.gold}';
    _gemsText.text = '💎 ${gameState.gems}';

    // Rebuild upgrade cards
    _buildUpgradeCards();
  }

  /// Go back to home scene
  void _goBack() {
    if (game is CatAlchemyGame) {
      (game as CatAlchemyGame).navigateTo('home');
    }
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

    // Upgrade panel background
    final panelRect = Rect.fromLTWH(30, 160, size.x - 60, size.y - 190);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(15)),
      Paint()..color = MGColors.warning.withValues(alpha: 0.1),
    );
  }
}
