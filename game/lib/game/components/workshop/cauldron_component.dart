/// Cauldron Component - 가마솥 컴포넌트
///
/// 제작 시스템의 핵심 컴포넌트입니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

/// 가마솥 컴포넌트
///
/// 플레이어가 터치하여 제작을 시작할 수 있습니다.
class CauldronComponent extends SpriteComponent with TapCallbacks, HasGameReference {
  // 제작 상태
  bool _isCrafting = false;
  double _craftingProgress = 0.0;
  String? _currentRecipe;

  // 시각 효과
  late SpriteAnimationComponent _steamAnimation;

  CauldronComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(128),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 스프라이트 로드
    try {
      sprite = await game.loadSprite('cauldron.png');
    } catch (e) {
      debugPrint('Failed to load cauldron sprite: $e');
    }

    // 증기 애니메이션 추가
    _steamAnimation = await _createSteamAnimation();
    add(_steamAnimation);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    // 제작 시작/완료 처리
    if (_isCrafting) {
      // 제작 중일 때 진행도 표시
      debugPrint('Crafting in progress: $_craftingProgress%');
    } else {
      // 제작 시작
      _startCrafting();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 제작 진행
    if (_isCrafting) {
      _craftingProgress += dt * 10; // 10% per second

      if (_craftingProgress >= 100) {
        _completeCrafting();
      }
    }
  }

  /// 제작 시작
  void _startCrafting() {
    _isCrafting = true;
    _craftingProgress = 0.0;
    _currentRecipe = 'health_potion';
    debugPrint('Started crafting: $_currentRecipe');

    // 시각 효과 - 애니메이션 표시
    // 애니메이션 컴포넌트의 투명도 설정은 별도 처리 필요
  }

  /// 제작 완료
  void _completeCrafting() {
    _isCrafting = false;
    _craftingProgress = 0.0;
    debugPrint('Completed crafting: $_currentRecipe');

    // 보상 지급
    _grantRewards();
  }

  /// 보상 지급
  void _grantRewards() {
    // TODO: 실제 보상 지급 로직 구현
    debugPrint('Rewards granted!');
  }

  /// 증기 애니메이션 생성
  Future<SpriteAnimationComponent> _createSteamAnimation() async {
    try {
      final image = await game.images.load('vfx/vfx_steam.png');
      final animation = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.1,
          textureSize: Vector2.all(128),
        ),
      );

      final component = SpriteAnimationComponent(
        animation: animation,
        size: Vector2.all(128),
        position: Vector2(0, -60),
        anchor: Anchor.center,
      );
      component.opacity = 0.5;
      return component;
    } catch (e) {
      debugPrint('Failed to create steam animation: $e');
      rethrow;
    }
  }

  /// 현재 제작 중인지 확인
  bool get isCrafting => _isCrafting;

  /// 제작 진행도 반환
  double get craftingProgress => _craftingProgress;

  /// 현재 레시피 반환
  String? get currentRecipe => _currentRecipe;
}
