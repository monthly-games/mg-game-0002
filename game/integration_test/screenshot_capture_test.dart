import 'package:cat_alchemy/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot Capture', () {
    testWidgets('Capture all store screens', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      debugPrint('App launched');

      await binding.convertFlutterSurfaceToImage();
      await binding.takeScreenshot('MG-0002/01_main_menu');
      debugPrint('Captured: 01_main_menu');

      final startButton = find.byKey(const ValueKey('start-game'));
      if (tester.any(startButton)) {
        await tester.tap(startButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await binding.convertFlutterSurfaceToImage();
        await binding.takeScreenshot('MG-0002/02_game_play_initial');
        debugPrint('Captured: 02_game_play_initial');

        final completeButton = find.byKey(const ValueKey('complete-action'));
        if (tester.any(completeButton)) {
          await tester.ensureVisible(completeButton);
          for (var i = 0; i < 5; i++) {
            await tester.tap(completeButton);
            await tester.pumpAndSettle();
          }
        }

        await binding.convertFlutterSurfaceToImage();
        await binding.takeScreenshot('MG-0002/03_game_play_progressed');
        debugPrint('Captured: 03_game_play_progressed');

        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final roadmapButton = find.byKey(const ValueKey('level-roadmap'));
      if (tester.any(roadmapButton)) {
        await tester.tap(roadmapButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await binding.convertFlutterSurfaceToImage();
        await binding.takeScreenshot('MG-0002/04_level_roadmap');
        debugPrint('Captured: 04_level_roadmap');

        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final dailyButton = find.byKey(const ValueKey('daily-quests'));
      if (tester.any(dailyButton)) {
        await tester.tap(dailyButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await binding.convertFlutterSurfaceToImage();
        await binding.takeScreenshot('MG-0002/05_daily_quests');
        debugPrint('Captured: 05_daily_quests');

        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final tournamentButton = find.byKey(const ValueKey('tournament'));
      if (tester.any(tournamentButton)) {
        await tester.tap(tournamentButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await binding.convertFlutterSurfaceToImage();
        await binding.takeScreenshot('MG-0002/06_tournament');
        debugPrint('Captured: 06_tournament');

        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final eventButton = find.byKey(const ValueKey('seasonal-event'));
      if (tester.any(eventButton)) {
        await tester.tap(eventButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await binding.convertFlutterSurfaceToImage();
        await binding.takeScreenshot('MG-0002/07_seasonal_event');
        debugPrint('Captured: 07_seasonal_event');
      }

      debugPrint('All screenshots captured');
    });
  });
}
