import 'package:flutter_test/flutter_test.dart';
import 'package:jhatpat/core/constants/scoring_constants.dart';
import 'package:jhatpat/core/constants/urdu_utils.dart';

void main() {
  group('ScoringConstants.calculatePoints', () {
    test('returns 0 for incorrect answers', () {
      expect(ScoringConstants.calculatePoints(15, false), 0);
      expect(ScoringConstants.calculatePoints(0, false), 0);
    });

    test('applies correct score brackets', () {
      expect(ScoringConstants.calculatePoints(15, true), 500);
      expect(ScoringConstants.calculatePoints(12, true), 500);
      expect(ScoringConstants.calculatePoints(11, true), 400);
      expect(ScoringConstants.calculatePoints(9, true), 400);
      expect(ScoringConstants.calculatePoints(6, true), 300);
      expect(ScoringConstants.calculatePoints(3, true), 200);
      expect(ScoringConstants.calculatePoints(0, true), 100);
    });
  });

  group('streak multiplier and labels', () {
    test('returns expected multipliers', () {
      expect(ScoringConstants.calculateStreakMultiplier(1), 1.0);
      expect(ScoringConstants.calculateStreakMultiplier(2), 1.0);
      expect(ScoringConstants.calculateStreakMultiplier(3), 1.5);
      expect(ScoringConstants.calculateStreakMultiplier(5), 2.0);
      expect(ScoringConstants.calculateStreakMultiplier(8), 3.0);
    });

    test('returns expected labels', () {
      expect(ScoringConstants.getStreakLabel(1), '');
      expect(ScoringConstants.getStreakLabel(3), '🔥 آگ لگ گئی');
      expect(ScoringConstants.getStreakLabel(5), '⚡ ناقابلِ روک');
      expect(ScoringConstants.getStreakLabel(8), '👑 استادوں کا استاد');
    });

    test('applies multiplier as rounded int', () {
      expect(ScoringConstants.applyStreakMultiplier(100, 1), 100);
      expect(ScoringConstants.applyStreakMultiplier(100, 3), 150);
      expect(ScoringConstants.applyStreakMultiplier(225, 3), 338);
      expect(ScoringConstants.applyStreakMultiplier(100, 5), 200);
      expect(ScoringConstants.applyStreakMultiplier(100, 8), 300);
    });
  });

  group('calculateSessionXp', () {
    test('zero correct, no daily bonus', () {
      expect(
        ScoringConstants.calculateSessionXp(
          correctCount: 0,
          totalCards: 10,
          dailyGoalHit: false,
        ),
        20,
      );
    });

    test('mixed session with daily bonus', () {
      expect(
        ScoringConstants.calculateSessionXp(
          correctCount: 7,
          totalCards: 10,
          dailyGoalHit: true,
        ),
        115,
      );
    });

    test('perfect session with daily bonus', () {
      expect(
        ScoringConstants.calculateSessionXp(
          correctCount: 10,
          totalCards: 10,
          dailyGoalHit: true,
        ),
        195,
      );
    });
  });

  group('toUrduNumerals', () {
    test('maps representative values', () {
      expect(toUrduNumerals(0), '٠');
      expect(toUrduNumerals(5), '٥');
      expect(toUrduNumerals(10), '١٠');
      expect(toUrduNumerals(42), '٤٢');
      expect(toUrduNumerals(99), '٩٩');
    });
  });
}
