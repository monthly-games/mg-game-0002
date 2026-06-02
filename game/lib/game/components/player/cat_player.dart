/// Cat Player - 플레이어 컴포넌트
///
/// Flame의 SpriteComponent와 TapCallbacks를 사용하여
/// 플레이어 캐릭터를 구현합니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

/// 고양이 플레이어 컴포넌트
///
/// FCS (Flame Component System)의 예시로,
/// 컴포넌트 기반으로 플레이어를 구현합니다.
class CatPlayer extends SpriteComponent with TapCallbacks, HasGameReference {
  // 플레이어 상태
  double _speed = 200.0;
  Vector2 _targetPosition = Vector2.zero();
  bool _isMoving = false;

  // 애니메이션
  SpriteAnimationComponent? _animationComponent;

  CatPlayer({required Vector2 position})
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
      sprite = await game.loadSprite('cat_orange_tabby.png');
    } catch (e) {
      // 스프라이트 로드 실패시 기본 형태 사용
      debugPrint('Failed to load cat sprite: $e');
    }

    // 애니메이션 컴포넌트 추가 (필요시)
    _animationComponent = SpriteAnimationComponent(
      animation: await _createIdleAnimation(),
      size: size,
      anchor: anchor,
    );
    add(_animationComponent!);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 이동 처리
    if (_isMoving) {
      final direction = _targetPosition - position;
      final distance = direction.length;

      if (distance < 5) {
        // 목표 지점 도달
        position = _targetPosition;
        _isMoving = false;
      } else {
        // 이동
        position += direction.normalized() * _speed * dt;
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    // 플레이어 터치 시 처리
    debugPrint('Cat tapped at ${event.canvasPosition}');
    _playTapAnimation();
  }

  /// 이동 설정
  void moveTo(Vector2 targetPosition) {
    _targetPosition = targetPosition;
    _isMoving = true;
  }

  /// 속도 설정
  void setSpeed(double speed) {
    _speed = speed;
  }

  /// 터치 애니메이션 재생
  void _playTapAnimation() {
    // 간단한 애니메이션 효과
    final originalSize = size.clone();
    size *= 1.2;

    Future.delayed(const Duration(milliseconds: 100), () {
      size = originalSize;
    });
  }

  /// 대기 애니메이션 생성
  Future<SpriteAnimation> _createIdleAnimation() async {
    // 스프라이트 시트에서 애니메이션 생성
    try {
      final image = await game.images.load('cat_idle.png');
      return SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2.all(128),
        ),
      );
    } catch (e) {
      // 애니메이션 로드 실패시 빈 애니메이션 반환
      debugPrint('Failed to load idle animation: $e');
      rethrow;
    }
  }

  /// 현재 이동 중인지 확인
  bool get isMoving => _isMoving;

  /// 현재 속도 반환
  double get speed => _speed;
}
