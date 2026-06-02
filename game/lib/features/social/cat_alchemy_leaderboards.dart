/// Cat Alchemy Social Leaderboards
///
/// 읽기 전용 리더보드 시스템 - 병합 속도, 컬렉션 완료도 등을 제공합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/social/leaderboard_manager.dart';
import 'package:mg_common_game/systems/social/models/social_models.dart';

/// Cat Alchemy 전용 리더보드 관리자
class CatAlchemyLeaderboards extends ChangeNotifier {
  final LeaderboardManager _leaderboardManager = LeaderboardManager.instance;
  String? _currentUserId;

  // 리더보드 ID
  static const String _mergeSpeedWeekly = 'cat_alchemy_merge_speed_weekly';
  static const String _mergeSpeedAllTime = 'cat_alchemy_merge_speed_alltime';
  static const String _collectionCompletion = 'cat_alchemy_collection_completion';
  static const String _prestigeLevel = 'cat_alchemy_prestige_level';
  static const String _totalCrafted = 'cat_alchemy_total_crafted';

  CatAlchemyLeaderboards();

  /// 초기화
  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    await _leaderboardManager.initialize(userId);
    notifyListeners();
  }

  /// 병합 속도 기록 제출 (분당 병합 수)
  Future<LeaderboardEntry?> submitMergeSpeed({
    required int mergesPerMinute,
    String? playerName,
  }) async {
    if (_currentUserId == null) return null;

    return await _leaderboardManager.submitScore(
      leaderboardId: _mergeSpeedWeekly,
      score: mergesPerMinute,
      playerName: playerName,
      type: LeaderboardType.global,
      timeScope: LeaderboardTimeScope.weekly,
      metadata: {
        'category': 'merge_speed',
        'unit': 'merges_per_minute',
      },
    );
  }

  /// 컬렉션 완료도 기록 제출
  Future<LeaderboardEntry?> submitCollectionProgress({
    required int completedRecipes,
    required int totalRecipes,
    String? playerName,
  }) async {
    if (_currentUserId == null) return null;

    // 백분율로 계산 (0-10000, 소수점 둘째자리까지)
    final percentage = ((completedRecipes / totalRecipes) * 10000).round();

    return await _leaderboardManager.submitScore(
      leaderboardId: _collectionCompletion,
      score: percentage,
      playerName: playerName,
      type: LeaderboardType.global,
      timeScope: LeaderboardTimeScope.allTime,
      metadata: {
        'category': 'collection',
        'completed': completedRecipes,
        'total': totalRecipes,
        'percentage': (completedRecipes / totalRecipes * 100).toStringAsFixed(2),
      },
    );
  }

  /// 프리스티지 레벨 기록 제출
  Future<LeaderboardEntry?> submitPrestigeLevel({
    required int prestigeLevel,
    String? playerName,
  }) async {
    if (_currentUserId == null) return null;

    return await _leaderboardManager.submitScore(
      leaderboardId: _prestigeLevel,
      score: prestigeLevel,
      playerName: playerName,
      type: LeaderboardType.global,
      timeScope: LeaderboardTimeScope.allTime,
      metadata: {
        'category': 'prestige',
      },
    );
  }

  /// 총 제작 수 기록 제출
  Future<LeaderboardEntry?> submitTotalCrafted({
    required int totalCrafted,
    String? playerName,
  }) async {
    if (_currentUserId == null) return null;

    return await _leaderboardManager.submitScore(
      leaderboardId: _totalCrafted,
      score: totalCrafted,
      playerName: playerName,
      type: LeaderboardType.global,
      timeScope: LeaderboardTimeScope.allTime,
      metadata: {
        'category': 'crafting',
      },
    );
  }

  /// 병합 속도 리더보드 조회 (주간)
  Future<List<LeaderboardEntry>> fetchMergeSpeedLeaderboard({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _leaderboardManager.fetchLeaderboard(
      leaderboardId: _mergeSpeedWeekly,
      type: LeaderboardType.global,
      timeScope: LeaderboardTimeScope.weekly,
      limit: limit,
      offset: offset,
    );
  }

  /// 컬렉션 완료도 리더보드 조회
  Future<List<LeaderboardEntry>> fetchCollectionLeaderboard({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _leaderboardManager.fetchLeaderboard(
      leaderboardId: _collectionCompletion,
      type: LeaderboardType.global,
      timeScope: LeaderboardTimeScope.allTime,
      limit: limit,
      offset: offset,
    );
  }

  /// 프리스티지 레벨 리더보드 조회
  Future<List<LeaderboardEntry>> fetchPrestigeLeaderboard({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _leaderboardManager.fetchLeaderboard(
      leaderboardId: _prestigeLevel,
      type: LeaderboardType.global,
      timeScope: LeaderboardTimeScope.allTime,
      limit: limit,
      offset: offset,
    );
  }

  /// 총 제작 수 리더보드 조회
  Future<List<LeaderboardEntry>> fetchTotalCraftedLeaderboard({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _leaderboardManager.fetchLeaderboard(
      leaderboardId: _totalCrafted,
      type: LeaderboardType.global,
      timeScope: LeaderboardTimeScope.allTime,
      limit: limit,
      offset: offset,
    );
  }

  /// 친구 리더보드 조회 (병합 속도)
  Future<List<LeaderboardEntry>> fetchFriendsMergeSpeedLeaderboard({
    required List<String> friendIds,
    int limit = 50,
  }) async {
    return await _leaderboardManager.fetchFriendsLeaderboard(
      leaderboardId: _mergeSpeedWeekly,
      friendIds: friendIds,
      limit: limit,
    );
  }

  /// 친구 리더보드 조회 (컬렉션 완료도)
  Future<List<LeaderboardEntry>> fetchFriendsCollectionLeaderboard({
    required List<String> friendIds,
    int limit = 50,
  }) async {
    return await _leaderboardManager.fetchFriendsLeaderboard(
      leaderboardId: _collectionCompletion,
      friendIds: friendIds,
      limit: limit,
    );
  }

  /// 내 순위 조회 (병합 속도)
  Future<LeaderboardEntry?> fetchMyMergeSpeedRank() async {
    if (_currentUserId == null) return null;
    return await _leaderboardManager.fetchPlayerRank(_mergeSpeedWeekly);
  }

  /// 내 순위 조회 (컬렉션 완료도)
  Future<LeaderboardEntry?> fetchMyCollectionRank() async {
    if (_currentUserId == null) return null;
    return await _leaderboardManager.fetchPlayerRank(_collectionCompletion);
  }

  /// 내 순위 조회 (프리스티지)
  Future<LeaderboardEntry?> fetchMyPrestigeRank() async {
    if (_currentUserId == null) return null;
    return await _leaderboardManager.fetchPlayerRank(_prestigeLevel);
  }

  /// 내 주변 랭커 조회 (병합 속도)
  Future<List<LeaderboardEntry>> fetchPlayersAroundMeInMergeSpeed({
    int range = 5,
  }) async {
    return await _leaderboardManager.fetchPlayersAroundMe(
      leaderboardId: _mergeSpeedWeekly,
      range: range,
    );
  }

  /// 상위 N명 조회 (병합 속도)
  Future<List<LeaderboardEntry>> fetchTopMergeSpeedPlayers({
    int count = 10,
  }) async {
    return await _leaderboardManager.getTopPlayers(
      leaderboardId: _mergeSpeedWeekly,
      count: count,
    );
  }

  /// 상위 N명 조회 (컬렉션 완료도)
  Future<List<LeaderboardEntry>> fetchTopCollectionPlayers({
    int count = 10,
  }) async {
    return await _leaderboardManager.getTopPlayers(
      leaderboardId: _collectionCompletion,
      count: count,
    );
  }

  /// 상위 퍼센트 확인 (병합 속도)
  Future<bool> isPlayerInTopPercentInMergeSpeed({
    required double percent,
  }) async {
    return await _leaderboardManager.isPlayerInTopPercent(
      leaderboardId: _mergeSpeedWeekly,
      percent: percent,
    );
  }

  /// 리더보드 보상 확인 및 수여
  Future<List<UserLeaderboardReward>> checkAndAwardMergeSpeedRewards() async {
    return await _leaderboardManager.checkAndAwardRewards(_mergeSpeedWeekly);
  }

  /// 보상 수령
  Future<bool> claimReward(String rewardId) async {
    return await _leaderboardManager.claimReward(rewardId);
  }

  /// 미수령 보상 목록
  Future<List<UserLeaderboardReward>> getPendingRewards() async {
    return await _leaderboardManager.getPendingRewards();
  }

  /// 캐시된 리더보드 조회 (네트워크 없음)
  List<LeaderboardEntry> getCachedMergeSpeedLeaderboard() {
    return _leaderboardManager.getCachedLeaderboard(_mergeSpeedWeekly);
  }

  List<LeaderboardEntry> getCachedCollectionLeaderboard() {
    return _leaderboardManager.getCachedLeaderboard(_collectionCompletion);
  }

  /// 캐시 클리어
  void clearCache() {
    _leaderboardManager.clearCache();
    notifyListeners();
  }

  /// 특정 리더보드 캐시 클리어
  void clearMergeSpeedCache() {
    _leaderboardManager.clearLeaderboardCache(_mergeSpeedWeekly);
    notifyListeners();
  }

  void clearCollectionCache() {
    _leaderboardManager.clearLeaderboardCache(_collectionCompletion);
    notifyListeners();
  }

  /// 리더보드 정보 (UI 표시용)
  Map<String, dynamic> getLeaderboardInfo(String leaderboardId) {
    switch (leaderboardId) {
      case _mergeSpeedWeekly:
      case _mergeSpeedAllTime:
        return {
          'title': '병합 속도 대회',
          'description': '1분간 가장 많이 병합한 플레이어',
          'unit': '회/분',
          'icon': '⚡',
          'timeScope': leaderboardId.contains('weekly') ? '주간' : '전체',
        };
      case _collectionCompletion:
        return {
          'title': '컬렉션 완료도',
          'description': '가장 많은 레시피를 발견한 플레이어',
          'unit': '%',
          'icon': '📚',
          'timeScope': '전체',
        };
      case _prestigeLevel:
        return {
          'title': '프리스티지 레벨',
          'description': '가장 높은 프리스티지를 달성한 플레이어',
          'unit': 'Lv',
          'icon': '⭐',
          'timeScope': '전체',
        };
      case _totalCrafted:
        return {
          'title': '총 제작 수',
          'description': '가장 많은 아이템을 제작한 플레이어',
          'unit': '개',
          'icon': '🔨',
          'timeScope': '전체',
        };
      default:
        return {
          'title': '리더보드',
          'description': '',
          'unit': '',
          'icon': '🏆',
          'timeScope': '',
        };
    }
  }

  /// 포맷된 점수 (UI 표시용)
  String formatScore(String leaderboardId, int score) {
    switch (leaderboardId) {
      case _collectionCompletion:
        // 백분율을 실제 퍼센트로 변환
        return '${(score / 100).toStringAsFixed(2)}%';
      case _prestigeLevel:
      case _totalCrafted:
        return score.toString();
      case _mergeSpeedWeekly:
      case _mergeSpeedAllTime:
        return '$score회/분';
      default:
        return score.toString();
    }
  }

  /// 모든 리더보드 ID 목록
  List<String> get allLeaderboardIds => [
        _mergeSpeedWeekly,
        _mergeSpeedAllTime,
        _collectionCompletion,
        _prestigeLevel,
        _totalCrafted,
      ];

  /// 사용 가능한 리더보드 목록 (UI 표시용)
  List<Map<String, dynamic>> get availableLeaderboards => allLeaderboardIds
      .map((id) => {
            'id': id,
            ...getLeaderboardInfo(id),
          })
      .toList();

  /// 초기화 여부
  bool get isInitialized => _leaderboardManager.isInitialized;

  /// 현재 사용자 ID
  String? get currentUserId => _currentUserId;
}

/// 리더보드 순위 보상 티어
class LeaderboardRewardTiers {
  static final Map<int, List<String>> _tiers = {};

  static void _initializeTiers() {
    if (_tiers.isNotEmpty) return;

    // 1위
    _tiers[1] = ['exclusive_cat_skin_legendary', '10000_gems', 'ssr_recipe_ticket'];

    // 2-3위
    _tiers[2] = ['exclusive_cat_skin_epic', '5000_gems', 'sr_recipe_ticket'];
    _tiers[3] = ['exclusive_cat_skin_epic', '5000_gems', 'sr_recipe_ticket'];

    // 4-10위
    for (int i = 4; i <= 10; i++) {
      _tiers[i] = ['premium_cat_skin', '2000_gems'];
    }

    // 11-50위
    for (int i = 11; i <= 50; i++) {
      _tiers[i] = ['rare_material_pack', '500_gems'];
    }

    // 51-100위
    for (int i = 51; i <= 100; i++) {
      _tiers[i] = ['gold_boost_7days', '100_gems'];
    }
  }

  static List<String> getRewardsForRank(int rank) {
    _initializeTiers();
    return _tiers[rank] ?? [];
  }

  /// 순위 등급 반환
  static String getRankTier(int rank) {
    if (rank == 1) return '챔피언';
    if (rank <= 3) return '마스터';
    if (rank <= 10) return '다이아몬드';
    if (rank <= 50) return '플래티넘';
    if (rank <= 100) return '골드';
    return '실버';
  }

  /// 순위 색상 반환
  static String getRankColor(int rank) {
    if (rank == 1) return '#FFD700'; // 금색
    if (rank <= 3) return '#C0C0C0'; // 은색
    if (rank <= 10) return '#CD7F32'; // 동색
    if (rank <= 50) return '#21618C'; // 파란색
    if (rank <= 100) return '#27AE60'; // 초록색
    return '#95A5A6'; // 회색
  }
}
