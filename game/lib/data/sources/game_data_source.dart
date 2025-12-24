import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/models/material.dart';
import '../../core/models/recipe.dart';
import '../../core/models/cat.dart';
import '../../core/models/npc.dart';

/// Data source for loading game data from JSON assets
class GameDataSource {
  static const _materialsPath = 'assets/data/materials.json';
  static const _recipesPath = 'assets/data/recipes.json';
  static const _catDataPath = 'assets/data/cat_data.json';
  static const _npcsPath = 'assets/data/npcs.json';

  // Cached data
  List<Material>? _materials;
  List<Recipe>? _recipes;
  Cat? _cat;
  List<NPC>? _npcs;
  List<OrderTemplate>? _orderTemplates;

  /// Load all game data
  Future<void> loadAll() async {
    await Future.wait([
      loadMaterials(),
      loadRecipes(),
      loadCatData(),
      loadNPCs(),
    ]);
  }

  /// Load materials from JSON
  Future<List<Material>> loadMaterials() async {
    if (_materials != null) return _materials!;

    final jsonString = await rootBundle.loadString(_materialsPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final materialsJson = json['materials'] as List;

    _materials = materialsJson
        .map((m) => Material.fromJson(m as Map<String, dynamic>))
        .toList();

    return _materials!;
  }

  /// Load recipes from JSON
  Future<List<Recipe>> loadRecipes() async {
    if (_recipes != null) return _recipes!;

    final jsonString = await rootBundle.loadString(_recipesPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final recipesJson = json['recipes'] as List;

    _recipes = recipesJson
        .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
        .toList();

    return _recipes!;
  }

  /// Load cat data from JSON
  Future<Cat> loadCatData() async {
    if (_cat != null) return _cat!;

    final jsonString = await rootBundle.loadString(_catDataPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final catJson = json['cat'] as Map<String, dynamic>;

    _cat = Cat.fromJson(catJson);

    return _cat!;
  }

  /// Load NPCs from JSON
  Future<List<NPC>> loadNPCs() async {
    if (_npcs != null) return _npcs!;

    final jsonString = await rootBundle.loadString(_npcsPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final npcsJson = json['npcs'] as List;
    final templatesJson = json['orderTemplates'] as List;

    _npcs = npcsJson
        .map((n) => NPC.fromJson(n as Map<String, dynamic>))
        .toList();

    _orderTemplates = templatesJson
        .map((t) => OrderTemplate.fromJson(t as Map<String, dynamic>))
        .toList();

    return _npcs!;
  }

  /// Get order templates
  List<OrderTemplate> getOrderTemplates() {
    return _orderTemplates ?? [];
  }

  /// Get material by ID
  Material? getMaterial(String id) {
    return _materials?.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception('Material not found: $id'),
    );
  }

  /// Get recipe by ID
  Recipe? getRecipe(String id) {
    return _recipes?.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Recipe not found: $id'),
    );
  }

  /// Get NPC by ID
  NPC? getNPC(String id) {
    return _npcs?.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('NPC not found: $id'),
    );
  }

  /// Get materials by tier
  List<Material> getMaterialsByTier(int tier) {
    return _materials?.where((m) => m.tier == tier).toList() ?? [];
  }

  /// Get recipes by category
  List<Recipe> getRecipesByCategory(String category) {
    return _recipes?.where((r) => r.category == category).toList() ?? [];
  }

  /// Get unlocked NPCs by level
  List<NPC> getUnlockedNPCs(int playerLevel) {
    return _npcs?.where((n) => n.isUnlocked(playerLevel)).toList() ?? [];
  }

  /// Clear cache (for testing)
  void clearCache() {
    _materials = null;
    _recipes = null;
    _cat = null;
    _npcs = null;
    _orderTemplates = null;
  }
}
