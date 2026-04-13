import 'package:mg_common_game/systems/tutorial/tutorial.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/systems/tutorial/tutorial_data.dart';

/// Tutorial configuration for MG-0002: Cat Alchemy (Merge/Idle).
///
/// Placeholder tutorial steps for v1.2.0 pilot integration.
/// In production, replace descriptions with localized strings
/// and add targetKey for highlight positioning.

// Global keys for tutorial targets
final gridKey = GlobalKey();
final comboAreaKey = GlobalKey();
final powerupKey = GlobalKey();
final goalAreaKey = GlobalKey();

const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: 'Cat Alchemy Tutorial',
  steps: [
    TutorialStep(
      id: 'grid',
      title: '3개를 매치하세요',
      description: '같은 색 타일 3개를 연결하여 제거합니다.',
      targetSelector: null, // TODO: assign gridKey
    ),
    TutorialStep(
      id: 'combo_area',
      title: '콤보를 만드세요',
      description: '연속 매치로 콤보 보너스를 획득하세요.',
      targetSelector: null, // TODO: assign comboAreaKey
    ),
    TutorialStep(
      id: 'powerup',
      title: '파워업을 사용하세요',
      description: '특수 타일을 만들어 강력한 효과를 발동하세요.',
      targetSelector: null, // TODO: assign powerupKey
    ),
    TutorialStep(
      id: 'goal_area',
      title: '보드를 클리어하세요',
      description: '목표를 달성하여 스테이지를 클리어하세요.',
      targetSelector: null, // TODO: assign goalAreaKey
    ),

  ],
  skippable: true,
);
