import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/main.dart';

void main() {
  testWidgets(
    'Main menu displays correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.byKey(const ValueKey('game-title')), findsOneWidget);
      expect(find.text('Core Fun: ${MyApp.coreFunLoop}'), findsOneWidget);
      expect(find.byKey(const ValueKey('engine-loop')), findsOneWidget);
    },
  );

  testWidgets(
    'Game screen works correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      expect(find.text('Game Ready'), findsWidgets);
      expect(find.byKey(const ValueKey('primary-loop')), findsOneWidget);
      expect(find.textContaining('Level 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('level-objective')), findsOneWidget);
      expect(find.byKey(const ValueKey('difficulty-label')), findsOneWidget);
      expect(find.byKey(const ValueKey('pressure-label')), findsOneWidget);
      expect(find.text('Reward bank: 0 gold / 0 xp'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Level 2'), findsOneWidget);
      expect(find.textContaining('Reward bank:'), findsOneWidget);
    },
  );

  testWidgets(
    'Level roadmap screen works correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('level-roadmap')));
      await tester.pumpAndSettle();

      expect(find.text('Level Roadmap'), findsWidgets);
      expect(find.byKey(const ValueKey('level-list')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.textContaining('Level 8'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.textContaining('Level 8'), findsOneWidget);
    },
  );

  testWidgets(
    'Rewards screen works correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('rewards')));
      await tester.pumpAndSettle();

      expect(find.text('Rewards'), findsWidgets);
      expect(
        find.text('Progression loop: return, claim, improve.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Daily quests screen works correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('daily-quests')));
      await tester.pumpAndSettle();

      expect(find.text('Daily Quests'), findsWidgets);
    },
  );

  testWidgets(
    'Guild war screen works correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('guild-war')));
      await tester.pumpAndSettle();

      expect(find.text('Guild War'), findsWidgets);
    },
  );

  testWidgets(
    'Tournament screen works correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tournament')));
      await tester.pumpAndSettle();

      expect(find.text('Tournament'), findsWidgets);
    },
  );

  testWidgets(
    'Seasonal event screen works correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('seasonal-event')));
      await tester.pumpAndSettle();

      expect(find.text('Seasonal Event'), findsWidgets);
    },
  );

  testWidgets(
    'Engine loop screen works correctly',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify engine loop button exists
      expect(find.byKey(const ValueKey('engine-loop')), findsOneWidget);
    },
  );
}
