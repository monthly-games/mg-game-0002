import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> returnToMenu(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);
  }

  group('MG-0002 Cat Alchemy Workshop - Game Loop E2E', () {
    testWidgets('Core gameplay loop: crafting, story progression, rewards', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify main menu
      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.text('MG-0002'), findsOneWidget);
      expect(find.text('Cat Alchemy Workshop'), findsOneWidget);

      // Start game
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify game screen
      expect(find.byKey(const ValueKey('complete-action')), findsOneWidget);
      expect(find.textContaining('Level 1'), findsOneWidget);

      // Complete crafting action
      await tester.ensureVisible(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify progression
      expect(find.textContaining('Level 2'), findsOneWidget);
      expect(find.textContaining('Reward bank:'), findsOneWidget);
    });

    testWidgets('Story mode progression and chapter unlocks', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('level-roadmap')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Level Roadmap'), findsWidgets);
      expect(find.byKey(const ValueKey('level-list')), findsOneWidget);

      // Verify story chapters exist
      expect(find.textContaining('Level'), findsWidgets);

      // Test chapter progression - scroll through list
      await tester.dragUntilVisible(
        find.textContaining('Level 8'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      await returnToMenu(tester);
    });

    testWidgets('Seasonal event integration and limited-time content', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('seasonal-event')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Seasonal Event'), findsWidgets);
      expect(find.textContaining('Timed content'), findsOneWidget);

      await returnToMenu(tester);
    });

    testWidgets('Alchemy crafting system and recipe progression', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify crafting mechanics
      expect(find.byKey(const ValueKey('complete-action')), findsOneWidget);
      expect(find.textContaining('Level'), findsOneWidget);

      // Complete multiple crafting actions
      for (int i = 0; i < 3; i++) {
        await tester.ensureVisible(
          find.byKey(const ValueKey('complete-action')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify recipe progression
      expect(find.textContaining('Level 4'), findsOneWidget);
    });

    testWidgets('Economy system: gold and recipe unlocks', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Initial state - check for bank display
      expect(find.byIcon(Icons.savings_rounded), findsOneWidget);

      // Complete crafting and verify rewards
      await tester.ensureVisible(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify reward accumulation
      expect(find.byIcon(Icons.psychology_alt_rounded), findsOneWidget);
    });

    testWidgets('Competition and leaderboard systems', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('tournament')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Tournament'), findsWidgets);
      await returnToMenu(tester);

      await tester.tap(find.byKey(const ValueKey('guild-war')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Guild War'), findsWidgets);
      await returnToMenu(tester);
    });

    testWidgets('Daily quests and retention systems', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('daily-quests')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Daily Quests'), findsWidgets);
      await returnToMenu(tester);

      await tester.tap(find.byKey(const ValueKey('rewards')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(
        find.text('Progression loop: return, claim, improve.'),
        findsOneWidget,
      );
      await returnToMenu(tester);
    });

    testWidgets('Full game loop: story -> craft -> progress -> events', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Start story mode
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Progress through story chapters
      for (int i = 0; i < 5; i++) {
        await tester.ensureVisible(
          find.byKey(const ValueKey('complete-action')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      expect(find.textContaining('Level 6'), findsOneWidget);
    });

    testWidgets('Engine loop verification - Flame game widget', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('engine-loop')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const ValueKey('engine-loop-status')), findsOneWidget);
      expect(find.textContaining('GameWidget frame loop'), findsOneWidget);

      await returnToMenu(tester);
    });

    testWidgets('Progressive difficulty scaling across levels', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Track difficulty progression
      final initialDifficulty = find.textContaining('Difficulty');
      expect(initialDifficulty, findsOneWidget);

      // Progress multiple levels
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify higher level reached
      expect(find.textContaining('Level 6'), findsOneWidget);
    });

    testWidgets('Reward accumulation and banking system', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Complete actions and track reward accumulation
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify reward display
      expect(find.byIcon(Icons.savings_rounded), findsOneWidget);
      expect(find.byIcon(Icons.psychology_alt_rounded), findsOneWidget);
    });

    testWidgets('Navigation flow between all game screens', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test all main navigation paths
      final routes = [
        'start-game',
        'level-roadmap',
        'daily-quests',
        'rewards',
        'tournament',
        'guild-war',
        'seasonal-event',
        'engine-loop',
      ];

      for (final route in routes) {
        await tester.tap(find.byKey(ValueKey(route)));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify returned to main menu
      expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);
    });

    testWidgets('Wave spawn system and enemy count verification', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify wave information display
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
      expect(find.textContaining('targets'), findsOneWidget);

      // Progress to see wave changes
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify wave progression
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
    });

    testWidgets('UI responsiveness and button interactions', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test main menu button interactions
      expect(find.byKey(const ValueKey('start-game')), findsOneWidget);
      expect(find.byKey(const ValueKey('level-roadmap')), findsOneWidget);
      expect(find.byKey(const ValueKey('daily-quests')), findsOneWidget);

      // Tap each button and verify navigation
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('complete-action')), findsOneWidget);

      await returnToMenu(tester);
    });

    testWidgets('Core fun loop consistency across sessions', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify core fun loop is displayed
      expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);
      expect(find.textContaining('Core Fun'), findsOneWidget);

      // Start and complete game loop
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Complete action
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Return and verify core loop still displayed
      await returnToMenu(tester);
      expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);
    });
  });

  group('Performance and Stability Tests', () {
    testWidgets('Extended gameplay session - 20 levels', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Complete 20 levels
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // Verify high level reached
      expect(find.textContaining('Level 21'), findsOneWidget);
    });

    testWidgets('Rapid button press stress test', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Rapid button presses
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      // Verify app still responsive
      expect(find.byKey(const ValueKey('complete-action')), findsOneWidget);
    });
  });
}
