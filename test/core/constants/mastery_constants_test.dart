import 'package:flutter_test/flutter_test.dart';
import 'package:jhatpat/core/constants/mastery_constants.dart';
import 'package:jhatpat/data/models/phrase_model.dart';

void main() {
  group('MasteryConstants', () {
    test('photoOptionCountForLevel', () {
      expect(MasteryConstants.photoOptionCountForLevel(0), 4);
      expect(MasteryConstants.photoOptionCountForLevel(1), 4);
      expect(MasteryConstants.photoOptionCountForLevel(2), 3);
      expect(MasteryConstants.photoOptionCountForLevel(3), 4);
    });

    test('playLevelForPhrase falls back from 5 without scenario', () {
      expect(
        MasteryConstants.playLevelForPhrase(
          storedLevel: 5,
          hasScenarioUrdu: false,
        ),
        4,
      );
      expect(
        MasteryConstants.playLevelForPhrase(
          storedLevel: 5,
          hasScenarioUrdu: true,
        ),
        5,
      );
    });

    test('shouldUseImageGrid and fill blank', () {
      expect(MasteryConstants.shouldUseImageGrid(3), isTrue);
      expect(MasteryConstants.shouldUseImageGrid(2), isFalse);
      expect(MasteryConstants.shouldUseFillBlankOnReveal(4), isTrue);
      expect(MasteryConstants.shouldUseFillBlankOnReveal(3), isFalse);
    });
  });

  group('PhraseModel example tokens', () {
    test('exampleTokens splits sentence', () {
      final PhraseModel p = PhraseModel(
        id: 'x',
        urduPhrase: 'test',
        romanised: 't',
        meaningUrdu: 'm',
        exampleSentence: 'الف ب پ',
        category: 'c',
        difficulty: 'd',
        imageUrl: '',
        revealImageUrl: '',
        isActive: true,
        createdAt: DateTime(2024),
        blankWordIndex: 1,
      );
      expect(p.exampleTokens, <String>['الف', 'ب', 'پ']);
    });
  });
}
