import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/recipe.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../components/progress_bar.dart';
import '../components/inventory_slot.dart';
import '../components/dialog_box.dart';
import '../cat_alchemy_game.dart';
import 'package:mg_common_game/mg_common_game.dart';

/// Crafting scene - recipe selection and crafting
class CraftingScene extends Component with HasGameRef {
  final WidgetRef ref;

  // UI State
  Recipe? _selectedRecipe;
  List<Recipe> _availableRecipes = [];
  List<CraftingJob> _craftingQueue = [];

  // UI Components
  late TextComponent _titleText;
  late GameButton _backButton;
  late InventoryGrid _recipeGrid;

  CraftingScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadRecipes();
    await _setupUI();
  }

  /// Load available recipes
  Future<void> _loadRecipes() async {
    final recipesAsync = ref.read(recipesProvider);
    await recipesAsync.when(
      data: (recipes) {
        final gameState = ref.read(gameStateProvider);
        _availableRecipes = recipes
            .where((r) => gameState.discoveredRecipes.contains(r.id))
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
      text: 'Crafting Workshop',
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

    // Recipe grid
    _buildRecipeGrid();

    // Crafting queue display
    _buildCraftingQueue();
  }

  /// Build recipe selection grid
  void _buildRecipeGrid() {
    // Convert recipes to inventory format for grid display
    final recipeItems = <String, int>{};
    for (final recipe in _availableRecipes) {
      recipeItems[recipe.id] = 1; // Display as single item
    }

    _recipeGrid = InventoryGrid(
      items: recipeItems,
      columns: 4,
      rows: 3,
      slotSize: 80,
      spacing: 12,
      position: Vector2(50, 120),
      selectedItemId: _selectedRecipe?.id,
      onItemTap: _onRecipeSelected,
    );

    add(_recipeGrid);
  }

  /// Build crafting queue display
  void _buildCraftingQueue() {
    final craftingManager = ref.read(craftingGameManagerProvider);
    _craftingQueue = craftingManager.queue;

    // Display queue (top right area)
    final queueX = gameRef.size.x - 350;
    var queueY = 120.0;

    // Queue title
    final queueTitle = TextComponent(
      text:
          'Crafting Queue (${_craftingQueue.length}/${craftingManager.maxQueueSize})',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5D4E37),
        ),
      ),
      position: Vector2(queueX, queueY),
    );
    add(queueTitle);

    queueY += 40;

    // Queue slots
    for (int i = 0; i < craftingManager.maxQueueSize; i++) {
      if (i < _craftingQueue.length) {
        final job = _craftingQueue[i];
        _buildQueueSlot(Vector2(queueX, queueY), job);
      } else {
        _buildEmptyQueueSlot(Vector2(queueX, queueY));
      }
      queueY += 100;
    }
  }

  /// Build a crafting queue slot with job
  void _buildQueueSlot(Vector2 position, CraftingJob job) {
    // Slot background
    final slotBg = RectangleComponent(
      position: position,
      size: Vector2(300, 90),
      paint: Paint()..color = const Color(0xFFD4B896).withOpacity(0.8),
    );
    add(slotBg);

    // Recipe name
    final recipeName = TextComponent(
      text: job.recipeId, // TODO: Get actual recipe name
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5D4E37),
        ),
      ),
      position: position + Vector2(10, 10),
    );
    add(recipeName);

    // Progress bar
    final progressBar = TimerProgressBar(
      position: position + Vector2(10, 35),
      size: Vector2(280, 24),
      remaining: job.getRemainingTime(),
      total: job.craftDuration,
      fillColor: const Color(0xFF8B6914),
    );
    add(progressBar);

    // Collect button (if complete)
    if (job.isComplete()) {
      final collectBtn = GameButton(
        text: 'Collect',
        onPressed: () => _collectCrafting(job.id),
        position: position + Vector2(150, 70),
        size: Vector2(140, 35),
        backgroundColor: const Color(0xFF228B22), // Forest green
      );
      add(collectBtn);
    }
  }

  /// Build empty queue slot
  void _buildEmptyQueueSlot(Vector2 position) {
    final slotBg = RectangleComponent(
      position: position,
      size: Vector2(300, 90),
      paint: Paint()
        ..color = const Color(0xFFD4B896).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    add(slotBg);

    final emptyText = TextComponent(
      text: 'Empty Slot',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Color(0xFFA0826D)),
      ),
      position: position + Vector2(150, 45),
      anchor: Anchor.center,
    );
    add(emptyText);
  }

  /// Handle recipe selection
  void _onRecipeSelected(String recipeId) {
    final recipe = _availableRecipes.firstWhere((r) => r.id == recipeId);
    _selectedRecipe = recipe;

    // Show recipe details dialog
    _showRecipeDetails(recipe);
  }

  /// Show recipe details dialog
  void _showRecipeDetails(Recipe recipe) {
    final gameState = ref.read(gameStateProvider);

    // Build ingredients text
    final ingredientsText = recipe.ingredients
        .map((i) => '${i.id}: ${i.amount}')
        .join('\n');

    // Check if can craft
    final canCraft = recipe.canCraft(gameState.inventory);

    final message =
        'Ingredients:\n$ingredientsText\n\n'
        'Craft Time: ${recipe.craftDuration.inSeconds}s\n'
        'Sell Price: ${recipe.sellPrice} gold';

    final dialog = DialogBox(
      title: recipe.name,
      message: message,
      buttons: [
        DialogButton(text: 'Cancel', onPressed: () {}),
        DialogButton(
          text: 'Craft',
          onPressed: canCraft ? () => _startCrafting(recipe) : () {},
          color: canCraft
              ? const Color(0xFF228B22) // Green
              : const Color(0xFF808080), // Gray (disabled)
        ),
      ],
      onClose: () => remove(children.whereType<DialogBox>().first),
      position: gameRef.size / 2,
      size: Vector2(500, 350),
    );

    add(dialog);
  }

  /// Start crafting a recipe
  void _startCrafting(Recipe recipe) {
    if (gameRef is CatAlchemyGame) {
      final game = gameRef as CatAlchemyGame;
      game.selectedRecipe = recipe;
      game.navigateTo('puzzle');

      // Close dialog
      for (final child in children.whereType<DialogBox>()) {
        remove(child);
      }
    }
  }

  /// Collect completed crafting
  void _collectCrafting(String jobId) {
    final craftingManager = ref.read(craftingGameManagerProvider);
    craftingManager.collectCompleted(jobId);

    // Refresh UI
    _refreshUI();

    _showMessage('Item collected!');
  }

  /// Refresh UI
  void _refreshUI() {
    // Remove old components
    removeAll(children);

    // Rebuild UI
    _setupUI();
  }

  /// Show temporary message
  void _showMessage(String message) {
    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF228B22),
          shadows: [
            Shadow(color: Colors.white, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
      position: gameRef.size / 2 + Vector2(0, -50),
      anchor: Anchor.center,
    );

    add(messageText);

    // Remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (isMounted) {
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
  void update(double dt) {
    super.update(dt);

    // Update crafting queue timers
    // TODO: Optimize - only update when needed
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

    // Recipe selection area background
    final recipeAreaRect = Rect.fromLTWH(30, 100, 440, 400);
    canvas.drawRRect(
      RRect.fromRectAndRadius(recipeAreaRect, const Radius.circular(15)),
      Paint()..color = const Color(0xFFE8D5B7).withOpacity(0.6),
    );

    // Queue area background
    final queueAreaRect = Rect.fromLTWH(size.x - 370, 100, 340, 500);
    canvas.drawRRect(
      RRect.fromRectAndRadius(queueAreaRect, const Radius.circular(15)),
      Paint()..color = const Color(0xFFE8D5B7).withOpacity(0.6),
    );
  }
}
