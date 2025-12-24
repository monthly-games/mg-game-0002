import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';

/// Collection scene - codex of discovered materials and potions
class CollectionScene extends Component with HasGameRef {
  final WidgetRef ref;

  // UI state
  String _currentTab = 'materials'; // 'materials' or 'potions'
  String _selectedItemId = '';

  // UI Components
  late GameButton _backButton;
  late GameButton _materialsTabButton;
  late GameButton _potionsTabButton;

  // Collection data
  final List<CollectionItem> _materialCollection = [];
  final List<CollectionItem> _potionCollection = [];

  CollectionScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeCollections();
    await _setupUI();
  }

  /// Initialize collection data
  void _initializeCollections() {
    final gameState = ref.read(gameStateProvider);
    final inventory = gameState.inventory;

    // Materials collection
    _materialCollection.addAll([
      CollectionItem(
        id: 'mat_wildgrass',
        name: 'Wild Grass',
        icon: '🌿',
        description: 'Common grass found in meadows. Basic alchemy ingredient.',
        rarity: 'Common',
        discovered: inventory.containsKey('mat_wildgrass'),
        timesGathered: inventory['mat_wildgrass'] ?? 0,
        category: 'Herb',
      ),
      CollectionItem(
        id: 'mat_blueflower',
        name: 'Blue Flower',
        icon: '🌼',
        description: 'Delicate flower with calming properties. Used in healing potions.',
        rarity: 'Common',
        discovered: inventory.containsKey('mat_blueflower'),
        timesGathered: inventory['mat_blueflower'] ?? 0,
        category: 'Flower',
      ),
      CollectionItem(
        id: 'mat_mushroom',
        name: 'Magic Mushroom',
        icon: '🍄',
        description: 'Mystical fungus with unpredictable effects. Handle with care.',
        rarity: 'Uncommon',
        discovered: inventory.containsKey('mat_mushroom'),
        timesGathered: inventory['mat_mushroom'] ?? 0,
        category: 'Fungus',
      ),
      CollectionItem(
        id: 'mat_crystal',
        name: 'Crystal Shard',
        icon: '💎',
        description: 'Pure crystallized mana. Amplifies potion effects.',
        rarity: 'Rare',
        discovered: inventory.containsKey('mat_crystal'),
        timesGathered: inventory['mat_crystal'] ?? 0,
        category: 'Mineral',
      ),
      CollectionItem(
        id: 'mat_moonpetal',
        name: 'Moon Petal',
        icon: '🌙',
        description: 'Blooms only under moonlight. Extremely rare and valuable.',
        rarity: 'Epic',
        discovered: inventory.containsKey('mat_moonpetal'),
        timesGathered: inventory['mat_moonpetal'] ?? 0,
        category: 'Flower',
      ),
      CollectionItem(
        id: 'mat_dragonscale',
        name: 'Dragon Scale',
        icon: '🐉',
        description: 'Ancient dragon scale. The ultimate alchemical catalyst.',
        rarity: 'Legendary',
        discovered: inventory.containsKey('mat_dragonscale'),
        timesGathered: inventory['mat_dragonscale'] ?? 0,
        category: 'Monster',
      ),
    ]);

    // Potions collection
    _potionCollection.addAll([
      CollectionItem(
        id: 'potion_healing_minor',
        name: 'Minor Healing Potion',
        icon: '⚗️',
        description: 'Restores a small amount of health. Your first creation.',
        rarity: 'Common',
        discovered: inventory.containsKey('potion_healing_minor'),
        timesCrafted: _getCraftCount('potion_healing_minor'),
        category: 'Healing',
        tier: 1,
      ),
      CollectionItem(
        id: 'potion_healing',
        name: 'Healing Potion',
        icon: '🧪',
        description: 'Restores moderate health. A reliable remedy.',
        rarity: 'Common',
        discovered: inventory.containsKey('potion_healing'),
        timesCrafted: _getCraftCount('potion_healing'),
        category: 'Healing',
        tier: 2,
      ),
      CollectionItem(
        id: 'potion_mana',
        name: 'Mana Potion',
        icon: '💙',
        description: 'Restores magical energy. Essential for spellcasters.',
        rarity: 'Uncommon',
        discovered: inventory.containsKey('potion_mana'),
        timesCrafted: _getCraftCount('potion_mana'),
        category: 'Mana',
        tier: 2,
      ),
      CollectionItem(
        id: 'potion_strength',
        name: 'Strength Potion',
        icon: '💪',
        description: 'Temporarily increases physical power.',
        rarity: 'Uncommon',
        discovered: inventory.containsKey('potion_strength'),
        timesCrafted: _getCraftCount('potion_strength'),
        category: 'Buff',
        tier: 2,
      ),
      CollectionItem(
        id: 'potion_speed',
        name: 'Speed Potion',
        icon: '⚡',
        description: 'Enhances movement and reaction speed.',
        rarity: 'Rare',
        discovered: inventory.containsKey('potion_speed'),
        timesCrafted: _getCraftCount('potion_speed'),
        category: 'Buff',
        tier: 3,
      ),
      CollectionItem(
        id: 'potion_invisibility',
        name: 'Invisibility Potion',
        icon: '👻',
        description: 'Grants temporary invisibility. Advanced alchemy required.',
        rarity: 'Epic',
        discovered: inventory.containsKey('potion_invisibility'),
        timesCrafted: _getCraftCount('potion_invisibility'),
        category: 'Special',
        tier: 4,
      ),
      CollectionItem(
        id: 'potion_immortality',
        name: 'Elixir of Immortality',
        icon: '✨',
        description: 'The legendary philosopher\'s stone in liquid form.',
        rarity: 'Legendary',
        discovered: inventory.containsKey('potion_immortality'),
        timesCrafted: _getCraftCount('potion_immortality'),
        category: 'Mythic',
        tier: 5,
      ),
    ]);
  }

  /// Get craft count from game state (placeholder)
  int _getCraftCount(String potionId) {
    // TODO: Track craft counts in game state
    return 0;
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
      backgroundColor: const Color(0xFF808080),
    );
    add(_backButton);

    // Tab buttons
    final centerX = size.x / 2;
    _materialsTabButton = GameButton(
      text: '🌿 Materials',
      onPressed: () => _switchTab('materials'),
      position: Vector2(centerX - 170, 90),
      size: Vector2(160, 50),
      fontSize: 18,
      backgroundColor: const Color(0xFF228B22), // Green
    );
    add(_materialsTabButton);

    _potionsTabButton = GameButton(
      text: '⚗️ Potions',
      onPressed: () => _switchTab('potions'),
      position: Vector2(centerX + 10, 90),
      size: Vector2(160, 50),
      fontSize: 18,
      backgroundColor: const Color(0xFF9370DB), // Purple
    );
    add(_potionsTabButton);
  }

  /// Switch between tabs
  void _switchTab(String tab) {
    _currentTab = tab;
    _selectedItemId = '';
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
      Paint()..color = const Color(0xFFF0F8FF), // Alice blue
    );

    // Title
    _drawTitle(canvas);

    // Collection stats
    _drawStats(canvas);

    // Update tab button appearance
    _updateTabButtons();

    // Draw collection grid
    if (_currentTab == 'materials') {
      _drawCollectionGrid(canvas, _materialCollection);
    } else {
      _drawCollectionGrid(canvas, _potionCollection);
    }

    // Draw selected item detail
    if (_selectedItemId.isNotEmpty) {
      _drawItemDetail(canvas);
    }
  }

  /// Draw title
  void _drawTitle(Canvas canvas) {
    final size = gameRef.size;
    final centerX = size.x / 2;

    final titlePainter = TextPainter(
      text: const TextSpan(
        text: '📚 Collection Codex',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4B0082), // Indigo
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(centerX - titlePainter.width / 2, 30),
    );
  }

  /// Draw collection stats
  void _drawStats(Canvas canvas) {
    final size = gameRef.size;
    final centerX = size.x / 2;

    final collection = _currentTab == 'materials'
        ? _materialCollection
        : _potionCollection;

    final discovered = collection.where((item) => item.discovered).length;
    final total = collection.length;
    final percentage = total > 0 ? (discovered / total * 100).toStringAsFixed(1) : '0.0';

    final statsPainter = TextPainter(
      text: TextSpan(
        text: 'Discovered: $discovered / $total ($percentage%)',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E8B57), // Sea green
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    statsPainter.layout();
    statsPainter.paint(
      canvas,
      Offset(centerX - statsPainter.width / 2, 160),
    );
  }

  /// Update tab button appearance
  void _updateTabButtons() {
    if (_currentTab == 'materials') {
      _materialsTabButton.backgroundColor = const Color(0xFF228B22); // Green (active)
      _potionsTabButton.backgroundColor = const Color(0xFF808080); // Gray (inactive)
    } else {
      _materialsTabButton.backgroundColor = const Color(0xFF808080); // Gray (inactive)
      _potionsTabButton.backgroundColor = const Color(0xFF9370DB); // Purple (active)
    }
  }

  /// Draw collection grid
  void _drawCollectionGrid(Canvas canvas, List<CollectionItem> items) {
    final size = gameRef.size;
    final startX = 40.0;
    final startY = 210.0;
    final cardWidth = (size.x - 100) / 2; // 2 columns
    final cardHeight = 120.0;
    final spacing = 20.0;

    int row = 0;
    int col = 0;

    for (final item in items) {
      final x = startX + col * (cardWidth + spacing);
      final y = startY + row * (cardHeight + spacing);

      if (y + cardHeight > size.y - 20) break; // Don't draw off screen

      _drawCollectionCard(
        canvas,
        item,
        Vector2(x, y),
        Vector2(cardWidth, cardHeight),
      );

      col++;
      if (col >= 2) {
        col = 0;
        row++;
      }
    }
  }

  /// Draw collection card
  void _drawCollectionCard(
    Canvas canvas,
    CollectionItem item,
    Vector2 position,
    Vector2 cardSize,
  ) {
    final isSelected = _selectedItemId == item.id;

    // Card background
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.x, position.y, cardSize.x, cardSize.y),
      const Radius.circular(12),
    );

    // Background color based on discovery and selection
    Color bgColor;
    if (!item.discovered) {
      bgColor = const Color(0xFF2F2F2F); // Dark gray (locked)
    } else if (isSelected) {
      bgColor = const Color(0xFFFFE4B5); // Moccasin (selected)
    } else {
      bgColor = const Color(0xFFFFFFFF); // White (normal)
    }

    canvas.drawRRect(cardRect, Paint()..color = bgColor);

    // Border
    final borderColor = isSelected
        ? const Color(0xFFFFD700) // Gold (selected)
        : _getRarityColor(item.rarity);

    canvas.drawRRect(
      cardRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = borderColor
        ..strokeWidth = isSelected ? 4 : 2,
    );

    if (item.discovered) {
      // Icon
      final iconPainter = TextPainter(
        text: TextSpan(
          text: item.icon,
          style: const TextStyle(fontSize: 48),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(position.x + 20, position.y + 15),
      );

      // Name
      final namePainter = TextPainter(
        text: TextSpan(
          text: item.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout(maxWidth: cardSize.x - 100);
      namePainter.paint(
        canvas,
        Offset(position.x + 80, position.y + 15),
      );

      // Category
      final categoryPainter = TextPainter(
        text: TextSpan(
          text: item.category,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      categoryPainter.layout();
      categoryPainter.paint(
        canvas,
        Offset(position.x + 80, position.y + 38),
      );

      // Rarity badge
      _drawRarityBadge(
        canvas,
        item.rarity,
        Offset(position.x + cardSize.x - 80, position.y + 15),
      );

      // Stats
      final statsText = item.tier != null
          ? 'Tier ${item.tier} • Crafted: ${item.timesCrafted}'
          : 'Gathered: ${item.timesGathered}';

      final statsPainter = TextPainter(
        text: TextSpan(
          text: statsText,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF888888),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      statsPainter.layout();
      statsPainter.paint(
        canvas,
        Offset(position.x + 15, position.y + cardSize.y - 30),
      );
    } else {
      // Locked state
      final lockPainter = TextPainter(
        text: const TextSpan(
          text: '🔒',
          style: TextStyle(fontSize: 40),
        ),
        textDirection: TextDirection.ltr,
      );
      lockPainter.layout();
      lockPainter.paint(
        canvas,
        Offset(
          position.x + cardSize.x / 2 - lockPainter.width / 2,
          position.y + cardSize.y / 2 - lockPainter.height / 2 - 10,
        ),
      );

      final unknownPainter = TextPainter(
        text: const TextSpan(
          text: '???',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF888888),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      unknownPainter.layout();
      unknownPainter.paint(
        canvas,
        Offset(
          position.x + cardSize.x / 2 - unknownPainter.width / 2,
          position.y + cardSize.y / 2 + 20,
        ),
      );
    }

    // Make card tappable (simplified - would need proper tap handling)
    if (item.discovered) {
      // TODO: Add tap detection to set _selectedItemId = item.id
    }
  }

  /// Draw rarity badge
  void _drawRarityBadge(Canvas canvas, String rarity, Offset position) {
    final color = _getRarityColor(rarity);
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, position.dy, 70, 24),
      const Radius.circular(12),
    );

    canvas.drawRRect(badgeRect, Paint()..color = color);

    final textPainter = TextPainter(
      text: TextSpan(
        text: rarity,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx + 35 - textPainter.width / 2,
        position.dy + 12 - textPainter.height / 2,
      ),
    );
  }

  /// Get rarity color
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common':
        return const Color(0xFF808080); // Gray
      case 'Uncommon':
        return const Color(0xFF228B22); // Green
      case 'Rare':
        return const Color(0xFF4169E1); // Blue
      case 'Epic':
        return const Color(0xFF9370DB); // Purple
      case 'Legendary':
        return const Color(0xFFFFD700); // Gold
      default:
        return const Color(0xFF808080);
    }
  }

  /// Draw item detail panel
  void _drawItemDetail(Canvas canvas) {
    final size = gameRef.size;
    final item = _findItemById(_selectedItemId);
    if (item == null || !item.discovered) return;

    // Overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0x80000000), // 50% black
    );

    // Detail panel
    final panelWidth = size.x - 80.0;
    final panelHeight = 400.0;
    final panelX = 40.0;
    final panelY = size.y / 2 - panelHeight / 2;

    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(panelX, panelY, panelWidth, panelHeight),
      const Radius.circular(20),
    );

    canvas.drawRRect(panelRect, Paint()..color = const Color(0xFFFFFFF0)); // Ivory

    final borderColor = _getRarityColor(item.rarity);
    canvas.drawRRect(
      panelRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = borderColor
        ..strokeWidth = 4,
    );

    // Icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: item.icon,
        style: const TextStyle(fontSize: 80),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        panelX + panelWidth / 2 - iconPainter.width / 2,
        panelY + 30,
      ),
    );

    // Name
    final namePainter = TextPainter(
      text: TextSpan(
        text: item.name,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    namePainter.layout(maxWidth: panelWidth - 40);
    namePainter.paint(
      canvas,
      Offset(
        panelX + panelWidth / 2 - namePainter.width / 2,
        panelY + 130,
      ),
    );

    // Rarity and category
    final categoryText = item.tier != null
        ? '${item.rarity} • Tier ${item.tier} • ${item.category}'
        : '${item.rarity} • ${item.category}';

    final categoryPainter = TextPainter(
      text: TextSpan(
        text: categoryText,
        style: TextStyle(
          fontSize: 16,
          color: _getRarityColor(item.rarity),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    categoryPainter.layout();
    categoryPainter.paint(
      canvas,
      Offset(
        panelX + panelWidth / 2 - categoryPainter.width / 2,
        panelY + 170,
      ),
    );

    // Description
    final descPainter = TextPainter(
      text: TextSpan(
        text: item.description,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF555555),
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    descPainter.layout(maxWidth: panelWidth - 60);
    descPainter.paint(
      canvas,
      Offset(
        panelX + panelWidth / 2 - descPainter.width / 2,
        panelY + 210,
      ),
    );

    // Stats
    final statsText = item.tier != null
        ? 'Times Crafted: ${item.timesCrafted}'
        : 'Times Gathered: ${item.timesGathered}';

    final statsPainter = TextPainter(
      text: TextSpan(
        text: statsText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E8B57),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    statsPainter.layout();
    statsPainter.paint(
      canvas,
      Offset(
        panelX + panelWidth / 2 - statsPainter.width / 2,
        panelY + 310,
      ),
    );

    // Close button hint
    final closePainter = TextPainter(
      text: const TextSpan(
        text: 'Tap anywhere to close',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF888888),
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    closePainter.layout();
    closePainter.paint(
      canvas,
      Offset(
        panelX + panelWidth / 2 - closePainter.width / 2,
        panelY + panelHeight - 40,
      ),
    );
  }

  /// Find item by ID
  CollectionItem? _findItemById(String id) {
    for (final item in _materialCollection) {
      if (item.id == id) return item;
    }
    for (final item in _potionCollection) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Collection item model
class CollectionItem {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String rarity; // Common, Uncommon, Rare, Epic, Legendary
  final bool discovered;
  final int timesGathered;
  final int timesCrafted;
  final String category;
  final int? tier; // For potions

  CollectionItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.rarity,
    required this.discovered,
    this.timesGathered = 0,
    this.timesCrafted = 0,
    required this.category,
    this.tier,
  });
}
