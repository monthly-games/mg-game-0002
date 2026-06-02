/// Resource Display Component - 리소스 디스플레이 컴포넌트
///
/// 골드, 보석 등 리소스를 표시합니다.
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 리소스 디스플레이 컴포넌트
class ResourceDisplayComponent extends PositionComponent {
  final String resourceName;
  int _value = 0;

  ResourceDisplayComponent({
    required this.resourceName,
    required Vector2 position,
  }) : super(position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 배경
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, 120, 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(rRect, paint);

    // 리소스 이름
    final namePainter = TextPainter(
      text: TextSpan(
        text: '$resourceName:',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, const Offset(8, 8));

    // 리소스 값
    final valuePainter = TextPainter(
      text: TextSpan(
        text: '$_value',
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout();
    valuePainter.paint(canvas, Offset(110 - valuePainter.width, 8));
  }

  /// 값 업데이트
  void updateValue(int value) {
    _value = value;
  }

  /// 현재 값 반환
  int get value => _value;
}
