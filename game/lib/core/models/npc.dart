/// NPC order patterns configuration
class OrderPatterns {
  final List<int> tier;
  final List<String> preferredCategories;
  final String frequency; // high, medium, low, rare
  final double rewardMultiplier;
  final String? bonusReward;

  const OrderPatterns({
    required this.tier,
    required this.preferredCategories,
    required this.frequency,
    required this.rewardMultiplier,
    this.bonusReward,
  });

  factory OrderPatterns.fromJson(Map<String, dynamic> json) {
    return OrderPatterns(
      tier: (json['tier'] as List).cast<int>(),
      preferredCategories: (json['preferredCategories'] as List).cast<String>(),
      frequency: json['frequency'] as String,
      rewardMultiplier: (json['rewardMultiplier'] as num).toDouble(),
      bonusReward: json['bonusReward'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier,
      'preferredCategories': preferredCategories,
      'frequency': frequency,
      'rewardMultiplier': rewardMultiplier,
      if (bonusReward != null) 'bonusReward': bonusReward,
    };
  }
}

/// NPC (Non-Player Character) model
class NPC {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int unlockLevel;
  final OrderPatterns orderPatterns;
  final List<String> dialogue;
  final bool isSpecial;
  final List<String> personality;

  const NPC({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.unlockLevel,
    required this.orderPatterns,
    required this.dialogue,
    this.isSpecial = false,
    this.personality = const [],
  });

  factory NPC.fromJson(Map<String, dynamic> json) {
    return NPC(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      unlockLevel: json['unlockLevel'] as int,
      orderPatterns: OrderPatterns.fromJson(
        json['orderPatterns'] as Map<String, dynamic>,
      ),
      dialogue: (json['dialogue'] as List).cast<String>(),
      isSpecial: json['special'] as bool? ?? false,
      personality: (json['personality'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'unlockLevel': unlockLevel,
      'orderPatterns': orderPatterns.toJson(),
      'dialogue': dialogue,
      if (isSpecial) 'special': isSpecial,
      'personality': personality,
    };
  }

  /// Check if NPC is unlocked
  bool isUnlocked(int playerLevel) => playerLevel >= unlockLevel;

  /// Get random dialogue
  String getRandomDialogue() {
    if (dialogue.isEmpty) return '';
    return dialogue[(DateTime.now().millisecondsSinceEpoch) % dialogue.length];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NPC && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NPC($id: $name)';
}

/// Order template configuration
class OrderTemplate {
  final int tier;
  final int timeLimit; // seconds
  final Map<String, int> itemCount; // min, max
  final Map<String, int> goldReward; // min, max
  final Map<String, int> reputationReward; // min, max
  final Map<String, int>? gemsReward; // min, max (optional)

  const OrderTemplate({
    required this.tier,
    required this.timeLimit,
    required this.itemCount,
    required this.goldReward,
    required this.reputationReward,
    this.gemsReward,
  });

  factory OrderTemplate.fromJson(Map<String, dynamic> json) {
    return OrderTemplate(
      tier: json['tier'] as int,
      timeLimit: json['timeLimit'] as int,
      itemCount: (json['itemCount'] as Map<String, dynamic>)
          .cast<String, int>(),
      goldReward: (json['goldReward'] as Map<String, dynamic>)
          .cast<String, int>(),
      reputationReward: (json['reputationReward'] as Map<String, dynamic>)
          .cast<String, int>(),
      gemsReward: json['gemsReward'] != null
          ? (json['gemsReward'] as Map<String, dynamic>).cast<String, int>()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier,
      'timeLimit': timeLimit,
      'itemCount': itemCount,
      'goldReward': goldReward,
      'reputationReward': reputationReward,
      if (gemsReward != null) 'gemsReward': gemsReward,
    };
  }
}
