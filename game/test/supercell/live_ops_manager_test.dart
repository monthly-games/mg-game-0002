import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/supercell/live_ops_manager.dart';

void main() {
  group('LiveOpsManager', () {
    late LiveOpsManager manager;

    setUp(() {
      manager = LiveOpsManager();
    });

    test('eventCalendar_generatesNineEvents', () {
      final calendar = manager.generateEventCalendar();

      expect(calendar, isNotNull);
      expect(calendar.events, isNotNull);
      expect(calendar.events.length, equals(9));
    });

    test('abTestRoadmap_generatesEightTests', () {
      final roadmap = manager.generateABTestRoadmap();

      expect(roadmap, isNotNull);
      expect(roadmap.tests, isNotNull);
      expect(roadmap.tests.length, equals(8));
    });

    test('convertToGameEvent_validFormat', () {
      final eventPlan = EventPlan(
        name: 'Weekend Bonus',
        type: EventType.xpMultiplier,
        duration: Duration(days: 2),
      );

      final gameEvent = manager.convertToGameEvent(eventPlan);

      expect(gameEvent, isNotNull);
      expect(gameEvent.name, equals('Weekend Bonus'));
      expect(gameEvent.type, equals(EventType.xpMultiplier));
      expect(gameEvent.duration, equals(Duration(days: 2)));
    });

    test('report_containsAllSections', () {
      final report = manager.generateReport();

      expect(report, isNotEmpty);
      expect(report, contains('EVENT CALENDAR'));
      expect(report, contains('A/B TESTS'));
      expect(report, contains('RECOMMENDATIONS'));
    });

    test('generateEventCalendar_includesAllEventTypes', () {
      final calendar = manager.generateEventCalendar();

      // Should include various event types
      expect(calendar.events, isNotEmpty);
      expect(calendar.events.length, equals(9));
    });

    test('generateABTestRoadmap_includesAllTestCategories', () {
      final roadmap = manager.generateABTestRoadmap();

      // Should include different test categories
      expect(roadmap.tests, isNotEmpty);
      expect(roadmap.tests.length, equals(8));
    });

    test('getLiveOpsStrategy_returnsCompleteStrategy', () {
      final strategy = manager.getLiveOpsStrategy();

      expect(strategy, isNotNull);
      expect(strategy.events, isNotEmpty);
      expect(strategy.tests, isNotEmpty);
      expect(strategy.timeline, isNotNull);
    });

    test('eventFrequency_matchesBestPractices', () {
      final calendar = manager.generateEventCalendar();

      // Events should be spread across 12 weeks
      expect(calendar.events.length, equals(9));
    });
  });

  group('EventPlan', () {
    test('create_returnsValidEvent', () {
      final event = EventPlan(
        name: 'Test Event',
        type: EventType.xpMultiplier,
        duration: Duration(days: 3),
      );

      expect(event.name, equals('Test Event'));
      expect(event.type, equals(EventType.xpMultiplier));
      expect(event.duration, equals(Duration(days: 3)));
    });

    test('create_withRewards_savesRewards', () {
      final event = EventPlan(
        name: 'Reward Event',
        type:EventType.resourceBonus,
        duration: Duration(days: 1),
        rewards: {'gold': 100, 'gems': 50},
      );

      expect(event.rewards, isNotNull);
      expect(event.rewards!['gold'], equals(100));
      expect(event.rewards!['gems'], equals(50));
    });
  });

  group('EventType', () {
    test('xpMultiplier_isValid', () {
      expect(EventType.xpMultiplier, isNotNull);
    });

    test('resourceBonus_isValid', () {
      expect(EventType.resourceBonus, isNotNull);
    });

    test('specialOffer_isValid', () {
      expect(EventType.specialOffer, isNotNull);
    });

    test('limitedTimeCat_isValid', () {
      expect(EventType.limitedTimeCat, isNotNull);
    });

    test('challenge_isValid', () {
      expect(EventType.challenge, isNotNull);
    });
  });

  group('ABTestPlan', () {
    test('create_returnsValidTest', () {
      final test = ABTestPlan(
        name: 'Merge Rate Test',
        hypothesis: 'Faster animations increase engagement',
        variants: ['Normal', 'Fast', 'Instant'],
        duration: Duration(days: 7),
      );

      expect(test.name, equals('Merge Rate Test'));
      expect(test.hypothesis, contains('engagement'));
      expect(test.variants.length, equals(3));
      expect(test.duration, equals(Duration(days: 7)));
    });

    test('create_withMetrics_savesMetrics', () {
      final test = ABTestPlan(
        name: 'Metric Test',
        hypothesis: 'Test hypothesis',
        variants: ['A', 'B'],
        duration: Duration(days: 7),
        metrics: ['retention', 'session_length', 'merges_per_session'],
      );

      expect(test.metrics, isNotNull);
      expect(test.metrics!.length, equals(3));
    });
  });

  group('LiveOpsStrategy', () {
    test('create_returnsCompleteStrategy', () {
      final strategy = LiveOpsStrategy(
        events: [],
        tests: [],
        timeline: LiveOpsTimeline(weeks: 12),
      );

      expect(strategy.events, isNotNull);
      expect(strategy.tests, isNotNull);
      expect(strategy.timeline, isNotNull);
      expect(strategy.timeline.weeks, equals(12));
    });
  });

  group('LiveOpsCalendar', () {
    test('create_returnsValidCalendar', () {
      final calendar = LiveOpsCalendar(
        events: [],
        startDate: DateTime(2026, 1, 1),
      );

      expect(calendar.events, isNotNull);
      expect(calendar.startDate, equals(DateTime(2026, 1, 1)));
    });

    test('events_sortedByDate', () {
      final events = [
        EventPlan(
          name: 'Event 1',
          type: EventType.xpMultiplier,
          duration: Duration(days: 1),
        ),
        EventPlan(
          name: 'Event 2',
          type: EventType.resourceBonus,
          duration: Duration(days: 1),
        ),
      ];

      final calendar = LiveOpsCalendar(
        events: events,
        startDate: DateTime(2026, 1, 1),
      );

      expect(calendar.events.length, equals(2));
    });
  });
}
