import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/systems/rpg/inventory_system.dart';
import 'package:mg_common_game/core/systems/rpg/item_data.dart';
import 'package:mg_common_game/core/ui/theme/game_theme.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/features/crafting/logic/crafting_manager.dart';
import 'package:mg_common_game/core/systems/save_system.dart';
import 'game/logic/idle_manager.dart';
import 'game/logic/persistence_manager.dart';
import 'game/data/item_registry.dart';

import 'ui/screens/crafting_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const CatAlchemyApp());
}

Future<void> setupDependencies() async {
  final getIt = GetIt.instance;

  // 1. Core Systems
  final inventory = InventorySystem(capacity: 20);
  getIt.registerSingleton<InventorySystem>(inventory);

  final crafting = CraftingManager(inventory);
  getIt.registerSingleton<CraftingManager>(crafting);

  final goldManager = GoldManager();
  getIt.registerSingleton<GoldManager>(goldManager);

  // 2. Persistence
  final saveSystem = LocalSaveSystem();
  final persistence = PersistenceManager(saveSystem, inventory, goldManager);
  await persistence.init(); // Loads data
  getIt.registerSingleton<PersistenceManager>(persistence);

  // 3. Game Logic
  final idleManager = IdleManager(inventory);
  getIt.registerSingleton<IdleManager>(idleManager);
  idleManager.start();

  // 4. Mock Data (Only if empty inv?)
  // For prototype simplicity, we always add some defaults if inventory is empty.
  if (inventory.slots.isEmpty) {
    inventory.addItem(ItemRegistry.getItem('herb'), 5);
    inventory.addItem(ItemRegistry.getItem('water'), 5);
  }
}

class CatAlchemyApp extends StatelessWidget {
  const CatAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Alchemy',
      theme: GameTheme.darkTheme, // Use common theme
      home: const CraftingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
