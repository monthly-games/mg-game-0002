/// Recipe Gacha System - Cat Alchemy Workshop
///
/// 레시피 뽑기 시스템 구현 (소프트 피티 70, 하드 피티 80)
library;

import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/gacha/gacha_manager.dart';
import 'package:mg_common_game/systems/gacha/gacha_pool.dart';

/// 레시피 아이템
class RecipeItem {
  final String id;
  final String name;
  final GachaRarity rarity;
  final String? imageAsset;
  final Map<String, dynamic> stats;
  final String? description;

  const RecipeItem({
    required this.id,
    required this.name,
    required this.rarity,
    this.imageAsset,
    this.stats = const {},
    this.description,
  });

  /// GachaItem으로 변환
  GachaItem toGachaItem() {
    return GachaItem(
      id: id,
      nameKr: name,
      rarity: rarity,
      imageAsset: imageAsset,
      metadata: stats,
    );
  }

  /// GachaItem에서 변환
  factory RecipeItem.fromGachaItem(GachaItem item) {
    return RecipeItem(
      id: item.id,
      name: item.nameKr,
      rarity: item.rarity,
      imageAsset: item.imageAsset,
      stats: item.metadata,
    );
  }
}

/// 레시피 뽑기 결과
class RecipeGachaResult {
  final RecipeItem recipe;
  final bool isPityTriggered;
  final bool isNew;
  final int pullNumber;
  final int currentPity;

  const RecipeGachaResult({
    required this.recipe,
    this.isPityTriggered = false,
    this.isNew = true,
    required this.pullNumber,
    required this.currentPity,
  });
}

/// Cat Alchemy 레시피 가챠 시스템
class RecipeGachaSystem extends ChangeNotifier {
  final GachaManager _gachaManager = GachaManager(
    pityConfig: const PityConfig(
      softPityStart: 70,
      hardPity: 80,
      softPityBonus: 6.0,
      resetOnHighRarity: true,
      guaranteedRarity: GachaRarity.ultraRare,
    ),
    multiPullGuarantee: const MultiPullGuarantee(
      pullCount: 10,
      minRarity: GachaRarity.rare,
      guaranteedCount: 1,
    ),
  );

  static const String _mainPoolId = 'cat_alchemy_recipes';
  static const String _limitedPoolId = 'cat_alchemy_limited';

  // 발견한 레시피 추적
  final Set<String> _discoveredRecipes = {};
  final Set<String> _ownedRecipes = {};

  RecipeGachaSystem() {
    _initializePools();
    _setupCallbacks();
  }

  void _initializePools() {
    // 메인 레시피 풀
    final mainPool = GachaPool(
      id: _mainPoolId,
      nameKr: '고양이 연금술 레시피',
      description: '다양한 레시피를 획득하세요!',
      items: _generateMainPoolItems(),
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 365)),
    );

    // 한정 레시피 풀
    final limitedPool = GachaPool(
      id: _limitedPoolId,
      nameKr: '한정 레시피',
      description: '시즌 한정 레시피를 획득하세요!',
      items: _generateLimitedPoolItems(),
      pickupItemIds: ['limited_sr_001', 'limited_ssr_001'],
      pickupRateBonus: 50.0,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 30)),
    );

    _gachaManager.registerPool(mainPool);
    _gachaManager.registerPool(limitedPool);
  }

  void _setupCallbacks() {
    _gachaManager.onPull = (result) {
      debugPrint('🎰 Gacha Pull: ${result.item.nameKr} (${result.item.rarity.nameKr})');
    };

    _gachaManager.onMultiPull = (results) {
      final ssrCount = results.where((r) => r.item.rarity == GachaRarity.ultraRare).length;
      final srCount = results.where((r) => r.item.rarity == GachaRarity.superRare).length;
      debugPrint('🎰 10-Pull Result: SSR=$ssrCount, SR=$srCount');
    };
  }

  /// 메인 풀 아이템 생성
  List<GachaItem> _generateMainPoolItems() {
    return [
      // UR (0.6%) - 5개
      GachaItem(id: 'ur_cat_philosopher', nameKr: '철학자 고양이', rarity: GachaRarity.ultraRare),
      GachaItem(id: 'ur_elixir_life', nameKr: '생명의 엘릭서', rarity: GachaRarity.ultraRare),
      GachaItem(id: 'ur_stone_philosophy', nameKr: '현자의 돌', rarity: GachaRarity.ultraRare),
      GachaItem(id: 'ur_recipe_legendary', nameKr: '전설의 조리법', rarity: GachaRarity.ultraRare),
      GachaItem(id: 'ur_cauldron_infinite', nameKr: '무한 가마솥', rarity: GachaRarity.ultraRare),

      // SSR (2.4%) - 12개
      GachaItem(id: 'ssr_cat_alchemist', nameKr: '연금술사 고양이', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_potion_gold', nameKr: '황금 물약', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_spell_transmute', nameKr: '변환의 주문', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_recipe_master', nameKr: '마스터 레시피', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_ingredient_dragon', nameKr: '드래곤의 비늘', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_cat_wizard', nameKr: '마법사 고양이', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_potion_mana', nameKr: '마나 물약', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_recipe_enchanted', nameKr: '마법 부여 레시피', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_crystal_magic', nameKr: '마법 수정', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_cat_mystic', nameKr: '신비한 고양이', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_book_ancient', nameKr: '고대 마법서', rarity: GachaRarity.superRare),
      GachaItem(id: 'ssr_recipe_arcane', nameKr: '비전 레시피', rarity: GachaRarity.superRare),

      // SR (12%) - 30개
      ...List.generate(30, (i) => GachaItem(
        id: 'sr_recipe_$i',
        nameKr: '고급 레시피 ${i + 1}',
        rarity: GachaRarity.superRare,
      )),

      // R (35%) - 50개
      ...List.generate(50, (i) => GachaItem(
        id: 'r_recipe_$i',
        nameKr: '일반 레시피 ${i + 1}',
        rarity: GachaRarity.rare,
      )),

      // N (50.2%) - 80개
      ...List.generate(80, (i) => GachaItem(
        id: 'n_recipe_$i',
        nameKr: '기본 레시피 ${i + 1}',
        rarity: GachaRarity.normal,
      )),
    ];
  }

  /// 한정 풀 아이템 생성
  List<GachaItem> _generateLimitedPoolItems() {
    return [
      // 한정 UR
      GachaItem(
        id: 'limited_ur_season',
        nameKr: '시즌 한정: 축제의 고양이',
        rarity: GachaRarity.ultraRare,
        isLimited: true,
        isPickup: true,
      ),

      // 한정 SSR
      GachaItem(
        id: 'limited_ssr_001',
        nameKr: '한정: 불꽃 축제 레시피',
        rarity: GachaRarity.superRare,
        isLimited: true,
        isPickup: true,
      ),
      GachaItem(
        id: 'limited_ssr_002',
        nameKr: '한정: 물놀이 고양이',
        rarity: GachaRarity.superRare,
        isLimited: true,
      ),
      GachaItem(
        id: 'limited_ssr_003',
        nameKr: '한정: 여름 밤의 레시피',
        rarity: GachaRarity.superRare,
        isLimited: true,
      ),

      // 일반 SSR
      ...List.generate(10, (i) => GachaItem(
        id: 'limited_ssrr_$i',
        nameKr: '고급 레시피 ${i + 1}',
        rarity: GachaRarity.superRare,
      )),

      // SR
      ...List.generate(25, (i) => GachaItem(
        id: 'limited_sr_$i',
        nameKr: '일반 레시피 ${i + 1}',
        rarity: GachaRarity.superRare,
      )),

      // R
      ...List.generate(40, (i) => GachaItem(
        id: 'limited_r_$i',
        nameKr: '기본 레시피 ${i + 1}',
        rarity: GachaRarity.rare,
      )),

      // N
      ...List.generate(60, (i) => GachaItem(
        id: 'limited_n_$i',
        nameKr: '보통 재료 ${i + 1}',
        rarity: GachaRarity.normal,
      )),
    ];
  }

  /// 단일 뽑기
  RecipeGachaResult? pullSingle({bool useLimitedPool = false}) {
    final poolId = useLimitedPool ? _limitedPoolId : _mainPoolId;
    final result = _gachaManager.pull(poolId);

    if (result == null) return null;

    final pityState = _gachaManager.getPityState(poolId);
    final isNew = !_ownedRecipes.contains(result.item.id);

    if (isNew) {
      _ownedRecipes.add(result.item.id);
      _discoveredRecipes.add(result.item.id);
    }

    notifyListeners();

    return RecipeGachaResult(
      recipe: RecipeItem.fromGachaItem(result.item),
      isPityTriggered: result.isPityTriggered,
      isNew: isNew,
      pullNumber: result.pullNumber,
      currentPity: pityState?.currentPity ?? 0,
    );
  }

  /// 10연차
  List<RecipeGachaResult> pullTen({bool useLimitedPool = false}) {
    final poolId = useLimitedPool ? _limitedPoolId : _mainPoolId;
    final results = _gachaManager.multiPull(poolId, count: 10);

    final pityState = _gachaManager.getPityState(poolId);
    final gachaResults = <RecipeGachaResult>[];

    for (final result in results) {
      final isNew = !_ownedRecipes.contains(result.item.id);

      if (isNew) {
        _ownedRecipes.add(result.item.id);
        _discoveredRecipes.add(result.item.id);
      }

      gachaResults.add(RecipeGachaResult(
        recipe: RecipeItem.fromGachaItem(result.item),
        isPityTriggered: result.isPityTriggered,
        isNew: isNew,
        pullNumber: result.pullNumber,
        currentPity: pityState?.currentPity ?? 0,
      ));
    }

    notifyListeners();
    return gachaResults;
  }

  /// 레시피 소유 여부
  bool ownsRecipe(String recipeId) => _ownedRecipes.contains(recipeId);

  /// 발견한 레시피 수
  int get discoveredCount => _discoveredRecipes.length;

  /// 소유한 레시피 수
  int get ownedCount => _ownedRecipes.length;

  /// 전체 레시피 수
  int get totalRecipeCount => _gachaManager.pools
      .expand((pool) => pool.items)
      .map((item) => item.id)
      .toSet()
      .length;

  /// 컬렉션 완료도
  double get collectionProgress {
    if (totalRecipeCount == 0) return 0;
    return discoveredCount / totalRecipeCount;
  }

  /// 천장까지 남은 횟수
  int pullsUntilPity({bool useLimitedPool = false}) {
    final poolId = useLimitedPool ? _limitedPoolId : _mainPoolId;
    return _gachaManager.remainingPity(poolId);
  }

  /// 현재 피티
  int currentPity({bool useLimitedPool = false}) {
    final poolId = useLimitedPool ? _limitedPoolId : _mainPoolId;
    return _gachaManager.getPityState(poolId)?.currentPity ?? 0;
  }

  /// 총 뽑기 횟수
  int totalPulls({bool useLimitedPool = false}) {
    final poolId = useLimitedPool ? _limitedPoolId : _mainPoolId;
    return _gachaManager.getPityState(poolId)?.totalPulls ?? 0;
  }

  /// 통계
  GachaStats stats({bool useLimitedPool = false}) {
    final poolId = useLimitedPool ? _limitedPoolId : _mainPoolId;
    return _gachaManager.getStats(poolId);
  }

  /// 히스토리
  List<GachaHistoryEntry> get history => _gachaManager.history;

  /// 소유한 레시피 목록
  List<String> get ownedRecipes => List.unmodifiable(_ownedRecipes);

  /// 발견한 레시피 목록
  List<String> get discoveredRecipes => List.unmodifiable(_discoveredRecipes);

  /// 활성화된 풀 목록
  List<GachaPool> get activePools => _gachaManager.activePools;

  /// 저장
  Map<String, dynamic> toJson() {
    return {
      'gacha': _gachaManager.toJson(),
      'ownedRecipes': _ownedRecipes.toList(),
      'discoveredRecipes': _discoveredRecipes.toList(),
    };
  }

  /// 불러오기
  void loadFromJson(Map<String, dynamic> json) {
    _gachaManager.loadFromJson(json['gacha'] as Map<String, dynamic>? ?? {});
    _ownedRecipes.clear();
    _discoveredRecipes.clear();
    _ownedRecipes.addAll((json['ownedRecipes'] as List<dynamic>?)?.cast<String>() ?? []);
    _discoveredRecipes.addAll((json['discoveredRecipes'] as List<dynamic>?)?.cast<String>() ?? []);
    notifyListeners();
  }

  /// 리셋 (디버그용)
  @visibleForTesting
  void reset() {
    _ownedRecipes.clear();
    _discoveredRecipes.clear();
    _gachaManager.resetPity(_mainPoolId);
    _gachaManager.resetPity(_limitedPoolId);
    notifyListeners();
  }
}
