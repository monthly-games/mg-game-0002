/// Input Manager - 입력 관리자
///
/// 사용자 입력을 처리하고 게임에 전달하는 컴포넌트입니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// 입력 매니저 컴포넌트
///
/// Flame의 Component와 TapCallbacks를 사용하여 입력을 관리합니다.
class InputManager extends Component with TapCallbacks {
  // 입력 상태
  final List<Vector2> _tapPositions = [];

  // 입력 리스너들
  final List<void Function(Vector2)> _tapListeners = [];

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    // 터치 위치 기록
    _tapPositions.add(event.canvasPosition);

    // 리스너들에게 알림
    for (final listener in _tapListeners) {
      listener(event.canvasPosition);
    }

    // 너무 많은 위치 기록 제거
    if (_tapPositions.length > 100) {
      _tapPositions.removeAt(0);
    }
  }

  /// 터치 처리
  void handleTap(Vector2 position) {
    _tapPositions.add(position);

    for (final listener in _tapListeners) {
      listener(position);
    }
  }

  /// 터치 리스너 추가
  void addTapListener(void Function(Vector2) listener) {
    _tapListeners.add(listener);
  }

  /// 터치 리스너 제거
  void removeTapListener(void Function(Vector2) listener) {
    _tapListeners.remove(listener);
  }

  /// 마지막 터치 위치 반환
  Vector2? get lastTapPosition =>
      _tapPositions.isEmpty ? null : _tapPositions.last;
}
