/// Cat Alchemy World - 게임 월드 컨테이너
///
/// Flame의 World 컴포넌트를 사용하여 게임 세계를 구성합니다.
library;

import 'package:flame/components.dart';
import 'package:cat_alchemy/game/components/player/cat_player.dart';
import 'package:cat_alchemy/game/components/background/background_component.dart';
import 'package:cat_alchemy/game/components/workshop/cauldron_component.dart';
import 'package:cat_alchemy/game/components/workshop/workbench_component.dart';

/// Cat Alchemy 게임 월드
///
/// 각 월드는 게임의 다른 장소/상태를 나타냅니다:
/// - home: 메인 화면
/// - workshop: 작업실 (제작)
/// - gathering: 재료 수집 장소
/// - shop: 상점
/// - inventory: 인벤토리
class CatAlchemyWorld extends World {
  final String worldName;

  // 플레이어 컴포넌트
  late CatPlayer _player;

  // 월드별 컴포넌트들
  final List<Component> _worldComponents = [];

  CatAlchemyWorld(this.worldName);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 배경 추가
    await _addBackground();

    // 플레이어 추가
    _player = CatPlayer(position: Vector2(100, 300));
    await add(_player);

    // 월드별 컴포넌트 추가
    await _addWorldComponents();
  }

  /// 배경 컴포넌트 추가
  Future<void> _addBackground() async {
    final background = BackgroundComponent(worldName);
    await add(background);
  }

  /// 월드별 컴포넌트 추가
  Future<void> _addWorldComponents() async {
    switch (worldName) {
      case 'home':
        // 홈 화면 컴포넌트들
        break;

      case 'workshop':
        // 작업실 컴포넌트들
        final cauldron = CauldronComponent(
          position: Vector2(400, 300),
        );
        await add(cauldron);
        _worldComponents.add(cauldron);

        final workbench = WorkbenchComponent(
          position: Vector2(600, 300),
        );
        await add(workbench);
        _worldComponents.add(workbench);
        break;

      case 'gathering':
        // 재료 수집 장소 컴포넌트들
        break;

      case 'shop':
        // 상점 컴포넌트들
        break;

      case 'inventory':
        // 인벤토리 컴포넌트들
        break;
    }
  }

  /// 플레이어 반환
  CatPlayer get player => _player;

  /// 월드 컴포넌트들 반환
  List<Component> get worldComponents => List.unmodifiable(_worldComponents);
}
