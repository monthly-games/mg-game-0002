import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class WorkshopGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF222222); // Dark background

  @override
  Future<void> onLoad() async {
    // 1. Background Placeholder (Workshop Floor)
    add(
      RectangleComponent(
        position: Vector2(0, size.y * 0.3),
        size: Vector2(size.x, size.y * 0.7),
        paint: BasicPalette.darkGray.paint(),
      ),
    );

    // 2. Cauldron (Center)
    add(
      CircleComponent(
        radius: 40,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        paint: BasicPalette.purple.withAlpha(200).paint(),
      ),
    );

    // 3. Cat (Placeholder)
    add(CatCharacter(position: Vector2(size.x / 2 + 60, size.y / 2 + 20)));
  }
}

class CatCharacter extends PositionComponent {
  CatCharacter({required Vector2 position})
    : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Cat Body
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      16,
      BasicPalette.orange.paint(),
    );
    // Ears
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(10, -10)
      ..lineTo(20, 0);
    canvas.drawPath(path, BasicPalette.orange.paint());
  }

  // TODO: Add movement logic
}
