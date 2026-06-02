import 'package:flutter/foundation.dart';
import '../models/story_chapter.dart';
import '../models/game_state.dart';
import 'package:cat_alchemy/core/models/recipe.dart';

/// Manager for story mode progression
class StoryManager {
  final List<StoryChapter> chapters;
  final GameState gameState;
  final List<Recipe> allRecipes;

  // Player progress tracking
  final Set<String> _completedChapters = {};
  final Set<String> _unlockedRecipes = {};
  String _currentChapterId = '';
  int _currentSceneIndex = 0;

  StoryManager({
    required this.chapters,
    required this.gameState,
    required this.allRecipes,
  });

  /// Get current chapter progress
  String get currentChapterId => _currentChapterId;
  int get currentSceneIndex => _currentSceneIndex;

  /// Get all available chapters
  List<StoryChapter> getAvailableChapters() {
    return chapters.where((chapter) {
      return chapter.isUnlocked(
        gameState.workshopLevel,
        gameState.reputation,
      );
    }).toList();
  }

  /// Get chapter by ID
  StoryChapter? getChapter(String chapterId) {
    try {
      return chapters.firstWhere((c) => c.id == chapterId);
    } catch (_) {
      return null;
    }
  }

  /// Get current chapter
  StoryChapter? get currentChapter {
    if (_currentChapterId.isEmpty) return null;
    return getChapter(_currentChapterId);
  }

  /// Get current scene
  StoryScene? get currentScene {
    final chapter = currentChapter;
    if (chapter == null) return null;

    if (_currentSceneIndex < 0 || _currentSceneIndex >= chapter.scenes.length) {
      return null;
    }

    return chapter.scenes[_currentSceneIndex];
  }

  /// Check if chapter is completed
  bool isChapterCompleted(String chapterId) {
    return _completedChapters.contains(chapterId);
  }

  /// Start a chapter
  bool startChapter(String chapterId) {
    final chapter = getChapter(chapterId);
    if (chapter == null) {
      debugPrint('Chapter not found: $chapterId');
      return false;
    }

    if (!chapter.isUnlocked(gameState.workshopLevel, gameState.reputation)) {
      debugPrint('Chapter not unlocked: $chapterId');
      return false;
    }

    _currentChapterId = chapterId;
    _currentSceneIndex = 0;
    return true;
  }

  /// Advance to next scene
  bool advanceToNextScene() {
    final chapter = currentChapter;
    if (chapter == null) return false;

    if (_currentSceneIndex < chapter.scenes.length - 1) {
      _currentSceneIndex++;
      return true;
    }

    return false;
  }

  /// Jump to specific scene
  bool goToScene(int sceneIndex) {
    final chapter = currentChapter;
    if (chapter == null) return false;

    if (sceneIndex >= 0 && sceneIndex < chapter.scenes.length) {
      _currentSceneIndex = sceneIndex;
      return true;
    }

    return false;
  }

  /// Make a story choice
  bool makeChoice(StoryChoice choice) {
    // Apply trust changes if any
    if (choice.trustChange != null) {
      choice.trustChange!.forEach((catId, amount) {
        if (catId == 'main') {
          gameState.addCatTrust(amount);
        }
      });
    }

    // Handle unlock content
    if (choice.unlockContent != null) {
      _handleUnlockContent(choice.unlockContent!);
    }

    // Advance to next scene or specified scene
    if (choice.nextSceneId != null) {
      final chapter = currentChapter;
      if (chapter != null) {
        final sceneIndex = chapter.scenes.indexWhere(
          (s) => s.id == choice.nextSceneId,
        );
        if (sceneIndex >= 0) {
          _currentSceneIndex = sceneIndex;
          return true;
        }
      }
    }

    return advanceToNextScene();
  }

  /// Complete current chapter
  bool completeChapter() {
    if (_currentChapterId.isEmpty) return false;

    final chapter = currentChapter;
    if (chapter == null) return false;

    // Mark chapter as completed
    _completedChapters.add(_currentChapterId);

    // Grant rewards
    gameState.gold += chapter.reward.gold;
    gameState.playerExp += chapter.reward.exp;
    if (chapter.reward.gems != null) {
      gameState.gems += chapter.reward.gems!;
    }
    if (chapter.reward.reputation != null) {
      gameState.reputation += chapter.reward.reputation!;
    }

    // Unlock chapter recipes
    for (final recipeId in chapter.unlockRecipeIds) {
      gameState.discoverRecipe(recipeId);
      _unlockedRecipes.add(recipeId);
    }

    // Reset current chapter
    _currentChapterId = '';
    _currentSceneIndex = 0;

    debugPrint('Chapter completed: ${chapter.title}');
    return true;
  }

  /// Get newly unlocked recipes from chapter
  List<String> getNewlyUnlockedRecipes(String chapterId) {
    final chapter = getChapter(chapterId);
    if (chapter == null) return [];

    return chapter.unlockRecipeIds
        .where((id) => !_unlockedRecipes.contains(id))
        .toList();
  }

  /// Handle unlock content from choices
  void _handleUnlockContent(String contentId) {
    // Could unlock special items, cats, etc.
    debugPrint('Unlocked content: $contentId');
  }

  /// Get story progress percentage
  double getStoryProgress() {
    if (chapters.isEmpty) return 0.0;
    return _completedChapters.length / chapters.length;
  }

  /// Exit story mode
  void exitStoryMode() {
    _currentChapterId = '';
    _currentSceneIndex = 0;
  }

  /// Get all completed chapters
  List<String> get completedChapterIds => List.from(_completedChapters);

  /// Get next available chapter
  StoryChapter? getNextAvailableChapter() {
    final available = getAvailableChapters();
    for (final chapter in available) {
      if (!_completedChapters.contains(chapter.id)) {
        return chapter;
      }
    }
    return null;
  }
}
