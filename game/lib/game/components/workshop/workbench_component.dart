/// Workbench Component - 작업대 컴포넌트
///
/// 플레이어가 터치하여 레시피를 확인하거나 업그레이드할 수 있습니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

/// 작업대 컴포넌트
class WorkbenchComponent extends SpriteComponent with TapCallbacks, HasGameReference {
  // 레시피 상태
  int _unlockedRecipes = 0;

  WorkbenchComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(96),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 스프라이트 로드
    try {
      sprite = await game.loadSprite('workbench.png');
    } catch (e) {
      debugPrint('Failed to load workbench sprite: $e');
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    // 레시피 화면 표시
    _showRecipeMenu();
  }

  /// 레시피 메뉴 표시
  void _showRecipeMenu() {
    debugPrint('Showing recipe menu...');
    debugPrint('Unlocked recipes: $_unlockedRecipes');
  }

  /// 레시피 추가
  void unlockRecipe() {
    _unlockedRecipes++;
    debugPrint('New recipe unlocked! Total: $_unlockedRecipes');
  }

  /// 해금 레시피 수 반환
  int get unlockedRecipes => _unlockedRecipes;
}
