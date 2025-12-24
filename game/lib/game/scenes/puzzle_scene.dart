import 'package:flame/components.dart';
import 'package:flame/effects.dart'; // For ScaleEffect
import 'package:flame/events.dart';
import 'package:flame/particles.dart'; // For ParticleSystem
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math'; // For Random
import '../../core/models/recipe.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';

class PuzzleScene extends Component with HasGameRef<CatAlchemyGame> {
  final WidgetRef ref;
  final Recipe recipe;

  PuzzleScene(this.ref, this.recipe);

  // Constants
  static const double slotSize = 80.0;
  static const double spacing = 10.0;

  // State
  late List<List<String?>> _gridState;
  late int _rows;
  late int _cols;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initGrid();
    _setupUI();
  }

  void _initGrid() {
    int size = 3;
    if (recipe.tier >= 5) {
      size = 5;
    } else if (recipe.tier >= 3)
      size = 4;

    _rows = size;
    _cols = size;
    _gridState = List.generate(_rows, (i) => List.filled(_cols, null));
  }

  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Title
    add(
      TextComponent(
        text: 'Crafting: ${recipe.name}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
        ),
        position: Vector2(size.x / 2, 40),
        anchor: Anchor.center,
      ),
    );

    // Grid Background
    double gridWidth = _cols * slotSize + (_cols - 1) * spacing;
    Vector2 gridStart = Vector2((size.x - gridWidth) / 2, 120);

    // Draw Slots
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        Vector2 pos =
            gridStart +
            Vector2(c * (slotSize + spacing), r * (slotSize + spacing));
        add(
          PuzzleSlot(
            position: pos,
            size: Vector2(slotSize, slotSize),
            row: r,
            col: c,
          ),
        );
      }
    }

    // Required Ingredients & Pattern Hint
    if (recipe.pattern != null) {
      add(
        TextComponent(
          text: 'Pattern Required:',
          position: Vector2(50, 450),
          textRenderer: TextPaint(style: const TextStyle(color: Colors.black)),
        ),
      );

      double y = 480;
      for (var line in recipe.pattern!) {
        add(
          TextComponent(
            text: line.replaceAll(' ', '.').replaceAll('-', '.'),
            position: Vector2(50, y),
            textRenderer: TextPaint(
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 20,
                color: Colors.blueGrey,
              ),
            ),
          ),
        );
        y += 25;
      }
    }

    // Craft Button
    add(
      GameButton(
        text: 'Craft!',
        position: Vector2(size.x / 2, size.y - 80),
        size: Vector2(150, 50),
        onPressed: _tryCraft,
        backgroundColor: Colors.green,
      ),
    );

    // Cancel Button
    add(
      GameButton(
        text: 'Cancel',
        position: Vector2(80, size.y - 80),
        size: Vector2(100, 40),
        onPressed: () => gameRef.navigateTo('crafting'),
        backgroundColor: Colors.grey,
      ),
    );

    // Draggable Ingredients
    // Render available ingredients as draggable sources at the bottom
    double invX = 50;
    double invY = size.y - 150;

    // We only show ingredients relevant to this recipe for the MVP puzzle
    for (var ing in recipe.ingredients) {
      // Add label
      add(
        TextComponent(
          text: ing.id,
          position: Vector2(invX, invY - 20),
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
      );

      // Add Draggable Source
      add(
        IngredientSource(
          itemId: ing.id,
          position: Vector2(invX, invY),
          size: Vector2(60, 60),
        ),
      );

      invX += 80;
    }
  }

  void _tryCraft() {
    // Validate grid against pattern
    // ... same logic as before ...
    if (_validatePattern()) {
      // Success Effect
      _playSuccessEffect();

      // Slight delay to see effect before leaving
      add(
        TimerComponent(
          period: 1.0,
          removeOnFinish: true,
          onTick: () {
            final result = ref
                .read(craftingGameManagerProvider)
                .startCrafting(recipe);
            if (result.success) {
              gameRef.navigateTo('crafting');
            } else {
              print("Crafting failed: ${result.message}");
            }
          },
        ),
      );
    } else {
      print("Pattern mismatch!");
      // Failure Shake Effect (Simulated by print for now, or could shake grid)
    }
  }

  void _playSuccessEffect() {
    // Particle Explosion at center of grid
    final size = gameRef.size;
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 50,
          lifespan: 1.0,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(
              Random().nextDouble() * 200 - 100,
              -Random().nextDouble() * 400,
            ),
            position: Vector2(size.x / 2, size.y / 2), // Center
            child: CircleParticle(
              radius: 5,
              paint: Paint()..color = Colors.amber,
            ),
          ),
        ),
      ),
    );
  }

  bool _validatePattern() {
    if (recipe.pattern == null) return true;
    final pRows = recipe.pattern!.length;
    final pCols = recipe.pattern![0].length;
    for (int r = 0; r <= _rows - pRows; r++) {
      for (int c = 0; c <= _cols - pCols; c++) {
        if (_checkMatchAt(r, c)) return true;
      }
    }
    return false;
  }

  bool _checkMatchAt(int startR, int startC) {
    for (int r = 0; r < recipe.pattern!.length; r++) {
      String rowStr = recipe.pattern![r];
      for (int c = 0; c < rowStr.length; c++) {
        String char = rowStr[c];
        String? gridItem = _gridState[startR + r][startC + c];
        if (char == '-' || char == ' ') {
          if (gridItem != null && char == ' ') return false;
          continue;
        }
        int index = int.tryParse(char) ?? -1;
        if (index == -1) continue;
        if (index >= recipe.ingredients.length) return false;
        String requiredId = recipe.ingredients[index].id;
        if (gridItem != requiredId) return false;
      }
    }
    return true;
  }

  // API for Drag Items to interact with Grid
  void checkDrop(IngredientDragItem item) {
    // Find which slot we are dropped on
    for (final component in children) {
      if (component is PuzzleSlot) {
        if (component.toRect().contains(item.absoluteCenter.toOffset())) {
          // Valid Drop
          _placeItem(component.row, component.col, item.itemId);
          // Play Snap Animation
          component.playSnapEffect();
          item.removeFromParent(); // Consume item (simplification)
          return;
        }
      }
    }
    // If no hit, return to source? Or just destroy temp drag item
    item.removeFromParent();
  }

  void _placeItem(int row, int col, String itemId) {
    _gridState[row][col] = itemId;
    final slot = children.whereType<PuzzleSlot>().firstWhere(
      (s) => s.row == row && s.col == col,
    );
    slot.setItem(itemId);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      Paint()..color = const Color(0xFFF5E6D3),
    );
  }
}

class PuzzleSlot extends PositionComponent {
  final int row;
  final int col;
  String? currentItem;

  PuzzleSlot({
    required Vector2 position,
    required Vector2 size,
    required this.row,
    required this.col,
  }) : super(position: position, size: size);

  void setItem(String itemId) {
    currentItem = itemId;
  }

  void playSnapEffect() {
    // Enlarge and shrink back
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFD4B896)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(size.toRect(), paint);

    if (currentItem != null) {
      final textSpan = TextSpan(
        text: currentItem,
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.x);
      textPainter.paint(canvas, const Offset(5, 30));

      // Draw simple circle to represent item visually
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        20,
        Paint()..color = Colors.blueAccent.withOpacity(0.5),
      );
    }
  }
}

// Source component that spawns draggables
class IngredientSource extends PositionComponent
    with TapCallbacks, HasGameRef<CatAlchemyGame> {
  final String itemId;

  IngredientSource({
    required this.itemId,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    // Draw container
    canvas.drawRect(size.toRect(), Paint()..color = Colors.grey.shade400);
    // Draw item placeholder
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      20,
      Paint()..color = Colors.blue,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Spawn a drag item
    final dragItem = IngredientDragItem(
      itemId: itemId,
      position: position.clone(),
      size: size.clone(),
    );
    gameRef.add(dragItem); // Add to game ref to be top level
    dragItem.startDrag(event);
  }
}

class IngredientDragItem extends PositionComponent with DragCallbacks {
  final String itemId;

  IngredientDragItem({
    required this.itemId,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  void startDrag(TapDownEvent event) {
    // Initial offset logic if needed
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // Check drop
    if (parent is CatAlchemyGame) {
      // We need to find the PuzzleScene to check slots
      // This is a bit hacky, normally dragged item updates logic in parent
      // But DragItem is on Top Level Game, Puzzle is a child.
      final puzzle = (parent as CatAlchemyGame).children
          .whereType<PuzzleScene>()
          .firstOrNull;
      puzzle?.checkDrop(this);
    } else {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      25,
      Paint()..color = Colors.blue.withOpacity(0.8),
    );

    final textSpan = TextSpan(
      text: itemId,
      style: const TextStyle(color: Colors.white, fontSize: 10),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 20));
  }
}
