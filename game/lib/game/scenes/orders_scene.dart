import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/npc.dart';
import '../../core/models/recipe.dart';
import '../../core/services/order_service.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../components/dialog_box.dart';
import '../cat_alchemy_game.dart';

/// Orders scene - NPC orders and quest board
class OrdersScene extends Component with HasGameRef {
  final WidgetRef ref;

  // Order data
  final OrderService _orderService = OrderService();
  final List<ActiveOrder> _activeOrders = [];
  List<NPC> _availableNPCs = [];
  List<Recipe> _discoveredRecipes = [];

  // UI Components
  late TextComponent _titleText;
  late GameButton _backButton;
  late GameButton _refreshButton;

  OrdersScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadData();
    await _setupUI();
    _loadActiveOrders();
  }

  /// Load NPCs and recipes
  Future<void> _loadData() async {
    final gameState = ref.read(gameStateProvider);

    // Load unlocked NPCs
    final npcsAsync = ref.read(unlockedNPCsProvider);
    await npcsAsync.when(
      data: (npcs) {
        _availableNPCs = npcs;
      },
      loading: () {},
      error: (_, __) {},
    );

    // Load discovered recipes
    final recipesAsync = ref.read(recipesProvider);
    await recipesAsync.when(
      data: (recipes) {
        _discoveredRecipes = recipes
            .where((r) => gameState.discoveredRecipes.contains(r.id))
            .toList();
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// Load active orders from game state
  void _loadActiveOrders() {
    // TODO: Load from GameState.activeOrders
    // For now, generate sample orders if none exist
    if (_activeOrders.isEmpty && _availableNPCs.isNotEmpty) {
      _generateSampleOrders();
    }
  }

  /// Generate sample orders for testing
  void _generateSampleOrders() {
    if (_discoveredRecipes.isEmpty) return;

    final gameState = ref.read(gameStateProvider);

    // Generate 2-3 orders
    for (int i = 0; i < 2 && i < _availableNPCs.length; i++) {
      try {
        final order = _orderService.generateOrder(
          npc: _availableNPCs[i],
          availableRecipes: _discoveredRecipes,
          playerLevel: gameState.workshopLevel,
        );
        _activeOrders.add(order);
      } catch (e) {
        print('Failed to generate order: $e');
      }
    }
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Title
    _titleText = TextComponent(
      text: 'Order Board - NPC Requests',
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

    // Refresh orders button
    _refreshButton = GameButton(
      text: '🔄 Refresh',
      onPressed: _refreshOrders,
      position: Vector2(size.x - 120, 40),
      size: Vector2(140, 50),
      fontSize: 18,
    );
    add(_refreshButton);

    // Build order cards
    _buildOrderCards();
  }

  /// Build order cards
  void _buildOrderCards() {
    if (_activeOrders.isEmpty) {
      _showNoOrdersMessage();
      return;
    }

    final size = gameRef.size;
    var yPos = 120.0;

    for (int i = 0; i < _activeOrders.length; i++) {
      final order = _activeOrders[i];
      _buildOrderCard(order, Vector2(50, yPos));
      yPos += 200;
    }
  }

  /// Build a single order card
  void _buildOrderCard(ActiveOrder order, Vector2 position) {
    final size = Vector2(gameRef.size.x - 100, 180);
    final gameState = ref.read(gameStateProvider);

    // Card background
    final cardBg = RectangleComponent(
      position: position,
      size: size,
      paint: Paint()..color = const Color(0xFFE8D5B7).withOpacity(0.9),
    );
    add(cardBg);

    // NPC name
    final npcName = TextComponent(
      text: '${order.npc.name} requests:',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: position + Vector2(20, 15),
    );
    add(npcName);

    // Order items
    var itemY = 45.0;
    for (final item in order.items) {
      final itemText = TextComponent(
        text: '- ${item.recipeId} x${item.amount}',
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 18, color: Color(0xFF5D4E37)),
        ),
        position: position + Vector2(30, itemY),
      );
      add(itemText);
      itemY += 25;
    }

    // Rewards
    final rewardText = TextComponent(
      text:
          'Reward: ${order.goldReward}g, ${order.expReward}xp, +${order.reputationReward} rep',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF228B22), // Forest green
          fontWeight: FontWeight.bold,
        ),
      ),
      position: position + Vector2(20, size.y - 60),
    );
    add(rewardText);

    // Time remaining
    final timeRemaining = order.getRemainingTime();
    final timeText = TextComponent(
      text: 'Time: ${_formatDuration(timeRemaining)}',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 16,
          color: order.isExpired()
              ? const Color(0xFFDC143C) // Crimson
              : const Color(0xFF4169E1), // Royal blue
        ),
      ),
      position: position + Vector2(20, size.y - 35),
    );
    add(timeText);

    // Completion percentage
    final completionPct = _orderService.getCompletionPercentage(
      order: order,
      inventory: gameState.inventory,
    );

    final completionText = TextComponent(
      text: 'Progress: ${(completionPct * 100).toInt()}%',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 16, color: Color(0xFF8B4513)),
      ),
      position: position + Vector2(size.x - 200, size.y - 35),
    );
    add(completionText);

    // Complete button
    final canComplete = _orderService.canCompleteOrder(
      order: order,
      inventory: gameState.inventory,
    );

    final completeButton = GameButton(
      text: canComplete ? 'Complete' : 'In Progress',
      onPressed: canComplete ? () => _completeOrder(order) : () {},
      position: position + Vector2(size.x - 130, size.y - 90),
      size: Vector2(120, 50),
      enabled: canComplete,
      backgroundColor: canComplete
          ? const Color(0xFF228B22)
          : const Color(0xFF808080),
      fontSize: 16,
    );
    add(completeButton);
  }

  /// Show no orders message
  void _showNoOrdersMessage() {
    final size = gameRef.size;

    final noOrdersText = TextComponent(
      text: 'No active orders.\nCheck back later or refresh!',
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
    add(noOrdersText);
  }

  /// Complete an order
  void _completeOrder(ActiveOrder order) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);

    // Remove items from inventory
    for (final item in order.items) {
      if (!gameStateNotifier.removeFromInventory(item.recipeId, item.amount)) {
        _showMessage('Failed to complete order!');
        return;
      }
    }

    // Add rewards
    final prestigeManager = ref.read(prestigeManagerProvider);
    final multiplier = prestigeManager.getPrestigeMultiplier('gold_boost');
    final actualGold = (order.goldReward * multiplier).toInt();

    gameStateNotifier.addGold(actualGold);
    // TODO: Add exp and reputation

    // Remove order from active list
    _activeOrders.remove(order);

    // Refresh UI
    _refreshUI();

    // Show completion dialog
    _showCompletionDialog(order);
  }

  /// Show order completion dialog
  void _showCompletionDialog(ActiveOrder order) {
    // Calculate bonus for display
    final prestigeManager = ref.read(prestigeManagerProvider);
    final multiplier = prestigeManager.getPrestigeMultiplier('gold_boost');
    final actualGold = (order.goldReward * multiplier).toInt();
    final bonusText = multiplier > 1.0
        ? ' (x${multiplier.toStringAsFixed(1)})'
        : '';

    final message =
        'Order completed!\n\n'
        '${order.npc.name} thanks you!\n\n'
        'Rewards:\n'
        '+ $actualGold gold$bonusText\n'
        '+ ${order.expReward} exp\n'
        '+ ${order.reputationReward} reputation';

    final dialog = InfoDialog(
      title: 'Order Complete! 🎉',
      message: message,
      position: gameRef.size / 2,
    );

    add(dialog);

    // Remove dialog after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (dialog.isMounted) {
        remove(dialog);
      }
    });
  }

  /// Refresh orders (costs gems or time)
  void _refreshOrders() {
    // TODO: Implement refresh logic (cost gems or daily limit)
    _showMessage('Refresh feature coming soon!');
  }

  /// Refresh UI
  void _refreshUI() {
    // Remove all children except title and buttons
    final toKeep = [_titleText, _backButton, _refreshButton];
    final toRemove = children.where((c) => !toKeep.contains(c));
    removeAll(toRemove);

    // Rebuild order cards
    _buildOrderCards();
  }

  /// Format duration
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Expired';
    }
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

    // Quest board decoration
    final boardRect = Rect.fromLTWH(30, 100, size.x - 60, size.y - 150);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(15)),
      Paint()..color = const Color(0xFF8B6914).withOpacity(0.2),
    );
  }
}
