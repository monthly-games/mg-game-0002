import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/supercell/prototype_validator.dart';

void main() {
  group('CatAlchemyPrototypeValidator', () {
    late CatAlchemyPrototypeValidator validator;

    setUp(() {
      validator = CatAlchemyPrototypeValidator();
    });

    test('makeKillDecision_returnsValidResult', () {
      final result = validator.makeKillDecision();

      expect(result, isNotNull);
      expect(result.scores, isNotNull);
      expect(result.decision, isA<KillDecision>());
      expect(result.reason, isNotEmpty);
    });

    test('evaluatePaperPrototype_calculatesScores', () {
      final score = validator.evaluatePaperPrototype();

      expect(score, isNotNull);
      expect(score.conceptStrength, greaterThanOrEqualTo(0));
      expect(score.conceptStrength, lessThanOrEqualTo(2));
      expect(score.coreLoopClarity, greaterThanOrEqualTo(0));
      expect(score.coreLoopClarity, lessThanOrEqualTo(2));
      expect(score.mechanicsViability, greaterThanOrEqualTo(0));
      expect(score.mechanicsViability, lessThanOrEqualTo(1));
      expect(score.overall, greaterThanOrEqualTo(0));
      expect(score.overall, lessThanOrEqualTo(5));
    });

    test('evaluateGraybox_calculatesScores', () {
      final score = validator.evaluateGraybox();

      expect(score, isNotNull);
      expect(score.conceptStrength, greaterThanOrEqualTo(0));
      expect(score.conceptStrength, lessThanOrEqualTo(2));
      expect(score.coreLoopClarity, greaterThanOrEqualTo(0));
      expect(score.coreLoopClarity, lessThanOrEqualTo(2));
      expect(score.mechanicsViability, greaterThanOrEqualTo(0));
      expect(score.mechanicsViability, lessThanOrEqualTo(1));
      expect(score.overall, greaterThanOrEqualTo(0));
      expect(score.overall, lessThanOrEqualTo(5));
    });

    test('generateReport_containsDecision', () {
      final report = validator.generateReport();

      expect(report, isNotEmpty);
      expect(report, contains('FINAL DECISION'));
      expect(report, contains(RegExp(r'(APPROVE|REVISE|KILL)')));
      expect(report, contains('PAPER PROTOTYPE'));
      expect(report, contains('GRAYBOX PROTOTYPE'));
      expect(report, contains('VERTICAL SLICE'));
    });

    test('evaluateVerticalSlice_calculatesScores', () {
      final score = validator.evaluateVerticalSlice();

      expect(score, isNotNull);
      expect(score.conceptStrength, greaterThanOrEqualTo(0));
      expect(score.conceptStrength, lessThanOrEqualTo(2));
      expect(score.coreLoopClarity, greaterThanOrEqualTo(0));
      expect(score.coreLoopClarity, lessThanOrEqualTo(2));
      expect(score.mechanicsViability, greaterThanOrEqualTo(0));
      expect(score.mechanicsViability, lessThanOrEqualTo(1));
      expect(score.overall, greaterThanOrEqualTo(0));
      expect(score.overall, lessThanOrEqualTo(5));
    });
  });

  group('PrototypeScore', () {
    test('fromEvaluation_calculatesConceptStrength', () {
      final score = PrototypeScore.fromEvaluation(
        'Unique cat alchemy game with mechanics',
        'Tap → merge → discover',
        ['mech1', 'mech2', 'mech3'],
      );

      expect(score.conceptStrength, greaterThan(0));
      expect(score.conceptStrength, lessThanOrEqualTo(2));
    });

    test('fromEvaluation_calculatesCoreLoopClarity', () {
      final score = PrototypeScore.fromEvaluation(
        'Concept',
        'Tap to merge → discover new cats',
        ['mech1', 'mech2', 'mech3'],
      );

      expect(score.coreLoopClarity, greaterThan(0));
      expect(score.coreLoopClarity, lessThanOrEqualTo(2));
    });

    test('fromEvaluation_calculatesMechanicsViability', () {
      final score = PrototypeScore.fromEvaluation(
        'Concept',
        'Core loop',
        ['mech1', 'mech2', 'mech3'],
      );

      expect(score.mechanicsViability, 1.0);
    });

    test('fromEvaluation_withMinimalMechanics_returnsZero', () {
      final score = PrototypeScore.fromEvaluation(
        'Concept',
        'Core loop',
        ['mech1', 'mech2'],
      );

      expect(score.mechanicsViability, 0.0);
    });
  });

  group('KillDecisionResult', () {
    test('fromScore_withHighScore_returnsApprove', () {
      final score = PrototypeScore(
        conceptStrength: 2.0,
        coreLoopClarity: 2.0,
        mechanicsViability: 1.0,
      );

      final result = KillDecisionResult.fromScore(score);

      expect(result.decision, KillDecision.approve);
      expect(result.shouldProceed, isTrue);
      expect(result.shouldKill, isFalse);
    });

    test('fromScore_withMediumScore_returnsRevise', () {
      final score = PrototypeScore(
        conceptStrength: 1.0,
        coreLoopClarity: 1.0,
        mechanicsViability: 1.0,
      );

      final result = KillDecisionResult.fromScore(score);

      expect(result.decision, KillDecision.revise);
      expect(result.shouldProceed, isFalse);
      expect(result.shouldKill, isFalse);
    });

    test('fromScore_withLowScore_returnsKill', () {
      final score = PrototypeScore(
        conceptStrength: 0.0,
        coreLoopClarity: 0.5,
        mechanicsViability: 0.0,
      );

      final result = KillDecisionResult.fromScore(score);

      expect(result.decision, KillDecision.kill);
      expect(result.shouldProceed, isFalse);
      expect(result.shouldKill, isTrue);
    });
  });

  group('KillDecisionExtension', () {
    test('displayName_returnsCorrectFormat', () {
      expect(KillDecision.approve.displayName, contains('APPROVE'));
      expect(KillDecision.revise.displayName, contains('REVISE'));
      expect(KillDecision.kill.displayName, contains('KILL'));
    });
  });
}
