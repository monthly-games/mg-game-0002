/// Cat skill effect type
enum CatSkillType {
  productionRate,
  craftTime,
  sellPrice,
  queueSize,
  reputation,
  luckyCraft,
}

/// Cat skill effect
class CatSkillEffect {
  final CatSkillType type;
  final double value;

  const CatSkillEffect({
    required this.type,
    required this.value,
  });

  factory CatSkillEffect.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = CatSkillType.values.firstWhere(
      (e) => e.name == typeStr.replaceAll('_', ''),
      orElse: () => CatSkillType.productionRate,
    );

    return CatSkillEffect(
      type: type,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'value': value,
    };
  }
}

/// Cat skill definition
class CatSkill {
  final int level;
  final String type; // passive or active
  final String name;
  final String description;
  final CatSkillEffect effect;

  const CatSkill({
    required this.level,
    required this.type,
    required this.name,
    required this.description,
    required this.effect,
  });

  factory CatSkill.fromJson(Map<String, dynamic> json) {
    return CatSkill(
      level: json['level'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      effect: CatSkillEffect.fromJson(json['effect'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'type': type,
      'name': name,
      'description': description,
      'effect': effect.toJson(),
    };
  }

  bool get isPassive => type == 'passive';
  bool get isActive => type == 'active';
}

/// Cat trust level requirement
class TrustLevel {
  final int level;
  final int requiredTrust;

  const TrustLevel({
    required this.level,
    required this.requiredTrust,
  });

  factory TrustLevel.fromJson(Map<String, dynamic> json) {
    return TrustLevel(
      level: json['level'] as int,
      requiredTrust: json['requiredTrust'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'requiredTrust': requiredTrust,
    };
  }
}

/// Cat interaction configuration
class CatInteraction {
  final int trustGain;
  final int? dailyLimit;
  final int? cooldown;
  final String? cost;
  final List<String> messages;

  const CatInteraction({
    required this.trustGain,
    this.dailyLimit,
    this.cooldown,
    this.cost,
    required this.messages,
  });

  factory CatInteraction.fromJson(Map<String, dynamic> json) {
    return CatInteraction(
      trustGain: json['trustGain'] as int,
      dailyLimit: json['dailyLimit'] as int?,
      cooldown: json['cooldown'] as int?,
      cost: json['cost'] as String?,
      messages: (json['messages'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trustGain': trustGain,
      if (dailyLimit != null) 'dailyLimit': dailyLimit,
      if (cooldown != null) 'cooldown': cooldown,
      if (cost != null) 'cost': cost,
      'messages': messages,
    };
  }
}

/// Cat companion model
class Cat {
  final String id;
  final String name;
  final String description;
  final String appearance;
  final int maxLevel;
  final List<CatSkill> skills;
  final List<TrustLevel> trustLevels;
  final Map<String, CatInteraction> interactions;
  final List<String> idleAnimations;

  const Cat({
    required this.id,
    required this.name,
    required this.description,
    required this.appearance,
    required this.maxLevel,
    required this.skills,
    required this.trustLevels,
    required this.interactions,
    required this.idleAnimations,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      appearance: json['appearance'] as String,
      maxLevel: json['maxLevel'] as int,
      skills: (json['skills'] as List)
          .map((s) => CatSkill.fromJson(s as Map<String, dynamic>))
          .toList(),
      trustLevels: (json['trustLevels'] as List)
          .map((t) => TrustLevel.fromJson(t as Map<String, dynamic>))
          .toList(),
      interactions: (json['interactions'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          CatInteraction.fromJson(value as Map<String, dynamic>),
        ),
      ),
      idleAnimations: (json['idleAnimations'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'appearance': appearance,
      'maxLevel': maxLevel,
      'skills': skills.map((s) => s.toJson()).toList(),
      'trustLevels': trustLevels.map((t) => t.toJson()).toList(),
      'interactions': interactions.map((k, v) => MapEntry(k, v.toJson())),
      'idleAnimations': idleAnimations,
    };
  }

  /// Get skill for a specific level
  CatSkill? getSkillForLevel(int level) {
    try {
      return skills.firstWhere((s) => s.level == level);
    } catch (_) {
      return null;
    }
  }

  /// Get all unlocked skills for a level
  List<CatSkill> getUnlockedSkills(int level) {
    return skills.where((s) => s.level <= level).toList();
  }

  /// Get trust requirement for level
  int getTrustRequirement(int level) {
    try {
      return trustLevels.firstWhere((t) => t.level == level).requiredTrust;
    } catch (_) {
      return 0;
    }
  }

  /// Calculate current level from trust points
  int calculateLevel(int trustPoints) {
    for (int i = trustLevels.length - 1; i >= 0; i--) {
      if (trustPoints >= trustLevels[i].requiredTrust) {
        return trustLevels[i].level;
      }
    }
    return 1;
  }

  @override
  String toString() => 'Cat($id: $name, Lv.$maxLevel)';
}
