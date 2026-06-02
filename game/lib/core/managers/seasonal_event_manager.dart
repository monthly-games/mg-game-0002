import 'package:flutter/foundation.dart';
import '../models/seasonal_event.dart';
import '../models/game_state.dart';

/// Manager for seasonal events
class SeasonalEventManager {
  final List<SeasonalEvent> events;
  final GameState gameState;

  // Player event progress
  final Map<String, int> _eventPoints = {};
  final Map<String, Map<String, int>> _questProgress = {};
  final Set<String> _claimedMilestones = {};
  final Set<String> _completedQuests = {};

  SeasonalEventManager({required this.events, required this.gameState});

  /// Get current active events
  List<SeasonalEvent> getActiveEvents() {
    final now = DateTime.now();
    return events.where((event) => event.isActive(now)).toList();
  }

  /// Get upcoming events
  List<SeasonalEvent> getUpcomingEvents() {
    final now = DateTime.now();
    return events.where((event) => event.isUpcoming(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get event by ID
  SeasonalEvent? getEvent(String eventId) {
    try {
      return events.firstWhere((e) => e.id == eventId);
    } catch (_) {
      return null;
    }
  }

  /// Get player's event points for an event
  int getEventPoints(String eventId) {
    return _eventPoints[eventId] ?? 0;
  }

  /// Add event points
  void addEventPoints(String eventId, int points) {
    final current = getEventPoints(eventId);
    final event = getEvent(eventId);

    if (event != null) {
      final newPoints = (current + points).clamp(
        0,
        event.rewards.maxEventPoints,
      );
      _eventPoints[eventId] = newPoints;
      debugPrint('Event $eventId: $points pts added (total: $newPoints)');
    }
  }

  /// Get quest progress
  Map<String, int> getQuestProgress(String eventId, String questId) {
    final eventProgress = _questProgress[eventId];
    if (eventProgress == null) return {};

    return Map.from(eventProgress)
      ..removeWhere((key, value) => !key.startsWith(questId));
  }

  /// Update quest progress
  void updateQuestProgress(
    String eventId,
    String questId,
    String target,
    int progress,
  ) {
    final eventProgress = _questProgress[eventId] ?? {};
    final key = '$questId:$target';
    eventProgress[key] = progress;
    _questProgress[eventId] = eventProgress;

    // Check if quest is complete
    final event = getEvent(eventId);
    if (event != null) {
      final quest = event.quests.firstWhere((q) => q.id == questId);
      if (quest.isComplete(eventProgress) &&
          !_completedQuests.contains(questId)) {
        _completedQuests.add(questId);
        addEventPoints(eventId, quest.eventPoints);
        debugPrint('Quest completed: $questId (+${quest.eventPoints} pts)');
      }
    }
  }

  /// Check if quest is completed
  bool isQuestCompleted(String questId) {
    return _completedQuests.contains(questId);
  }

  /// Get all completed quests for an event
  List<String> getCompletedQuests(String eventId) {
    final event = getEvent(eventId);
    if (event == null) return [];

    return event.quests
        .where((quest) => _completedQuests.contains(quest.id))
        .map((q) => q.id)
        .toList();
  }

  /// Get available quests for an event
  List<EventQuest> getAvailableQuests(String eventId) {
    final event = getEvent(eventId);
    if (event == null) return [];

    return event.quests
        .where((quest) => !_completedQuests.contains(quest.id))
        .toList();
  }

  /// Claim milestone reward
  Map<String, Object>? claimMilestone(String eventId, int milestonePoints) {
    final event = getEvent(eventId);
    if (event == null) return null;

    final key = '$eventId:$milestonePoints';
    if (_claimedMilestones.contains(key)) {
      debugPrint('Milestone already claimed: $key');
      return null;
    }

    final currentPoints = getEventPoints(eventId);
    if (currentPoints < milestonePoints) {
      debugPrint('Not enough points for milestone: $key');
      return null;
    }

    final reward = event.rewards.getMilestoneReward(milestonePoints);
    if (reward == null) {
      debugPrint('No reward found for milestone: $key');
      return null;
    }

    _claimedMilestones.add(key);

    // Grant rewards
    final itemAmount = reward['amount'] is int ? reward['amount'] as int : 1;
    for (final entry in reward.entries) {
      final itemId = entry.key;
      final value = entry.value;

      if (itemId == 'amount') continue;

      if (itemId == 'gold' && value is int) {
        gameState.gold += value;
      } else if (itemId == 'gems' && value is int) {
        gameState.gems += value;
      } else if (itemId == 'exp' && value is int) {
        gameState.playerExp += value;
      } else if (value is int) {
        gameState.addToInventory(itemId, value);
      } else if (itemId == 'special_recipe' && value is String) {
        gameState.discoverRecipe(value);
      } else if (value is String) {
        gameState.addToInventory(value, itemAmount);
      }
    }

    debugPrint('Milestone claimed: $key');
    return reward;
  }

  /// Get claimable milestones
  List<int> getClaimableMilestones(String eventId) {
    final event = getEvent(eventId);
    if (event == null) return [];

    final currentPoints = getEventPoints(eventId);
    final claimable = <int>[];

    for (final milestone in event.rewards.milestones) {
      if (currentPoints >= milestone) {
        final key = '$eventId:$milestone';
        if (!_claimedMilestones.contains(key)) {
          claimable.add(milestone);
        }
      }
    }

    return claimable;
  }

  /// Get claimed milestones
  List<int> getClaimedMilestones(String eventId) {
    final claimed = <int>[];
    for (final key in _claimedMilestones) {
      if (key.startsWith('$eventId:')) {
        final parts = key.split(':');
        if (parts.length == 2) {
          final milestone = int.tryParse(parts[1]);
          if (milestone != null) {
            claimed.add(milestone);
          }
        }
      }
    }
    return claimed;
  }

  /// Check if special recipe is unlocked from event
  bool isRecipeUnlocked(String recipeId) {
    final activeEvents = getActiveEvents();
    for (final event in activeEvents) {
      if (event.specialRecipeIds.contains(recipeId)) {
        return true;
      }
    }
    return false;
  }

  /// Check if special material is available from event
  bool isMaterialAvailable(String materialId) {
    final activeEvents = getActiveEvents();
    for (final event in activeEvents) {
      if (event.specialMaterialIds.contains(materialId)) {
        return true;
      }
    }
    return false;
  }

  /// Check if limited cat is available
  bool isCatAvailable(String catId) {
    final activeEvents = getActiveEvents();
    for (final event in activeEvents) {
      if (event.limitedCatIds.contains(catId)) {
        return true;
      }
    }
    return false;
  }

  /// Get event progress percentage
  double getEventProgress(String eventId) {
    final event = getEvent(eventId);
    if (event == null) return 0.0;

    final currentPoints = getEventPoints(eventId);
    return currentPoints / event.rewards.maxEventPoints;
  }

  /// Calculate event end time warning
  bool shouldShowEndWarning(String eventId) {
    final event = getEvent(eventId);
    if (event == null) return false;

    final now = DateTime.now();
    final timeUntilEnd = event.timeUntilEnd(now);

    // Show warning if less than 24 hours remaining
    return timeUntilEnd != null && timeUntilEnd.inHours < 24;
  }

  /// Reset event progress (called when event ends)
  void resetEventProgress(String eventId) {
    _eventPoints.remove(eventId);
    _questProgress.remove(eventId);
    // Keep claimed milestones for history
  }

  /// Get player event statistics
  Map<String, dynamic> getEventStats(String eventId) {
    return {
      'points': getEventPoints(eventId),
      'progress': getEventProgress(eventId),
      'completedQuests': getCompletedQuests(eventId).length,
      'claimedMilestones': getClaimedMilestones(eventId).length,
    };
  }
}
