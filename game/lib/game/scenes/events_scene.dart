import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';
import '../../core/managers/seasonal_event_manager.dart';
import '../../core/models/seasonal_event.dart';
import '../../game/data/seasonal_events_data.dart';
import '../../providers/game_providers.dart';

/// Events scene - limited-time events and special challenges
class EventsScene extends Component with HasGameReference {
  final WidgetRef ref;

  // UI state
  final String _selectedEventId = '';

  // UI Components
  late GameButton _backButton;

  // Seasonal event manager
  late SeasonalEventManager _eventManager;

  // Events data
  final List<GameEvent> _activeEvents = [];
  final List<GameEvent> _upcomingEvents = [];
  final List<GameEvent> _completedEvents = [];

  EventsScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize seasonal event manager
    final gameState = ref.read(gameStateProvider);
    final allEvents = SeasonalEventsData.getAllEvents(DateTime.now().year);
    _eventManager = SeasonalEventManager(
      events: allEvents,
      gameState: gameState,
    );

    _initializeEvents();
    await _setupUI();
  }

  /// Initialize events data
  void _initializeEvents() {
    final now = DateTime.now();

    // Get active events
    _activeEvents.clear();
    _activeEvents.addAll(
      _eventManager.getActiveEvents().map(
        (event) => _toGameEvent(event, EventStatus.active),
      ),
    );

    // Get upcoming events
    _upcomingEvents.clear();
    _upcomingEvents.addAll(
      _eventManager.getUpcomingEvents().map(
        (event) => _toGameEvent(event, EventStatus.upcoming),
      ),
    );

    // Get completed events (events that have ended)
    _completedEvents.clear();
    for (final event in _eventManager.events) {
      if (event.hasEnded(now)) {
        _completedEvents.add(_toGameEvent(event, EventStatus.completed));
      }
    }
  }

  GameEvent _toGameEvent(SeasonalEvent event, EventStatus status) {
    final milestones = event.rewards.milestones;
    final firstReward = milestones.isEmpty
        ? <String, Object>{}
        : event.rewards.getMilestoneReward(milestones.first) ??
              <String, Object>{};

    return GameEvent(
      id: event.id,
      name: event.name,
      icon: _iconForTheme(event.theme),
      description: event.description,
      startDate: event.startTime,
      endDate: event.endTime,
      status: status,
      rewards: firstReward,
      progress: _eventManager.getEventPoints(event.id),
      maxProgress: event.rewards.maxEventPoints,
      difficulty: _difficultyForTheme(event.theme),
      color: _colorForTheme(event.theme),
    );
  }

  String _iconForTheme(String theme) {
    switch (theme) {
      case 'spring':
        return 'S';
      case 'summer':
        return 'F';
      case 'autumn':
        return 'H';
      case 'winter':
        return 'W';
      default:
        return '*';
    }
  }

  String _difficultyForTheme(String theme) {
    switch (theme) {
      case 'special':
        return 'Hard';
      case 'winter':
      case 'autumn':
        return 'Normal';
      default:
        return 'Easy';
    }
  }

  Color _colorForTheme(String theme) {
    switch (theme) {
      case 'spring':
        return const Color(0xFFFF69B4);
      case 'summer':
        return const Color(0xFFFF8C00);
      case 'autumn':
        return const Color(0xFFB5651D);
      case 'winter':
        return const Color(0xFF1E90FF);
      default:
        return const Color(0xFF8A2BE2);
    }
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    // Back button
    _backButton = GameButton(
      text: '← Back',
      onPressed: _navigateBack,
      position: Vector2(20, 20),
      size: Vector2(120, 50),
      fontSize: 18,
      backgroundColor: MGColors.common,
    );
    add(_backButton);
  }

  /// Navigate back to home
  void _navigateBack() {
    if (game is CatAlchemyGame) {
      (game as CatAlchemyGame).navigateTo('home');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final size = game.size;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFFFAF0), // Floral white
    );

    // Title
    _drawTitle(canvas);

    // Draw event sections
    _drawEventSections(canvas);

    // Draw selected event detail
    if (_selectedEventId.isNotEmpty) {
      _drawEventDetail(canvas);
    }
  }

  /// Draw title
  void _drawTitle(Canvas canvas) {
    final size = game.size;
    final centerX = size.x / 2;

    final titlePainter = TextPainter(
      text: const TextSpan(
        text: '🎪 Special Events',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF1493), // Deep pink
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(centerX - titlePainter.width / 2, 30));

    // Subtitle
    final subtitlePainter = TextPainter(
      text: const TextSpan(
        text: 'Limited-time challenges and exclusive rewards!',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF666666),
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subtitlePainter.layout();
    subtitlePainter.paint(
      canvas,
      Offset(centerX - subtitlePainter.width / 2, 75),
    );
  }

  /// Draw event sections
  void _drawEventSections(Canvas canvas) {
    double currentY = 120;

    // Active events
    if (_activeEvents.isNotEmpty) {
      _drawSectionHeader(canvas, '🔥 Active Events', currentY);
      currentY += 40;
      for (final event in _activeEvents) {
        _drawEventCard(canvas, event, Vector2(30, currentY));
        currentY += 140;
      }
    }

    // Upcoming events
    if (_upcomingEvents.isNotEmpty && currentY < game.size.y - 200) {
      _drawSectionHeader(canvas, '⏰ Upcoming Events', currentY);
      currentY += 40;
      for (final event in _upcomingEvents) {
        if (currentY > game.size.y - 180) break; // Don't draw off-screen
        _drawEventCard(canvas, event, Vector2(30, currentY));
        currentY += 140;
      }
    }
  }

  /// Draw section header
  void _drawSectionHeader(Canvas canvas, String title, double y) {
    final headerPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: MGColors.border,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    headerPainter.layout();
    headerPainter.paint(canvas, Offset(40, y));
  }

  /// Draw event card
  void _drawEventCard(Canvas canvas, GameEvent event, Vector2 position) {
    final size = game.size;
    final cardWidth = size.x - 60;
    final cardHeight = 120.0;

    // Card background
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.x, position.y, cardWidth, cardHeight),
      const Radius.circular(15),
    );

    // Background color based on status
    Color bgColor;
    if (event.status == EventStatus.active) {
      bgColor = event.color.withValues(alpha: 0.15);
    } else if (event.status == EventStatus.upcoming) {
      bgColor = const Color(0xFFF5F5F5); // White smoke
    } else {
      bgColor = const Color(0xFFE0E0E0); // Light gray
    }

    canvas.drawRRect(cardRect, Paint()..color = bgColor);

    // Border
    canvas.drawRRect(
      cardRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = event.color
        ..strokeWidth = 3,
    );

    // Icon
    final iconPainter = TextPainter(
      text: TextSpan(text: event.icon, style: const TextStyle(fontSize: 48)),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas, Offset(position.x + 20, position.y + 20));

    // Event name
    final namePainter = TextPainter(
      text: TextSpan(
        text: event.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: MGColors.border,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout(maxWidth: cardWidth - 200);
    namePainter.paint(canvas, Offset(position.x + 90, position.y + 15));

    // Description
    final descPainter = TextPainter(
      text: TextSpan(
        text: event.description,
        style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
      ),
      textDirection: TextDirection.ltr,
    );
    descPainter.layout(maxWidth: cardWidth - 200);
    descPainter.paint(canvas, Offset(position.x + 90, position.y + 40));

    // Status badge
    _drawStatusBadge(
      canvas,
      event,
      Offset(position.x + cardWidth - 100, position.y + 15),
    );

    // Progress bar (for active events)
    if (event.status == EventStatus.active) {
      _drawProgressBar(
        canvas,
        event.progress / event.maxProgress,
        Offset(position.x + 90, position.y + 85),
        cardWidth - 120,
      );

      // Progress text
      final progressText = '${event.progress} / ${event.maxProgress}';
      final progressPainter = TextPainter(
        text: TextSpan(
          text: progressText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: MGColors.success,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      progressPainter.layout();
      progressPainter.paint(
        canvas,
        Offset(position.x + cardWidth - 100, position.y + 80),
      );
    }

    // Time remaining (for active/upcoming events)
    if (event.status != EventStatus.completed) {
      final timeText = _getTimeRemaining(event);
      final timePainter = TextPainter(
        text: TextSpan(
          text: timeText,
          style: TextStyle(
            fontSize: 12,
            color: event.status == EventStatus.active
                ? const Color(0xFFFF4500) // Orange red
                : MGColors.common, // Gray
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      timePainter.layout();
      timePainter.paint(
        canvas,
        Offset(position.x + 90, position.y + cardHeight - 25),
      );
    }

    // TODO: Add tap detection to set _selectedEventId = event.id
  }

  /// Draw status badge
  void _drawStatusBadge(Canvas canvas, GameEvent event, Offset position) {
    String text;
    Color color;

    switch (event.status) {
      case EventStatus.active:
        text = 'ACTIVE';
        color = MGColors.success; // Forest green
        break;
      case EventStatus.upcoming:
        text = 'UPCOMING';
        color = MGColors.info; // Royal blue
        break;
      case EventStatus.completed:
        text = 'ENDED';
        color = MGColors.common; // Gray
        break;
    }

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, position.dy, 85, 26),
      const Radius.circular(13),
    );

    canvas.drawRRect(badgeRect, Paint()..color = color);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: MGColors.textHighEmphasis,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx + 42.5 - textPainter.width / 2,
        position.dy + 13 - textPainter.height / 2,
      ),
    );
  }

  /// Draw progress bar
  void _drawProgressBar(
    Canvas canvas,
    double progress,
    Offset position,
    double width,
  ) {
    final height = 16.0;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(position.dx, position.dy, width, height),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFD3D3D3), // Light gray
    );

    // Progress fill
    if (progress > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(position.dx, position.dy, width * progress, height),
          const Radius.circular(8),
        ),
        Paint()..color = MGColors.success, // Forest green
      );
    }

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(position.dx, position.dy, width, height),
        const Radius.circular(8),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = MGColors.common
        ..strokeWidth = 1,
    );
  }

  /// Get time remaining text
  String _getTimeRemaining(GameEvent event) {
    final now = DateTime.now();
    final Duration diff;

    if (event.status == EventStatus.active) {
      diff = event.endDate.difference(now);
    } else {
      diff = event.startDate.difference(now);
    }

    if (diff.inDays > 0) {
      return event.status == EventStatus.active
          ? '⏰ ${diff.inDays}d ${diff.inHours % 24}h remaining'
          : '⏰ Starts in ${diff.inDays}d ${diff.inHours % 24}h';
    } else if (diff.inHours > 0) {
      return event.status == EventStatus.active
          ? '⏰ ${diff.inHours}h ${diff.inMinutes % 60}m remaining'
          : '⏰ Starts in ${diff.inHours}h ${diff.inMinutes % 60}m';
    } else {
      return event.status == EventStatus.active
          ? '⏰ ${diff.inMinutes}m remaining'
          : '⏰ Starting soon!';
    }
  }

  /// Draw event detail panel
  void _drawEventDetail(Canvas canvas) {
    final event = _findEventById(_selectedEventId);
    if (event == null) return;

    final size = game.size;

    // Overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..color = MGColors.backgroundDark.withValues(alpha: 0.5), // 50% black
    );

    // Detail panel
    final panelWidth = size.x - 60.0;
    final panelHeight = 500.0;
    final panelX = 30.0;
    final panelY = size.y / 2 - panelHeight / 2;

    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(panelX, panelY, panelWidth, panelHeight),
      const Radius.circular(20),
    );

    canvas.drawRRect(
      panelRect,
      Paint()..color = const Color(0xFFFFFFF0),
    ); // Ivory
    canvas.drawRRect(
      panelRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = event.color
        ..strokeWidth = 4,
    );

    // Icon
    final iconPainter = TextPainter(
      text: TextSpan(text: event.icon, style: const TextStyle(fontSize: 80)),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(panelX + panelWidth / 2 - iconPainter.width / 2, panelY + 30),
    );

    // Name
    final namePainter = TextPainter(
      text: TextSpan(
        text: event.name,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: MGColors.border,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    namePainter.layout(maxWidth: panelWidth - 40);
    namePainter.paint(
      canvas,
      Offset(panelX + panelWidth / 2 - namePainter.width / 2, panelY + 130),
    );

    // Description
    final descPainter = TextPainter(
      text: TextSpan(
        text: event.description,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF555555),
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    descPainter.layout(maxWidth: panelWidth - 60);
    descPainter.paint(
      canvas,
      Offset(panelX + panelWidth / 2 - descPainter.width / 2, panelY + 180),
    );

    // Rewards section
    _drawRewardsSection(canvas, event, panelX, panelY + 240, panelWidth);

    // Difficulty badge
    _drawDifficultyBadge(
      canvas,
      event.difficulty,
      Offset(panelX + 30, panelY + 370),
    );

    // Time info
    final timeText = _getTimeRemaining(event);
    final timePainter = TextPainter(
      text: TextSpan(
        text: timeText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF4500),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    timePainter.layout();
    timePainter.paint(
      canvas,
      Offset(panelX + panelWidth - timePainter.width - 30, panelY + 375),
    );

    // Close hint
    final closePainter = TextPainter(
      text: const TextSpan(
        text: 'Tap anywhere to close',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF888888),
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    closePainter.layout();
    closePainter.paint(
      canvas,
      Offset(
        panelX + panelWidth / 2 - closePainter.width / 2,
        panelY + panelHeight - 40,
      ),
    );
  }

  /// Draw rewards section
  void _drawRewardsSection(
    Canvas canvas,
    GameEvent event,
    double x,
    double y,
    double width,
  ) {
    // Rewards header
    final headerPainter = TextPainter(
      text: const TextSpan(
        text: '🎁 Rewards:',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: MGColors.border,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    headerPainter.layout();
    headerPainter.paint(canvas, Offset(x + 30, y));

    // Draw reward items
    double currentY = y + 35;
    final rewards = event.rewards;

    if (rewards.containsKey('gold')) {
      _drawRewardItem(
        canvas,
        '💰',
        'Gold: ${rewards['gold']}',
        Offset(x + 40, currentY),
      );
      currentY += 25;
    }

    if (rewards.containsKey('gems')) {
      _drawRewardItem(
        canvas,
        '💎',
        'Gems: ${rewards['gems']}',
        Offset(x + 40, currentY),
      );
      currentY += 25;
    }

    if (rewards.containsKey('items')) {
      final items = rewards['items'] as List<String>;
      for (final item in items) {
        _drawRewardItem(canvas, '📦', item, Offset(x + 40, currentY));
        currentY += 25;
      }
    }
  }

  /// Draw single reward item
  void _drawRewardItem(
    Canvas canvas,
    String icon,
    String text,
    Offset position,
  ) {
    final iconPainter = TextPainter(
      text: TextSpan(text: icon, style: const TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas, position);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, color: MGColors.border),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx + 30, position.dy + 2));
  }

  /// Draw difficulty badge
  void _drawDifficultyBadge(Canvas canvas, String difficulty, Offset position) {
    Color color;
    switch (difficulty) {
      case 'Easy':
        color = MGColors.success; // Green
        break;
      case 'Normal':
        color = MGColors.info; // Blue
        break;
      case 'Hard':
        color = const Color(0xFFFF4500); // Orange red
        break;
      default:
        color = MGColors.common;
    }

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, position.dy, 90, 28),
      const Radius.circular(14),
    );

    canvas.drawRRect(badgeRect, Paint()..color = color);

    final textPainter = TextPainter(
      text: TextSpan(
        text: difficulty,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: MGColors.textHighEmphasis,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx + 45 - textPainter.width / 2,
        position.dy + 14 - textPainter.height / 2,
      ),
    );
  }

  /// Find event by ID
  GameEvent? _findEventById(String id) {
    for (final event in _activeEvents) {
      if (event.id == id) return event;
    }
    for (final event in _upcomingEvents) {
      if (event.id == id) return event;
    }
    for (final event in _completedEvents) {
      if (event.id == id) return event;
    }
    return null;
  }
}

/// Event status enum
enum EventStatus { active, upcoming, completed }

/// Game event model
class GameEvent {
  final String id;
  final String name;
  final String icon;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final EventStatus status;
  final Map<String, dynamic> rewards;
  final int progress;
  final int maxProgress;
  final String difficulty;
  final Color color;

  GameEvent({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.rewards,
    required this.progress,
    required this.maxProgress,
    required this.difficulty,
    required this.color,
  });
}
