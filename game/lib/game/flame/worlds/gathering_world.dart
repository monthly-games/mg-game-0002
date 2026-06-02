/// Gathering World - 재료 수집 월드
///
/// 다양한 장소에서 재료를 수집하는 월드입니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:cat_alchemy/game/components/game_button.dart';
import 'package:cat_alchemy/game/flame/worlds/cat_alchemy_world.dart';

/// 수집 월드
///
/// 플레이어가 다양한 장소를 탐험하며 재료를 수집합니다.
class GatheringWorld extends CatAlchemyWorld {
  // 수집 포인트들
  final List<GatheringPoint> _gatheringPoints = [];

  // 수집된 재료
  final Map<String, int> _gatheredMaterials = {};

  GatheringWorld() : super('gathering');

  @override
  Future<void> onWorldLoad() async {
    // 수집 장소 컴포넌트들 추가
    await _addGatheringPoints();
    await _addGatheringUI();
  }

  /// 수집 포인트 추가
  Future<void> _addGatheringPoints() async {
    // 숲 수집 포인트
    final forestPoint = GatheringPoint(
      type: GatheringType.forest,
      position: Vector2(200, 250),
      onGather: () => _gatherMaterial('herb', 1),
    );
    await add(forestPoint);
    _gatheringPoints.add(forestPoint);

    // 광산 수집 포인트
    final minePoint = GatheringPoint(
      type: GatheringType.mine,
      position: Vector2(400, 250),
      onGather: () => _gatherMaterial('ore', 1),
    );
    await add(minePoint);
    _gatheringPoints.add(minePoint);

    // 마을 수집 포인트
    final villagePoint = GatheringPoint(
      type: GatheringType.village,
      position: Vector2(600, 250),
      onGather: () => _gatherMaterial('cloth', 1),
    );
    await add(villagePoint);
    _gatheringPoints.add(villagePoint);
  }

  /// 수집 UI 추가
  Future<void> _addGatheringUI() async {
    // 작업실로 돌아가기 버튼
    final workshopButton = GameButton(
      text: 'Back to Workshop',
      position: Vector2(50, 50),
      size: Vector2(160, 40),
      onPressed: _onWorkshopPressed,
    );
    await add(workshopButton);

    // 홈으로 버튼
    final homeButton = GameButton(
      text: 'Home',
      position: Vector2(50, 100),
      size: Vector2(120, 40),
      onPressed: _onHomePressed,
    );
    await add(homeButton);
  }

  /// 작업실 버튼 핸들러
  void _onWorkshopPressed() {
    debugPrint('Navigate to workshop');
  }

  /// 홈 버튼 핸들러
  void _onHomePressed() {
    debugPrint('Navigate to home');
  }

  /// 재료 수집
  void _gatherMaterial(String materialType, int amount) {
    _gatheredMaterials[materialType] =
        (_gatheredMaterials[materialType] ?? 0) + amount;
    debugPrint('Gathered $amount $materialType');
  }

  /// 수집된 재료 반환
  Map<String, int> get gatheredMaterials =>
      Map.unmodifiable(_gatheredMaterials);

  /// 수집 포인트들 반환
  List<GatheringPoint> get gatheringPoints =>
      List.unmodifiable(_gatheringPoints);
}

/// 수집 포인트 컴포넌트
class GatheringPoint extends PositionComponent with TapCallbacks {
  final GatheringType type;
  final VoidCallback onGather;

  // 수집 쿨다운
  double _cooldown = 0.0;
  static const double _cooldownTime = 3.0;

  GatheringPoint({
    required this.type,
    required Vector2 position,
    required this.onGather,
  }) : super(
          position: position,
          size: Vector2.all(80),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 수집 포인트 시각적 표시 (실제 구현에서는 스프라이트 추가)
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 쿨다운 업데이트
    if (_cooldown > 0) {
      _cooldown -= dt;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    // 쿨다운 중이 아니면 수집 실행
    if (_cooldown <= 0) {
      onGather();
      _cooldown = _cooldownTime;
    }
  }

  /// 수집 가능한지 확인
  bool get canGather => _cooldown <= 0;

  /// 쿨다운 상태 반환
  double get cooldown => _cooldown;
}

/// 수집 장소 타입
enum GatheringType {
  forest,
  mine,
  village,
  lake,
}
