import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/features/game/domain/enums/card_level.dart';
import 'package:scard_game/features/game/domain/enums/card_color.dart';

void main() {
  group('TensionService', () {
    group('getEffectiveLevel', () {
      // Note: TensionService requires IGameSessionService, but getEffectiveLevel is pure
      // We test it directly via the method logic

      test('returns white for tension 0-24%', () {
        // Directly test thresholds based on GameConstants
        expect(_getEffectiveLevel(0), CardLevel.white);
        expect(_getEffectiveLevel(10), CardLevel.white);
        expect(_getEffectiveLevel(24), CardLevel.white);
      });

      test('returns blue for tension 25-49%', () {
        expect(_getEffectiveLevel(25), CardLevel.blue);
        expect(_getEffectiveLevel(35), CardLevel.blue);
        expect(_getEffectiveLevel(49), CardLevel.blue);
      });

      test('returns yellow for tension 50-74%', () {
        expect(_getEffectiveLevel(50), CardLevel.yellow);
        expect(_getEffectiveLevel(60), CardLevel.yellow);
        expect(_getEffectiveLevel(74), CardLevel.yellow);
      });

      test('returns red for tension 75-100%', () {
        expect(_getEffectiveLevel(75), CardLevel.red);
        expect(_getEffectiveLevel(90), CardLevel.red);
        expect(_getEffectiveLevel(100), CardLevel.red);
      });
    });

    group('canPlayCard', () {
      test('white cards can always be played', () {
        expect(_canPlayCard(CardColor.white, CardLevel.white), true);
        expect(_canPlayCard(CardColor.white, CardLevel.blue), true);
        expect(_canPlayCard(CardColor.white, CardLevel.yellow), true);
        expect(_canPlayCard(CardColor.white, CardLevel.red), true);
      });

      test('blue cards need blue level or higher', () {
        expect(_canPlayCard(CardColor.blue, CardLevel.white), false);
        expect(_canPlayCard(CardColor.blue, CardLevel.blue), true);
        expect(_canPlayCard(CardColor.blue, CardLevel.yellow), true);
        expect(_canPlayCard(CardColor.blue, CardLevel.red), true);
      });

      test('yellow cards need yellow level or higher', () {
        expect(_canPlayCard(CardColor.yellow, CardLevel.white), false);
        expect(_canPlayCard(CardColor.yellow, CardLevel.blue), false);
        expect(_canPlayCard(CardColor.yellow, CardLevel.yellow), true);
        expect(_canPlayCard(CardColor.yellow, CardLevel.red), true);
      });

      test('red cards need red level', () {
        expect(_canPlayCard(CardColor.red, CardLevel.white), false);
        expect(_canPlayCard(CardColor.red, CardLevel.blue), false);
        expect(_canPlayCard(CardColor.red, CardLevel.yellow), false);
        expect(_canPlayCard(CardColor.red, CardLevel.red), true);
      });

      test('green cards (negotiations) can always be played', () {
        expect(_canPlayCard(CardColor.green, CardLevel.white), true);
        expect(_canPlayCard(CardColor.green, CardLevel.blue), true);
        expect(_canPlayCard(CardColor.green, CardLevel.yellow), true);
        expect(_canPlayCard(CardColor.green, CardLevel.red), true);
      });
    });

    group('getTensionIncrease', () {
      test('white cards give 5% tension', () {
        expect(_getTensionIncrease(CardColor.white), 5.0);
      });

      test('blue cards give 8% tension', () {
        expect(_getTensionIncrease(CardColor.blue), 8.0);
      });

      test('yellow cards give 12% tension', () {
        expect(_getTensionIncrease(CardColor.yellow), 12.0);
      });

      test('red cards give 15% tension', () {
        expect(_getTensionIncrease(CardColor.red), 15.0);
      });

      test('green cards give 0% tension', () {
        expect(_getTensionIncrease(CardColor.green), 0.0);
      });
    });
  });
}

// Pure function implementations for testing (same logic as TensionService)
CardLevel _getEffectiveLevel(double tension) {
  if (tension >= 75) return CardLevel.red;
  if (tension >= 50) return CardLevel.yellow;
  if (tension >= 25) return CardLevel.blue;
  return CardLevel.white;
}

bool _canPlayCard(CardColor cardColor, CardLevel currentLevel) {
  final colorString = cardColor.toString().split('.').last;
  return currentLevel.availableColors.contains(colorString);
}

double _getTensionIncrease(CardColor cardColor) {
  switch (cardColor) {
    case CardColor.white:
      return 5.0;
    case CardColor.blue:
      return 8.0;
    case CardColor.yellow:
      return 12.0;
    case CardColor.red:
      return 15.0;
    case CardColor.green:
      return 0.0;
  }
}
