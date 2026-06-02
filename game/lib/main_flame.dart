/// Cat Alchemy Workshop - Flame Engine Entry Point
///
/// Flame 엔진 기반의 새로운 앱 진입점입니다.
library;

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:cat_alchemy/game/flame/cat_alchemy_flame_game.dart';

/// 메인 앱 함수
void main() {
  runApp(const CatAlchemyFlameApp());
}

/// Cat Alchemy Flame 앱
class CatAlchemyFlameApp extends StatelessWidget {
  const CatAlchemyFlameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Alchemy Workshop - Flame Edition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: GameWidget<CatAlchemyFlameGame>.controlled(
        gameFactory: CatAlchemyFlameGame.new,
        loadingBuilder: (context) => const Material(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading Cat Alchemy Workshop...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
