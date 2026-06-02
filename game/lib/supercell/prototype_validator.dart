/// Supercell Cells First - Prototype Validator for Cat Alchemy
///
/// Evaluates the game against Supercell's rapid prototyping criteria.
library;

/// Prototype evaluation scores
class PrototypeScore {
  final double conceptStrength; // 0-2
  final double coreLoopClarity; // 0-2
  final double mechanicsViability; // 0-1
  final double overall;

  PrototypeScore({
    required this.conceptStrength,
    required this.coreLoopClarity,
    required this.mechanicsViability,
  }) : overall = conceptStrength + coreLoopClarity + mechanicsViability;

  factory PrototypeScore.fromEvaluation(
    String concept,
    String coreLoop,
    List<String> mechanics,
  ) {
    double conceptScore = 0;
    if (concept.isNotEmpty && concept.length > 20) {
      conceptScore += 1;
    }
    if (concept.toLowerCase().contains('unique') ||
        concept.toLowerCase().contains('cat') ||
        concept.toLowerCase().contains('alchemy')) {
      conceptScore += 1;
    }

    double loopScore = 0;
    if (coreLoop.isNotEmpty) loopScore += 1;
    if (coreLoop.contains('→') || coreLoop.contains('merge') || coreLoop.contains('tap')) {
      loopScore += 1;
    }

    double mechanicsScore = 0;
    if (mechanics.length >= 3) mechanicsScore += 1;

    return PrototypeScore(
      conceptStrength: conceptScore,
      coreLoopClarity: loopScore,
      mechanicsViability: mechanicsScore,
    );
  }

  @override
  String toString() =>
      'PrototypeScore(concept: $conceptStrength, loop: $coreLoopClarity, mechanics: $mechanicsViability, overall: $overall/5.0)';
}

/// Kill decision for prototype phase
enum KillDecision { approve, revise, kill }

class KillDecisionResult {
  final KillDecision decision;
  final String reason;
  final PrototypeScore scores;

  KillDecisionResult({
    required this.decision,
    required this.reason,
    required this.scores,
  });

  factory KillDecisionResult.fromScore(PrototypeScore scores) {
    if (scores.overall >= 4.0) {
      return KillDecisionResult(
        decision: KillDecision.approve,
        reason: 'Strong concept with clear core loop and viable mechanics',
        scores: scores,
      );
    } else if (scores.overall >= 3.0) {
      return KillDecisionResult(
        decision: KillDecision.revise,
        reason: 'Promising but needs refinement in 24 hours',
        scores: scores,
      );
    } else {
      return KillDecisionResult(
        decision: KillDecision.kill,
        reason: 'Below minimum threshold. Consider post-mortem.',
        scores: scores,
      );
    }
  }

  bool get shouldKill => decision == KillDecision.kill;
  bool get shouldProceed => decision == KillDecision.approve;
}

/// Cat Alchemy specific prototype validator
class CatAlchemyPrototypeValidator {
  /// Evaluate paper prototype
  PrototypeScore evaluatePaperPrototype() {
    return PrototypeScore.fromEvaluation(
      'Merge cats to create alchemical creatures with unique properties',
      'Tap to merge → Discover new cats → Earn resources → Upgrade workspace → Merge more',
      ['Merge Mechanics', 'Idle Generation', 'Collection Progress', 'Upgrade System', 'Catalyst Creation'],
    );
  }

  /// Evaluate graybox (playable without art)
  PrototypeScore evaluateGraybox() {
    return PrototypeScore.fromEvaluation(
      'Core merge gameplay with colored rectangles representing cats',
      'Tap matching items → Merge animation → Reward display → Progress update',
      ['Tap Interaction', 'Match Detection', 'Reward Feedback', 'Progress Tracking'],
    );
  }

  /// Evaluate vertical slice (one polished experience)
  PrototypeScore evaluateVerticalSlice() {
    return PrototypeScore.fromEvaluation(
      'Complete first 5 minutes with polished UI, tutorial, and win state',
      'Tutorial → First merge → First discovery → Reward celebration → Continue prompt',
      ['Onboarding', 'First Merge', 'Discovery', 'Achievement', 'Retention Hook'],
    );
  }

  /// Make final kill decision
  KillDecisionResult makeKillDecision() {
    final paperScore = evaluatePaperPrototype();
    final grayboxScore = evaluateGraybox();
    final verticalScore = evaluateVerticalSlice();

    // Average all stages
    final avgScore = PrototypeScore(
      conceptStrength: (paperScore.conceptStrength + grayboxScore.conceptStrength + verticalScore.conceptStrength) / 3,
      coreLoopClarity: (paperScore.coreLoopClarity + grayboxScore.coreLoopClarity + verticalScore.coreLoopClarity) / 3,
      mechanicsViability: (paperScore.mechanicsViability + grayboxScore.mechanicsViability + verticalScore.mechanicsViability) / 3,
    );

    return KillDecisionResult.fromScore(avgScore);
  }

  /// Generate validation report
  String generateReport() {
    final paper = evaluatePaperPrototype();
    final graybox = evaluateGraybox();
    final vertical = evaluateVerticalSlice();
    final decision = makeKillDecision();

    return '''
═══════════════════════════════════════════════
     CELLS FIRST - PROTOTYPE VALIDATION REPORT
            Cat Alchemy Workshop (MG-0002)
═══════════════════════════════════════════════

📱 PAPER PROTOTYPE
Score: ${paper.overall}/5.0
Concept: ${paper.conceptStrength}/2.0
Core Loop: ${paper.coreLoopClarity}/2.0
Mechanics: ${paper.mechanicsViability}/1.0

🎮 GRAYBOX PROTOTYPE
Score: ${graybox.overall}/5.0
Concept: ${graybox.conceptStrength}/2.0
Core Loop: ${graybox.coreLoopClarity}/2.0
Mechanics: ${graybox.mechanicsViability}/1.0

✨ VERTICAL SLICE
Score: ${vertical.overall}/5.0
Concept: ${vertical.conceptStrength}/2.0
Core Loop: ${vertical.coreLoopClarity}/2.0
Mechanics: ${vertical.mechanicsViability}/1.0

─────────────────────────────────────────────
FINAL DECISION: ${decision.decision.toString().toUpperCase()}
Overall Score: ${decision.scores.overall}/5.0
Reason: ${decision.reason}

${decision.shouldKill
    ? '❌ PROJECT KILLED - Create post-mortem and move to next concept'
    : '✅ PROJECT APPROVED - Proceed to full development'}
═══════════════════════════════════════════════
''';
  }
}

/// Extension for KillDecision enum
extension KillDecisionExtension on KillDecision {
  String get displayName {
    switch (this) {
      case KillDecision.approve:
        return '✅ APPROVE';
      case KillDecision.revise:
        return '⚠️ REVISE';
      case KillDecision.kill:
        return '❌ KILL';
    }
  }
}
