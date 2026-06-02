/// Game Manager - 게임 상태 관리자
///
/// 게임의 전체적인 상태를 관리하는 컴포넌트입니다.
library;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

/// 게임 매니저 컴포넌트
///
/// Flame의 Component를 상속받아 게임 상태를 관리합니다.
class GameManager extends Component {
  // 게임 상태
  int _level = 1;
  double _experience = 0.0;
  int _gold = 1000;
  int _gems = 50;

  // 연결된 매니저
  // InputManager? _inputManager; // TODO: Implement input manager integration

  // @override
  // void onMount() {
  //   super.onMount();
  //
  //   // 다른 매니저들 참조 찾기
  //   _inputManager = parent?.children.whereType<InputManager>().firstOrNull;
  // }

  /// 경험치 추가
  void addExperience(double amount) {
    _experience += amount;

    // 레벨업 체크
    final requiredExp = _getRequiredExperience();
    if (_experience >= requiredExp) {
      _levelUp();
    }
  }

  /// 골드 추가
  void addGold(int amount) {
    _gold += amount;
  }

  /// 보석 추가
  void addGems(int amount) {
    _gems += amount;
  }

  /// 레벨업
  void _levelUp() {
    _level++;
    _experience = 0;
    debugPrint('Level up! Now level $_level');
  }

  /// 필요 경험치 계산
  double _getRequiredExperience() {
    return _level * 100.0;
  }

  /// 현재 레벨 반환
  int get level => _level;

  /// 현재 경험치 반환
  double get experience => _experience;

  /// 현재 골드 반환
  int get gold => _gold;

  /// 현재 보석 반환
  int get gems => _gems;

  // /// 입력 매니저 설정
  // void setInputManager(InputManager manager) {
  //   _inputManager = manager;
  // }
}
