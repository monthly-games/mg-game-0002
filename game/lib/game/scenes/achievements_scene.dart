import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';

/// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int targetValue;
  final int currentValue;
  final bool claimed;
  final Map<String, int> rewards; // 'gold', 'gems', 'exp'

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    required this.currentValue,
    this.claimed = false,
    required this.rewards,
  });

  /// Check if achievement is completed
  bool isCompleted() {
    return currentValue >= targetValue;
  }

  /// Get completion percentage
  double getProgress() {
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Get progress text
  String getProgressText() {
    return '$currentValue / $targetValue';
  }
}

/// Achievements scene - track and claim achievements
class AchievementsScene extends Component with HasGameRef {
  final WidgetRef ref;

  // UI Components
  late TextComponent _titleText;
  late TextComponent _progressText;
  late GameButton _backButton;
  late GameButton _categoryAllButton;
  late GameButton _categoryCraftingButton;
  late GameButton _categoryGatheringButton;
  late GameButton _categorySocialButton;

  // Current category filter
  String _currentCategory = 'all'; // 'all', 'crafting', 'gathering', 'social'

  // Achievements data
  List<Achievement> _achievements = [];

  AchievementsScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _loadAchievements();
    await _setupUI();
  }

  /// Load achievements from game state
  void _loadAchievements() {
    final gameState = ref.read(gameStateProvider);

    // TODO: Load from GameState achievements tracking
    // For now, create sample achievements
    _achievements = [
      // Crafting achievements
      Achievement(
        id: 'first_potion',
        name: 'First Brew',
        description: 'Craft your first potion',
        icon: '🧪',
        category: 'crafting',
        targetValue: 1,
        currentValue: 0,
        rewards: {'gold': 50, 'exp': 10},
      ),
      Achievement(
        id: 'craft_10',
        name: 'Apprentice Alchemist',
        description: 'Craft 10 potions',
        icon: '⚗️',
        category: 'crafting',
        targetValue: 10,
        currentValue: 0,
        rewards: {'gold': 200, 'exp': 50},
      ),
      Achievement(
        id: 'craft_50',
        name: 'Master Alchemist',
        description: 'Craft 50 potions',
        icon: '🏆',
        category: 'crafting',
        targetValue: 50,
        currentValue: 0,
        rewards: {'gold': 1000, 'gems': 5, 'exp': 200},
      ),
      Achievement(
        id: 'craft_100',
        name: 'Legendary Alchemist',
        description: 'Craft 100 potions',
        icon: '👑',
        category: 'crafting',
        targetValue: 100,
        currentValue: 0,
        rewards: {'gold': 5000, 'gems': 20, 'exp': 500},
      ),

      // Gathering achievements
      Achievement(
        id: 'gather_10',
        name: 'Novice Gatherer',
        description: 'Gather 10 materials',
        icon: '🌿',
        category: 'gathering',
        targetValue: 10,
        currentValue: 0,
        rewards: {'gold': 100, 'exp': 20},
      ),
      Achievement(
        id: 'gather_100',
        name: 'Expert Gatherer',
        description: 'Gather 100 materials',
        icon: '🌳',
        category: 'gathering',
        targetValue: 100,
        currentValue: 0,
        rewards: {'gold': 500, 'gems': 3, 'exp': 100},
      ),
      Achievement(
        id: 'gather_500',
        name: 'Master Gatherer',
        description: 'Gather 500 materials',
        icon: '🌲',
        category: 'gathering',
        targetValue: 500,
        currentValue: 0,
        rewards: {'gold': 2000, 'gems': 10, 'exp': 300},
      ),

      // Social/Orders achievements
      Achievement(
        id: 'order_1',
        name: 'First Customer',
        description: 'Complete your first order',
        icon: '📜',
        category: 'social',
        targetValue: 1,
        currentValue: 0,
        rewards: {'gold': 100, 'exp': 30},
      ),
      Achievement(
        id: 'order_10',
        name: 'Trusted Merchant',
        description: 'Complete 10 orders',
        icon: '🤝',
        category: 'social',
        targetValue: 10,
        currentValue: 0,
        rewards: {'gold': 500, 'gems': 5, 'exp': 150},
      ),
      Achievement(
        id: 'cat_bond_5',
        name: 'Cat Friend',
        description: 'Reach Cat Level 5',
        icon: '😺',
        category: 'social',
        targetValue: 5,
        currentValue: gameState.catLevel,
        rewards: {'gold': 300, 'gems': 3, 'exp': 100},
      ),
      Achievement(
        id: 'cat_bond_10',
        name: 'Cat Master',
        description: 'Reach Cat Level 10',
        icon: '😻',
        category: 'social',
        targetValue: 10,
        currentValue: gameState.catLevel,
        rewards: {'gold': 2000, 'gems': 15, 'exp': 500},
      ),

      // Progression achievements
      Achievement(
        id: 'rich_1000',
        name: 'Wealthy',
        description: 'Accumulate 1,000 gold',
        icon: '💰',
        category: 'all',
        targetValue: 1000,
        currentValue: gameState.gold,
        rewards: {'gems': 5, 'exp': 50},
      ),
      Achievement(
        id: 'rich_10000',
        name: 'Tycoon',
        description: 'Accumulate 10,000 gold',
        icon: '💎',
        category: 'all',
        targetValue: 10000,
        currentValue: gameState.gold,
        rewards: {'gems': 20, 'exp': 200},
      ),
      Achievement(
        id: 'workshop_5',
        name: 'Workshop Upgrade',
        description: 'Reach Workshop Level 5',
        icon: '🏭',
        category: 'all',
        targetValue: 5,
        currentValue: gameState.workshopLevel,
        rewards: {'gold': 500, 'gems': 10, 'exp': 100},
      ),
      Achievement(
        id: 'workshop_10',
        name: 'Grand Workshop',
        description: 'Reach Workshop Level 10',
        icon: '🏰',
        category: 'all',
        targetValue: 10,
        currentValue: gameState.workshopLevel,
        rewards: {'gold': 3000, 'gems': 30, 'exp': 500},
      ),
    ];
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Title
    _titleText = TextComponent(
      text: 'Achievements',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513), // Saddle brown
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

    // Progress text
    final completed = _achievements.where((a) => a.isCompleted()).length;
    final total = _achievements.length;
    final percentage = (completed * 100 / total).toInt();

    _progressText = TextComponent(
      text: 'Completed: $completed/$total ($percentage%)',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF228B22), // Forest green
        ),
      ),
      position: Vector2(size.x - 220, 40),
      anchor: Anchor.center,
    );
    add(_progressText);

    // Category buttons
    _addCategoryButtons();

    // Build achievement cards
    _buildAchievementCards();
  }

  /// Add category filter buttons
  void _addCategoryButtons() {
    final size = gameRef.size;
    final centerX = size.x / 2;

    _categoryAllButton = GameButton(
      text: 'All',
      onPressed: () => _setCategory('all'),
      position: Vector2(centerX - 240, 100),
      size: Vector2(100, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFF8B6914),
    );
    add(_categoryAllButton);

    _categoryCraftingButton = GameButton(
      text: '🔨 Crafting',
      onPressed: () => _setCategory('crafting'),
      position: Vector2(centerX - 120, 100),
      size: Vector2(120, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFFD4B896),
    );
    add(_categoryCraftingButton);

    _categoryGatheringButton = GameButton(
      text: '🌿 Gathering',
      onPressed: () => _setCategory('gathering'),
      position: Vector2(centerX + 20, 100),
      size: Vector2(130, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFFD4B896),
    );
    add(_categoryGatheringButton);

    _categorySocialButton = GameButton(
      text: '🤝 Social',
      onPressed: () => _setCategory('social'),
      position: Vector2(centerX + 170, 100),
      size: Vector2(110, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFFD4B896),
    );
    add(_categorySocialButton);
  }

  /// Build achievement cards
  void _buildAchievementCards() {
    // Filter achievements by category
    final filteredAchievements = _currentCategory == 'all'
        ? _achievements
        : _achievements.where((a) => a.category == _currentCategory).toList();

    if (filteredAchievements.isEmpty) {
      _showEmptyMessage();
      return;
    }

    // Build cards vertically
    var yPos = 170.0;
    for (final achievement in filteredAchievements) {
      _buildAchievementCard(achievement, Vector2(50, yPos));
      yPos += 130;
    }
  }

  /// Build a single achievement card
  void _buildAchievementCard(Achievement achievement, Vector2 position) {
    final cardSize = Vector2(gameRef.size.x - 100, 110);
    final isCompleted = achievement.isCompleted();

    // Card background
    final cardBg = RectangleComponent(
      position: position,
      size: cardSize,
      paint: Paint()
        ..color = isCompleted
            ? const Color(0xFFFFD700).withOpacity(
                0.2,
              ) // Gold tint for completed
            : const Color(0xFFE8D5B7).withOpacity(0.9),
    );
    add(cardBg);

    // Card border
    final borderColor = isCompleted
        ? const Color(0xFFFFD700) // Gold
        : const Color(0xFF8B6914);
    final cardBorder = RectangleComponent(
      position: position,
      size: cardSize,
      paint: Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCompleted ? 3 : 2,
    );
    add(cardBorder);

    // Icon
    final iconText = TextComponent(
      text: achievement.icon,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 40)),
      position: position + Vector2(30, 25),
    );
    add(iconText);

    // Name
    final nameText = TextComponent(
      text: achievement.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: position + Vector2(90, 15),
    );
    add(nameText);

    // Description
    final descText = TextComponent(
      text: achievement.description,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Color(0xFF5D4E37)),
      ),
      position: position + Vector2(90, 40),
    );
    add(descText);

    // Progress text
    final progressText = TextComponent(
      text: achievement.getProgressText(),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isCompleted
              ? const Color(0xFF228B22) // Green for completed
              : const Color(0xFF4169E1), // Blue for in progress
        ),
      ),
      position: position + Vector2(90, 65),
    );
    add(progressText);

    // Progress bar
    final progressBarBg = RectangleComponent(
      position: position + Vector2(90, 85),
      size: Vector2(300, 15),
      paint: Paint()..color = const Color(0xFFD4B896),
    );
    add(progressBarBg);

    final progressBarFill = RectangleComponent(
      position: position + Vector2(90, 85),
      size: Vector2(300 * achievement.getProgress(), 15),
      paint: Paint()
        ..color = isCompleted
            ? const Color(0xFF228B22) // Green
            : const Color(0xFF4169E1), // Blue
    );
    add(progressBarFill);

    // Rewards display
    final rewardsText = _buildRewardsText(achievement.rewards);
    final rewardsComponent = TextComponent(
      text: rewardsText,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF228B22),
          fontWeight: FontWeight.bold,
        ),
      ),
      position: position + Vector2(cardSize.x - 200, 20),
    );
    add(rewardsComponent);

    // Claim button or completed badge
    if (isCompleted && !achievement.claimed) {
      final claimButton = GameButton(
        text: 'Claim!',
        onPressed: () => _claimReward(achievement),
        position: position + Vector2(cardSize.x - 120, 55),
        size: Vector2(100, 40),
        fontSize: 16,
        backgroundColor: const Color(0xFFFFD700), // Gold
      );
      add(claimButton);
    } else if (achievement.claimed) {
      final claimedBadge = TextComponent(
        text: '✓ Claimed',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF228B22), // Green
          ),
        ),
        position: position + Vector2(cardSize.x - 100, 70),
        anchor: Anchor.center,
      );
      add(claimedBadge);
    }
  }

  /// Build rewards text
  String _buildRewardsText(Map<String, int> rewards) {
    final parts = <String>[];
    if (rewards.containsKey('gold')) {
      parts.add('${rewards['gold']}💰');
    }
    if (rewards.containsKey('gems')) {
      parts.add('${rewards['gems']}💎');
    }
    if (rewards.containsKey('exp')) {
      parts.add('${rewards['exp']}✨');
    }
    return parts.join(' ');
  }

  /// Claim achievement reward
  void _claimReward(Achievement achievement) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);

    // Give rewards
    if (achievement.rewards.containsKey('gold')) {
      gameStateNotifier.addGold(achievement.rewards['gold']!);
    }
    if (achievement.rewards.containsKey('gems')) {
      gameStateNotifier.addGems(achievement.rewards['gems']!);
    }
    // TODO: Add experience rewards

    // Mark as claimed
    // TODO: Update GameState to track claimed achievements

    _showMessage('Rewards claimed! ${_buildRewardsText(achievement.rewards)}');

    // Reload and refresh
    _loadAchievements();
    _refreshUI();
  }

  /// Set category filter
  void _setCategory(String category) {
    _currentCategory = category;

    // Update button colors
    _categoryAllButton.backgroundColor = category == 'all'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);
    _categoryCraftingButton.backgroundColor = category == 'crafting'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);
    _categoryGatheringButton.backgroundColor = category == 'gathering'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);
    _categorySocialButton.backgroundColor = category == 'social'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);

    // Rebuild achievement cards
    _refreshUI();
  }

  /// Show empty message
  void _showEmptyMessage() {
    final size = gameRef.size;

    final emptyText = TextComponent(
      text: 'No achievements in this category.',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 24, color: Color(0xFF8B4513)),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(emptyText);
  }

  /// Show temporary message
  void _showMessage(String message) {
    final size = gameRef.size;

    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFD700), // Gold
          shadows: [
            Shadow(color: Colors.white, offset: Offset(2, 2), blurRadius: 4),
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
      _progressText,
      _categoryAllButton,
      _categoryCraftingButton,
      _categoryGatheringButton,
      _categorySocialButton,
    ];
    final toRemove = children.where((c) => !toKeep.contains(c));
    removeAll(toRemove);

    // Update progress text
    final completed = _achievements.where((a) => a.isCompleted()).length;
    final total = _achievements.length;
    final percentage = (completed * 100 / total).toInt();
    _progressText.text = 'Completed: $completed/$total ($percentage%)';

    // Rebuild achievement cards
    _buildAchievementCards();
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
      Paint()..color = const Color(0xFFF5E6D3), // Warm cream
    );

    // Achievement panel background
    final panelRect = Rect.fromLTWH(30, 160, size.x - 60, size.y - 190);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(15)),
      Paint()..color = const Color(0xFF8B6914).withOpacity(0.1),
    );
  }
}
