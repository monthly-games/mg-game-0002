import 'package:flutter/material.dart';
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
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home_work,
                size: 18,
                color: Colors.brown,
              ),
              const SizedBox(width: 6),
              Text(
                'Lv.$workshopLevel',
                style: MGTextStyles.hudSmall.copyWith(
                  color: Colors.white,
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
            backgroundColor: Colors.pink.withValues(alpha: 0.8),
            color: Colors.white,
            tooltip: 'Events',
          ),
        MGSpacing.hXs,
        if (onPrestige != null)
          MGIconButton(
            icon: Icons.auto_awesome,
            onPressed: onPrestige,
            size: 44,
            backgroundColor: Colors.purple.withValues(alpha: 0.8),
            color: Colors.white,
            tooltip: 'Prestige',
          ),
        MGSpacing.hXs,
        if (onCollection != null)
          MGIconButton(
            icon: Icons.menu_book,
            onPressed: onCollection,
            size: 44,
            backgroundColor: Colors.deepPurple.withValues(alpha: 0.8),
            color: Colors.white,
            tooltip: 'Collection',
          ),
        MGSpacing.hXs,
        if (onTutorial != null)
          MGIconButton(
            icon: Icons.help,
            onPressed: onTutorial,
            size: 44,
            backgroundColor: Colors.blue.withValues(alpha: 0.8),
            color: Colors.white,
            tooltip: 'Tutorial',
          ),
        MGSpacing.hXs,
        if (onSettings != null)
          MGIconButton(
            icon: Icons.settings,
            onPressed: onSettings,
            size: 44,
            backgroundColor: Colors.grey.withValues(alpha: 0.8),
            color: Colors.white,
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
}
