/// Home World - 메인 홈 화면 월드
///
/// 게임의 메인 메뉴와 홈 화면을 표시합니다.
library;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:cat_alchemy/game/components/game_button.dart';
import 'package:cat_alchemy/game/flame/worlds/cat_alchemy_world.dart';

/// 홈 월드
///
/// 게임 시작 시 첫 번째로 표시되는 월드입니다.
class HomeWorld extends CatAlchemyWorld {
  // 홈 화면 UI 버튼들
  GameButton? _playButton;
  GameButton? _shopButton;
  GameButton? _inventoryButton;

  HomeWorld() : super('home');

  @override
  Future<void> onWorldLoad() async {
    // 홈 화면 특정 컴포넌트들 추가
    await _addHomeUI();
  }

  /// 홈 화면 UI 추가
  Future<void> _addHomeUI() async {
    // 플레이 버튼 (작업실로 이동)
    _playButton = GameButton(
      text: 'Start Crafting',
      position: Vector2(400, 300),
      size: Vector2(200, 60),
      onPressed: _onPlayPressed,
    );
    await add(_playButton!);

    // 상점 버튼
    _shopButton = GameButton(
      text: 'Shop',
      position: Vector2(400, 380),
      size: Vector2(200, 60),
      onPressed: _onShopPressed,
    );
    await add(_shopButton!);

    // 인벤토리 버튼
    _inventoryButton = GameButton(
      text: 'Inventory',
      position: Vector2(400, 460),
      size: Vector2(200, 60),
      onPressed: _onInventoryPressed,
    );
    await add(_inventoryButton!);

    // 홈 화면 타이틀 효과
    _addTitleEffect();
  }

  /// 플레이 버튼 핸들러
  void _onPlayPressed() {
    // 게임 매니저를 통해 작업실 월드로 전환
    debugPrint('Navigate to workshop');
  }

  /// 상점 버튼 핸들러
  void _onShopPressed() {
    debugPrint('Navigate to shop');
  }

  /// 인벤토리 버튼 핸들러
  void _onInventoryPressed() {
    debugPrint('Navigate to inventory');
  }

  /// 타이틀 효과 추가
  void _addTitleEffect() {
    // 홈 화면 분위기를 위한 간단한 효과
    // 실제 구현에서는 스프라이트나 파티클 효과 추가
  }

  /// 플레이 버튼 반환
  GameButton? get playButton => _playButton;

  /// 상점 버튼 반환
  GameButton? get shopButton => _shopButton;

  /// 인벤토리 버튼 반환
  GameButton? get inventoryButton => _inventoryButton;
}
