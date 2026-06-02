/// Cat Alchemy Workshop - Flame Engine Architecture
///
/// 이 파일은 Flame 엔진의 구조에 맞춰 게임을 재구성합니다.
library;

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:cat_alchemy/game/flame/worlds/cat_alchemy_world.dart';
import 'package:cat_alchemy/game/flame/worlds/home_world.dart';
import 'package:cat_alchemy/game/flame/worlds/workshop_world.dart';
import 'package:cat_alchemy/game/flame/worlds/gathering_world.dart';
import 'package:cat_alchemy/game/flame/worlds/shop_world.dart';
import 'package:cat_alchemy/game/flame/worlds/inventory_world.dart';
import 'package:cat_alchemy/game/components/ui/hud_component.dart';
import 'package:cat_alchemy/game/components/ui/menu_button_component.dart';
import 'package:cat_alchemy/game/flame/components/ui/battlepass_overlay_component.dart';
import 'package:cat_alchemy/game/flame/components/ui/leaderboard_overlay_component.dart';
import 'package:cat_alchemy/game/flame/components/ui/event_overlay_component.dart';
import 'package:cat_alchemy/game/managers/game_manager.dart';
import 'package:cat_alchemy/game/managers/input_manager.dart';
import 'package:cat_alchemy/features/battlepass/cat_alchemy_battle_pass.dart';
import 'package:cat_alchemy/features/social/cat_alchemy_leaderboards.dart';
import 'package:cat_alchemy/events/cat_alchemy_live_ops_manager.dart';

/// 메인 게임 클래스 - FlameGame을 상속받아 게임 루프를 관리합니다.
///
/// Flame 엔진의 핵심 구조:
/// 1. FlameGame: 게임의 루트 컴포넌트, 게임 루프 관리
/// 2. World: 게임 월드 컨테이너 (Camera와 함께 사용)
/// 3. Components: 게임 객체들 (SpriteComponent, PositionComponent 등)
/// 4. FCS (Flame Component System): 컴포넌트 기반 아키텍처
class CatAlchemyFlameGame extends FlameGame
    with HasGameReference, TapCallbacks {

  // 게임 상태 관리자
  late GameManager _gameManager;
  late InputManager _inputManager;

  // 현재 월드
  CatAlchemyWorld? _currentWorld;

  // HUD 컴포넌트
  HudComponent? _hud;

  // 메뉴 상태
  bool _isMenuVisible = true;

  // 게임 시스템
  late CatAlchemyBattlePass _battlePass;
  late CatAlchemyLeaderboards _leaderboards;
  late CatAlchemyLiveOpsManager _liveOpsManager;

  // 오버레이 컴포넌트
  BattlePassOverlayComponent? _battlePassOverlay;
  LeaderboardOverlayComponent? _leaderboardOverlay;
  EventOverlayComponent? _eventOverlay;

  @override
  Color backgroundColor() => const Color(0xFF1a2332);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 매니저 초기화
    _gameManager = GameManager();
    _inputManager = InputManager();

    add(_gameManager);
    add(_inputManager);

    // 게임 시스템 초기화
    _battlePass = CatAlchemyBattlePass();
    _leaderboards = CatAlchemyLeaderboards();
    _liveOpsManager = CatAlchemyLiveOpsManager();

    // 리더보드 초기화 (데모용 사용자 ID)
    await _leaderboards.initialize('demo_user_001');

    // 초기 월드 로드
    await loadWorld('home');

    // HUD 추가 (고정된 UI 요소)
    _hud = HudComponent();
    add(_hud!);

    // 메뉴 버튼 추가
    add(MenuButtonComponent(
      position: Vector2(20, 20),
      onTap: _toggleMenu,
    ));

    // 게임 시스템 오버레이 추가
    _addSystemOverlays();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 게임 상태 업데이트
    _gameManager.update(dt);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    // 입력 처리
    if (!_isMenuVisible) {
      _inputManager.handleTap(event.canvasPosition);
    }
  }

  /// 월드 로드
  Future<void> loadWorld(String worldName) async {
    // 기존 월드 제거
    if (_currentWorld != null) {
      remove(_currentWorld!);
    }

    // 새 월드 생성 및 추가
    _currentWorld = _createWorld(worldName);
    await add(_currentWorld!);

    // 카메라가 새 월드를 바라보도록 설정
    camera.follow(_currentWorld!.player);
  }

  /// 월드 생성
  CatAlchemyWorld _createWorld(String worldName) {
    switch (worldName) {
      case 'home':
        return HomeWorld();
      case 'workshop':
        return WorkshopWorld();
      case 'gathering':
        return GatheringWorld();
      case 'shop':
        return ShopWorld();
      case 'inventory':
        return InventoryWorld();
      default:
        return HomeWorld();
    }
  }

  /// 메뉴 토글
  void _toggleMenu() {
    _isMenuVisible = !_isMenuVisible;
    _hud?.setVisible(_isMenuVisible);
  }

  /// 현재 월드 반환
  CatAlchemyWorld? get currentWorld => _currentWorld;

  /// 게임 매니저 반환
  GameManager get gameManager => _gameManager;

  /// 입력 매니저 반환
  InputManager get inputManager => _inputManager;

  /// 메뉴 상태 반환
  bool get isMenuVisible => _isMenuVisible;

  /// 게임 시스템 오버레이 추가
  void _addSystemOverlays() {
    final screenSize = size;

    // 배틀패스 오버레이 (우측 상단)
    _battlePassOverlay = BattlePassOverlayComponent(
      battlePass: _battlePass,
      position: Vector2(screenSize.x - 220, 20),
    );
    add(_battlePassOverlay!);

    // 리더보드 오버레이 (우측 중앙)
    _leaderboardOverlay = LeaderboardOverlayComponent(
      leaderboards: _leaderboards,
      position: Vector2(screenSize.x - 200, 100),
    );
    add(_leaderboardOverlay!);

    // 이벤트 오버레이 (좌측 상단)
    _eventOverlay = EventOverlayComponent(
      liveOpsManager: _liveOpsManager,
      position: Vector2(20, 70),
    );
    add(_eventOverlay!);
  }

  /// 배틀패스 참조
  CatAlchemyBattlePass get battlePass => _battlePass;

  /// 리더보드 참조
  CatAlchemyLeaderboards get leaderboards => _leaderboards;

  /// 라이브 옵스 매니저 참조
  CatAlchemyLiveOpsManager get liveOpsManager => _liveOpsManager;
}
