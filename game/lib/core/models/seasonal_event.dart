/// Seasonal event model for Cat Alchemy Workshop
/// Represents limited-time events with special content
class SeasonalEvent {
  final String id;
  final String name;
  final String description;
  final String theme; // spring, summer, autumn, winter, special
  final DateTime startTime;
  final DateTime endTime;
  final List<String> specialMaterialIds;
  final List<String> specialRecipeIds;
  final List<String> limitedCatIds;
  final EventRewards rewards;
  final List<EventQuest> quests;
  final String? bannerAsset;
  final String? themeMusicAsset;

  const SeasonalEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    required this.startTime,
    required this.endTime,
    required this.specialMaterialIds,
    required this.specialRecipeIds,
    required this.limitedCatIds,
    required this.rewards,
    required this.quests,
    this.bannerAsset,
    this.themeMusicAsset,
  });

  factory SeasonalEvent.fromJson(Map<String, dynamic> json) {
    return SeasonalEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      theme: json['theme'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      specialMaterialIds: (json['specialMaterialIds'] as List).cast<String>(),
      specialRecipeIds: (json['specialRecipeIds'] as List).cast<String>(),
      limitedCatIds: (json['limitedCatIds'] as List).cast<String>(),
      rewards: EventRewards.fromJson(json['rewards'] as Map<String, dynamic>),
      quests: (json['quests'] as List)
          .map((q) => EventQuest.fromJson(q as Map<String, dynamic>))
          .toList(),
      bannerAsset: json['bannerAsset'] as String?,
      themeMusicAsset: json['themeMusicAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'theme': theme,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'specialMaterialIds': specialMaterialIds,
      'specialRecipeIds': specialRecipeIds,
      'limitedCatIds': limitedCatIds,
      'rewards': rewards.toJson(),
      'quests': quests.map((q) => q.toJson()).toList(),
      if (bannerAsset != null) 'bannerAsset': bannerAsset,
      if (themeMusicAsset != null) 'themeMusicAsset': themeMusicAsset,
    };
  }

  /// Check if event is currently active
  bool isActive(DateTime currentTime) {
    return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
  }

  /// Check if event is upcoming
  bool isUpcoming(DateTime currentTime) {
    return currentTime.isBefore(startTime);
  }

  /// Check if event has ended
  bool hasEnded(DateTime currentTime) {
    return currentTime.isAfter(endTime);
  }

  /// Get event duration in days
  int get durationInDays => endTime.difference(startTime).inDays;

  /// Get time until event starts
  Duration? timeUntilStart(DateTime currentTime) {
    if (!isUpcoming(currentTime)) return null;
    return startTime.difference(currentTime);
  }

  /// Get time until event ends
  Duration? timeUntilEnd(DateTime currentTime) {
    if (!isActive(currentTime)) return null;
    return endTime.difference(currentTime);
  }

  @override
  String toString() => 'Event($name: $theme)';
}

/// Event rewards structure
class EventRewards {
  final String currencyName; // e.g., "Blossom Petals", "Snowflakes"
  final Map<String, Map<String, Object>> milestoneRewards;
  final int maxEventPoints;

  const EventRewards({
    required this.currencyName,
    required this.milestoneRewards,
    required this.maxEventPoints,
  });

  factory EventRewards.fromJson(Map<String, dynamic> json) {
    return EventRewards(
      currencyName: json['currencyName'] as String,
      milestoneRewards: (json['milestoneRewards'] as Map<String, dynamic>).map(
        (k, v) =>
            MapEntry(k, Map<String, Object>.from(v as Map<String, dynamic>)),
      ),
      maxEventPoints: json['maxEventPoints'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyName': currencyName,
      'milestoneRewards': milestoneRewards,
      'maxEventPoints': maxEventPoints,
    };
  }

  /// Get reward for milestone
  Map<String, Object>? getMilestoneReward(int points) {
    return milestoneRewards[points.toString()];
  }

  /// Get all milestone thresholds
  List<int> get milestones {
    return milestoneRewards.keys
        .map((k) => int.tryParse(k) ?? 0)
        .where((v) => v > 0)
        .toList()
      ..sort();
  }
}

/// Event quest/task
class EventQuest {
  final String id;
  final String title;
  final String description;
  final String type; // craft, gather, sell, special
  final Map<String, int> targets; // target -> amount
  final int eventPoints;
  final Map<String, int> rewards;

  const EventQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targets,
    required this.eventPoints,
    required this.rewards,
  });

  factory EventQuest.fromJson(Map<String, dynamic> json) {
    return EventQuest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      targets: (json['targets'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as int),
      ),
      eventPoints: json['eventPoints'] as int,
      rewards: (json['rewards'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as int),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'targets': targets,
      'eventPoints': eventPoints,
      'rewards': rewards,
    };
  }

  /// Calculate progress percentage
  double calculateProgress(Map<String, int> currentProgress) {
    int totalRequired = 0;
    int totalCompleted = 0;

    targets.forEach((key, required) {
      totalRequired += required;
      totalCompleted += currentProgress[key] ?? 0;
    });

    if (totalRequired == 0) return 0.0;
    return (totalCompleted / totalRequired).clamp(0.0, 1.0);
  }

  /// Check if quest is complete
  bool isComplete(Map<String, int> currentProgress) {
    return calculateProgress(currentProgress) >= 1.0;
  }

  @override
  String toString() => 'Quest($title: $eventPoints pts)';
}
