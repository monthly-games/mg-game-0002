import 'package:mg_common_game/systems/tutorial/tutorial.dart';

/// Tutorial configuration for MG-0002: Cat Alchemy (Merge/Idle).
///
/// Placeholder tutorial steps for v1.2.0 pilot integration.
/// In production, replace descriptions with localized strings
/// and add targetSelector for highlight positioning.
const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: 'Cat Alchemy Tutorial',
  steps: [
    TutorialStep(
      id: 'welcome',
      title: 'Welcome to Cat Alchemy!',
      description: 'Merge cats to create powerful alchemical creatures.',
      actionHint: 'Tap to continue',
    ),
    TutorialStep(
      id: 'first_merge',
      title: 'Your First Merge',
      description: 'Drag two identical cats together to merge them.',
      actionHint: 'Drag & drop',
      targetSelector: 'merge_area',
    ),
    TutorialStep(
      id: 'workshop_upgrade',
      title: 'Upgrade Your Workshop',
      description: 'Spend gold to upgrade your workshop level.',
      actionHint: 'Tap upgrade',
      targetSelector: 'workshop_button',
    ),
    TutorialStep(
      id: 'idle_earnings',
      title: 'Idle Earnings',
      description:
          'Your cats earn gold even while you are away. '
          'Come back often to collect!',
      actionHint: 'Tap to continue',
    ),
  ],
  skippable: true,
  showOnFirstLaunch: true,
  trigger: TutorialTrigger.firstLaunch,
);
