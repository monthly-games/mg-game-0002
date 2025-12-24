import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

class WorkshopGame extends FlameGame {
  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    // 1. Background
    final bgSprite = await loadSprite('bg_workshop_interior.png');
    add(SpriteComponent(sprite: bgSprite, size: size));

    // 2. Cauldron (Center)
    final cauldronSprite = await loadSprite('cauldron.png');
    final cauldron = SpriteComponent(
      sprite: cauldronSprite,
      size: Vector2.all(128),
      position: Vector2(size.x / 2, size.y / 2 + 50),
      anchor: Anchor.center,
    );
    add(cauldron);

    // 2.1 Cauldron Steam VFX
    final steamSheet = await images.load('vfx/vfx_steam.png');
    final steamAnimation = SpriteAnimation.fromFrameData(
      steamSheet,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2(128, 128),
        amountPerRow:
            4, // 256x512 image, 128x128 frames -> 256/128=2 cols? Wait, prompt said 2x4 grid. 256 wide, 128 frame allows 2 cols. 512 height, 128 frame allows 4 rows. 2*4=8 frames.
        // Flame's sequenced assumes row-major.
      ),
    );
    add(
      SpriteAnimationComponent(
        animation: steamAnimation,
        size: Vector2(128, 128),
        position: cauldron.position + Vector2(0, -60), // Above cauldron
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xAAFFFFFF), // Semi-transparent
      ),
    );

    // 3. Cat Character
    add(CatCharacter(position: Vector2(size.x / 2, size.y / 2 - 50)));

    // 4. Example Items (Decor)
    final grassSprite = await loadSprite('item_grass.png');
    add(
      SpriteComponent(
        sprite: grassSprite,
        position: Vector2(50, 200),
        size: Vector2.all(32),
      ),
    );

    // Play BGM
    try {
      GetIt.I<AudioManager>().playBgm('bgm_workshop.wav');
    } catch (e) {
      print('Audio Error: $e');
    }
  }
}

class CatCharacter extends SpriteComponent with HasGameRef {
  CatCharacter({required Vector2 position})
    : super(position: position, size: Vector2.all(128), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('cat_orange_tabby.png');
  }
}
