/// Background Component - 배경 컴포넌트
///
/// 월드별 배경을 표시하는 컴포넌트입니다.
library;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

/// 배경 컴포넌트
///
/// Flame의 PositionComponent를 상속받아 배경을 구현합니다.
class BackgroundComponent extends PositionComponent with HasGameReference {
  final String worldName;
  SpriteComponent? _backgroundSprite;

  BackgroundComponent(this.worldName);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 월드별 배경 로드
    final imageName = _getBackgroundImage();
    try {
      final sprite = await game.loadSprite(imageName);
      _backgroundSprite = SpriteComponent(
        sprite: sprite,
        size: game.size,
        position: Vector2.zero(),
      );
      add(_backgroundSprite!);
    } catch (e) {
      // 배경 로드 실패시 기본 색상 사용
      debugPrint('Failed to load background: $e');
    }
  }

  /// 월드별 배경 이미지 반환
  String _getBackgroundImage() {
    switch (worldName) {
      case 'home':
        return 'bg_home.png';
      case 'workshop':
        return 'bg_workshop_interior.png';
      case 'gathering':
        return 'bg_gathering.png';
      case 'shop':
        return 'bg_shop.png';
      case 'inventory':
        return 'bg_inventory.png';
      default:
        return 'bg_default.png';
    }
  }

  /// 배경 변경
  Future<void> changeBackground(String worldName) async {
    if (_backgroundSprite != null) {
      remove(_backgroundSprite!);
    }

    final imageName = _getBackgroundImage();
    try {
      final sprite = await game.loadSprite(imageName);
      _backgroundSprite = SpriteComponent(
        sprite: sprite,
        size: game.size,
        position: Vector2.zero(),
      );
      add(_backgroundSprite!);
    } catch (e) {
      debugPrint('Failed to change background: $e');
    }
  }
}
