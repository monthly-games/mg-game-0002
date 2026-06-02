/// Menu Button Component - 메뉴 버튼 컴포넌트
///
/// 메뉴를 토글하는 버튼입니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// 메뉴 버튼 컴포넌트
class MenuButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;

  MenuButtonComponent({
    required Vector2 position,
    required this.onTap,
  }) : super(
          position: position,
          size: Vector2(80, 40),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 버튼 배경
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(8),
    );
    canvas.drawRRect(rRect, paint);

    // 버튼 텍스트
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Menu',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.x);

    // 텍스트 중앙 정렬
    final offset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    onTap();
  }
}
