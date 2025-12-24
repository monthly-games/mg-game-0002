import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/recipe.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';

/// Recipes scene - recipe book/codex
class RecipesScene extends Component with HasGameRef {
  final WidgetRef ref;

  // Recipe data
  List<Recipe> _allRecipes = [];
  List<Recipe> _discoveredRecipes = [];
  List<Recipe> _lockedRecipes = [];

  // UI Components
  late TextComponent _titleText;
  late TextComponent _discoveryProgressText;
  late GameButton _backButton;
  late GameButton _filterAllButton;
  late GameButton _filterDiscoveredButton;
  late GameButton _filterLockedButton;

  // Filter state
  String _currentFilter = 'all'; // 'all', 'discovered', 'locked'

  // Constants
  static const int _recipesPerRow = 4;
  static const double _cardWidth = 160.0;
  static const double _cardHeight = 220.0;
  static const double _cardSpacing = 20.0;

  RecipesScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadRecipes();
    await _setupUI();
  }

  /// Load recipes from provider
  Future<void> _loadRecipes() async {
    final gameState = ref.read(gameStateProvider);
    final recipesAsync = ref.read(recipesProvider);

    await recipesAsync.when(
      data: (recipes) {
        _allRecipes = recipes;
        _discoveredRecipes = recipes
            .where((r) => gameState.discoveredRecipes.contains(r.id))
            .toList();
        _lockedRecipes = recipes
            .where((r) => !gameState.discoveredRecipes.contains(r.id))
            .toList();
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Title
    _titleText = TextComponent(
      text: 'Recipe Codex',
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

    // Discovery progress
    final progress = _discoveredRecipes.length;
    final total = _allRecipes.length;
    final percentage = total > 0 ? (progress * 100 / total).toInt() : 0;

    _discoveryProgressText = TextComponent(
      text: 'Discovered: $progress/$total ($percentage%)',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF228B22), // Forest green
        ),
      ),
      position: Vector2(size.x - 200, 40),
      anchor: Anchor.center,
    );
    add(_discoveryProgressText);

    // Filter buttons
    _addFilterButtons();

    // Build recipe cards
    _buildRecipeCards();
  }

  /// Add filter buttons
  void _addFilterButtons() {
    final size = gameRef.size;
    final centerX = size.x / 2;

    // All filter
    _filterAllButton = GameButton(
      text: 'All (${_allRecipes.length})',
      onPressed: () => _setFilter('all'),
      position: Vector2(centerX - 200, 100),
      size: Vector2(120, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFF8B6914),
    );
    add(_filterAllButton);

    // Discovered filter
    _filterDiscoveredButton = GameButton(
      text: 'Discovered (${_discoveredRecipes.length})',
      onPressed: () => _setFilter('discovered'),
      position: Vector2(centerX - 60, 100),
      size: Vector2(160, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFFD4B896),
    );
    add(_filterDiscoveredButton);

    // Locked filter
    _filterLockedButton = GameButton(
      text: 'Locked (${_lockedRecipes.length})',
      onPressed: () => _setFilter('locked'),
      position: Vector2(centerX + 120, 100),
      size: Vector2(140, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFFD4B896),
    );
    add(_filterLockedButton);
  }

  /// Build recipe cards
  void _buildRecipeCards() {
    final size = gameRef.size;

    // Get filtered recipes
    List<Recipe> recipesToShow;
    switch (_currentFilter) {
      case 'discovered':
        recipesToShow = _discoveredRecipes;
        break;
      case 'locked':
        recipesToShow = _lockedRecipes;
        break;
      case 'all':
      default:
        recipesToShow = _allRecipes;
        break;
    }

    if (recipesToShow.isEmpty) {
      _showEmptyMessage();
      return;
    }

    // Calculate grid layout
    final gridWidth =
        _recipesPerRow * (_cardWidth + _cardSpacing) - _cardSpacing;
    final gridStartX = (size.x - gridWidth) / 2;
    final gridStartY = 170.0;

    // Build cards
    for (int i = 0; i < recipesToShow.length; i++) {
      final row = i ~/ _recipesPerRow;
      final col = i % _recipesPerRow;

      final x = gridStartX + col * (_cardWidth + _cardSpacing);
      final y = gridStartY + row * (_cardHeight + _cardSpacing);

      final recipe = recipesToShow[i];
      final isDiscovered = _discoveredRecipes.contains(recipe);

      _buildRecipeCard(recipe, Vector2(x, y), isDiscovered);
    }
  }

  /// Build a single recipe card
  void _buildRecipeCard(Recipe recipe, Vector2 position, bool isDiscovered) {
    final cardSize = Vector2(_cardWidth, _cardHeight);

    // Card background
    final cardBg = RectangleComponent(
      position: position,
      size: cardSize,
      paint: Paint()
        ..color = isDiscovered
            ? const Color(0xFFE8D5B7).withOpacity(0.95)
            : const Color(0xFF8B7355).withOpacity(0.6),
    );
    add(cardBg);

    // Card border
    final cardBorder = RectangleComponent(
      position: position,
      size: cardSize,
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    cardBorder.paint.color = isDiscovered
        ? const Color(0xFF8B6914)
        : const Color(0xFF5D4E37);
    add(cardBorder);

    if (isDiscovered) {
      // Discovered recipe - show full details
      _buildDiscoveredCard(recipe, position, cardSize);
    } else {
      // Locked recipe - show hint
      _buildLockedCard(recipe, position, cardSize);
    }

    // Click area for details
    if (isDiscovered) {
      final clickButton = GameButton(
        text: '',
        onPressed: () => _showRecipeDetails(recipe),
        position: position,
        size: cardSize,
        backgroundColor: Colors.transparent,
      );
      add(clickButton);
    }
  }

  /// Build discovered recipe card
  void _buildDiscoveredCard(Recipe recipe, Vector2 position, Vector2 cardSize) {
    // Recipe icon placeholder
    final iconText = TextComponent(
      text: '🧪', // Placeholder - would be recipe icon
      textRenderer: TextPaint(style: const TextStyle(fontSize: 48)),
      position: position + Vector2(cardSize.x / 2, 40),
      anchor: Anchor.center,
    );
    add(iconText);

    // Recipe name
    final nameText = TextComponent(
      text: recipe.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: position + Vector2(cardSize.x / 2, 90),
      anchor: Anchor.center,
    );
    add(nameText);

    // Tier
    final tierText = TextComponent(
      text: 'Tier ${recipe.tier}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Color(0xFF5D4E37)),
      ),
      position: position + Vector2(cardSize.x / 2, 115),
      anchor: Anchor.center,
    );
    add(tierText);

    // Crafting time
    final timeMinutes = recipe.craftTime ~/ 60;
    final timeSeconds = recipe.craftTime % 60;
    final timeText = TextComponent(
      text: '⏱ ${timeMinutes}m ${timeSeconds}s',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4169E1), // Royal blue
        ),
      ),
      position: position + Vector2(cardSize.x / 2, 140),
      anchor: Anchor.center,
    );
    add(timeText);

    // Sell price
    final priceText = TextComponent(
      text: '💰 ${recipe.sellPrice}g',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFD700), // Gold
        ),
      ),
      position: position + Vector2(cardSize.x / 2, 165),
      anchor: Anchor.center,
    );
    add(priceText);

    // Ingredients count
    final ingredientsText = TextComponent(
      text: '${recipe.ingredients.length} ingredients',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 11, color: Color(0xFF808080)),
      ),
      position: position + Vector2(cardSize.x / 2, 190),
      anchor: Anchor.center,
    );
    add(ingredientsText);
  }

  /// Build locked recipe card
  void _buildLockedCard(Recipe recipe, Vector2 position, Vector2 cardSize) {
    // Lock icon
    final lockIcon = TextComponent(
      text: '🔒',
      textRenderer: TextPaint(style: const TextStyle(fontSize: 48)),
      position: position + Vector2(cardSize.x / 2, 50),
      anchor: Anchor.center,
    );
    add(lockIcon);

    // "???" text
    final unknownText = TextComponent(
      text: '???',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5D4E37),
        ),
      ),
      position: position + Vector2(cardSize.x / 2, 110),
      anchor: Anchor.center,
    );
    add(unknownText);

    // Hint - tier
    final tierHint = TextComponent(
      text: 'Tier ${recipe.tier} Recipe',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 12, color: Color(0xFF808080)),
      ),
      position: position + Vector2(cardSize.x / 2, 145),
      anchor: Anchor.center,
    );
    add(tierHint);

    // Hint - unlock requirement
    final unlockHint = _getUnlockHint(recipe);
    final hintText = TextComponent(
      text: unlockHint,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF808080),
          fontStyle: FontStyle.italic,
        ),
      ),
      position: position + Vector2(cardSize.x / 2, 175),
      anchor: Anchor.center,
    );
    add(hintText);
  }

  /// Get unlock hint for locked recipe
  String _getUnlockHint(Recipe recipe) {
    // Based on tier
    if (recipe.tier == 1) {
      return 'Start crafting!';
    } else if (recipe.tier == 2) {
      return 'Craft Tier 1 potions';
    } else if (recipe.tier == 3) {
      return 'Reach Workshop Lv.3';
    } else if (recipe.tier == 4) {
      return 'Reach Workshop Lv.5';
    } else if (recipe.tier >= 5) {
      return 'Master higher tiers';
    }

    return 'Keep exploring!';
  }

  /// Show recipe details dialog
  void _showRecipeDetails(Recipe recipe) {
    final size = gameRef.size;

    // Dialog background
    final dialogBg = RectangleComponent(
      position: size / 2,
      size: Vector2(500, 450),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFE8D5B7),
    );
    add(dialogBg);

    // Dialog border
    final dialogBorder = RectangleComponent(
      position: size / 2,
      size: Vector2(500, 450),
      anchor: Anchor.center,
      paint: Paint()
        ..color = const Color(0xFF8B6914)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(dialogBorder);

    // Recipe name
    final nameText = TextComponent(
      text: recipe.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: size / 2 + Vector2(0, -190),
      anchor: Anchor.center,
    );
    add(nameText);

    // Description
    final descText = TextComponent(
      text: recipe.description,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 16, color: Color(0xFF5D4E37)),
      ),
      position: size / 2 + Vector2(0, -150),
      anchor: Anchor.center,
    );
    add(descText);

    // Tier and category
    final infoText = TextComponent(
      text: 'Tier ${recipe.tier} • ${recipe.category}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Color(0xFF808080)),
      ),
      position: size / 2 + Vector2(0, -120),
      anchor: Anchor.center,
    );
    add(infoText);

    // Ingredients title
    final ingredientsTitle = TextComponent(
      text: 'Ingredients:',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: size / 2 + Vector2(0, -80),
      anchor: Anchor.center,
    );
    add(ingredientsTitle);

    // Ingredients list
    var ingredientY = -50.0;
    for (final ingredient in recipe.ingredients) {
      final ingredientText = TextComponent(
        text: '• ${ingredient.id} x${ingredient.amount}',
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 14, color: Color(0xFF5D4E37)),
        ),
        position: size / 2 + Vector2(0, ingredientY),
        anchor: Anchor.center,
      );
      add(ingredientText);
      ingredientY += 25;
    }

    // Stats
    final statsY = ingredientY + 20;

    final timeText = TextComponent(
      text: '⏱ Craft Time: ${recipe.craftTime}s',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Color(0xFF4169E1)),
      ),
      position: size / 2 + Vector2(0, statsY),
      anchor: Anchor.center,
    );
    add(timeText);

    final priceText = TextComponent(
      text: '💰 Sell Price: ${recipe.sellPrice}g',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFD700),
        ),
      ),
      position: size / 2 + Vector2(0, statsY + 25),
      anchor: Anchor.center,
    );
    add(priceText);

    final expText = TextComponent(
      text: '✨ Exp Reward: ${recipe.discoveryBonus.exp}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Color(0xFF9370DB)),
      ),
      position: size / 2 + Vector2(0, statsY + 50),
      anchor: Anchor.center,
    );
    add(expText);

    // Close button
    final closeButton = GameButton(
      text: 'Close',
      onPressed: () {
        remove(dialogBg);
        remove(dialogBorder);
        remove(nameText);
        remove(descText);
        remove(infoText);
        remove(ingredientsTitle);
        remove(timeText);
        remove(priceText);
        remove(expText);
      },
      position: size / 2 + Vector2(0, 180),
      size: Vector2(120, 50),
    );
    add(closeButton);
  }

  /// Show empty message
  void _showEmptyMessage() {
    final size = gameRef.size;

    String message;
    switch (_currentFilter) {
      case 'discovered':
        message = 'No recipes discovered yet.\nStart crafting to unlock them!';
        break;
      case 'locked':
        message = 'All recipes discovered!\nYou\'re a master alchemist!';
        break;
      default:
        message = 'No recipes available.';
        break;
    }

    final emptyText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Color(0xFF8B4513),
          height: 1.5,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(emptyText);
  }

  /// Set filter mode
  void _setFilter(String filter) {
    _currentFilter = filter;

    // Update button colors
    _filterAllButton.backgroundColor = filter == 'all'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);
    _filterDiscoveredButton.backgroundColor = filter == 'discovered'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);
    _filterLockedButton.backgroundColor = filter == 'locked'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);

    // Rebuild cards
    _refreshUI();
  }

  /// Refresh UI
  void _refreshUI() {
    // Remove all children except title, progress, back button, and filter buttons
    final toKeep = [
      _titleText,
      _discoveryProgressText,
      _backButton,
      _filterAllButton,
      _filterDiscoveredButton,
      _filterLockedButton,
    ];
    final toRemove = children.where((c) => !toKeep.contains(c));
    removeAll(toRemove);

    // Rebuild recipe cards
    _buildRecipeCards();
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

    // Book background decoration
    final bookRect = Rect.fromLTWH(30, 160, size.x - 60, size.y - 190);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bookRect, const Radius.circular(15)),
      Paint()..color = const Color(0xFF8B6914).withOpacity(0.1),
    );

    // Book spine decoration (left side)
    final spineRect = Rect.fromLTWH(30, 160, 20, size.y - 190);
    canvas.drawRect(
      spineRect,
      Paint()..color = const Color(0xFF8B4513).withOpacity(0.3),
    );
  }
}
