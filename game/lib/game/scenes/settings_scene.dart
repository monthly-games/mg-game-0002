import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';

/// Settings scene - game settings and data management
class SettingsScene extends Component with HasGameRef {
  final WidgetRef ref;

  // UI Components
  late TextComponent _titleText;
  late GameButton _backButton;

  // Setting values (placeholder - would be stored in GameState)
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationsEnabled = true;
  double _soundVolume = 1.0;
  double _musicVolume = 0.7;

  SettingsScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setupUI();
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Title
    _titleText = TextComponent(
      text: 'Settings',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513), // Saddle brown
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

    // Build settings sections
    _buildAudioSettings();
    _buildGameplaySettings();
    _buildDataSettings();
    _buildInfoSection();
  }

  /// Build audio settings section
  void _buildAudioSettings() {
    final size = gameRef.size;
    var yPos = 120.0;

    // Section title
    final audioTitle = TextComponent(
      text: 'Audio Settings',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: Vector2(60, yPos),
    );
    add(audioTitle);
    yPos += 50;

    // Sound toggle
    _buildToggleSetting(
      'Sound Effects',
      _soundEnabled,
      (value) {
        _soundEnabled = value;
        _showMessage(_soundEnabled ? 'Sound enabled' : 'Sound disabled');
        _refreshUI();
      },
      Vector2(60, yPos),
    );
    yPos += 60;

    // Music toggle
    _buildToggleSetting(
      'Background Music',
      _musicEnabled,
      (value) {
        _musicEnabled = value;
        _showMessage(_musicEnabled ? 'Music enabled' : 'Music disabled');
        _refreshUI();
      },
      Vector2(60, yPos),
    );
    yPos += 60;

    // Volume sliders (placeholder - represented as buttons)
    _buildVolumeControl(
      'Sound Volume',
      _soundVolume,
      Vector2(60, yPos),
    );
    yPos += 60;

    _buildVolumeControl(
      'Music Volume',
      _musicVolume,
      Vector2(60, yPos + 60),
    );
  }

  /// Build gameplay settings section
  void _buildGameplaySettings() {
    final size = gameRef.size;
    var yPos = 500.0;

    // Section title
    final gameplayTitle = TextComponent(
      text: 'Gameplay Settings',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: Vector2(60, yPos),
    );
    add(gameplayTitle);
    yPos += 50;

    // Notifications toggle
    _buildToggleSetting(
      'Push Notifications',
      _notificationsEnabled,
      (value) {
        _notificationsEnabled = value;
        _showMessage(_notificationsEnabled
            ? 'Notifications enabled'
            : 'Notifications disabled');
        _refreshUI();
      },
      Vector2(60, yPos),
    );
  }

  /// Build data management section
  void _buildDataSettings() {
    final size = gameRef.size;
    var yPos = 660.0;

    // Section title
    final dataTitle = TextComponent(
      text: 'Data Management',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: Vector2(60, yPos),
    );
    add(dataTitle);
    yPos += 50;

    // Save button
    final saveButton = GameButton(
      text: '💾 Save Game',
      onPressed: _saveGame,
      position: Vector2(60, yPos),
      size: Vector2(200, 50),
      fontSize: 18,
      backgroundColor: const Color(0xFF228B22), // Forest green
    );
    add(saveButton);

    // Load button
    final loadButton = GameButton(
      text: '📂 Load Game',
      onPressed: _loadGame,
      position: Vector2(280, yPos),
      size: Vector2(200, 50),
      fontSize: 18,
      backgroundColor: const Color(0xFF4169E1), // Royal blue
    );
    add(loadButton);

    yPos += 70;

    // Reset button (dangerous)
    final resetButton = GameButton(
      text: '⚠️ Reset Progress',
      onPressed: _confirmReset,
      position: Vector2(60, yPos),
      size: Vector2(200, 50),
      fontSize: 18,
      backgroundColor: const Color(0xFFDC143C), // Crimson
    );
    add(resetButton);

    // Export button
    final exportButton = GameButton(
      text: '📤 Export Data',
      onPressed: _exportData,
      position: Vector2(280, yPos),
      size: Vector2(200, 50),
      fontSize: 18,
      backgroundColor: const Color(0xFF8B6914), // Golden brown
    );
    add(exportButton);
  }

  /// Build info section
  void _buildInfoSection() {
    final size = gameRef.size;
    var yPos = 850.0;

    // Section title
    final infoTitle = TextComponent(
      text: 'Game Information',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: Vector2(60, yPos),
    );
    add(infoTitle);
    yPos += 40;

    // Version info
    final versionText = TextComponent(
      text: 'Version: 0.1.0 (Alpha)',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF5D4E37),
        ),
      ),
      position: Vector2(60, yPos),
    );
    add(versionText);
    yPos += 30;

    // Developer info
    final devText = TextComponent(
      text: 'Developer: MG Games Studio',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF5D4E37),
        ),
      ),
      position: Vector2(60, yPos),
    );
    add(devText);
    yPos += 30;

    // Credits button
    final creditsButton = GameButton(
      text: 'Credits',
      onPressed: _showCredits,
      position: Vector2(60, yPos),
      size: Vector2(150, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFF8B6914),
    );
    add(creditsButton);

    // Help button
    final helpButton = GameButton(
      text: 'Help',
      onPressed: _showHelp,
      position: Vector2(230, yPos),
      size: Vector2(150, 45),
      fontSize: 16,
      backgroundColor: const Color(0xFF8B6914),
    );
    add(helpButton);
  }

  /// Build toggle setting
  void _buildToggleSetting(
    String label,
    bool value,
    Function(bool) onToggle,
    Vector2 position,
  ) {
    // Label
    final labelText = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF5D4E37),
        ),
      ),
      position: position,
    );
    add(labelText);

    // Toggle button
    final toggleButton = GameButton(
      text: value ? 'ON' : 'OFF',
      onPressed: () => onToggle(!value),
      position: position + Vector2(300, -10),
      size: Vector2(100, 40),
      fontSize: 16,
      backgroundColor: value
          ? const Color(0xFF228B22) // Green for ON
          : const Color(0xFF808080), // Gray for OFF
    );
    add(toggleButton);
  }

  /// Build volume control
  void _buildVolumeControl(String label, double volume, Vector2 position) {
    // Label
    final labelText = TextComponent(
      text: '$label: ${(volume * 100).toInt()}%',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF5D4E37),
        ),
      ),
      position: position,
    );
    add(labelText);

    // Decrease button
    final decreaseButton = GameButton(
      text: '-',
      onPressed: () {
        if (label.contains('Sound')) {
          _soundVolume = (_soundVolume - 0.1).clamp(0.0, 1.0);
        } else {
          _musicVolume = (_musicVolume - 0.1).clamp(0.0, 1.0);
        }
        _refreshUI();
      },
      position: position + Vector2(250, -10),
      size: Vector2(50, 40),
      fontSize: 24,
      backgroundColor: const Color(0xFF8B6914),
    );
    add(decreaseButton);

    // Increase button
    final increaseButton = GameButton(
      text: '+',
      onPressed: () {
        if (label.contains('Sound')) {
          _soundVolume = (_soundVolume + 0.1).clamp(0.0, 1.0);
        } else {
          _musicVolume = (_musicVolume + 0.1).clamp(0.0, 1.0);
        }
        _refreshUI();
      },
      position: position + Vector2(320, -10),
      size: Vector2(50, 40),
      fontSize: 24,
      backgroundColor: const Color(0xFF8B6914),
    );
    add(increaseButton);

    // Visual volume bar
    final volumeBarBg = RectangleComponent(
      position: position + Vector2(390, 5),
      size: Vector2(150, 20),
      paint: Paint()..color = const Color(0xFFD4B896),
    );
    add(volumeBarBg);

    final volumeBarFill = RectangleComponent(
      position: position + Vector2(390, 5),
      size: Vector2(150 * volume, 20),
      paint: Paint()..color = const Color(0xFF228B22),
    );
    add(volumeBarFill);
  }

  /// Save game
  void _saveGame() {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    gameStateNotifier.save();
    _showMessage('Game saved successfully! 💾');
  }

  /// Load game
  void _loadGame() {
    // Game auto-loads on startup, this is just a manual refresh
    _showMessage('Game state reloaded! 📂');
    _refreshUI();
  }

  /// Confirm reset
  void _confirmReset() {
    // Show confirmation dialog
    _showConfirmDialog(
      'Reset Progress',
      'Are you sure you want to reset all progress?\nThis action cannot be undone!',
      _resetProgress,
    );
  }

  /// Reset progress
  void _resetProgress() {
    // TODO: Implement reset logic in GameStateNotifier
    _showMessage('Progress reset! Starting fresh...');
    // Navigate back to splash or home
    if (gameRef is CatAlchemyGame) {
      (gameRef as CatAlchemyGame).navigateTo('splash');
    }
  }

  /// Export data
  void _exportData() {
    // TODO: Implement data export (JSON format)
    _showMessage('Export feature coming soon! 📤');
  }

  /// Show credits
  void _showCredits() {
    _showInfoDialog(
      'Credits',
      'Cat Alchemy Workshop\n\n'
      'Game Design: MG Games\n'
      'Programming: Claude AI\n'
      'Art: AI Generated\n'
      'Music: AI Generated\n\n'
      'Special Thanks:\n'
      '- Flutter & Flame Engine\n'
      '- Riverpod\n'
      '- All our players!',
    );
  }

  /// Show help
  void _showHelp() {
    _showInfoDialog(
      'How to Play',
      '🌿 Gather materials from the field\n'
      '🔨 Craft potions using recipes\n'
      '🛒 Buy and sell in the shop\n'
      '📜 Complete NPC orders for rewards\n'
      '🐱 Bond with your cat companion\n'
      '⬆️ Upgrade your workshop\n'
      '🏆 Earn achievements\n\n'
      'Have fun crafting!',
    );
  }

  /// Show confirmation dialog
  void _showConfirmDialog(String title, String message, VoidCallback onConfirm) {
    final size = gameRef.size;

    // Overlay
    final overlay = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
    );
    add(overlay);

    // Dialog background
    final dialogBg = RectangleComponent(
      position: size / 2,
      size: Vector2(450, 300),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFE8D5B7),
    );
    add(dialogBg);

    // Dialog border
    final dialogBorder = RectangleComponent(
      position: size / 2,
      size: Vector2(450, 300),
      anchor: Anchor.center,
      paint: Paint()
        ..color = const Color(0xFFDC143C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(dialogBorder);

    // Title
    final titleText = TextComponent(
      text: title,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFDC143C),
        ),
      ),
      position: size / 2 + Vector2(0, -120),
      anchor: Anchor.center,
    );
    add(titleText);

    // Message
    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF5D4E37),
          height: 1.5,
        ),
      ),
      position: size / 2 + Vector2(0, -40),
      anchor: Anchor.center,
    );
    add(messageText);

    // Cancel button
    final cancelButton = GameButton(
      text: 'Cancel',
      onPressed: () {
        remove(overlay);
        remove(dialogBg);
        remove(dialogBorder);
        remove(titleText);
        remove(messageText);
      },
      position: size / 2 + Vector2(-120, 80),
      size: Vector2(100, 50),
      fontSize: 16,
      backgroundColor: const Color(0xFF808080),
    );
    add(cancelButton);

    // Confirm button
    final confirmButton = GameButton(
      text: 'Confirm',
      onPressed: () {
        remove(overlay);
        remove(dialogBg);
        remove(dialogBorder);
        remove(titleText);
        remove(messageText);
        remove(cancelButton);
        onConfirm();
      },
      position: size / 2 + Vector2(20, 80),
      size: Vector2(100, 50),
      fontSize: 16,
      backgroundColor: const Color(0xFFDC143C),
    );
    add(confirmButton);
  }

  /// Show info dialog
  void _showInfoDialog(String title, String message) {
    final size = gameRef.size;

    // Overlay
    final overlay = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
    );
    add(overlay);

    // Dialog background
    final dialogBg = RectangleComponent(
      position: size / 2,
      size: Vector2(500, 400),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFE8D5B7),
    );
    add(dialogBg);

    // Title
    final titleText = TextComponent(
      text: title,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
      position: size / 2 + Vector2(0, -160),
      anchor: Anchor.center,
    );
    add(titleText);

    // Message
    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF5D4E37),
          height: 1.8,
        ),
      ),
      position: size / 2 + Vector2(0, -20),
      anchor: Anchor.center,
    );
    add(messageText);

    // Close button
    final closeButton = GameButton(
      text: 'Close',
      onPressed: () {
        remove(overlay);
        remove(dialogBg);
        remove(titleText);
        remove(messageText);
      },
      position: size / 2 + Vector2(0, 140),
      size: Vector2(120, 50),
      fontSize: 18,
    );
    add(closeButton);
  }

  /// Show temporary message
  void _showMessage(String message) {
    final size = gameRef.size;

    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF228B22),
          shadows: [
            Shadow(
              color: Colors.white,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: size / 2 + Vector2(0, -200),
      anchor: Anchor.center,
    );

    add(messageText);

    Future.delayed(const Duration(seconds: 2), () {
      if (messageText.isMounted) {
        remove(messageText);
      }
    });
  }

  /// Refresh UI
  void _refreshUI() {
    // Remove all dynamic children except title and back button
    final toKeep = [_titleText, _backButton];
    final toRemove = children.where((c) => !toKeep.contains(c));
    removeAll(toRemove);

    // Rebuild all sections
    _buildAudioSettings();
    _buildGameplaySettings();
    _buildDataSettings();
    _buildInfoSection();
  }

  /// Go back to home scene
  void _goBack() {
    if (gameRef is CatAlchemyGame) {
      (gameRef as CatAlchemyGame).navigateTo('home');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background
    final size = gameRef.size;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFF5E6D3), // Warm cream
    );

    // Settings panel background
    final panelRect = Rect.fromLTWH(30, 100, size.x - 60, size.y - 130);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(15)),
      Paint()..color = const Color(0xFF8B6914).withOpacity(0.1),
    );
  }
}
