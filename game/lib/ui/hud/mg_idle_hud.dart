import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';

/// MG UI 기반 아이들 게임 HUD
/// mg_common_game의 공통 UI 컴포넌트 활용
class MGIdleHud extends StatelessWidget {
  final int gold;
  final int gems;
  final int workshopLevel;
  final VoidCallback? onSettings;
  final VoidCallback? onTutorial;
  final VoidCallback? onCollection;
  final VoidCallback? onPrestige;
  final VoidCallback? onEvents;
  final VoidCallback? onDailyHub;
  final VoidCallback? onGuildWar;
  final VoidCallback? onTournament;
  final VoidCallback? onSeasonalEvent;

  const MGIdleHud({
    super.key,
    required this.gold,
    required this.gems,
    required this.workshopLevel,
    this.onSettings,
    this.onTutorial,
    this.onCollection,
    this.onPrestige,
    this.onEvents,
    this.onDailyHub,
    this.onGuildWar,
    this.onTournament,
    this.onSeasonalEvent,
  });

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    return Positioned.fill(
      child: Column(
        children: [
          // 상단 HUD: 자원 바
          Container(
            padding: EdgeInsets.only(
              top: safeArea.top + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildResourceBar(),
                _buildTopButtons(),
              ],
            ),
          ),

          // 중앙 영역 확장 (게임 콘텐츠)
          const Expanded(child: SizedBox()),
          // Spine 캐릭터 표시
          _buildSpineCharacter(),
          const SizedBox(height: 50),

          // 하단에는 게임 내 버튼들이 있으므로 HUD 없음
        ],
      ),
    );
  }

  Widget _buildResourceBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 골드
        MGResourceBar(
          icon: Icons.monetization_on,
          value: _formatNumber(gold),
          iconColor: MGColors.gold,
          onTap: null,
        ),
        MGSpacing.hSm,
        // 젬
        MGResourceBar(
          icon: Icons.diamond,
          value: _formatNumber(gems),
          iconColor: MGColors.gem,
          onTap: null,
        ),
        MGSpacing.hSm,
        // 공방 레벨
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: MGColors.backgroundDark.withValues(alpha: 0.54),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home_work,
                size: 18,
                color: MGColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                'Lv.$workshopLevel',
                style: MGTextStyles.hudSmall.copyWith(
                  color: MGColors.textHighEmphasis,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEvents != null)
          MGIconButton(
            icon: Icons.celebration,
            onPressed: onEvents,
            size: 44,
            backgroundColor: MGColors.error.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Events',
          ),
        MGSpacing.hXs,
        if (onPrestige != null)
          MGIconButton(
            icon: Icons.auto_awesome,
            onPressed: onPrestige,
            size: 44,
            backgroundColor: MGColors.gem.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Prestige',
          ),
        MGSpacing.hXs,
        if (onCollection != null)
          MGIconButton(
            icon: Icons.menu_book,
            onPressed: onCollection,
            size: 44,
            backgroundColor: MGColors.gem.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Collection',
          ),
        MGSpacing.hXs,
        if (onTutorial != null)
          MGIconButton(
            icon: Icons.help,
            onPressed: onTutorial,
            size: 44,
            backgroundColor: MGColors.info.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Tutorial',
          ),
        MGSpacing.hXs,
        if (onGuildWar != null)
          MGIconButton(
            icon: Icons.shield,
            onPressed: onGuildWar,
            size: 44,
            backgroundColor: MGColors.info.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Guild War',
          ),
        MGSpacing.hXs,
        if (onTournament != null)
          MGIconButton(
            icon: Icons.emoji_events,
            onPressed: onTournament,
            size: 44,
            backgroundColor: MGColors.info.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Tournament',
          ),
        MGSpacing.hXs,
        if (onSeasonalEvent != null)
          MGIconButton(
            icon: Icons.celebration,
            onPressed: onSeasonalEvent,
            size: 44,
            backgroundColor: MGColors.info.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Seasonal Event',
          ),
        MGSpacing.hXs,
        if (onDailyHub != null)
          MGIconButton(
            icon: Icons.calendar_today,
            onPressed: onDailyHub,
            size: 44,
            backgroundColor: MGColors.info.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Daily Hub',
          ),
        MGSpacing.hXs,
        if (onSettings != null)
          MGIconButton(
            icon: Icons.settings,
            onPressed: onSettings,
            size: 44,
            backgroundColor: MGColors.common.withValues(alpha: 0.8),
            color: MGColors.textHighEmphasis,
            tooltip: 'Settings',
          ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildSpineCharacter() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300, width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 28, color: Colors.white),
            SizedBox(height: 4),
            Text(
              'Owner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
