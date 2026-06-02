/// HUD Component - Heads-Up Display 컴포넌트
///
/// 게임의 UI를 표시하는 컴포넌트입니다.
library;

import 'package:flame/components.dart';
import 'package:cat_alchemy/game/components/ui/resource_display_component.dart';

/// HUD 컴포넌트
///
/// 리소스 표시, 메뉴 버튼 등 고정 UI 요소들을 관리합니다.
class HudComponent extends PositionComponent with HasGameReference {
  // 리소스 디스플레이
  ResourceDisplayComponent? _goldDisplay;
  ResourceDisplayComponent? _gemDisplay;

  // 표시 상태
  bool _isVisible = true;

  HudComponent() : super(position: Vector2.zero());

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 리소스 디스플레이 추가
    _goldDisplay = ResourceDisplayComponent(
      resourceName: 'Gold',
      position: Vector2(20, 60),
    );
    add(_goldDisplay!);

    _gemDisplay = ResourceDisplayComponent(
      resourceName: 'Gems',
      position: Vector2(20, 100),
    );
    add(_gemDisplay!);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 리소스 업데이트
    if (_isVisible) {
      _goldDisplay?.updateValue(_getGoldAmount());
      _gemDisplay?.updateValue(_getGemAmount());
    }
  }

  /// 표시 상태 설정
  void setVisible(bool visible) {
    _isVisible = visible;
    // Component의 opacity는 PositionComponent에서 사용 가능
    // isVisible 상태에 따라 render에서 표시 여부 결정
  }

  /// 골드 얻기 (데모용)
  int _getGoldAmount() => 1000;

  /// 보석 얻기 (데모용)
  int _getGemAmount() => 50;
}
