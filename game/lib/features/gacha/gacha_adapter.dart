/// 가챠 시스템 어댑터 - MG-0002 Cat Alchemy Workshop
library;

import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/gacha/gacha_config.dart';
import 'package:mg_common_game/systems/gacha/gacha_manager.dart';

/// 게임 내 Recipe 모델
class Recipe {
  final String id;
  final String name;
  final GachaRarity rarity;
  final Map<String, dynamic> stats;

  const Recipe({
    required this.id,
    required this.name,
    required this.rarity,
    this.stats = const {},
  });
}

/// Cat Alchemy Workshop 가챠 어댑터
class RecipeGachaAdapter extends ChangeNotifier {
  final GachaManager _gachaManager = GachaManager(
    pityConfig: const PityConfig(
      softPityStart: 70,
      hardPity: 80,
      softPityBonus: 6.0,
    ),
    multiPullGuarantee: const MultiPullGuarantee(
      minRarity: GachaRarity.rare,
    ),
  );

  static const String _poolId = 'alchemy_pool';

  RecipeGachaAdapter() {
    _initPool();
  }

  void _initPool() {
    final pool = GachaPool(
      id: _poolId,
      name: 'Cat Alchemy Workshop 가챠',
      items: _generateItems(),
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 365)),
    );
    _gachaManager.registerPool(pool);
  }

  List<GachaItem> _generateItems() {
    return [
      // UR (0.6%)
      GachaItem(id: 'ur_alchemy_001', name: '전설의 Recipe', rarity: GachaRarity.ultraRare, weight: 1.0),
      GachaItem(id: 'ur_alchemy_002', name: '신화의 Recipe', rarity: GachaRarity.ultraRare, weight: 1.0),
      // SSR (2.4%)
      GachaItem(id: 'ssr_alchemy_001', name: '영웅의 Recipe', rarity: GachaRarity.superSuperRare, weight: 1.0),
      GachaItem(id: 'ssr_alchemy_002', name: '고대의 Recipe', rarity: GachaRarity.superSuperRare, weight: 1.0),
      GachaItem(id: 'ssr_alchemy_003', name: '황금의 Recipe', rarity: GachaRarity.superSuperRare, weight: 1.0),
      // SR (12%)
      GachaItem(id: 'sr_alchemy_001', name: '희귀한 Recipe A', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_alchemy_002', name: '희귀한 Recipe B', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_alchemy_003', name: '희귀한 Recipe C', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_alchemy_004', name: '희귀한 Recipe D', rarity: GachaRarity.superRare, weight: 1.0),
      // R (35%)
      GachaItem(id: 'r_alchemy_001', name: '우수한 Recipe A', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_alchemy_002', name: '우수한 Recipe B', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_alchemy_003', name: '우수한 Recipe C', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_alchemy_004', name: '우수한 Recipe D', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_alchemy_005', name: '우수한 Recipe E', rarity: GachaRarity.rare, weight: 1.0),
      // N (50%)
      GachaItem(id: 'n_alchemy_001', name: '일반 Recipe A', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_alchemy_002', name: '일반 Recipe B', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_alchemy_003', name: '일반 Recipe C', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_alchemy_004', name: '일반 Recipe D', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_alchemy_005', name: '일반 Recipe E', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_alchemy_006', name: '일반 Recipe F', rarity: GachaRarity.normal, weight: 1.0),
    ];
  }

  /// 단일 뽑기
  Recipe? pullSingle() {
    final result = _gachaManager.pull(_poolId);
    if (result == null) return null;
    notifyListeners();
    return _convertToItem(result.item);
  }

  /// 10연차
  List<Recipe> pullTen() {
    final results = _gachaManager.multiPull(_poolId, count: 10);
    notifyListeners();
    return results.map((r) => _convertToItem(r.item)).toList();
  }

  Recipe _convertToItem(GachaItem item) {
    return Recipe(
      id: item.id,
      name: item.name,
      rarity: item.rarity,
    );
  }

  /// 천장까지 남은 횟수
  int get pullsUntilPity => _gachaManager.remainingPity(_poolId);

  /// 총 뽑기 횟수
  int get totalPulls => _gachaManager.getPityState(_poolId)?.totalPulls ?? 0;

  /// 통계
  GachaStats get stats => _gachaManager.getStats(_poolId);

  Map<String, dynamic> toJson() => _gachaManager.toJson();
  void loadFromJson(Map<String, dynamic> json) {
    _gachaManager.loadFromJson(json);
    notifyListeners();
  }
}
