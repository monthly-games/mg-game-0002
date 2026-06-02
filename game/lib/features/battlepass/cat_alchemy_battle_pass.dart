/// Cat Alchemy Battle Pass - MG-0002 전용 배틀패스 구현
///
/// mg_common_game의 BattlePassManager를 확장하여 Cat Alchemy Workshop에 특화된
/// 보상, 시즌, 미션을 제공합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_manager.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_config.dart';
import 'package:mg_common_game/systems/gacha/gacha_config.dart';

/// Cat Alchemy 전용 배틀패스
class CatAlchemyBattlePass extends ChangeNotifier {
  final BattlePassManager _manager = BattlePassManager();
  List<BPMission> _seasonalMissions = [];

  CatAlchemyBattlePass() {
    _initializeSeason();
    _setupCallbacks();
  }

  void _initializeSeason() {
    // 28일 시즌 생성
    final season = BPSeasonBuilder.create28DaySeason(
      id: 'cat_alchemy_season_1',
      nameKr: '고양이 연금술 공방 시즌 1: 마법의 레시피',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      expPerLevel: 1000,
    );

    // Cat Alchemy 전용 보상으로 티어 재정의
    final customTiers = _createCatAlchemyTiers(season.maxLevel);
    final updatedSeason = BPSeasonConfig(
      id: season.id,
      nameKr: season.nameKr,
      startDate: season.startDate,
      endDate: season.endDate,
      expPerLevel: season.expPerLevel,
      maxLevel: season.maxLevel,
      tiers: customTiers,
    );

    _manager.setSeason(updatedSeason);
    _seasonalMissions = _createSeasonalMissions();
    _manager.setMissions(
      daily: _createDailyMissions(),
      weekly: _createWeeklyMissions(),
      seasonal: _seasonalMissions,
    );
  }

  void _setupCallbacks() {
    _manager.onLevelUp = (level) {
      debugPrint('🎉 Battle Pass Level Up: $level');
    };

    _manager.onRewardClaimed = (rewards) {
      debugPrint('🎁 Rewards Claimed: ${rewards.length} items');
    };

    _manager.onMissionComplete = (mission) {
      debugPrint('✅ Mission Complete: ${mission.titleKr}');
    };
  }

  /// Cat Alchemy 전용 보상 티어 생성
  List<BPTier> _createCatAlchemyTiers(int maxLevel) {
    final tiers = <BPTier>[];

    for (int level = 1; level <= maxLevel; level++) {
      final freeRewards = _getFreeRewardsForLevel(level);
      final premiumRewards = _getPremiumRewardsForLevel(level);

      tiers.add(BPTier(
        level: level,
        requiredExp: level * 1000,
        freeRewards: freeRewards,
        premiumRewards: premiumRewards,
      ));
    }

    return tiers;
  }

  /// 무료 보상
  List<BPReward> _getFreeRewardsForLevel(int level) {
    final rewards = <BPReward>[];

    // 골드 보상 (모든 레벨)
    rewards.add(BPReward(
      id: 'gold_$level',
      nameKr: '${100 + (level * 50)} 골드',
      type: BPRewardType.currency,
      amount: 100 + (level * 50),
    ));

    // 5레벨마다 특별 보상
    if (level % 5 == 0) {
      rewards.add(BPReward(
        id: 'rare_material_$level',
        nameKr: '희귀 재료 x5',
        type: BPRewardType.item,
        amount: 5,
      ));
    }

    // 10레벨마다 레시피
    if (level % 10 == 0) {
      rewards.add(BPReward(
        id: 'recipe_ticket_$level',
        nameKr: '레시피 티켓 x1',
        type: BPRewardType.item,
        amount: 1,
      ));
    }

    // 20레벨마다 고양이
    if (level % 20 == 0) {
      rewards.add(BPReward(
        id: 'cat_skin_$level',
        nameKr: '특별 고양이 스킨',
        type: BPRewardType.character,
        amount: 1,
      ));
    }

    return rewards;
  }

  /// 프리미엄 보상
  List<BPReward> _getPremiumRewardsForLevel(int level) {
    final rewards = <BPReward>[];

    // 더 많은 골드
    rewards.add(BPReward(
      id: 'premium_gold_$level',
      nameKr: '${200 + (level * 100)} 골드 (프리미엄)',
      type: BPRewardType.currency,
      amount: 200 + (level * 100),
      isPremiumOnly: true,
    ));

    // 모든 레벨에서 보석
    rewards.add(BPReward(
      id: 'gems_$level',
      nameKr: '${10 + level} 보석',
      type: BPRewardType.currency,
      amount: 10 + level,
      isPremiumOnly: true,
    ));

    // 3레벨마다 희귀 재료
    if (level % 3 == 0) {
      rewards.add(BPReward(
        id: 'premium_material_$level',
        nameKr: '희귀 재료 x10',
        type: BPRewardType.item,
        amount: 10,
        isPremiumOnly: true,
      ));
    }

    // 10레벨마다 SR 레시피
    if (level % 10 == 0) {
      rewards.add(BPReward(
        id: 'sr_recipe_guaranteed_$level',
        nameKr: 'SR 레시피 확정 뽑기',
        type: BPRewardType.item,
        amount: 1,
        isPremiumOnly: true,
      ));
    }

    // 15레벨마다 특별 고양이
    if (level % 15 == 0) {
      rewards.add(BPReward(
        id: 'exclusive_cat_$level',
        nameKr: '한정 고양이 스킨',
        type: BPRewardType.character,
        amount: 1,
        isPremiumOnly: true,
      ));
    }

    // 25레벨마다 배경 테마
    if (level % 25 == 0) {
      rewards.add(BPReward(
        id: 'theme_$level',
        nameKr: '특별 테마',
        type: BPRewardType.item,
        amount: 1,
        isPremiumOnly: true,
      ));
    }

    return rewards;
  }

  /// 일일 미션
  List<BPMission> _createDailyMissions() {
    return const [
      // 로그인 미션
      BPMission(
        id: 'daily_login',
        titleKr: '오늘도 방문!',
        descriptionKr: '게임에 접속하세요',
        type: BPMissionType.daily,
        targetValue: 1,
        expReward: 50,
        trackingKey: 'login',
      ),

      // 제작 미션
      BPMission(
        id: 'daily_craft_3',
        titleKr: '연금술의 기본',
        descriptionKr: '레시피 3개 제작하기',
        type: BPMissionType.daily,
        targetValue: 3,
        expReward: 100,
        trackingKey: 'craft',
      ),

      BPMission(
        id: 'daily_craft_10',
        titleKr: '연금술 숙련가',
        descriptionKr: '레시피 10개 제작하기',
        type: BPMissionType.daily,
        targetValue: 10,
        expReward: 200,
        trackingKey: 'craft',
      ),

      // 자원 수집
      BPMission(
        id: 'daily_gather',
        titleKr: '재료 수집',
        descriptionKr: '재료 100개 수집하기',
        type: BPMissionType.daily,
        targetValue: 100,
        expReward: 80,
        trackingKey: 'gather',
      ),

      // 판매 미션
      BPMission(
        id: 'daily_sell_5',
        titleKr: '상인의 하루',
        descriptionKr: '완성품 5개 판매하기',
        type: BPMissionType.daily,
        targetValue: 5,
        expReward: 100,
        trackingKey: 'sell',
      ),

      // 고양이 상호작용
      BPMission(
        id: 'daily_pet_cat',
        titleKr: '고양이 친구',
        descriptionKr: '고양이 10번 쓰다듬기',
        type: BPMissionType.daily,
        targetValue: 10,
        expReward: 60,
        trackingKey: 'pet_cat',
      ),

      // 광고 시청
      BPMission(
        id: 'daily_ad',
        titleKr: '후원감',
        descriptionKr: '광고 3회 시청하기',
        type: BPMissionType.daily,
        targetValue: 3,
        expReward: 100,
        trackingKey: 'watch_ad',
      ),
    ];
  }

  /// 주간 미션
  List<BPMission> _createWeeklyMissions() {
    return const [
      // 제작량
      BPMission(
        id: 'weekly_craft_50',
        titleKr: '주간 제작 달인',
        descriptionKr: '레시피 50개 제작하기',
        type: BPMissionType.weekly,
        targetValue: 50,
        expReward: 500,
        trackingKey: 'craft',
      ),

      BPMission(
        id: 'weekly_craft_100',
        titleKr: '주간 제작 마스터',
        descriptionKr: '레시피 100개 제작하기',
        type: BPMissionType.weekly,
        targetValue: 100,
        expReward: 1000,
        trackingKey: 'craft',
      ),

      // 판매량
      BPMission(
        id: 'weekly_sell_30',
        titleKr: '주간 판매왕',
        descriptionKr: '완성품 30개 판매하기',
        type: BPMissionType.weekly,
        targetValue: 30,
        expReward: 400,
        trackingKey: 'sell',
      ),

      // 컬렉션
      BPMission(
        id: 'weekly_collect_5',
        titleKr: '컬렉션 도전',
        descriptionKr: '새로운 레시피 5개 발견하기',
        type: BPMissionType.weekly,
        targetValue: 5,
        expReward: 600,
        trackingKey: 'discover_recipe',
      ),

      // 가챠
      BPMission(
        id: 'weekly_gacha_10',
        titleKr: '운명의 뽑기',
        descriptionKr: '레시피 뽑기 10회 진행하기',
        type: BPMissionType.weekly,
        targetValue: 10,
        expReward: 500,
        trackingKey: 'gacha_pull',
      ),

      // 특별 미션
      BPMission(
        id: 'weekly_prestige',
        titleKr: '도전의 길',
        descriptionKr: '프리스티지 1회 달성하기',
        type: BPMissionType.weekly,
        targetValue: 1,
        expReward: 800,
        trackingKey: 'prestige',
      ),

      // 소셜
      BPMission(
        id: 'weekly_social',
        titleKr: '친구와 함께',
        descriptionKr: '친구 방문 5회 또는 선물 5개 보내기',
        type: BPMissionType.weekly,
        targetValue: 5,
        expReward: 300,
        trackingKey: 'social_interaction',
      ),
    ];
  }

  /// 시즌 미션
  List<BPMission> _createSeasonalMissions() {
    return const [
      BPMission(
        id: 'season_craft_500',
        titleKr: '시즌 제작의 달인',
        descriptionKr: '시즌 동안 500개 제작하기',
        type: BPMissionType.seasonal,
        targetValue: 500,
        expReward: 2000,
        trackingKey: 'craft',
      ),

      BPMission(
        id: 'season_collect_50',
        titleKr: '시즌 컬렉터',
        descriptionKr: '레시피 50종 발견하기',
        type: BPMissionType.seasonal,
        targetValue: 50,
        expReward: 3000,
        trackingKey: 'discover_recipe',
      ),

      BPMission(
        id: 'season_prestige_10',
        titleKr: '시즌 도전자',
        descriptionKr: '프리스티지 10회 달성하기',
        type: BPMissionType.seasonal,
        targetValue: 10,
        expReward: 5000,
        trackingKey: 'prestige',
      ),

      BPMission(
        id: 'season_gold_million',
        titleKr: '백만장자의 꿈',
        descriptionKr: '누적 골드 1,000,000 획득하기',
        type: BPMissionType.seasonal,
        targetValue: 1000000,
        expReward: 4000,
        trackingKey: 'earn_gold',
      ),

      BPMission(
        id: 'season_gacha_100',
        titleKr: '시즌 뽑기의 신',
        descriptionKr: '레시피 뽑기 100회 진행하기',
        type: BPMissionType.seasonal,
        targetValue: 100,
        expReward: 3000,
        trackingKey: 'gacha_pull',
      ),
    ];
  }

  // === Getters ===

  BattlePassState? get state => _manager.state;
  int get currentLevel => _manager.currentLevel;
  int get currentExp => _manager.currentExp;
  double get levelProgress => _manager.levelProgress;
  int get expToNextLevel => _manager.expToNextLevel;
  bool get isPremium => _manager.isPremium;
  Set<int> get claimedFreeLevels => _manager.state?.claimedFreeLevels ?? {};
  Set<int> get claimedPremiumLevels => _manager.state?.claimedPremiumLevels ?? {};
  List<BPMission> get dailyMissions => _manager.dailyMissions;
  List<BPMission> get weeklyMissions => _manager.weeklyMissions;
  List<BPMission> get seasonalMissions => _seasonalMissions;
  List<BPMission> get allMissions => [
    ...dailyMissions,
    ...weeklyMissions,
    ...seasonalMissions,
  ];
  Map<String, MissionProgress> get missionProgress => _manager.state?.missionProgress ?? {};
  BPSeasonConfig? get currentSeason => _manager.currentSeason;
  List<BPTier> get tiers => _manager.currentSeason?.tiers ?? [];
  int get maxLevel => _manager.currentSeason?.maxLevel ?? 50;
  String get seasonName => _manager.currentSeason?.nameKr ?? '';
  int get remainingDays => _manager.currentSeason?.remainingDays ?? 0;
  int get unclaimedRewardCount => _manager.unclaimedRewardCount;

  // === Actions ===

  /// 경험치 추가
  void addExp(int amount) {
    _manager.addExp(amount);
    notifyListeners();
  }

  /// 미션 진행도 업데이트
  void updateMissionProgress(String trackingKey, int value) {
    _manager.updateMissionProgress(trackingKey, value);
    notifyListeners();
  }

  /// 미션 진행도 증가
  void incrementMission(String trackingKey, [int amount = 1]) {
    _manager.incrementMissionProgress(trackingKey, amount: amount);
    notifyListeners();
  }

  /// 미션 보상 수령
  bool claimMissionReward(String missionId) {
    final result = _manager.claimMissionReward(missionId);
    if (result) {
      notifyListeners();
    }
    return result;
  }

  /// 레벨 보상 수령
  List<BPReward> claimReward(int level, {required bool isPremiumReward}) {
    final rewards = _manager.claimReward(level, isPremiumReward: isPremiumReward);
    if (rewards.isNotEmpty) {
      notifyListeners();
    }
    return rewards;
  }

  /// 모든 수령 가능한 보상 일괄 수령
  List<BPReward> claimAllAvailable() {
    final rewards = _manager.claimAllAvailable();
    if (rewards.isNotEmpty) {
      notifyListeners();
    }
    return rewards;
  }

  /// 프리미엄 구매
  void purchasePremium() {
    _manager.purchasePremium();
    notifyListeners();
  }

  /// 일일 미션 리셋
  void resetDailyMissions() {
    _manager.resetDailyMissions();
    notifyListeners();
  }

  /// 주간 미션 리셋
  void resetWeeklyMissions() {
    _manager.resetWeeklyMissions();
    notifyListeners();
  }

  /// 미션 완료 여부
  bool isMissionCompleted(String missionId) {
    return _manager.isMissionCompleted(missionId);
  }

  /// 미션 진행률
  double getMissionProgress(String missionId) {
    return _manager.getMissionProgress(missionId);
  }

  /// 보상 수령 가능 여부
  bool canClaimReward(int level, {required bool isPremiumReward}) {
    return _manager.canClaimReward(level, isPremiumReward: isPremiumReward);
  }

  /// 저장
  Map<String, dynamic> toJson() => _manager.toJson();

  /// 불러오기
  void loadFromJson(Map<String, dynamic> json) {
    _manager.loadFromJson(json);
    notifyListeners();
  }
}

/// 레어도 확장 (BattlePassConfig에서 가져오기 위해)
extension GachaRarityExtension on GachaRarity {
  String get nameKr {
    switch (this) {
      case GachaRarity.normal:
        return 'N';
      case GachaRarity.rare:
        return 'R';
      case GachaRarity.superRare:
        return 'SR';
      case GachaRarity.ultraRare:
        return 'SSR';
      case GachaRarity.legendary:
        return 'UR';
    }
  }
}
