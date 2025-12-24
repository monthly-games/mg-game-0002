import 'dart:math';
import '../models/recipe.dart';
import '../models/game_state.dart';

/// Result quality from crafting
enum CraftQuality {
  failure,    // 50% output
  normal,     // 100% output
  critical,   // 150% output
}

/// Crafting result with quality information
class AlchemyCraftResult {
  final bool success;
  final String? message;
  final String? jobId;
  final CraftQuality? quality;
  final int? outputAmount;

  const AlchemyCraftResult({
    required this.success,
    this.message,
    this.jobId,
    this.quality,
    this.outputAmount,
  });

  factory AlchemyCraftResult.failure(String message) {
    return AlchemyCraftResult(success: false, message: message);
  }

  factory AlchemyCraftResult.queued(String jobId) {
    return AlchemyCraftResult(success: true, jobId: jobId);
  }

  factory AlchemyCraftResult.completed(CraftQuality quality, int outputAmount) {
    return AlchemyCraftResult(
      success: true,
      quality: quality,
      outputAmount: outputAmount,
    );
  }
}

/// Alchemy-specific crafting job with quality result
class AlchemyCraftingJob {
  final String id;
  final String recipeId;
  final DateTime startTime;
  final Duration craftDuration;
  final Map<String, int> baseResult;
  CraftQuality? quality;
  int? finalOutputAmount;

  AlchemyCraftingJob({
    required this.id,
    required this.recipeId,
    required this.startTime,
    required this.craftDuration,
    required this.baseResult,
    this.quality,
    this.finalOutputAmount,
  });

  /// Check if crafting is completed
  bool get isCompleted {
    final now = DateTime.now();
    final completionTime = startTime.add(craftDuration);
    return now.isAfter(completionTime) || now.isAtSameMomentAs(completionTime);
  }

  /// Calculate quality when crafting completes
  void calculateQuality(double luckModifier) {
    final random = Random();
    final roll = random.nextDouble(); // 0.0 to 1.0

    // Base probabilities:
    // Critical: 10%
    // Normal: 75%
    // Failure: 15%

    // Luck modifier increases critical chance and reduces failure
    final criticalChance = 0.10 + (luckModifier * 0.05); // +5% per luck point
    final failureChance = max(0.15 - (luckModifier * 0.05), 0.05); // Min 5% failure

    if (roll < criticalChance) {
      quality = CraftQuality.critical;
      finalOutputAmount = (baseResult.values.first * 1.5).ceil();
    } else if (roll < 1.0 - failureChance) {
      quality = CraftQuality.normal;
      finalOutputAmount = baseResult.values.first;
    } else {
      quality = CraftQuality.failure;
      finalOutputAmount = max((baseResult.values.first * 0.5).floor(), 1);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeId': recipeId,
      'startTime': startTime.toIso8601String(),
      'craftDuration': craftDuration.inSeconds,
      'baseResult': baseResult,
      'quality': quality?.name,
      'finalOutputAmount': finalOutputAmount,
    };
  }

  factory AlchemyCraftingJob.fromJson(Map<String, dynamic> json) {
    return AlchemyCraftingJob(
      id: json['id'],
      recipeId: json['recipeId'],
      startTime: DateTime.parse(json['startTime']),
      craftDuration: Duration(seconds: json['craftDuration']),
      baseResult: Map<String, int>.from(json['baseResult']),
      quality: json['quality'] != null
          ? CraftQuality.values.firstWhere((e) => e.name == json['quality'])
          : null,
      finalOutputAmount: json['finalOutputAmount'],
    );
  }
}

/// Alchemy-specific crafting manager with success/failure mechanics
class AlchemyCraftingManager {
  final GameState _gameState;
  final List<AlchemyCraftingJob> _queue = [];
  int _maxQueueSize = 3;
  double _luckModifier = 0.0; // From cat skills, decorations
  double _craftTimeModifier = 1.0; // Affects craft speed

  AlchemyCraftingManager(this._gameState) {
    _maxQueueSize = _gameState.getMaxCraftingQueueSize();
  }

  /// Start crafting a recipe with quality calculation
  AlchemyCraftResult startCrafting(Recipe recipe) {
    // Check if player has discovered this recipe
    if (!_gameState.isRecipeDiscovered(recipe.id)) {
      return AlchemyCraftResult.failure('Recipe not discovered');
    }

    // Check if queue is full
    if (_queue.length >= _maxQueueSize) {
      return AlchemyCraftResult.failure('Crafting queue is full');
    }

    // Check if player has ingredients
    if (!recipe.canCraft(_gameState.inventory)) {
      return AlchemyCraftResult.failure('Not enough ingredients');
    }

    // Consume ingredients
    for (final ingredient in recipe.ingredients) {
      final success = _gameState.removeFromInventory(
        ingredient.id,
        ingredient.amount,
      );
      if (!success) {
        return AlchemyCraftResult.failure('Failed to consume ingredients');
      }
    }

    // Create crafting job
    final jobId = DateTime.now().millisecondsSinceEpoch.toString();
    final adjustedDuration = Duration(
      milliseconds: (recipe.craftDuration.inMilliseconds * _craftTimeModifier).round(),
    );

    final job = AlchemyCraftingJob(
      id: jobId,
      recipeId: recipe.id,
      startTime: DateTime.now(),
      craftDuration: adjustedDuration,
      baseResult: {recipe.result.id: recipe.result.amount},
    );

    _queue.add(job);
    return AlchemyCraftResult.queued(jobId);
  }

  /// Collect completed crafting job with quality result
  AlchemyCraftResult? collectCompleted(String jobId) {
    final job = _queue.firstWhere(
      (j) => j.id == jobId,
      orElse: () => throw Exception('Job not found'),
    );

    if (!job.isCompleted) {
      return null;
    }

    // Calculate quality if not already calculated
    if (job.quality == null) {
      job.calculateQuality(_luckModifier);
    }

    // Add crafted items to inventory
    if (job.finalOutputAmount != null) {
      final itemId = job.baseResult.keys.first;
      _gameState.addToInventory(itemId, job.finalOutputAmount!);
    }

    // Remove from queue
    _queue.remove(job);

    return AlchemyCraftResult.completed(
      job.quality!,
      job.finalOutputAmount!,
    );
  }

  /// Collect all completed jobs
  List<AlchemyCraftResult> collectAllCompleted() {
    final results = <AlchemyCraftResult>[];
    final completedJobs = _queue.where((j) => j.isCompleted).toList();

    for (final job in completedJobs) {
      final result = collectCompleted(job.id);
      if (result != null) {
        results.add(result);
      }
    }

    return results;
  }

  /// Process offline crafting with quality calculation
  List<AlchemyCraftResult> processOfflineCrafting(DateTime lastLoginTime) {
    final results = <AlchemyCraftResult>[];
    final now = DateTime.now();

    for (final job in _queue.toList()) {
      final completionTime = job.startTime.add(job.craftDuration);

      if (completionTime.isBefore(now) || completionTime.isAtSameMomentAs(now)) {
        // Job completed offline
        job.calculateQuality(_luckModifier);

        if (job.finalOutputAmount != null) {
          final itemId = job.baseResult.keys.first;
          _gameState.addToInventory(itemId, job.finalOutputAmount!);
        }

        results.add(AlchemyCraftResult.completed(
          job.quality!,
          job.finalOutputAmount!,
        ));

        _queue.remove(job);
      }
    }

    return results;
  }

  /// Cancel crafting job (refund ingredients)
  bool cancelJob(String jobId, Recipe recipe) {
    final jobIndex = _queue.indexWhere((j) => j.id == jobId);
    if (jobIndex == -1) return false;

    // Refund ingredients
    for (final ingredient in recipe.ingredients) {
      _gameState.addToInventory(ingredient.id, ingredient.amount);
    }

    _queue.removeAt(jobIndex);
    return true;
  }

  /// Instant complete a job (premium feature)
  AlchemyCraftResult? instantComplete(String jobId) {
    final job = _queue.firstWhere(
      (j) => j.id == jobId,
      orElse: () => throw Exception('Job not found'),
    );

    // Calculate quality
    job.calculateQuality(_luckModifier);

    // Add crafted items to inventory
    if (job.finalOutputAmount != null) {
      final itemId = job.baseResult.keys.first;
      _gameState.addToInventory(itemId, job.finalOutputAmount!);
    }

    // Remove from queue
    _queue.remove(job);

    return AlchemyCraftResult.completed(
      job.quality!,
      job.finalOutputAmount!,
    );
  }

  /// Set luck modifier (from cat skills, decorations)
  void setLuckModifier(double modifier) {
    _luckModifier = modifier;
  }

  /// Set craft time modifier (from cat skills, upgrades)
  void setCraftTimeModifier(double modifier) {
    _craftTimeModifier = modifier;
  }

  /// Update max queue size
  void updateMaxQueueSize() {
    _maxQueueSize = _gameState.getMaxCraftingQueueSize();
  }

  /// Get current queue
  List<AlchemyCraftingJob> get queue => List.unmodifiable(_queue);

  /// Get queue size
  int get queueSize => _queue.length;

  /// Get max queue size
  int get maxQueueSize => _maxQueueSize;

  /// Check if queue is full
  bool get isQueueFull => _queue.length >= _maxQueueSize;

  /// Get completed jobs
  List<AlchemyCraftingJob> getCompletedJobs() {
    return _queue.where((j) => j.isCompleted).toList();
  }

  /// Get time until next completion
  Duration? getTimeUntilNextCompletion() {
    if (_queue.isEmpty) return null;

    final now = DateTime.now();
    final nextCompletion = _queue
        .map((j) => j.startTime.add(j.craftDuration))
        .where((t) => t.isAfter(now))
        .reduce((a, b) => a.isBefore(b) ? a : b);

    return nextCompletion.difference(now);
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'queue': _queue.map((j) => j.toJson()).toList(),
      'maxQueueSize': _maxQueueSize,
      'luckModifier': _luckModifier,
      'craftTimeModifier': _craftTimeModifier,
    };
  }

  /// Deserialize from JSON
  void fromJson(Map<String, dynamic> json) {
    _queue.clear();
    _queue.addAll(
      (json['queue'] as List)
          .map((j) => AlchemyCraftingJob.fromJson(j))
          .toList(),
    );
    _maxQueueSize = json['maxQueueSize'] ?? 3;
    _luckModifier = json['luckModifier'] ?? 0.0;
    _craftTimeModifier = json['craftTimeModifier'] ?? 1.0;
  }
}
