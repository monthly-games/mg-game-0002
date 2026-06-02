/// Battle Pass Overlay Component - 배틀패스 오버레이 컴포넌트
///
/// 배틀패스 진행 상황, 미션, 보상을 표시하는 UI 오버레이입니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:cat_alchemy/features/battlepass/cat_alchemy_battle_pass.dart';

/// 배틀패스 오버레이 컴포넌트
///
/// 화면 우측 상단에 배틀패스 진행 상황을 표시합니다.
class BattlePassOverlayComponent extends PositionComponent with TapCallbacks {
  final CatAlchemyBattlePass battlePass;

  // 표시 상태
  bool _isVisible = true;
  bool _isExpanded = false;

  // 확장 영역
  late Rect _collapsedRect;
  late Rect _expandedRect;

  BattlePassOverlayComponent({
    required this.battlePass,
    Vector2? position,
  }) : super(
          position: position ?? Vector2(0, 0),
          size: Vector2(200, 60),
        ) {
    _collapsedRect = Rect.fromLTWH(0, 0, 200, 60);
    _expandedRect = Rect.fromLTWH(0, 0, 300, 400);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 배틀패스 상태 변경 리스너 등록
    battlePass.addListener(_onBattlePassChanged);
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
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rRect, borderPaint);
  }

  /// 축소 상태 렌더링
  void _renderCollapsedContent(Canvas canvas) {
    // 시즌 이름
    final seasonPainter = TextPainter(
      text: TextSpan(
        text: 'Battle Pass',
        style: TextStyle(
          color: Colors.amber.shade300,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    seasonPainter.layout(maxWidth: size.x - 20);
    seasonPainter.paint(canvas, const Offset(10, 8));

    // 레벨 표시
    final levelText = 'Lv.${battlePass.currentLevel}/${battlePass.maxLevel}';
    final levelPainter = TextPainter(
      text: TextSpan(
        text: levelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    levelPainter.layout(maxWidth: size.x - 20);
    levelPainter.paint(canvas, Offset(10, seasonPainter.height + 12));

    // 경험치 바
    _renderProgressBar(
      canvas,
      Offset(10, levelPainter.height + seasonPainter.height + 20),
      size.x - 20,
      8,
      battlePass.levelProgress,
      Colors.amber,
    );

    // 미수령 보상 알림
    if (battlePass.unclaimedRewardCount > 0) {
      _renderNotificationBadge(canvas);
    }
  }

  /// 확장 상태 렌더링
  void _renderExpandedContent(Canvas canvas) {
    double yOffset = 10;

    // 시즌 이름
    final seasonPainter = TextPainter(
      text: TextSpan(
        text: battlePass.seasonName,
        style: TextStyle(
          color: Colors.amber.shade300,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    seasonPainter.layout(maxWidth: size.x - 20);
    seasonPainter.paint(canvas, Offset(10, yOffset));
    yOffset += seasonPainter.height + 10;

    // 레벨 및 경험치
    final levelText = 'Lv.${battlePass.currentLevel}/${battlePass.maxLevel}';
    final levelPainter = TextPainter(
      text: TextSpan(
        text: levelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    levelPainter.layout(maxWidth: size.x - 20);
    levelPainter.paint(canvas, Offset(10, yOffset));
    yOffset += levelPainter.height + 8;

    // 경험치 바
    _renderProgressBar(
      canvas,
      Offset(10, yOffset),
      size.x - 20,
      12,
      battlePass.levelProgress,
      Colors.amber,
    );
    yOffset += 20;

    // 남은 일수
    final daysText = '남은 시간: ${battlePass.remainingDays}일';
    final daysPainter = TextPainter(
      text: TextSpan(
        text: daysText,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    daysPainter.layout(maxWidth: size.x - 20);
    daysPainter.paint(canvas, Offset(10, yOffset));
    yOffset += daysPainter.height + 15;

    // 구분선
    _renderDivider(canvas, yOffset);
    yOffset += 15;

    // 미션 섹션
    _renderMissionsSection(canvas, yOffset);
  }

  /// 진행 바 렌더링
  void _renderProgressBar(
    Canvas canvas,
    Offset offset,
    double width,
    double height,
    double progress,
    Color color,
  ) {
    // 배경
    final bgPaint = Paint()..color = Colors.grey.shade800;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, height),
      Radius.circular(height / 2),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // 진행
    final progressPaint = Paint()..color = color;
    final progressRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width * progress, height),
      Radius.circular(height / 2),
    );
    canvas.drawRRect(progressRect, progressPaint);
  }

  /// 알림 배지 렌더링
  void _renderNotificationBadge(Canvas canvas) {
    final badgePaint = Paint()..color = Colors.red;
    final badgeCenter = Offset(size.x - 15, 15);
    canvas.drawCircle(badgeCenter, 8, badgePaint);

    // 숫자
    final countText = battlePass.unclaimedRewardCount > 9
        ? '9+'
        : '${battlePass.unclaimedRewardCount}';
    final countPainter = TextPainter(
      text: TextSpan(
        text: countText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    countPainter.layout();
    countPainter.paint(
      canvas,
      Offset(
        badgeCenter.dx - countPainter.width / 2,
        badgeCenter.dy - countPainter.height / 2,
      ),
    );
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

  /// 미션 섹션 렌더링
  void _renderMissionsSection(Canvas canvas, double y) {
    // 섹션 제목
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: '일일 미션',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: size.x - 20);
    titlePainter.paint(canvas, Offset(10, y));

    double missionY = y + titlePainter.height + 10;

    // 일일 미션 목록 (최대 3개)
    final dailyMissions = battlePass.dailyMissions.take(3);
    for (final mission in dailyMissions) {
      _renderMissionItem(canvas, mission, missionY);
      missionY += 35;
    }
  }

  /// 미션 아이템 렌더링
  void _renderMissionItem(Canvas canvas, dynamic mission, double y) {
    final progress = battlePass.getMissionProgress(mission.id);
    final isCompleted = battlePass.isMissionCompleted(mission.id);

    // 미션 이름
    final namePainter = TextPainter(
      text: TextSpan(
        text: mission.titleKr,
        style: TextStyle(
          color: isCompleted ? Colors.green.shade400 : Colors.white,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout(maxWidth: size.x - 60);
    namePainter.paint(canvas, Offset(10, y));

    // 진행률 텍스트
    final progressText = '${mission.trackingKey}: $progress/${mission.targetValue}';
    final progressPainter = TextPainter(
      text: TextSpan(
        text: progressText,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    progressPainter.layout(maxWidth: size.x - 60);
    progressPainter.paint(canvas, Offset(10, y + namePainter.height + 2));

    // 완료 표시
    if (isCompleted) {
      final checkPainter = TextPainter(
        text: const TextSpan(
          text: '✓',
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      checkPainter.layout();
      checkPainter.paint(canvas, Offset(size.x - 25, y + 5));
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    _isExpanded = !_isExpanded;
  }

  /// 배틀패스 상태 변경 콜백
  void _onBattlePassChanged() {
    // 상태가 변경되면 리렌더링 트리거
  }

  /// 표시 상태 설정
  void setVisible(bool visible) {
    _isVisible = visible;
  }

  @override
  void onRemove() {
    battlePass.removeListener(_onBattlePassChanged);
    super.onRemove();
  }
}
