import 'dart:math';
import '../models/npc.dart';
import '../models/recipe.dart';

/// Active order model
class ActiveOrder {
  final String id;
  final NPC npc;
  final List<OrderItem> items;
  final int goldReward;
  final int expReward;
  final int reputationReward;
  final DateTime createdTime;
  final Duration timeLimit;

  ActiveOrder({
    required this.id,
    required this.npc,
    required this.items,
    required this.goldReward,
    required this.expReward,
    required this.reputationReward,
    required this.createdTime,
    required this.timeLimit,
  });

  /// Check if order is expired
  bool isExpired() {
    final now = DateTime.now();
    return now.difference(createdTime) > timeLimit;
  }

  /// Get remaining time
  Duration getRemainingTime() {
    final now = DateTime.now();
    final elapsed = now.difference(createdTime);
    final remaining = timeLimit - elapsed;
    return remaining < Duration.zero ? Duration.zero : remaining;
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'npcId': npc.id,
      'items': items.map((i) => i.toJson()).toList(),
      'goldReward': goldReward,
      'expReward': expReward,
      'reputationReward': reputationReward,
      'createdTime': createdTime.millisecondsSinceEpoch,
      'timeLimit': timeLimit.inSeconds,
    };
  }

  /// Deserialize from JSON (requires NPC lookup)
  static ActiveOrder fromJson(Map<String, dynamic> json, NPC npc) {
    return ActiveOrder(
      id: json['id'] as String,
      npc: npc,
      items: (json['items'] as List)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      goldReward: json['goldReward'] as int,
      expReward: json['expReward'] as int,
      reputationReward: json['reputationReward'] as int,
      createdTime: DateTime.fromMillisecondsSinceEpoch(
        json['createdTime'] as int,
      ),
      timeLimit: Duration(seconds: json['timeLimit'] as int),
    );
  }
}

/// Order item (recipe + amount)
class OrderItem {
  final String recipeId;
  final int amount;

  OrderItem({
    required this.recipeId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'amount': amount,
    };
  }

  static OrderItem fromJson(Map<String, dynamic> json) {
    return OrderItem(
      recipeId: json['recipeId'] as String,
      amount: json['amount'] as int,
    );
  }
}

/// Service for generating and managing orders
class OrderService {
  final Random _random = Random();

  /// Generate a new order from NPC and available recipes
  ActiveOrder generateOrder({
    required NPC npc,
    required List<Recipe> availableRecipes,
    required int playerLevel,
  }) {
    // Filter recipes by NPC preferences and tier
    final suitableRecipes = availableRecipes.where((recipe) {
      // Check tier (NPC level ±1)
      if (recipe.tier < npc.unlockLevel - 1 ||
          recipe.tier > npc.unlockLevel + 1) {
        return false;
      }

      // Check if NPC prefers this item (simple name matching)
      // In full implementation, would use proper preference system
      return true;
    }).toList();

    if (suitableRecipes.isEmpty) {
      throw Exception('No suitable recipes for NPC ${npc.name}');
    }

    // Determine number of items (1-3 based on NPC level)
    final itemCount = 1 + _random.nextInt(min(3, npc.unlockLevel));

    // Select random recipes
    final selectedRecipes = <Recipe>[];
    for (int i = 0; i < itemCount; i++) {
      final recipe = suitableRecipes[_random.nextInt(suitableRecipes.length)];
      selectedRecipes.add(recipe);
    }

    // Create order items with amounts
    final orderItems = selectedRecipes.map((recipe) {
      // Amount: 1-3 for tier 1, 1-2 for tier 2+
      final maxAmount = recipe.tier == 1 ? 3 : 2;
      final amount = 1 + _random.nextInt(maxAmount);

      return OrderItem(
        recipeId: recipe.id,
        amount: amount,
      );
    }).toList();

    // Calculate rewards
    final baseGoldReward = selectedRecipes.fold<int>(
      0,
      (sum, recipe) => sum + recipe.sellPrice,
    );

    // Add bonus based on NPC personality
    final goldReward = (baseGoldReward * _getGoldMultiplier(npc)).round();
    final expReward = 10 * npc.unlockLevel * itemCount;
    final reputationReward = 5 * itemCount;

    // Time limit (1 hour per item tier)
    final totalTier = selectedRecipes.fold<int>(
      0,
      (sum, recipe) => sum + recipe.tier,
    );
    final timeLimit = Duration(hours: totalTier + 1);

    return ActiveOrder(
      id: '${DateTime.now().millisecondsSinceEpoch}_${npc.id}',
      npc: npc,
      items: orderItems,
      goldReward: goldReward,
      expReward: expReward,
      reputationReward: reputationReward,
      createdTime: DateTime.now(),
      timeLimit: timeLimit,
    );
  }

  /// Get gold reward multiplier based on NPC personality
  double _getGoldMultiplier(NPC npc) {
    // Generous NPCs pay more
    if (npc.personality.contains('generous') ||
        npc.personality.contains('wealthy')) {
      return 1.3;
    }

    // Frugal NPCs pay less
    if (npc.personality.contains('frugal') ||
        npc.personality.contains('poor')) {
      return 0.8;
    }

    return 1.0;
  }

  /// Check if player can complete order
  bool canCompleteOrder({
    required ActiveOrder order,
    required Map<String, int> inventory,
  }) {
    for (final item in order.items) {
      final available = inventory[item.recipeId] ?? 0;
      if (available < item.amount) {
        return false;
      }
    }
    return true;
  }

  /// Calculate order completion percentage
  double getCompletionPercentage({
    required ActiveOrder order,
    required Map<String, int> inventory,
  }) {
    int totalRequired = 0;
    int totalHave = 0;

    for (final item in order.items) {
      totalRequired += item.amount;
      final available = inventory[item.recipeId] ?? 0;
      totalHave += min(available, item.amount);
    }

    if (totalRequired == 0) return 0.0;
    return totalHave / totalRequired;
  }
}
