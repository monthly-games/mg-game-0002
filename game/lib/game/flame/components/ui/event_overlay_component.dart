/// Event Overlay Component - 이벤트 오버레이 컴포넌트
///
/// 활성화된 이벤트와 보너스를 표시하는 UI 오버레이입니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:cat_alchemy/events/cat_alchemy_live_ops_manager.dart';

/// 이벤트 오버레이 컴포넌트
///
/// 화면 좌측 상단에 활성 이벤트를 표시합니다.
class EventOverlayComponent extends PositionComponent with TapCallbacks {
  final CatAlchemyLiveOpsManager liveOpsManager;

  // 표시 상태
  bool _isVisible = true;
  bool _isExpanded = false;

  // 활성 이벤트 목록
  List<CatAlchemyEvent> _activeEvents = [];

  // 확장 영역
  late Rect _collapsedRect;
  late Rect _expandedRect;

  EventOverlayComponent({
    required this.liveOpsManager,
    Vector2? position,
  }) : super(
          position: position ?? Vector2(0, 0),
          size: Vector2(180, 50),
        ) {
    _collapsedRect = Rect.fromLTWH(0, 0, 180, 50);
    _expandedRect = Rect.fromLTWH(0, 0, 300, 380);

    // 활성 이벤트 필터링
    _loadActiveEvents();
  }

  /// 활성 이벤트 로드
  void _loadActiveEvents() {
    final allEvents = liveOpsManager.createEventCalendar();
    final now = DateTime.now();

    _activeEvents = allEvents.where((event) {
      final gameEvent = event.toGameEvent();
      return now.isAfter(gameEvent.startDate) &&
          now.isBefore(gameEvent.endDate);
    }).toList();
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible) return;

    super.render(canvas);

    // 현재 영역 결정
    final currentRect = _isExpanded ? _expandedRect : _collapsedRect;
    size.setValues(currentRect.width, currentRect.height);

    // 배경
    _renderBackground(canvas, currentRect);

    if (_isExpanded) {
      // 확장 상태: 상세 정보 표시
      _renderExpandedContent(canvas);
    } else {
      // 축소 상태: 요약 정보만 표시
      _renderCollapsedContent(canvas);
    }
  }

  /// 배경 렌더링
  void _renderBackground(Canvas canvas, Rect rect) {
    // 반투명 배경
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.85);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rRect, bgPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rRect, borderPaint);
  }

  /// 축소 상태 렌더링
  void _renderCollapsedContent(Canvas canvas) {
    if (_activeEvents.isEmpty) {
      // 활성 이벤트 없음
      _renderNoEvents(canvas);
      return;
    }

    // 아이콘
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '🎉',
        style: TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas, const Offset(10, 15));

    // 제목
    final titlePainter = TextPainter(
      text: TextSpan(
        text: 'Active Events',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(40, 12));

    // 이벤트 수
    final countText = '${_activeEvents.length} 진행중';
    final countPainter = TextPainter(
      text: TextSpan(
        text: countText,
        style: TextStyle(
          color: Colors.purple.shade300,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    countPainter.layout();
    countPainter.paint(canvas, Offset(40, 30));
  }

  /// 이벤트 없음 렌더링
  void _renderNoEvents(Canvas canvas) {
    final painter = TextPainter(
      text: const TextSpan(
        text: 'No Active Events',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: size.x - 20);
    painter.paint(canvas, Offset(10, 18));
  }

  /// 확장 상태 렌더링
  void _renderExpandedContent(Canvas canvas) {
    double yOffset = 10;

    // 제목
    final titlePainter = TextPainter(
      text: TextSpan(
        text: '🎉 Live Events',
        style: TextStyle(
          color: Colors.purple.shade300,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: size.x - 20);
    titlePainter.paint(canvas, Offset(10, yOffset));
    yOffset += titlePainter.height + 10;

    if (_activeEvents.isEmpty) {
      // 활성 이벤트 없음 메시지
      final noEventsPainter = TextPainter(
        text: TextSpan(
          text: '현재 진행 중인 이벤트가 없습니다.\n곧 새로운 이벤트가 시작됩니다!',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      textDirection: TextDirection.ltr,
      );
      noEventsPainter.layout(maxWidth: size.x - 20);
      noEventsPainter.paint(canvas, Offset(10, yOffset));
      return;
    }

    // 이벤트 목록
    for (final event in _activeEvents) {
      _renderEventItem(canvas, event, yOffset);
      yOffset += _getEventItemHeight(event);
    }
  }

  /// 이벤트 아이템 렌더링
  void _renderEventItem(Canvas canvas, CatAlchemyEvent event, double y) {
    final gameEvent = event.toGameEvent();
    final now = DateTime.now();
    final remainingDays = gameEvent.endDate.difference(now).inDays;

    // 이벤트 타입 배지
    _renderEventTypeBadge(canvas, event.type, y);

    // 이벤트 이름
    final namePainter = TextPainter(
      text: TextSpan(
        text: event.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout(maxWidth: size.x - 60);
    namePainter.paint(canvas, Offset(10, y + 5));

    // 설명
    final descPainter = TextPainter(
      text: TextSpan(
        text: event.description,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    descPainter.layout(maxWidth: size.x - 20);
    descPainter.paint(canvas, Offset(10, y + namePainter.height + 8));

    // 남은 시간
    final remainingText = '⏱️ $remainingDays일 남음';
    final remainingPainter = TextPainter(
      text: TextSpan(
        text: remainingText,
        style: TextStyle(
          color: Colors.orange.shade300,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    remainingPainter.layout();
    remainingPainter.paint(
      canvas,
      Offset(10, y + namePainter.height + descPainter.height + 12),
    );

    // 보너스 목록
    double bonusY = y + namePainter.height + descPainter.height + 30;
    _renderBonuses(canvas, event.bonuses, bonusY);
  }

  /// 이벤트 타입 배지 렌더링
  void _renderEventTypeBadge(Canvas canvas, String type, double y) {
    final badgeColor = _getEventTypeColor(type);
    final badgeText = _getEventTypeLabel(type);

    final bgPaint = Paint()..color = badgeColor.withValues(alpha: 0.3);
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x - 55, y + 5, 45, 16),
      const Radius.circular(8),
    );
    canvas.drawRRect(bgRect, bgPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.x - 55 + (45 - textPainter.width) / 2, y + 7),
    );
  }

  /// 보너스 렌더링
  void _renderBonuses(Canvas canvas, Map<String, dynamic> bonuses, double y) {
    final bonusList = bonuses.entries.toList();
    double xOffset = 10;

    for (int i = 0; i < bonusList.length && i < 3; i++) {
      final bonus = bonusList[i];
      final bonusText = _formatBonus(bonus.key, bonus.value);

      final painter = TextPainter(
        text: TextSpan(
          text: bonusText,
          style: TextStyle(
            color: Colors.green.shade400,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      painter.paint(canvas, Offset(xOffset, y));
      xOffset += painter.width + 15;
    }
  }

  /// 보너스 포맷팅
  String _formatBonus(String key, dynamic value) {
    final label = _getBonusLabel(key);
    final multiplier = value is num ? value.toStringAsFixed(1) : value.toString();
    return '$label x$multiplier';
  }

  /// 보너스 라벨 반환
  String _getBonusLabel(String key) {
    switch (key) {
      case 'merge_speed':
        return '⚡병합';
      case 'gold_drop':
        return '💰골드';
      case 'experience':
        return '✨경험치';
      case 'spring_cat_drop_rate':
      case 'summer_cat_drop':
        return '🐱고양이';
      case 'collection_bonus':
        return '📚컬렉션';
      case 'tournament_multiplier':
        return '🏆대회';
      case 'friend_merge_bonus':
        return '👥친구';
      case 'social_rewards':
        return '💬소셜';
      case 'speed_multiplier':
        return '⚡속도';
      case 'guild_coop_bonus':
        return '🏰길드';
      case 'all_rewards':
        return '🎁전체';
      case 'special_gift':
        return '🎁선물';
      default:
        return '📦보너스';
    }
  }

  /// 이벤트 타입 색상 반환
  Color _getEventTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'seasonal':
        return Colors.green;
      case 'competitive':
        return Colors.red;
      case 'collaborative':
        return Colors.blue;
      case 'milestone':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// 이벤트 타입 라벨 반환
  String _getEventTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'seasonal':
        return '시즌';
      case 'competitive':
        return '경쟁';
      case 'collaborative':
        return '협력';
      case 'milestone':
        return '기념';
      default:
        return '이벤트';
    }
  }

  /// 이벤트 아이템 높이 계산
  double _getEventItemHeight(CatAlchemyEvent event) {
    double height = 5; // 이름
    height += 20; // 설명
    height += 15; // 남은 시간
    height += 20; // 보너스
    height += 15; // 여백
    return height;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    _isExpanded = !_isExpanded;
  }

  /// 이벤트 새로고침
  void refreshEvents() {
    _loadActiveEvents();
  }

  /// 표시 상태 설정
  void setVisible(bool visible) {
    _isVisible = visible;
  }

  /// 활성 이벤트 수 반환
  int get activeEventCount => _activeEvents.length;
}
