/// Workshop World - 작업실 월드
///
/// 아이템 제작과 조합이 이루어지는 작업실 장면입니다.
library;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cat_alchemy/game/components/workshop/cauldron_component.dart';
import 'package:cat_alchemy/game/components/workshop/workbench_component.dart';
import 'package:cat_alchemy/game/components/game_button.dart';
import 'package:cat_alchemy/game/components/progress_bar.dart';
import 'package:cat_alchemy/game/flame/worlds/cat_alchemy_world.dart';

/// 작업실 월드
///
/// 제작 시스템의 중심이 되는 월드입니다.
class WorkshopWorld extends CatAlchemyWorld {
  // 작업실 컴포넌트들
  CauldronComponent? _cauldron;
  WorkbenchComponent? _workbench;
  ProgressBar? _craftingProgressBar;

  // 제작 상태
  bool _isCrafting = false;
  double _craftingProgress = 0.0;

  WorkshopWorld() : super('workshop');

  @override
  Future<void> onWorldLoad() async {
    // 작업실 특정 컴포넌트들 추가
    await _addWorkshopComponents();
  }

  /// 작업실 컴포넌트 추가
  Future<void> _addWorkshopComponents() async {
    // 가마솥 (카드 뽑기/제작)
    _cauldron = CauldronComponent(
      position: Vector2(300, 350),
    );
    await add(_cauldron!);

    // 작업대 (조합/강화)
    _workbench = WorkbenchComponent(
      position: Vector2(500, 350),
    );
    await add(_workbench!);

    // 제작 진행률 바
    _craftingProgressBar = ProgressBar(
      position: Vector2(300, 280),
      size: Vector2(400, 20),
      progress: 0.0,
    );
    await add(_craftingProgressBar!);

    // 작업실 UI 버튼들
    await _addWorkshopUI();
  }

  /// 작업실 UI 추가
  Future<void> _addWorkshopUI() async {
    // 홈으로 돌아가기 버튼
    final homeButton = GameButton(
      text: 'Home',
      position: Vector2(50, 50),
      size: Vector2(120, 40),
      onPressed: _onHomePressed,
    );
    await add(homeButton);

    // 수집 장소로 이동 버튼
    final gatherButton = GameButton(
      text: 'Gather Materials',
      position: Vector2(50, 100),
      size: Vector2(160, 40),
      onPressed: _onGatherPressed,
    );
    await add(gatherButton);
  }

  /// 홈 버튼 핸들러
  void _onHomePressed() {
    debugPrint('Navigate to home');
  }

  /// 수집 버튼 핸들러
  void _onGatherPressed() {
    debugPrint('Navigate to gathering');
  }

  /// 제작 시작
  void startCrafting() {
    _isCrafting = true;
    _craftingProgress = 0.0;
  }

  /// 제작 취소
  void cancelCrafting() {
    _isCrafting = false;
    _craftingProgress = 0.0;
    _craftingProgressBar?.progress = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 제작 진행률 업데이트
    if (_isCrafting && _craftingProgress < 1.0) {
      _craftingProgress += dt * 0.2; // 5초에 완료
      _craftingProgressBar?.progress = _craftingProgress;

      if (_craftingProgress >= 1.0) {
        _isCrafting = false;
        _craftingProgress = 0.0;
        // 제작 완료 처리
      }
    }
  }

  /// 가마솥 반환
  CauldronComponent? get cauldron => _cauldron;

  /// 작업대 반환
  WorkbenchComponent? get workbench => _workbench;

  /// 제작 중인지 확인
  bool get isCrafting => _isCrafting;

  /// 제작 진행률 반환
  double get craftingProgress => _craftingProgress;
}
