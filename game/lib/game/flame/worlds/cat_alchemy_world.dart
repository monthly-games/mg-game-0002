/// Cat Alchemy Base World - 게임 월드 기본 클래스
///
/// 모든 월드가 상속받는 기반 월드 클래스입니다.
library;

import 'package:flame/components.dart';
import 'package:cat_alchemy/game/components/player/cat_player.dart';
import 'package:cat_alchemy/game/components/background/background_component.dart';

/// Cat Alchemy 게임 월드 기본 클래스
///
/// 각 월드는 게임의 다른 장소/상태를 나타냅니다:
/// - home: 메인 화면
/// - workshop: 작업실 (제작)
/// - gathering: 재료 수집 장소
/// - shop: 상점
/// - inventory: 인벤토리
abstract class CatAlchemyWorld extends World {
  final String worldName;

  // 플레이어 컴포넌트
  late CatPlayer _player;

  CatAlchemyWorld(this.worldName);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 배경 추가
    await _addBackground();

    // 플레이어 추가
    _player = CatPlayer(position: Vector2(100, 300));
    await add(_player);

    // 월드별 컴포넌트 추가 (하위 클래스에서 구현)
    await onWorldLoad();
  }

  /// 배경 컴포넌트 추가
  Future<void> _addBackground() async {
    final background = BackgroundComponent(worldName);
    await add(background);
  }

  /// 월드별 컴포넌트 추가 (하위 클래스에서 오버라이드)
  Future<void> onWorldLoad();

  /// 플레이어 반환
  CatPlayer get player => _player;
}
