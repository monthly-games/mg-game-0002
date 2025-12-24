/// Ingredient required for crafting
class Ingredient {
  final String id;
  final int amount;

  const Ingredient({required this.id, required this.amount});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(id: json['id'] as String, amount: json['amount'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount};
  }

  @override
  String toString() => '$id×$amount';
}

/// Crafting result
class CraftResult {
  final String id;
  final int amount;

  const CraftResult({required this.id, required this.amount});

  factory CraftResult.fromJson(Map<String, dynamic> json) {
    return CraftResult(id: json['id'] as String, amount: json['amount'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount};
  }
}

/// Discovery bonus rewards
class DiscoveryBonus {
  final int gold;
  final int exp;
  final int? gems;

  const DiscoveryBonus({required this.gold, required this.exp, this.gems});

  factory DiscoveryBonus.fromJson(Map<String, dynamic> json) {
    return DiscoveryBonus(
      gold: json['gold'] as int,
      exp: json['exp'] as int,
      gems: json['gems'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'gold': gold, 'exp': exp, if (gems != null) 'gems': gems};
  }
}

/// Recipe model for crafting items
class Recipe {
  final String id;
  final String name;
  final int tier;
  final String category; // potion, bomb, special
  final String icon;
  final String description;
  final List<Ingredient> ingredients;
  final int craftTime; // seconds
  final CraftResult result;
  final int sellPrice;
  final DiscoveryBonus discoveryBonus;
  final bool isLegendary;
  final List<String>? pattern; // Grid pattern for crafting puzzle

  const Recipe({
    required this.id,
    required this.name,
    required this.tier,
    required this.category,
    required this.icon,
    required this.description,
    required this.ingredients,
    required this.craftTime,
    required this.result,
    required this.sellPrice,
    required this.discoveryBonus,
    this.isLegendary = false,
    this.pattern,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: json['tier'] as int,
      category: json['category'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
          .toList(),
      craftTime: json['craftTime'] as int,
      result: CraftResult.fromJson(json['result'] as Map<String, dynamic>),
      sellPrice: json['sellPrice'] as int,
      discoveryBonus: DiscoveryBonus.fromJson(
        json['discoveryBonus'] as Map<String, dynamic>,
      ),
      isLegendary: json['isLegendary'] as bool? ?? false,
      pattern: (json['pattern'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier,
      'category': category,
      'icon': icon,
      'description': description,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'craftTime': craftTime,
      'result': result.toJson(),
      'sellPrice': sellPrice,
      'discoveryBonus': discoveryBonus.toJson(),
      'isLegendary': isLegendary,
      'pattern': pattern,
    };
  }

  /// Get total craft duration
  Duration get craftDuration => Duration(seconds: craftTime);

  /// Check if player has all required ingredients
  bool canCraft(Map<String, int> inventory) {
    for (final ingredient in ingredients) {
      final available = inventory[ingredient.id] ?? 0;
      if (available < ingredient.amount) {
        return false;
      }
    }
    return true;
  }

  /// Get missing ingredients
  Map<String, int> getMissingIngredients(Map<String, int> inventory) {
    final missing = <String, int>{};
    for (final ingredient in ingredients) {
      final available = inventory[ingredient.id] ?? 0;
      final needed = ingredient.amount - available;
      if (needed > 0) {
        missing[ingredient.id] = needed;
      }
    }
    return missing;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Recipe($id: $name)';
}
