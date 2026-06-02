import 'package:flutter_test/flutter_test.dart';
import 'package:cat_alchemy/supercell/playable_fun_validator.dart';

void main() {
  group('CatAlchemyPlayableFunValidator', () {
    late CatAlchemyPlayableFunValidator validator;

    setUp(() {
      validator = CatAlchemyPlayableFunValidator();
    });

    test('firstFiveSeconds_allChecksPass', () {
      final result = validator.testFirstFiveSeconds();

      expect(result, isNotNull);
      expect(result.understandsGame, isTrue);
      expect(result.knowsWhatToDo, isTrue);
      expect(result.feelsGood, isTrue);
      expect(result.wantsMore, isTrue);
      expect(result.passes, isTrue);
    });

    test('coreLoopValidation_allElementsPresent', () {
      final result = validator.validateCoreLoop();

      expect(result, isNotNull);
      expect(result.isComplete, isTrue);
      expect(result.elements.length, greaterThanOrEqualTo(5));
      expect(result.missingElements, isEmpty);
    });

    test('funScore_returnsValidRange', () {
      final score = validator.scoreFunFactor();

      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(5));
    });

    test('validate_returnsCompleteResult', () {
      final result = validator.validate();

      expect(result, isNotNull);
      expect(result.firstFive, isNotNull);
      expect(result.coreLoop, isNotNull);
      expect(result.funScore, greaterThanOrEqualTo(0));
      expect(result.overallPass, isTrue);
      expect(result.report, isNotEmpty);
    });

    test('report_containsAllSections', () {
      final result = validator.validate();

      expect(result.report, contains('FIRST 5 SECONDS'));
      expect(result.report, contains('CORE LOOP'));
      expect(result.report, contains('FUN FACTOR'));
      expect(result.report, contains('FINAL VERDICT'));
    });

    test('validateCoreLoop_includesAllRequiredElements', () {
      final result = validator.validateCoreLoop();

      expect(result.elements.containsKey(CoreLoopElement.action), isTrue);
      expect(result.elements.containsKey(CoreLoopElement.feedback), isTrue);
      expect(result.elements.containsKey(CoreLoopElement.reward), isTrue);
      expect(result.elements.containsKey(CoreLoopElement.progression), isTrue);
      expect(result.elements.containsKey(CoreLoopElement.motivation), isTrue);
    });

    test('scoreFunFactor_measuresAllFiveCriteria', () {
      final score = validator.scoreFunFactor();

      // Fun score should be sum of 5 criteria (each worth 1 point)
      expect(score, equals(5.0));
    });
  });

  group('FirstFiveSecondsResult', () {
    test('passes_returnsTrueWhenAllChecksPass', () {
      final result = FirstFiveSecondsResult(
        understandsGame: true,
        knowsWhatToDo: true,
        feelsGood: true,
        wantsMore: true,
      );

      expect(result.passes, isTrue);
    });

    test('passes_returnsFalseWhenAnyCheckFails', () {
      final result = FirstFiveSecondsResult(
        understandsGame: true,
        knowsWhatToDo: true,
        feelsGood: false,
        wantsMore: true,
      );

      expect(result.passes, isFalse);
    });

    test('passes_returnsFalseWhenIssuesExist', () {
      final result = FirstFiveSecondsResult(
        understandsGame: true,
        knowsWhatToDo: true,
        feelsGood: true,
        wantsMore: false,
        issues: ['Hook too weak'],
      );

      expect(result.passes, isFalse);
      expect(result.issues, contains('Hook too weak'));
    });
  });

  group('CoreLoopValidationResult', () {
    test('isComplete_returnsTrueWhenAllElementsPresent', () {
      final result = CoreLoopValidationResult(
        elements: {
          CoreLoopElement.action: true,
          CoreLoopElement.feedback: true,
          CoreLoopElement.reward: true,
          CoreLoopElement.progression: true,
          CoreLoopElement.motivation: true,
        },
        missingElements: [],
      );

      expect(result.isComplete, isTrue);
    });

    test('isComplete_returnsFalseWhenAnyElementMissing', () {
      final result = CoreLoopValidationResult(
        elements: {
          CoreLoopElement.action: true,
          CoreLoopElement.feedback: false,
          CoreLoopElement.reward: true,
          CoreLoopElement.progression: true,
          CoreLoopElement.motivation: true,
        },
        missingElements: [CoreLoopElement.feedback.toString()],
      );

      expect(result.isComplete, isFalse);
    });
  });

  group('PlayableFunResult', () {
    test('overallPass_returnsTrueWhenAllCriteriaPass', () {
      final result = PlayableFunResult(
        firstFive: FirstFiveSecondsResult(
          understandsGame: true,
          knowsWhatToDo: true,
          feelsGood: true,
          wantsMore: true,
        ),
        coreLoop: CoreLoopValidationResult(
          elements: {
            CoreLoopElement.action: true,
            CoreLoopElement.feedback: true,
            CoreLoopElement.reward: true,
            CoreLoopElement.progression: true,
            CoreLoopElement.motivation: true,
          },
          missingElements: [],
        ),
        funScore: 4.0,
      );

      expect(result.overallPass, isTrue);
    });

    test('overallPass_returnsFalseWhenFunScoreLow', () {
      final result = PlayableFunResult(
        firstFive: FirstFiveSecondsResult(
          understandsGame: true,
          knowsWhatToDo: true,
          feelsGood: true,
          wantsMore: true,
        ),
        coreLoop: CoreLoopValidationResult(
          elements: {
            CoreLoopElement.action: true,
            CoreLoopElement.feedback: true,
            CoreLoopElement.reward: true,
            CoreLoopElement.progression: true,
            CoreLoopElement.motivation: true,
          },
          missingElements: [],
        ),
        funScore: 2.0,
      );

      expect(result.overallPass, isFalse);
    });

    test('overallPass_returnsFalseWhenCoreLoopIncomplete', () {
      final result = PlayableFunResult(
        firstFive: FirstFiveSecondsResult(
          understandsGame: true,
          knowsWhatToDo: true,
          feelsGood: true,
          wantsMore: true,
        ),
        coreLoop: CoreLoopValidationResult(
          elements: {
            CoreLoopElement.action: true,
            CoreLoopElement.feedback: false,
            CoreLoopElement.reward: true,
            CoreLoopElement.progression: true,
            CoreLoopElement.motivation: true,
          },
          missingElements: [CoreLoopElement.feedback.toString()],
        ),
        funScore: 4.0,
      );

      expect(result.overallPass, isFalse);
    });

    test('report_containsFormattedContent', () {
      final result = PlayableFunResult(
        firstFive: FirstFiveSecondsResult(
          understandsGame: true,
          knowsWhatToDo: true,
          feelsGood: true,
          wantsMore: true,
        ),
        coreLoop: CoreLoopValidationResult(
          elements: {
            CoreLoopElement.action: true,
            CoreLoopElement.feedback: true,
            CoreLoopElement.reward: true,
            CoreLoopElement.progression: true,
            CoreLoopElement.motivation: true,
          },
          missingElements: [],
        ),
        funScore: 5.0,
      );

      expect(result.report, contains('✅'));
      expect(result.report, contains('Score:'));
    });
  });

  group('CoreLoopElement', () {
    test('allEnumValues_exist', () {
      expect(CoreLoopElement.action, isNotNull);
      expect(CoreLoopElement.feedback, isNotNull);
      expect(CoreLoopElement.reward, isNotNull);
      expect(CoreLoopElement.progression, isNotNull);
      expect(CoreLoopElement.motivation, isNotNull);
    });
  });
}
