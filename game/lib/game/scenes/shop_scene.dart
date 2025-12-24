import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/material.dart' as game_material;
import '../../core/models/recipe.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../components/inventory_slot.dart';
import '../components/dialog_box.dart';
import '../cat_alchemy_game.dart';

/// Shop scene - buy materials and sell potions
class ShopScene extends Component with HasGameRef {
  final WidgetRef ref;

  // Shop tabs
  String _currentTab = 'buy'; // 'buy' or 'sell'

  // Shop data
  List<game_material.Material> _buyableMaterials = [];
  List<String> _sellableItems = []; // Potion IDs from discovered recipes

  // UI Components
  late TextComponent _titleText;
  late GameButton _backButton;
  late GameButton _buyTabButton;
  late GameButton _sellTabButton;

  ShopScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadShopData();
    await _setupUI();
  }

  /// Load shop data
  Future<void> _loadShopData() async {
    // Load buyable materials (tier 1-3, not highest tier)
    final materialsAsync = ref.read(unlockedMaterialsProvider);
    await materialsAsync.when(
      data: (materials) {
        _buyableMaterials = materials
            .where((m) => m.tier <= 3) // Can buy up to tier 3
            .toList();
      },
      loading: () {},
      error: (_, __) {},
    );

    // Load sellable items (discovered potion recipes)
    final gameState = ref.read(gameStateProvider);
    final recipesAsync = ref.read(recipesProvider);

    await recipesAsync.when(
      data: (recipes) {
        _sellableItems = recipes
            .where(
              (r) =>
                  gameState.discoveredRecipes.contains(r.id) &&
                  r.category == 'potion',
            )
            .map((r) => r.id)
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
      text: 'Merchant Shop',
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

    // Tab buttons
    _buyTabButton = GameButton(
      text: 'Buy Materials',
      onPressed: () => _switchTab('buy'),
      position: Vector2(size.x / 2 - 160, 120),
      size: Vector2(150, 50),
      backgroundColor: _currentTab == 'buy'
          ? const Color(0xFF8B6914)
          : const Color(0xFFD4B896),
    );
    add(_buyTabButton);

    _sellTabButton = GameButton(
      text: 'Sell Potions',
      onPressed: () => _switchTab('sell'),
      position: Vector2(size.x / 2 + 10, 120),
      size: Vector2(150, 50),
      backgroundColor: _currentTab == 'sell'
          ? const Color(0xFF8B6914)
          : const Color(0xFFD4B896),
    );
    add(_sellTabButton);

    // Build shop content
    _buildShopContent();
  }

  /// Switch tab
  void _switchTab(String tab) {
    if (_currentTab == tab) return;

    _currentTab = tab;

    // Update button colors
    _buyTabButton.backgroundColor = _currentTab == 'buy'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);
    _sellTabButton.backgroundColor = _currentTab == 'sell'
        ? const Color(0xFF8B6914)
        : const Color(0xFFD4B896);

    // Rebuild content
    _refreshContent();
  }

  /// Build shop content based on current tab
  void _buildShopContent() {
    if (_currentTab == 'buy') {
      _buildBuyContent();
    } else {
      _buildSellContent();
    }
  }

  /// Build buy materials content
  void _buildBuyContent() {
    final size = gameRef.size;

    // Material grid
    final materialItems = <String, int>{};
    for (final material in _buyableMaterials) {
      materialItems[material.id] = 1; // Display as single item
    }

    final materialGrid = InventoryGrid(
      items: materialItems,
      columns: 5,
      rows: 3,
      slotSize: 80,
      spacing: 12,
      position: Vector2(50, 200),
      onItemTap: _onBuyMaterial,
    );

    add(materialGrid);

    // Instructions
    final instructionText = TextComponent(
      text: 'Click on materials to buy them',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18, color: Color(0xFF5D4E37)),
      ),
      position: Vector2(size.x / 2, size.y - 60),
      anchor: Anchor.center,
    );
    add(instructionText);
  }

  /// Build sell potions content
  void _buildSellContent() {
    final size = gameRef.size;
    final gameState = ref.read(gameStateProvider);

    // Get potions from inventory
    final potionItems = <String, int>{};
    for (final itemId in _sellableItems) {
      final amount = gameState.getInventoryAmount(itemId);
      if (amount > 0) {
        potionItems[itemId] = amount;
      }
    }

    if (potionItems.isEmpty) {
      // No potions to sell
      final noItemsText = TextComponent(
        text: 'You have no potions to sell.\nCraft some first!',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF8B4513),
            height: 1.5,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      );
      add(noItemsText);
    } else {
      // Potion grid
      final potionGrid = InventoryGrid(
        items: potionItems,
        columns: 5,
        rows: 3,
        slotSize: 80,
        spacing: 12,
        position: Vector2(50, 200),
        onItemTap: _onSellPotion,
      );

      add(potionGrid);

      // Instructions
      final instructionText = TextComponent(
        text: 'Click on potions to sell them',
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 18, color: Color(0xFF5D4E37)),
        ),
        position: Vector2(size.x / 2, size.y - 60),
        anchor: Anchor.center,
      );
      add(instructionText);
    }
  }

  /// Handle buy material click
  void _onBuyMaterial(String materialId) {
    final material = _buyableMaterials.firstWhere((m) => m.id == materialId);
    _showBuyDialog(material);
  }

  /// Show buy confirmation dialog
  void _showBuyDialog(game_material.Material material) {
    final gameState = ref.read(gameStateProvider);
    final buyPrice = _calculateBuyPrice(material);

    final canAfford = gameState.gold >= buyPrice;

    final message =
        'Material: ${material.name}\n'
        'Tier: ${material.tier}\n'
        'Price: $buyPrice gold\n\n'
        'Your gold: ${gameState.gold}';

    final dialog = DialogBox(
      title: 'Buy Material',
      message: message,
      buttons: [
        DialogButton(text: 'Cancel', onPressed: () {}),
        DialogButton(
          text: 'Buy (x1)',
          onPressed: canAfford ? () => _buyMaterial(material, 1) : () {},
          color: canAfford ? const Color(0xFF228B22) : const Color(0xFF808080),
        ),
        DialogButton(
          text: 'Buy (x10)',
          onPressed: canAfford && gameState.gold >= buyPrice * 10
              ? () => _buyMaterial(material, 10)
              : () {},
          color: canAfford && gameState.gold >= buyPrice * 10
              ? const Color(0xFF228B22)
              : const Color(0xFF808080),
        ),
      ],
      onClose: () => remove(children.whereType<DialogBox>().first),
      position: gameRef.size / 2,
      size: Vector2(500, 350),
    );

    add(dialog);
  }

  /// Calculate buy price for material
  int _calculateBuyPrice(game_material.Material material) {
    // Base price increases with tier
    return 10 *
        material.tier *
        material.tier; // Tier 1: 10g, Tier 2: 40g, Tier 3: 90g
  }

  /// Buy material
  void _buyMaterial(game_material.Material material, int amount) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final buyPrice = _calculateBuyPrice(material) * amount;

    // Spend gold
    if (!gameStateNotifier.spendGold(buyPrice)) {
      return; // Not enough gold
    }

    // Add material to inventory
    gameStateNotifier.addToInventory(material.id, amount);

    // Remove dialog
    for (final child in children.whereType<DialogBox>()) {
      remove(child);
    }

    // Show success message
    _showMessage('Bought $amount ${material.name}!');
  }

  /// Handle sell potion click
  void _onSellPotion(String potionId) async {
    final recipesAsync = ref.read(recipesProvider);

    await recipesAsync.when(
      data: (recipes) {
        final recipe = recipes.firstWhere((r) => r.id == potionId);
        _showSellDialog(recipe);
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// Show sell confirmation dialog
  void _showSellDialog(Recipe recipe) {
    final gameState = ref.read(gameStateProvider);
    final amount = gameState.getInventoryAmount(recipe.id);
    final sellPrice = recipe.sellPrice;

    final message =
        'Potion: ${recipe.name}\n'
        'You have: $amount\n'
        'Sell price: $sellPrice gold each\n\n'
        'Total (x1): $sellPrice gold\n'
        'Total (x10): ${sellPrice * 10} gold';

    final dialog = DialogBox(
      title: 'Sell Potion',
      message: message,
      buttons: [
        DialogButton(text: 'Cancel', onPressed: () {}),
        DialogButton(
          text: 'Sell (x1)',
          onPressed: amount >= 1 ? () => _sellPotion(recipe, 1) : () {},
          color: amount >= 1
              ? const Color(0xFF228B22)
              : const Color(0xFF808080),
        ),
        DialogButton(
          text: 'Sell (x10)',
          onPressed: amount >= 10 ? () => _sellPotion(recipe, 10) : () {},
          color: amount >= 10
              ? const Color(0xFF228B22)
              : const Color(0xFF808080),
        ),
      ],
      onClose: () => remove(children.whereType<DialogBox>().first),
      position: gameRef.size / 2,
      size: Vector2(500, 350),
    );

    add(dialog);
  }

  /// Sell potion
  void _sellPotion(Recipe recipe, int amount) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final prestigeManager = ref.read(prestigeManagerProvider);
    final multiplier = prestigeManager.getPrestigeMultiplier('gold_boost');
    final sellPrice = (recipe.sellPrice * amount * multiplier).toInt();

    // Remove potion from inventory
    if (!gameStateNotifier.removeFromInventory(recipe.id, amount)) {
      return; // Not enough potions
    }

    // Add gold
    gameStateNotifier.addGold(sellPrice);

    // Remove dialog
    for (final child in children.whereType<DialogBox>()) {
      remove(child);
    }

    // Refresh UI
    _refreshContent();

    // Show success message
    _showMessage('Sold $amount ${recipe.name} for $sellPrice gold!');
  }

  /// Refresh shop content
  void _refreshContent() {
    // Remove old content (keep title, back, tabs)
    final toRemove = children.where(
      (c) =>
          c is! TextComponent ||
          (c != _titleText &&
              c != _backButton &&
              c != _buyTabButton &&
              c != _sellTabButton),
    );

    removeAll(toRemove);

    // Rebuild
    _buildShopContent();
  }

  /// Show temporary message
  void _showMessage(String message) {
    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF228B22),
          shadows: [
            Shadow(color: Colors.white, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
      position: gameRef.size / 2 + Vector2(0, -100),
      anchor: Anchor.center,
    );

    add(messageText);

    // Remove after 2 seconds
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
      Paint()..color = const Color(0xFFF5E6D3), // Warm cream
    );

    // Shop counter/table decoration
    final counterRect = Rect.fromLTWH(30, 180, size.x - 60, size.y - 250);
    canvas.drawRRect(
      RRect.fromRectAndRadius(counterRect, const Radius.circular(15)),
      Paint()..color = const Color(0xFFD2B48C).withOpacity(0.4), // Tan
    );
  }
}
