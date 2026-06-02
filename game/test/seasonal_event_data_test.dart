import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/game/data/seasonal_events_data.dart';

void main() {
  test('seasonal event catalog builds with milestone reward maps', () {
    final events = SeasonalEventsData.getAllEvents(2026);

    expect(events, hasLength(5));
    for (final event in events) {
      expect(event.rewards.milestones, isNotEmpty);
      expect(
        event.rewards.getMilestoneReward(event.rewards.milestones.first),
        isNotEmpty,
      );
    }
  });
}
