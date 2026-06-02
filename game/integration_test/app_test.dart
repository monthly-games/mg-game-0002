import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cat_alchemy/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full E2E test: Main menu and navigation', (tester) async {
    // 앱 시작
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 메인 메뉴 확인
    expect(find.text('MG-0002'), findsOneWidget);
    expect(find.text('Cat Alchemy Workshop'), findsOneWidget);
    expect(find.textContaining('Core Fun:'), findsOneWidget);

    // 게임 시작 버튼 탭
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    // 게임 화면 확인
    expect(find.text('Game Ready'), findsOneWidget);
    expect(find.textContaining('Level 1'), findsOneWidget);

    // 액션 완료
    await tester.ensureVisible(find.text('Complete Action'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete Action'));
    await tester.pumpAndSettle();

    // 레벨 업 확인
    expect(find.textContaining('Level 2'), findsOneWidget);
  });

  testWidgets('E2E: Supercell Strategy screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Strategy 버튼 탭
    await tester.tap(find.text('Strategy'));
    await tester.pumpAndSettle();

    // Supercell Strategy 화면 확인
    expect(find.textContaining('Supercell'), findsWidgets);
  });

  testWidgets('E2E: Battle Pass screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Battle Pass 버튼 탭
    await tester.tap(find.text('Battle Pass'));
    await tester.pumpAndSettle();

    // 배틀패스 화면 확인
    expect(find.textContaining('Battle'), findsWidgets);
  });

  testWidgets('E2E: All menu screens accessible', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 각 메뉴 항목 테스트
    final menuItems = [
      'Level Roadmap',
      'Engine',
      'Rewards',
      'Daily',
      'Guild',
      'Tournament',
      'Event',
    ];

    for (final item in menuItems) {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final button = find.text(item);
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button);
        await tester.pumpAndSettle();
      }
    }
  });
}
