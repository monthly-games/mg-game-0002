import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/material.dart' as game_material;
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../components/progress_bar.dart';
import '../cat_alchemy_game.dart';

/// Gathering scene - material collection with mini-game
class GatheringScene extends Component with HasGameRef {
  final WidgetRef ref;

  // Gathering state
  bool _isGathering = false;
  double _gatherProgress = 0.0;
  final double _gatherDuration = 2.0; // 2 seconds per gather
  game_material.Material? _selectedMaterial;
  List<game_material.Material> _availableMaterials = [];

  // UI Components
  late TextComponent _titleText;
  late GameButton _backButton;
  late ProgressBar _gatherProgressBar;
  final List<GatheringNode> _gatheringNodes = [];

  // Random for material spawning
  final Random _random = Random();

  GatheringScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadMaterials();
    await _setupUI();
    _spawnGatheringNodes();
  }

  /// Load available materials
  Future<void> _loadMaterials() async {
    final materialsAsync = ref.read(unlockedMaterialsProvider);
    await materialsAsync.when(
      data: (materials) {
        // Only idle-produced materials can be gathered
        _availableMaterials = materials
            .where((m) => m.isIdleProduced && m.tier <= 2) // Tier 1-2 for manual gathering
            .toList();
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Title
    _titleText = TextComponent(
      text: 'Gathering - Collect Materials',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E8B57), // Sea green
        ),
      ),
      position: Vector2(size.x / 2, 40),
      anchor: Anchor.center,
    );
    add(_titleText);

    // Back button
    _backButton = GameButton(
      text: '← Back',
      onPressed: _goBack,
      position: Vector2(80, 40),
      size: Vector2(120, 50),
    );
    add(_backButton);

    // Gathering progress bar (hidden initially)
    _gatherProgressBar = ProgressBar(
      position: Vector2(size.x / 2 - 200, size.y - 100),
      size: Vector2(400, 30),
      progress: 0.0,
      fillColor: const Color(0xFF32CD32), // Lime green
    );
    // Don't add yet - only show when gathering
  }

  /// Spawn gathering nodes on the field
  void _spawnGatheringNodes() {
    final size = gameRef.size;

    // Spawn 6-8 nodes in gathering area
    final nodeCount = 6 + _random.nextInt(3);

    for (int i = 0; i < nodeCount; i++) {
      if (_availableMaterials.isEmpty) break;

      // Random material
      final material = _availableMaterials[_random.nextInt(_availableMaterials.length)];

      // Random position in gathering area (center of screen)
      final x = 150 + _random.nextDouble() * (size.x - 300);
      final y = 150 + _random.nextDouble() * (size.y - 300);

      final node = GatheringNode(
        material: material,
        position: Vector2(x, y),
        onTap: () => _startGathering(material),
      );

      _gatheringNodes.add(node);
      add(node);
    }
  }

  /// Start gathering a material
  void _startGathering(game_material.Material material) {
    if (_isGathering) return; // Already gathering

    _isGathering = true;
    _gatherProgress = 0.0;
    _selectedMaterial = material;

    // Show progress bar
    if (!_gatherProgressBar.isMounted) {
      add(_gatherProgressBar);
    }
  }

  /// Complete gathering
  void _completeGathering() {
    if (_selectedMaterial == null) return;

    // Calculate amount (1-3 based on tier)
    final amount = 1 + _random.nextInt(_selectedMaterial!.tier);

    // Add to inventory
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    gameStateNotifier.addToInventory(_selectedMaterial!.id, amount);

    // Show feedback
    _showGatherMessage('+$amount ${_selectedMaterial!.name}');

    // Reset gathering state
    _isGathering = false;
    _gatherProgress = 0.0;
    _selectedMaterial = null;

    // Remove progress bar
    if (_gatherProgressBar.isMounted) {
      remove(_gatherProgressBar);
    }

    // Respawn nodes occasionally
    if (_random.nextDouble() < 0.3) {
      _respawnNode();
    }
  }

  /// Respawn a random node
  void _respawnNode() {
    if (_availableMaterials.isEmpty) return;

    final size = gameRef.size;
    final material = _availableMaterials[_random.nextInt(_availableMaterials.length)];

    final x = 150 + _random.nextDouble() * (size.x - 300);
    final y = 150 + _random.nextDouble() * (size.y - 300);

    final node = GatheringNode(
      material: material,
      position: Vector2(x, y),
      onTap: () => _startGathering(material),
    );

    _gatheringNodes.add(node);
    add(node);
  }

  /// Show temporary gather message
  void _showGatherMessage(String message) {
    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF32CD32), // Lime green
          shadows: [
            Shadow(
              color: Colors.white,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: gameRef.size / 2 + Vector2(0, -100),
      anchor: Anchor.center,
    );

    add(messageText);

    // Fade out and remove after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (messageText.isMounted) {
        remove(messageText);
      }
    });
  }

  /// Go back to home scene
  void _goBack() {
    if (gameRef is CatAlchemyGame) {
      (gameRef as CatAlchemyGame).navigateTo('home');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update gathering progress
    if (_isGathering) {
      _gatherProgress += dt / _gatherDuration;

      if (_gatherProgress >= 1.0) {
        _gatherProgress = 1.0;
        _completeGathering();
      }

      _gatherProgressBar.progress = _gatherProgress;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background - nature scene
    final size = gameRef.size;

    // Sky gradient
    final skyGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF87CEEB), // Sky blue
          const Color(0xFFADD8E6), // Light blue
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      skyGradient,
    );

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 200, size.x, 200),
      Paint()..color = const Color(0xFF8FBC8F), // Dark sea green
    );

    // Gathering instructions (if not gathering)
    if (!_isGathering) {
      final instructionPaint = TextPaint(
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF2F4F4F), // Dark slate gray
          shadows: [
            Shadow(
              color: Colors.white,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );

      instructionPaint.render(
        canvas,
        'Click on materials to gather them!',
        Vector2(size.x / 2, size.y - 50),
        anchor: Anchor.center,
      );
    }
  }
}

/// Gathering node - represents a material on the field
class GatheringNode extends PositionComponent with TapCallbacks {
  final game_material.Material material;
  final VoidCallback onTap;

  bool _isHovered = false;
  double _bobOffset = 0.0;
  final Random _random = Random();

  GatheringNode({
    required this.material,
    required Vector2 position,
    required this.onTap,
  }) : super(
          position: position,
          size: Vector2.all(60),
          anchor: Anchor.center,
        ) {
    _bobOffset = _random.nextDouble() * 2 * pi; // Random start phase
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Gentle bobbing animation
    _bobOffset += dt * 2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Apply bobbing
    final bobY = sin(_bobOffset) * 5;

    // Node background (glowing circle)
    final glowRadius = _isHovered ? 35.0 : 30.0;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2 + bobY),
      glowRadius,
      Paint()
        ..color = _getMaterialColor().withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2 + bobY),
      glowRadius - 5,
      Paint()..color = _getMaterialColor().withOpacity(0.6),
    );

    // Material icon (emoji placeholder)
    final iconPaint = TextPaint(
      style: TextStyle(
        fontSize: _isHovered ? 36 : 32,
      ),
    );

    iconPaint.render(
      canvas,
      _getMaterialIcon(),
      Vector2(size.x / 2, size.y / 2 + bobY),
      anchor: Anchor.center,
    );

    // Material name (on hover)
    if (_isHovered) {
      final namePaint = TextPaint(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFF8DC), // Cornsilk
          shadows: [
            Shadow(
              color: Color(0xFF2F4F4F),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );

      namePaint.render(
        canvas,
        material.name,
        Vector2(size.x / 2, size.y / 2 + bobY + 30),
        anchor: Anchor.center,
      );
    }
  }

  /// Get color for material type
  Color _getMaterialColor() {
    if (material.id.contains('grass')) return const Color(0xFF32CD32); // Lime green
    if (material.id.contains('water')) return const Color(0xFF4169E1); // Royal blue
    if (material.id.contains('stone')) return const Color(0xFF808080); // Gray
    if (material.id.contains('branch')) return const Color(0xFF8B4513); // Saddle brown
    if (material.id.contains('ember')) return const Color(0xFFFF4500); // Orange red
    if (material.id.contains('dew')) return const Color(0xFF00CED1); // Dark turquoise
    return const Color(0xFFFFD700); // Gold (default)
  }

  /// Get icon for material (same as inventory_slot.dart)
  String _getMaterialIcon() {
    if (material.id.contains('grass')) return '🌿';
    if (material.id.contains('water')) return '💧';
    if (material.id.contains('stone')) return '🪨';
    if (material.id.contains('branch')) return '🪵';
    if (material.id.contains('ember')) return '🔥';
    if (material.id.contains('dew')) return '💎';
    return '✨';
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isHovered = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTap();
    // Remove this node after gathering
    removeFromParent();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isHovered = false;
  }
}
