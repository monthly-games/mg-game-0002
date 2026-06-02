/// Story chapter model for Cat Alchemy Workshop
/// Represents a chapter in the cat village mystery storyline
class StoryChapter {
  final String id;
  final int chapterNumber;
  final String title;
  final String description;
  final List<StoryScene> scenes;
  final List<String> unlockRecipeIds;
  final ChapterReward reward;
  final int requiredWorkshopLevel;
  final int requiredReputation;

  const StoryChapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.scenes,
    required this.unlockRecipeIds,
    required this.reward,
    this.requiredWorkshopLevel = 1,
    this.requiredReputation = 0,
  });

  factory StoryChapter.fromJson(Map<String, dynamic> json) {
    return StoryChapter(
      id: json['id'] as String,
      chapterNumber: json['chapterNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      scenes: (json['scenes'] as List)
          .map((s) => StoryScene.fromJson(s as Map<String, dynamic>))
          .toList(),
      unlockRecipeIds:
          (json['unlockRecipeIds'] as List).cast<String>(),
      reward: ChapterReward.fromJson(json['reward'] as Map<String, dynamic>),
      requiredWorkshopLevel: json['requiredWorkshopLevel'] as int? ?? 1,
      requiredReputation: json['requiredReputation'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterNumber': chapterNumber,
      'title': title,
      'description': description,
      'scenes': scenes.map((s) => s.toJson()).toList(),
      'unlockRecipeIds': unlockRecipeIds,
      'reward': reward.toJson(),
      'requiredWorkshopLevel': requiredWorkshopLevel,
      'requiredReputation': requiredReputation,
    };
  }

  /// Check if chapter is unlocked
  bool isUnlocked(int workshopLevel, int reputation) {
    return workshopLevel >= requiredWorkshopLevel &&
        reputation >= requiredReputation;
  }

  @override
  String toString() => 'Chapter $chapterNumber: $title';
}

/// Individual story scene within a chapter
class StoryScene {
  final String id;
  final String speaker; // narrator, cat, npc, player
  final String? characterName;
  final String dialogue;
  final String? backgroundAsset;
  final String? musicAsset;
  final List<StoryChoice>? choices;

  const StoryScene({
    required this.id,
    required this.speaker,
    this.characterName,
    required this.dialogue,
    this.backgroundAsset,
    this.musicAsset,
    this.choices,
  });

  factory StoryScene.fromJson(Map<String, dynamic> json) {
    return StoryScene(
      id: json['id'] as String,
      speaker: json['speaker'] as String,
      characterName: json['characterName'] as String?,
      dialogue: json['dialogue'] as String,
      backgroundAsset: json['backgroundAsset'] as String?,
      musicAsset: json['musicAsset'] as String?,
      choices: (json['choices'] as List?)
          ?.map((c) => StoryChoice.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speaker': speaker,
      if (characterName != null) 'characterName': characterName,
      'dialogue': dialogue,
      if (backgroundAsset != null) 'backgroundAsset': backgroundAsset,
      if (musicAsset != null) 'musicAsset': musicAsset,
      if (choices != null) 'choices': choices?.map((c) => c.toJson()).toList(),
    };
  }
}

/// Player choices in story scenes
class StoryChoice {
  final String text;
  final String? nextSceneId;
  final Map<String, int>? trustChange;
  final String? unlockContent;

  const StoryChoice({
    required this.text,
    this.nextSceneId,
    this.trustChange,
    this.unlockContent,
  });

  factory StoryChoice.fromJson(Map<String, dynamic> json) {
    return StoryChoice(
      text: json['text'] as String,
      nextSceneId: json['nextSceneId'] as String?,
      trustChange: (json['trustChange'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)),
      unlockContent: json['unlockContent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (nextSceneId != null) 'nextSceneId': nextSceneId,
      if (trustChange != null) 'trustChange': trustChange,
      if (unlockContent != null) 'unlockContent': unlockContent,
    };
  }
}

/// Chapter completion rewards
class ChapterReward {
  final int gold;
  final int exp;
  final int? gems;
  final int? reputation;
  final String? specialCatId;

  const ChapterReward({
    required this.gold,
    required this.exp,
    this.gems,
    this.reputation,
    this.specialCatId,
  });

  factory ChapterReward.fromJson(Map<String, dynamic> json) {
    return ChapterReward(
      gold: json['gold'] as int,
      exp: json['exp'] as int,
      gems: json['gems'] as int?,
      reputation: json['reputation'] as int?,
      specialCatId: json['specialCatId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gold': gold,
      'exp': exp,
      if (gems != null) 'gems': gems,
      if (reputation != null) 'reputation': reputation,
      if (specialCatId != null) 'specialCatId': specialCatId,
    };
  }
}
