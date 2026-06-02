/// Leaderboard Overlay Component - 리더보드 오버레이 컴포넌트
///
/// 순위표를 표시하는 UI 오버레이입니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:cat_alchemy/features/social/cat_alchemy_leaderboards.dart';
import 'package:mg_common_game/systems/social/models/social_models.dart';

/// 리더보드 오버레이 컴포넌트
///
/// 화면 우측에 리더보드 순위를 표시합니다.
class LeaderboardOverlayComponent extends PositionComponent with TapCallbacks {
  final CatAlchemyLeaderboards leaderboards;

  // 표시 상태
  bool _isVisible = true;
  bool _isExpanded = false;

  // 현재 선택된 리더보드
  String _currentLeaderboardId = 'cat_alchemy_merge_speed_weekly';

  // 캐시된 데이터
  List<LeaderboardEntry> _entries = [];
  LeaderboardEntry? _myRank;

  // 확장 영역
  late Rect _collapsedRect;
  late Rect _expandedRect;

  // 로딩 상태
  bool _isLoading = false;

  LeaderboardOverlayComponent({
    required this.leaderboards,
    Vector2? position,
  }) : super(
          position: position ?? Vector2(0, 0),
          size: Vector2(180, 50),
        ) {
    _collapsedRect = Rect.fromLTWH(0, 0, 180, 50);
    _expandedRect = Rect.fromLTWH(0, 0, 320, 450);

    // 초기 리더보드 ID 설정
    final available = leaderboards.availableLeaderboards;
    if (available.isNotEmpty) {
      _currentLeaderboardId = available[0]['id'] as String;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 리더보드 상태 변경 리스너 등록
    leaderboards.addListener(_onLeaderboardsChanged);

    // 초기 데이터 로드
    await _loadLeaderboardData();
  }

  /// 리더보드 데이터 로드
  Future<void> _loadLeaderboardData() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      // 캐시된 데이터 먼저 사용
      _entries = leaderboards.getCachedMergeSpeedLeaderboard();

      // 내 순위 조회
      _myRank = await leaderboards.fetchMyMergeSpeedRank();

      // 최신 데이터 가져오기
      if (_currentLeaderboardId.contains('merge_speed')) {
        _entries = await leaderboards.fetchMergeSpeedLeaderboard(limit: 10);
        _myRank = await leaderboards.fetchMyMergeSpeedRank();
      } else if (_currentLeaderboardId.contains('collection')) {
        _entries = await leaderboards.fetchCollectionLeaderboard(limit: 10);
        _myRank = await leaderboards.fetchMyCollectionRank();
      } else if (_currentLeaderboardId.contains('prestige')) {
        _entries = await leaderboards.fetchPrestigeLeaderboard(limit: 10);
        _myRank = await leaderboards.fetchMyPrestigeRank();
      }
    } catch (e) {
      // 에러 시 캐시된 데이터 사용
      _entries = leaderboards.getCachedMergeSpeedLeaderboard();
    } finally {
      _isLoading = false;
    }
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
      ..color = Colors.orange.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rRect, borderPaint);
  }

  /// 축소 상태 렌더링
  void _renderCollapsedContent(Canvas canvas) {
    // 아이콘
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '🏆',
        style: TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas, const Offset(10, 15));

    // 제목
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'Leaderboard',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(40, 12));

    // 내 순위 표시
    if (_myRank != null) {
      final rankText = '내 순위: #${_myRank!.rank}';
      final rankPainter = TextPainter(
        text: TextSpan(
          text: rankText,
          style: TextStyle(
            color: Colors.orange.shade300,
            fontSize: 11,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      rankPainter.layout();
      rankPainter.paint(canvas, Offset(40, 30));
    }
  }

  /// 확장 상태 렌더링
  void _renderExpandedContent(Canvas canvas) {
    double yOffset = 10;

    // 제목
    final info = leaderboards.getLeaderboardInfo(_currentLeaderboardId);
    final titlePainter = TextPainter(
      text: TextSpan(
        text: '${info['icon']} ${info['title']}',
        style: TextStyle(
          color: Colors.orange.shade300,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: size.x - 20);
    titlePainter.paint(canvas, Offset(10, yOffset));
    yOffset += titlePainter.height + 10;

    // 설명
    final descPainter = TextPainter(
      text: TextSpan(
        text: info['description'] as String?,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    descPainter.layout(maxWidth: size.x - 20);
    descPainter.paint(canvas, Offset(10, yOffset));
    yOffset += descPainter.height + 15;

    // 구분선
    _renderDivider(canvas, yOffset);
    yOffset += 15;

    // 리더보드 선택 버튼 (간단히 텍스트로 표시)
    _renderLeaderboardSelector(canvas, yOffset);
    yOffset += 35;

    // 구분선
    _renderDivider(canvas, yOffset);
    yOffset += 10;

    // 순위표 헤더
    _renderRankingHeader(canvas, yOffset);
    yOffset += 25;

    // 순위 목록
    _renderRankingList(canvas, yOffset);
  }

  /// 리더보드 선택기 렌더링
  void _renderLeaderboardSelector(Canvas canvas, double y) {
    final available = leaderboards.availableLeaderboards;

    for (int i = 0; i < available.length && i < 2; i++) {
      final item = available[i];
      final isSelected = item['id'] == _currentLeaderboardId;
      final yOffset = y + (i * 18);

      final painter = TextPainter(
        text: TextSpan(
          text: '${item['icon']} ${item['title']}',
          style: TextStyle(
            color: isSelected ? Colors.orange.shade300 : Colors.grey.shade400,
            fontSize: isSelected ? 12 : 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: size.x - 20);
      painter.paint(canvas, Offset(10, yOffset));
    }
  }

  /// 순위표 헤더 렌더링
  void _renderRankingHeader(Canvas canvas, double y) {
    // 순위
    final rankPainter = TextPainter(
      text: const TextSpan(
        text: '순위',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    rankPainter.layout();
    rankPainter.paint(canvas, Offset(20, y));

    // 플레이어
    final playerPainter = TextPainter(
      text: const TextSpan(
        text: '플레이어',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    playerPainter.layout();
    playerPainter.paint(canvas, Offset(80, y));

    // 점수
    final scorePainter = TextPainter(
      text: const TextSpan(
        text: '점수',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(canvas, Offset(size.x - 80, y));
  }

  /// 순위 목록 렌더링
  void _renderRankingList(Canvas canvas, double y) {
    if (_entries.isEmpty) {
      // 데이터 없음
      final emptyPainter = TextPainter(
        text: TextSpan(
          text: _isLoading ? '로딩 중...' : '순위 데이터 없음',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      emptyPainter.layout(maxWidth: size.x - 20);
      emptyPainter.paint(canvas, Offset(10, y));
      return;
    }

    double itemY = y;

    // 상위 10개 표시
    for (int i = 0; i < _entries.length && i < 10; i++) {
      final entry = _entries[i];
      _renderRankingItem(canvas, entry, itemY, i + 1);
      itemY += 32;
    }

    // 내 순위 표시
    if (_myRank != null && !_entries.contains(_myRank)) {
      _renderDivider(canvas, itemY);
      itemY += 10;
      _renderRankingItem(canvas, _myRank!, itemY, _myRank!.rank, isMyRank: true);
    }
  }

  /// 순위 아이템 렌더링
  void _renderRankingItem(
    Canvas canvas,
    LeaderboardEntry entry,
    double y,
    int displayRank, {
    bool isMyRank = false,
  }) {
    // 배경 (내 순위 하이라이트)
    if (isMyRank) {
      final bgPaint = Paint()..color = Colors.orange.withValues(alpha: 0.2);
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(5, y - 2, size.x - 10, 28),
        const Radius.circular(4),
      );
      canvas.drawRRect(bgRect, bgPaint);
    }

    // 순위 색상
    final rankColor = _getRankColor(displayRank);

    // 순위
    final rankText = displayRank <= 3 ? _getRankIcon(displayRank) : '#$displayRank';
    final rankPainter = TextPainter(
      text: TextSpan(
        text: rankText,
        style: TextStyle(
          color: rankColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    rankPainter.layout();
    rankPainter.paint(canvas, Offset(15, y));

    // 플레이어 이름
    final namePainter = TextPainter(
      text: TextSpan(
        text: entry.displayName,
        style: TextStyle(
          color: isMyRank ? Colors.orange.shade300 : Colors.white,
          fontSize: 12,
          fontWeight: isMyRank ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout(maxWidth: 80);
    namePainter.paint(canvas, Offset(55, y));

    // 점수
    final score = leaderboards.formatScore(_currentLeaderboardId, entry.score);
    final scorePainter = TextPainter(
      text: TextSpan(
        text: score,
        style: TextStyle(
          color: isMyRank ? Colors.orange.shade300 : Colors.grey.shade300,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(canvas, Offset(size.x - scorePainter.width - 15, y));
  }

  /// 순위 색상 반환
  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade400;
    return Colors.white;
  }

  /// 순위 아이콘 반환
  String _getRankIcon(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  /// 구분선 렌더링
  void _renderDivider(Canvas canvas, double y) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(10, y),
      Offset(size.x - 10, y),
      paint,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    if (!_isExpanded) {
      // 확장
      _isExpanded = true;
    } else {
      // 확장 상태에서 다른 영역 터치 시 처리
      // 간단히 축소
      _isExpanded = false;
    }
  }

  /// 리더보드 전환
  void switchLeaderboard(String leaderboardId) {
    if (_currentLeaderboardId != leaderboardId) {
      _currentLeaderboardId = leaderboardId;
      _loadLeaderboardData();
    }
  }

  /// 리더보드 상태 변경 콜백
  void _onLeaderboardsChanged() {
    // 상태가 변경되면 데이터 리로드
    _loadLeaderboardData();
  }

  /// 표시 상태 설정
  void setVisible(bool visible) {
    _isVisible = visible;
  }

  @override
  void onRemove() {
    leaderboards.removeListener(_onLeaderboardsChanged);
    super.onRemove();
  }
}
