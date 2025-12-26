import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// VFX Manager for Cat Alchemy Workshop (MG-0002)
/// Crafting + Idle 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();

  final Random _random = Random();

  // ============================================================
  // Crafting Effects
  // ============================================================

  /// 조합 시작 - 재료 투입 이펙트
  void showIngredientAdd(Vector2 position, Color ingredientColor) {
    gameRef.add(
      _createBurstEffect(
        position: position,
        color: ingredientColor,
        count: 8,
        speed: 60,
        lifespan: 0.4,
        gravity: 100,
      ),
    );
  }

  /// 조합 진행 중 - 버블링/보글보글 이펙트
  void showBubbling(Vector2 position) {
    gameRef.add(
      _createRisingEffect(
        position: position,
        color: Colors.white.withOpacity(0.7),
        count: 5,
        speed: 40,
        lifespan: 0.6,
      ),
    );
  }

  /// 조합 성공 - 빛나는 폭발 이펙트
  void showCraftingSuccess(Vector2 position, {bool isRare = false}) {
    final color = isRare ? Colors.purple : Colors.yellow;
    final count = isRare ? 30 : 20;

    // 메인 폭발
    gameRef.add(
      _createBurstEffect(
        position: position,
        color: color,
        count: count,
        speed: 120,
        lifespan: 0.8,
        gravity: 0,
      ),
    );

    // 스파클
    gameRef.add(
      _createSparkleEffect(
        position: position,
        color: Colors.white,
        count: 15,
      ),
    );

    // 희귀 아이템은 추가 이펙트
    if (isRare) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isMounted) return;
        gameRef.add(
          _createBurstEffect(
            position: position,
            color: Colors.amber,
            count: 15,
            speed: 80,
            lifespan: 0.6,
            gravity: 0,
          ),
        );
      });
    }
  }

  /// 조합 실패 - 연기 이펙트
  void showCraftingFailure(Vector2 position) {
    gameRef.add(
      _createSmokeEffect(
        position: position,
        count: 12,
      ),
    );
  }

  /// 새 레시피 발견 - 발견 이펙트
  void showDiscovery(Vector2 position) {
    // 별 모양 스파클
    gameRef.add(
      _createSparkleEffect(
        position: position,
        color: Colors.amber,
        count: 20,
      ),
    );

    // 위로 올라가는 빛
    gameRef.add(
      _createRisingEffect(
        position: position,
        color: Colors.yellow,
        count: 10,
        speed: 80,
        lifespan: 1.0,
      ),
    );
  }

  // ============================================================
  // Idle/Collection Effects
  // ============================================================

  /// 자원 획득 - 픽업 이펙트
  void showPickup(Vector2 position, Color resourceColor) {
    gameRef.add(
      _createBurstEffect(
        position: position,
        color: resourceColor,
        count: 6,
        speed: 50,
        lifespan: 0.3,
        gravity: -50, // 위로 살짝
      ),
    );
  }

  /// 레벨업 - 축하 이펙트
  void showLevelUp(Vector2 position) {
    // 큰 폭발
    gameRef.add(
      _createBurstEffect(
        position: position,
        color: Colors.amber,
        count: 40,
        speed: 150,
        lifespan: 1.0,
        gravity: 100,
      ),
    );

    // 별 스파클
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isMounted) return;
        gameRef.add(
          _createSparkleEffect(
            position: position + Vector2(
              (_random.nextDouble() - 0.5) * 60,
              (_random.nextDouble() - 0.5) * 60,
            ),
            color: Colors.yellow,
            count: 8,
          ),
        );
      });
    }
  }

  /// 코인 획득 - 코인 이펙트
  void showCoinGain(Vector2 position, {int amount = 1}) {
    final count = (amount / 10).clamp(5, 20).toInt();

    gameRef.add(
      _createCoinEffect(
        position: position,
        count: count,
      ),
    );
  }

  /// 오프라인 보상 - 보상 비처럼 내리기
  void showOfflineReward(Vector2 screenCenter) {
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (!isMounted) return;
        final pos = screenCenter + Vector2(
          (_random.nextDouble() - 0.5) * 200,
          -50,
        );
        gameRef.add(
          _createCoinEffect(position: pos, count: 8),
        );
      });
    }
  }

  // ============================================================
  // Cat Character Effects
  // ============================================================

  /// 고양이 반응 - 하트 이펙트
  void showCatHeart(Vector2 position) {
    gameRef.add(
      _createRisingEffect(
        position: position + Vector2(0, -30),
        color: Colors.pink,
        count: 3,
        speed: 30,
        lifespan: 1.0,
      ),
    );
  }

  /// 고양이 작업 - 반짝임 이펙트
  void showCatWorking(Vector2 position) {
    gameRef.add(
      _createSparkleEffect(
        position: position,
        color: Colors.white,
        count: 5,
      ),
    );
  }

  // ============================================================
  // UI Effects
  // ============================================================

  /// 버튼 탭 - 터치 피드백
  void showTapFeedback(Vector2 position) {
    gameRef.add(
      _createBurstEffect(
        position: position,
        color: Colors.white.withOpacity(0.5),
        count: 6,
        speed: 40,
        lifespan: 0.2,
        gravity: 0,
      ),
    );
  }

  /// 숫자 팝업 (데미지, 획득량 등)
  void showNumberPopup(Vector2 position, String text, {Color color = Colors.white}) {
    gameRef.add(
      _NumberPopup(
        position: position,
        text: text,
        color: color,
      ),
    );
  }

  // ============================================================
  // Private Effect Generators
  // ============================================================

  ParticleSystemComponent _createBurstEffect({
    required Vector2 position,
    required Color color,
    required int count,
    required double speed,
    required double lifespan,
    double gravity = 200,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: lifespan,
        generator: (i) {
          final angle = (i / count) * 2 * pi;
          final velocity = Vector2(cos(angle), sin(angle)) *
              (speed * (0.5 + _random.nextDouble() * 0.5));

          return AcceleratedParticle(
            position: position.clone(),
            speed: velocity,
            acceleration: Vector2(0, gravity),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final size = (1.0 - progress * 0.5) * 4;

                canvas.drawCircle(
                  Offset.zero,
                  size,
                  Paint()..color = color.withOpacity(opacity),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createRisingEffect({
    required Vector2 position,
    required Color color,
    required int count,
    required double speed,
    required double lifespan,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: lifespan,
        generator: (i) {
          final spreadX = (_random.nextDouble() - 0.5) * 40;

          return AcceleratedParticle(
            position: position.clone() + Vector2(spreadX, 0),
            speed: Vector2(0, -speed),
            acceleration: Vector2(0, -20),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final size = 3 * (1.0 - progress * 0.3);

                canvas.drawCircle(
                  Offset.zero,
                  size,
                  Paint()..color = color.withOpacity(opacity),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createSparkleEffect({
    required Vector2 position,
    required Color color,
    required int count,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.6,
        generator: (i) {
          final angle = _random.nextDouble() * 2 * pi;
          final speed = 50 + _random.nextDouble() * 30;
          final velocity = Vector2(cos(angle), sin(angle)) * speed;

          return AcceleratedParticle(
            position: position.clone(),
            speed: velocity,
            acceleration: Vector2(0, 30),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
                final size = 3 * (1.0 - particle.progress * 0.5);

                // 별 모양
                final path = Path();
                for (int j = 0; j < 5; j++) {
                  final a = (j * 4 * pi / 5) - pi / 2;
                  final x = cos(a) * size;
                  final y = sin(a) * size;
                  if (j == 0) {
                    path.moveTo(x, y);
                  } else {
                    path.lineTo(x, y);
                  }
                }
                path.close();

                canvas.drawPath(
                  path,
                  Paint()..color = color.withOpacity(opacity),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createSmokeEffect({
    required Vector2 position,
    required int count,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 1.2,
        generator: (i) {
          final spreadX = (_random.nextDouble() - 0.5) * 30;

          return AcceleratedParticle(
            position: position.clone() + Vector2(spreadX, 0),
            speed: Vector2(
              (_random.nextDouble() - 0.5) * 20,
              -40 - _random.nextDouble() * 20,
            ),
            acceleration: Vector2(0, -10),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final opacity = (0.6 - progress * 0.6).clamp(0.0, 1.0);
                final size = 8 + progress * 12;

                canvas.drawCircle(
                  Offset.zero,
                  size,
                  Paint()..color = Colors.grey.withOpacity(opacity),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createCoinEffect({
    required Vector2 position,
    required int count,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.8,
        generator: (i) {
          final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi / 3;
          final speed = 150 + _random.nextDouble() * 100;
          final velocity = Vector2(cos(angle), sin(angle)) * speed;

          return AcceleratedParticle(
            position: position.clone(),
            speed: velocity,
            acceleration: Vector2(0, 400),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final opacity = (1.0 - particle.progress * 0.3).clamp(0.0, 1.0);
                final rotation = particle.progress * 4 * pi;

                canvas.save();
                canvas.rotate(rotation);

                // 코인 모양 (타원)
                canvas.drawOval(
                  const Rect.fromLTWH(-4, -3, 8, 6),
                  Paint()..color = Colors.amber.withOpacity(opacity),
                );
                canvas.drawOval(
                  const Rect.fromLTWH(-4, -3, 8, 6),
                  Paint()
                    ..color = Colors.orange.withOpacity(opacity)
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1,
                );

                canvas.restore();
              },
            ),
          );
        },
      ),
    );
  }
}

/// 숫자/텍스트 팝업 컴포넌트
class _NumberPopup extends TextComponent {
  _NumberPopup({
    required Vector2 position,
    required String text,
    required Color color,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: const [
                Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 위로 떠오르면서 페이드아웃
    add(MoveByEffect(
      Vector2(0, -40),
      EffectController(duration: 0.8, curve: Curves.easeOut),
    ));

    add(OpacityEffect.fadeOut(
      EffectController(duration: 0.8, startDelay: 0.3),
    ));

    add(RemoveEffect(delay: 1.0));
  }
}
