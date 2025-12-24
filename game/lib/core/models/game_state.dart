import 'package:hive/hive.dart';

part 'game_state.g.dart';

/// Player progress and game state
@HiveType(typeId: 0)
class GameState extends HiveObject {
  @HiveField(0)
  int gold;

  @HiveField(1)
  int gems;

  @HiveField(2)
  int workshopLevel;

  @HiveField(3)
  int reputation;

  @HiveField(4)
  int playerExp;

  @HiveField(5)
  Map<String, int> inventory; // materialId/recipeId -> amount

  @HiveField(6)
  List<String> discoveredRecipes;

  @HiveField(7)
  DateTime lastLoginTime;

  @HiveField(8)
  Map<String, dynamic> catState; // trust, level, interactions

  @HiveField(9)
  List<Map<String, dynamic>> craftingQueue;

  @HiveField(10)
  List<Map<String, dynamic>> activeOrders;

  @HiveField(11)
  Map<String, int> dailyInteractions; // action -> count

  @HiveField(12)
  bool tutorialCompleted;

  GameState({
    this.gold = 0,
    this.gems = 0,
    this.workshopLevel = 1,
    this.reputation = 0,
    this.playerExp = 0,
    Map<String, int>? inventory,
    List<String>? discoveredRecipes,
    DateTime? lastLoginTime,
    Map<String, dynamic>? catState,
    List<Map<String, dynamic>>? craftingQueue,
    List<Map<String, dynamic>>? activeOrders,
    Map<String, int>? dailyInteractions,
    this.tutorialCompleted = false,
  })  : inventory = inventory ?? {},
        discoveredRecipes = discoveredRecipes ?? [],
        lastLoginTime = lastLoginTime ?? DateTime.now(),
        catState = catState ??
            {
              'trust': 0,
              'level': 1,
              'petToday': 0,
              'playToday': 0,
            },
        craftingQueue = craftingQueue ?? [],
        activeOrders = activeOrders ?? [],
        dailyInteractions = dailyInteractions ?? {};

  /// Create initial state for new player
  factory GameState.initial() {
    return GameState(
      gold: 500, // Starting gold
      gems: 50, // Starting gems
      workshopLevel: 1,
      reputation: 0,
      playerExp: 0,
      inventory: {
        // Starting materials
        'grass': 10,
        'water_clear': 10,
        'stone': 5,
        'branch': 5,
      },
      discoveredRecipes: [],
      lastLoginTime: DateTime.now(),
      catState: {
        'trust': 0,
        'level': 1,
        'petToday': 0,
        'playToday': 0,
        'lastPetTime': DateTime.now().millisecondsSinceEpoch,
      },
      craftingQueue: [],
      activeOrders: [],
      dailyInteractions: {},
      tutorialCompleted: false,
    );
  }

  /// Get inventory amount for an item
  int getInventoryAmount(String itemId) {
    return inventory[itemId] ?? 0;
  }

  /// Add item to inventory
  void addToInventory(String itemId, int amount) {
    inventory[itemId] = getInventoryAmount(itemId) + amount;
  }

  /// Remove item from inventory
  bool removeFromInventory(String itemId, int amount) {
    final current = getInventoryAmount(itemId);
    if (current < amount) return false;

    inventory[itemId] = current - amount;
    if (inventory[itemId]! <= 0) {
      inventory.remove(itemId);
    }
    return true;
  }

  /// Check if recipe is discovered
  bool isRecipeDiscovered(String recipeId) {
    return discoveredRecipes.contains(recipeId);
  }

  /// Discover a new recipe
  void discoverRecipe(String recipeId) {
    if (!discoveredRecipes.contains(recipeId)) {
      discoveredRecipes.add(recipeId);
    }
  }

  /// Get cat trust points
  int get catTrust => catState['trust'] as int? ?? 0;

  /// Get cat level
  int get catLevel => catState['level'] as int? ?? 1;

  /// Add cat trust
  void addCatTrust(int amount) {
    catState['trust'] = catTrust + amount;
  }

  /// Update cat level
  void updateCatLevel(int level) {
    catState['level'] = level;
  }

  /// Get today's pet count
  int get petToday => catState['petToday'] as int? ?? 0;

  /// Get today's play count
  int get playToday => catState['playToday'] as int? ?? 0;

  /// Increment pet count
  void incrementPetCount() {
    catState['petToday'] = petToday + 1;
    catState['lastPetTime'] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Increment play count
  void incrementPlayCount() {
    catState['playToday'] = playToday + 1;
  }

  /// Reset daily counters (called on new day)
  void resetDailyCounters() {
    catState['petToday'] = 0;
    catState['playToday'] = 0;
    dailyInteractions.clear();
  }

  /// Check if new day (for daily reset)
  bool isNewDay() {
    final now = DateTime.now();
    final lastLogin = lastLoginTime;

    return now.year != lastLogin.year ||
        now.month != lastLogin.month ||
        now.day != lastLogin.day;
  }

  /// Update last login time
  void updateLastLoginTime() {
    lastLoginTime = DateTime.now();
  }

  /// Get crafting queue size
  int get craftingQueueSize => craftingQueue.length;

  /// Get max crafting queue size (based on cat level and upgrades)
  int getMaxCraftingQueueSize() {
    int base = 3;

    // Cat skill at level 5 adds +1
    if (catLevel >= 5) {
      base += 1;
    }

    // Workshop level 6 adds +1
    if (workshopLevel >= 6) {
      base += 1;
    }

    return base;
  }

  /// Check if can add to crafting queue
  bool canAddToCraftingQueue() {
    return craftingQueueSize < getMaxCraftingQueueSize();
  }

  /// Calculate offline time in hours
  double getOfflineHours() {
    final now = DateTime.now();
    final diff = now.difference(lastLoginTime);
    return diff.inSeconds / 3600.0;
  }

  @override
  String toString() {
    return 'GameState(Level: $workshopLevel, Gold: $gold, Gems: $gems)';
  }
}
