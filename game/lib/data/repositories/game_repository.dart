import '../../core/models/material.dart';
import '../../core/models/recipe.dart';
import '../../core/models/cat.dart';
import '../../core/models/npc.dart';
import '../sources/game_data_source.dart';

/// Repository for game data access
class GameRepository {
  final GameDataSource _dataSource;

  GameRepository(this._dataSource);

  /// Initialize repository (load all data)
  Future<void> initialize() async {
    await _dataSource.loadAll();
  }

  // ========== Materials ==========

  /// Get all materials
  Future<List<Material>> getAllMaterials() async {
    return await _dataSource.loadMaterials();
  }

  /// Get material by ID
  Material? getMaterialById(String id) {
    return _dataSource.getMaterial(id);
  }

  /// Get materials by tier
  List<Material> getMaterialsByTier(int tier) {
    return _dataSource.getMaterialsByTier(tier);
  }

  /// Get unlocked materials based on workshop level
  Future<List<Material>> getUnlockedMaterials(int workshopLevel) async {
    final allMaterials = await getAllMaterials();
    return allMaterials.where((m) => m.isUnlocked(workshopLevel)).toList();
  }

  /// Get idle-produced materials
  Future<List<Material>> getIdleProducedMaterials() async {
    final allMaterials = await getAllMaterials();
    return allMaterials.where((m) => m.isIdleProduced).toList();
  }

  // ========== Recipes ==========

  /// Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    return await _dataSource.loadRecipes();
  }

  /// Get recipe by ID
  Recipe? getRecipeById(String id) {
    return _dataSource.getRecipe(id);
  }

  /// Get recipes by category
  List<Recipe> getRecipesByCategory(String category) {
    return _dataSource.getRecipesByCategory(category);
  }

  /// Get recipes by tier
  Future<List<Recipe>> getRecipesByTier(int tier) async {
    final allRecipes = await getAllRecipes();
    return allRecipes.where((r) => r.tier == tier).toList();
  }

  /// Find recipe by ingredient combination
  Future<Recipe?> findRecipeByIngredients(List<String> ingredientIds) async {
    final allRecipes = await getAllRecipes();

    for (final recipe in allRecipes) {
      // Check if ingredient sets match
      final recipeIngredientIds =
          recipe.ingredients.map((i) => i.id).toSet();
      final providedIds = ingredientIds.toSet();

      if (recipeIngredientIds.length == providedIds.length &&
          recipeIngredientIds.containsAll(providedIds)) {
        // Also check amounts match
        bool amountsMatch = true;
        for (final ingredient in recipe.ingredients) {
          final count = ingredientIds.where((id) => id == ingredient.id).length;
          if (count != ingredient.amount) {
            amountsMatch = false;
            break;
          }
        }

        if (amountsMatch) {
          return recipe;
        }
      }
    }

    return null;
  }

  // ========== Cat ==========

  /// Get cat data
  Future<Cat> getCatData() async {
    return await _dataSource.loadCatData();
  }

  // ========== NPCs ==========

  /// Get all NPCs
  Future<List<NPC>> getAllNPCs() async {
    return await _dataSource.loadNPCs();
  }

  /// Get NPC by ID
  NPC? getNPCById(String id) {
    return _dataSource.getNPC(id);
  }

  /// Get unlocked NPCs
  Future<List<NPC>> getUnlockedNPCs(int playerLevel) async {
    await _dataSource.loadNPCs();
    return _dataSource.getUnlockedNPCs(playerLevel);
  }

  /// Get order templates
  List<OrderTemplate> getOrderTemplates() {
    return _dataSource.getOrderTemplates();
  }

  /// Get order template by tier
  OrderTemplate? getOrderTemplateByTier(int tier) {
    final templates = getOrderTemplates();
    try {
      return templates.firstWhere((t) => t.tier == tier);
    } catch (_) {
      return null;
    }
  }
}
