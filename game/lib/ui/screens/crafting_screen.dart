import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/systems/rpg/inventory_system.dart';
import 'package:mg_common_game/features/crafting/logic/crafting_manager.dart';
import 'package:mg_common_game/features/crafting/logic/recipe.dart';
import 'package:mg_common_game/core/ui/layouts/game_scaffold.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart'; // Import
import 'package:mg_common_game/core/ui/widgets/inventory_grid.dart'; // Ensure exported or use direct path
import '../../l10n/localization.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:flame/game.dart';
import '../../game/workshop_game.dart';import 'package:mg_common_game/l10n/localization.dart';


class CraftingScreen extends StatefulWidget {
  const CraftingScreen({super.key});

  @override
  State<CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends State<CraftingScreen> {
  final inventory = GetIt.I<InventorySystem>();
  final crafting = GetIt.I<CraftingManager>();

  // Test Recipes
  final List<Recipe> recipes = [
    Recipe(
      id: 'potion_health',
      inputs: {'herb': 1, 'water': 1},
      outputs: {'potion_health': 1},
      durationSeconds: 3,
    ),
    Recipe(
      id: 'bomb_fire',
      inputs: {'fire_stone': 2},
      outputs: {'bomb_fire': 1},
      durationSeconds: 5,
    ),
  ];

  CraftingJob? currentJob;

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: Column(
        children: [
          // 1. Top Area: Cauldron / Status
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(MGSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Center(child: _buildCauldronArea()),
                ),
                Positioned(top: 24, right: 24, child: _buildGoldIndicator()),
              ],
            ),
          ),

          // 2. Middle Area: Recipes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: recipes.map((r) => _buildRecipeChip(r)).toList(),
              ),
            ),
          ),
          const SizedBox(height: MGSpacing.md),

          // 3. Bottom Area: Inventory
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(MGSpacing.md),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory',
                    style: TextStyle(
                      color: MGColors.textHighEmphasis,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: MGSpacing.xs),
                  Expanded(
                    child: StreamBuilder(
                      stream: inventory
                          .onInventoryChanged, // If InventorySystem exposes stream? Check implementation.
                      // If not, we might need manual setState on updates.
                      // Assuming it acts as ChangeNotifier or we just rebuild on interaction for prototype.
                      builder: (context, _) {
                        return InventoryGrid(inventory: inventory);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCauldronArea() {
    // We overlay UI on top of the GameWidget if needed, or just let GameWidget be the background of this area.
    // However, GameWidget needs to be in the tree.
    // Let's use a Stack: GameWidget at back, UI status at front.

    return Stack(
      children: [
        // 1. The Game Scene (Workshop)
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GameWidget(game: WorkshopGame()),
        ),

        // 2. Overlay UI (Progress / Claims)
        Positioned.fill(child: Center(child: _buildOverlayContent())),
      ],
    );
  }

  Widget _buildOverlayContent() {
    if (currentJob != null) {
      if (currentJob!.isFinished) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: MGColors.success, size: 48),
            const SizedBox(height: MGSpacing.xs),
            ElevatedButton(
              onPressed: _claimResult,
              child: Text(AppLocalizations.of(context).uiGeneralCollect),
            ),
          ],
        );
      } else {
        // Brewing... visual only, maybe a small spinner or text
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: MGColors.backgroundDark.withValues(alpha: 0.54),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MGColors.gem,
                ),
              ),
              SizedBox(width: MGSpacing.xs),
              Text(
                'Brewing...',
                style: TextStyle(color: MGColors.textHighEmphasis, fontSize: 12),
              ),
            ],
          ),
        );
      }
    }
    return const SizedBox.shrink(); // Hide overlay when idle (Game scene is visible)
  }

  Widget _buildRecipeChip(Recipe recipe) {
    final canCraft = crafting.canCraft(recipe);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(recipe.id),
        backgroundColor: canCraft ? MGColors.gem : MGColors.border,
        labelStyle: TextStyle(color: canCraft ? MGColors.textHighEmphasis : MGColors.textHighEmphasis.withValues(alpha: 0.54)),
        onPressed: canCraft && currentJob == null
            ? () => _startCraft(recipe)
            : null,
      ),
    );
  }

  void _startCraft(Recipe recipe) {
    setState(() {
      currentJob = crafting.startCraft(recipe);
    });

    try {
      GetIt.I<AudioManager>().playSfx('craft_start.wav');
    } catch (_) {}

    // Simple timer to update UI when done
    if (currentJob != null) {
      Future.delayed(Duration(seconds: recipe.durationSeconds), () {
        if (mounted) setState(() {});
      });
    }
  }

  Widget _buildGoldIndicator() {
    final goldManager = GetIt.I<GoldManager>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MGColors.backgroundDark.withValues(alpha: 0.87),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MGColors.warning),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: MGColors.warning, size: 20),
          const SizedBox(width: MGSpacing.xs),
          AnimatedBuilder(
            animation: goldManager,
            builder: (context, child) {
              return Text(
                '${goldManager.currentGold}',
                style: const TextStyle(
                  color: MGColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _claimResult() {
    if (currentJob != null) {
      final success = crafting.claim(currentJob!);
      if (success) {
        try {
          GetIt.I<AudioManager>().playSfx('craft_success.wav');
        } catch (_) {}

        // Bonus: Add Gold on claim? Or sell later?
        // For prototype loop, let's say crafting GIVES gold (commission model) or we just crafted an item.
        // Let's keep it simple: Crafted Item goes to Inventory.
        // User stays happy.
        setState(() {
          currentJob = null;
        });
      }
    }
  }
}
