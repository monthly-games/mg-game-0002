import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/recipe.dart';
import '../../core/models/story_chapter.dart';
import '../../core/managers/story_manager.dart';
import '../../providers/game_providers.dart';
import '../components/dialog_box.dart';
import '../components/game_button.dart';
import 'package:flame/flame.dart';

/// Story scene for displaying story content and handling choices
class StoryModeScene extends Component with HasGameReference {
  final WidgetRef ref;
  late StoryManager _storyManager;
  StoryScene? _currentScene;
  final Vector2 screenSize;
  bool _waitingForInput = false;

  // UI elements
  DialogBox? _dialogBox;
  GameButton? _continueButton;
  final List<GameButton> _choiceButtons = [];

  StoryModeScene(this.ref, this.screenSize);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Get story manager
    _storyManager = ref.read(storyManagerProvider);
    _currentScene = _storyManager.currentScene;

    if (_currentScene == null) {
      material.debugPrint('No scene to display');
      return;
    }

    await _loadSceneContent();
  }

  Future<void> _loadSceneContent() async {
    // Remove existing UI
    removeAll(children);

    _currentScene = _storyManager.currentScene;
    if (_currentScene == null) return;

    // Load background if available
    if (_currentScene!.backgroundAsset != null) {
      try {
        final backgroundImage = await Flame.images.load(
          _currentScene!.backgroundAsset!,
        );
        final backgroundSprite = SpriteComponent.fromImage(backgroundImage)
          ..size = screenSize
          ..position = Vector2.zero();
        add(backgroundSprite);
      } catch (e) {
        material.debugPrint('Failed to load background: $e');
      }
    }

    // Create dialog box based on speaker
    String dialogText = _currentScene!.dialogue;
    String speakerName = '';

    switch (_currentScene!.speaker) {
      case 'narrator':
        speakerName = '';
        break;
      case 'player':
        speakerName = 'You';
        break;
      case 'cat':
        speakerName = _currentScene!.characterName ?? '???';
        break;
      case 'npc':
        speakerName = _currentScene!.characterName ?? '???';
        break;
      default:
        speakerName = _currentScene!.speaker;
    }

    _dialogBox = DialogBox(
      title: speakerName.isEmpty ? 'Story' : speakerName,
      message: dialogText,
      buttons: const [],
      position: Vector2(screenSize.x * 0.5, screenSize.y * 0.825),
      size: Vector2(screenSize.x * 0.8, screenSize.y * 0.25),
    );
    add(_dialogBox!);

    // Check if scene has choices
    if (_currentScene!.choices != null && _currentScene!.choices!.isNotEmpty) {
      _createChoiceButtons(_currentScene!.choices!);
      _waitingForInput = true;
    } else {
      // Create continue button
      _continueButton = GameButton(
        text: 'Continue >',
        position: Vector2(screenSize.x * 0.85, screenSize.y * 0.85),
        size: Vector2(120, 40),
        onPressed: _onContinuePressed,
      );
      add(_continueButton!);
      _waitingForInput = true;
    }
  }

  void _createChoiceButtons(List<StoryChoice> choices) {
    final buttonWidth = screenSize.x * 0.6;
    final buttonHeight = 50.0;
    final startY = screenSize.y * 0.5;
    final gap = 10.0;

    for (int i = 0; i < choices.length; i++) {
      final choice = choices[i];
      final button = GameButton(
        text: choice.text,
        position: Vector2(
          screenSize.x * 0.2,
          startY + (buttonHeight + gap) * i,
        ),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () => _onChoiceSelected(choice),
      );
      _choiceButtons.add(button);
      add(button);
    }
  }

  void _onContinuePressed() {
    if (!_waitingForInput) return;
    _waitingForInput = false;

    // Try to advance to next scene
    if (_storyManager.advanceToNextScene()) {
      // Load next scene
      _loadSceneContent();
      _waitingForInput = true;
    } else {
      // Chapter complete
      _onChapterComplete();
    }
  }

  void _onChoiceSelected(StoryChoice choice) {
    if (!_waitingForInput) return;
    _waitingForInput = false;

    // Remove choice buttons
    for (final button in _choiceButtons) {
      remove(button);
    }
    _choiceButtons.clear();

    // Apply choice
    if (_storyManager.makeChoice(choice)) {
      // Load next scene
      _loadSceneContent();
      _waitingForInput = true;
    } else {
      // Chapter complete
      _onChapterComplete();
    }
  }

  void _onChapterComplete() {
    // Complete chapter
    _storyManager.completeChapter();

    // Show completion dialog
    material.debugPrint('Chapter completed!');

    // Return to home scene after a delay
    Future.delayed(const Duration(seconds: 2), () {
      final gameState = ref.read(gameStateProvider);
      gameState.save();
    });
  }

  /// Exit story mode
  void exitStoryMode() {
    _storyManager.exitStoryMode();
  }
}

/// Riverpod provider for story manager
final storyManagerProvider = Provider<StoryManager>((ref) {
  final gameState = ref.watch(gameStateProvider);
  final allRecipes = ref.watch(allRecipesProvider);

  // This should be initialized with actual data from game config
  final storyManager = StoryManager(
    chapters: const [],
    gameState: gameState,
    allRecipes: allRecipes,
  );

  return storyManager;
});

/// Provider for all recipes (should be defined elsewhere in the app)
final allRecipesProvider = Provider<List<Recipe>>((ref) {
  // Return empty list for now - should be populated from game data
  return const [];
});
