import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mg_common_game/systems/progression/prestige_manager.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';
import '../components/dialog_box.dart';

class PrestigeScene extends Component with HasGameRef<CatAlchemyGame> {
  final WidgetRef ref;

  PrestigeScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _setupUI();
  }

  Future<void> _setupUI() async {
    final size = gameRef.size;
    final prestigeManager = ref.read(prestigeManagerProvider);
    final gameState = ref.read(gameStateProvider);

    // Background
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF2C2C2C), // Dark theme for prestige
      ),
    );

    // Title
    add(
      TextComponent(
        text: 'Prestige Altar',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
        ), // Gold
        position: Vector2(size.x / 2, 40),
        anchor: Anchor.center,
      ),
    );

    // Stats
    add(
      TextComponent(
        text: 'Prestige Level: ${prestigeManager.prestigeLevel}',
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
        position: Vector2(size.x / 2, 90),
        anchor: Anchor.center,
      ),
    );

    add(
      TextComponent(
        text: 'Prestige Points: ${prestigeManager.prestigePoints}',
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 24, color: Colors.amber),
        ),
        position: Vector2(size.x / 2, 125),
        anchor: Anchor.center,
      ),
    );

    // Ascend Button (Reset)
    int potentialPoints = prestigeManager.calculatePrestigePoints(
      gameState.workshopLevel,
    );
    add(
      GameButton(
        text: 'Ascend (+$potentialPoints pts)',
        onPressed: () => _confirmAscend(potentialPoints),
        position: Vector2(size.x / 2, 190),
        size: Vector2(250, 60),
        backgroundColor: Colors.purple,
        enabled: potentialPoints > 0,
      ),
    );

    // Upgrades List
    double yPos = 300;
    for (final upgrade in prestigeManager.allPrestigeUpgrades) {
      _buildUpgradeCard(upgrade, Vector2(size.x / 2, yPos));
      yPos += 120;
    }

    // Back Button
    add(
      GameButton(
        text: 'Back',
        onPressed: () => gameRef.navigateTo('home'),
        position: Vector2(80, 40),
        size: Vector2(100, 40),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _buildUpgradeCard(PrestigeUpgrade upgrade, Vector2 centerPos) {
    final size = Vector2(gameRef.size.x - 60, 100);
    final topLeft =
        centerPos -
        Vector2(size.x / 2, 0); // Anchor top-center logic adjustment

    // Card Bg
    add(
      RectangleComponent(
        position: topLeft,
        size: size,
        paint: Paint()..color = Colors.grey.shade800,
      ),
    );

    // Info
    add(
      TextComponent(
        text:
            '${upgrade.name} (Lv.${upgrade.currentLevel}/${upgrade.maxLevel})',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: topLeft + Vector2(20, 15),
      ),
    );
    add(
      TextComponent(
        text: upgrade.description,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        position: topLeft + Vector2(20, 45),
      ),
    );

    // Buy Button
    final manager = ref.read(prestigeManagerProvider);
    final cost = upgrade.costForNextLevel;
    bool canAfford = manager.canAffordPrestigeUpgrade(upgrade.id);

    String btnText = cost == -1 ? 'Maxed' : 'Upgrade ($cost pts)';

    add(
      GameButton(
        text: btnText,
        onPressed: () {
          if (cost != -1 && canAfford) {
            manager.purchasePrestigeUpgrade(upgrade.id);
            _refreshUI();
          }
        },
        position: topLeft + Vector2(size.x - 100, size.y / 2),
        size: Vector2(160, 50),
        enabled: cost != -1 && canAfford,
        backgroundColor: cost != -1 && canAfford ? Colors.green : Colors.grey,
        fontSize: 14,
      ),
    );
  }

  void _confirmAscend(int points) {
    add(
      DialogBox(
        title: "Ascend?",
        message:
            "Reset workshop progress to gain $points Prestige Points?\n\nInventory, Recipes, and Workshop Level will be reset.\nPrestige Points and Upgrades are kept forever.",
        buttons: [
          DialogButton(text: "Cancel", onPressed: () => {}),
          DialogButton(
            text: "Ascend",
            color: Colors.purple,
            onPressed: () {
              final manager = ref.read(prestigeManagerProvider);
              final gameStateNotifier = ref.read(gameStateProvider.notifier);
              final gameState = ref.read(gameStateProvider);

              // Perform Prestige
              manager.performPrestige(gameState.workshopLevel);

              // Reset Game State (Keep prestige data, but reset progress)
              gameStateNotifier.reset();
              // Note: 'reset()' in GameStateNotifier might clear everything including Hive box.
              // We need a 'soft reset' or ensure Prestige Data is safe (it is, separate sharedPrefs).

              // Navigate
              gameRef.navigateTo('home');
            },
          ),
        ],
        onClose: () => remove(children.whereType<DialogBox>().first),
        position: gameRef.size / 2,
        size: Vector2(500, 350),
      ),
    );
  }

  void _refreshUI() {
    removeAll(children);
    _setupUI();
  }
}
