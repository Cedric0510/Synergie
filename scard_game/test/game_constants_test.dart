import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/core/constants/game_constants.dart';

void main() {
  group('GameConstants - Cartes spéciales', () {
    test('Ultima card is properly defined', () {
      expect(GameConstants.ultimaCardId, 'red_016');
      expect(GameConstants.ultimaCardName, 'ULTIMA');
    });
  });

  group('GameConstants - Limites de main', () {
    test('hand size limits are valid', () {
      expect(GameConstants.maxHandSize, 7);
      expect(GameConstants.initialHandSize, 5);
      expect(GameConstants.minHandSizeBeforeDraw, 3);

      // Logical relationships
      expect(
        GameConstants.initialHandSize,
        lessThanOrEqualTo(GameConstants.maxHandSize),
      );
      expect(
        GameConstants.minHandSizeBeforeDraw,
        lessThan(GameConstants.initialHandSize),
      );
    });
  });

  group('GameConstants - Points d\'Intimité (PI)', () {
    test('PI limits are valid', () {
      expect(GameConstants.initialPI, 5);
      expect(GameConstants.maxPI, 99);
      expect(GameConstants.minPI, 0);

      // Logical relationships
      expect(GameConstants.initialPI, greaterThan(GameConstants.minPI));
      expect(GameConstants.initialPI, lessThan(GameConstants.maxPI));
    });
  });

  group('GameConstants - Tension', () {
    test('tension limits are valid', () {
      expect(GameConstants.maxTension, 100.0);
      expect(GameConstants.minTension, 0.0);
    });

    test('tension by card color covers all colors', () {
      expect(GameConstants.tensionByCardColor.containsKey('white'), true);
      expect(GameConstants.tensionByCardColor.containsKey('blue'), true);
      expect(GameConstants.tensionByCardColor.containsKey('yellow'), true);
      expect(GameConstants.tensionByCardColor.containsKey('red'), true);
      expect(GameConstants.tensionByCardColor.containsKey('green'), true);
    });

    test('tension values increase with card power', () {
      final white = GameConstants.tensionByCardColor['white']!;
      final blue = GameConstants.tensionByCardColor['blue']!;
      final yellow = GameConstants.tensionByCardColor['yellow']!;
      final red = GameConstants.tensionByCardColor['red']!;
      final green = GameConstants.tensionByCardColor['green']!;

      expect(white, 5.0);
      expect(blue, 10.0);
      expect(yellow, 15.0);
      expect(red, 20.0);
      expect(green, 0.0); // Négociation cards don't increase tension

      // Increasing order
      expect(white, lessThan(blue));
      expect(blue, lessThan(yellow));
      expect(yellow, lessThan(red));
    });

    test('tension thresholds unlock colors progressively', () {
      expect(GameConstants.tensionThresholdBlue, 25.0);
      expect(GameConstants.tensionThresholdYellow, 50.0);
      expect(GameConstants.tensionThresholdRed, 75.0);

      // Thresholds are in increasing order
      expect(
        GameConstants.tensionThresholdBlue,
        lessThan(GameConstants.tensionThresholdYellow),
      );
      expect(
        GameConstants.tensionThresholdYellow,
        lessThan(GameConstants.tensionThresholdRed),
      );
      expect(
        GameConstants.tensionThresholdRed,
        lessThan(GameConstants.maxTension),
      );
    });
  });

  group('GameConstants - Compteur ULTIMA', () {
    test('ULTIMA counter limits are valid', () {
      expect(GameConstants.ultimaMaxCount, 5);
      expect(GameConstants.ultimaInitialCount, 0);

      expect(
        GameConstants.ultimaInitialCount,
        lessThan(GameConstants.ultimaMaxCount),
      );
    });
  });

  group('GameConstants - Deck', () {
    test('deck size is reasonable', () {
      expect(GameConstants.deckSize, 30);
      expect(GameConstants.deckSize, greaterThan(GameConstants.maxHandSize));
    });
  });

  group('GameConstants - UI Timings', () {
    test('timing values are positive', () {
      expect(GameConstants.dragDropDelay, greaterThan(0));
      expect(GameConstants.longPressDelay, greaterThan(0));
      expect(GameConstants.animationDuration, greaterThan(0));
      expect(GameConstants.snackbarDuration, greaterThan(0));
    });

    test('timing values are in expected ranges', () {
      // Drag drop delay should be quick
      expect(GameConstants.dragDropDelay, lessThanOrEqualTo(200));

      // Long press should be longer than drag drop
      expect(
        GameConstants.longPressDelay,
        greaterThanOrEqualTo(GameConstants.dragDropDelay),
      );

      // Animation should be perceptible but not slow
      expect(GameConstants.animationDuration, greaterThanOrEqualTo(100));
      expect(GameConstants.animationDuration, lessThanOrEqualTo(500));

      // Snackbar should be readable
      expect(GameConstants.snackbarDuration, greaterThanOrEqualTo(1000));
    });
  });

  group('GameConstants - Code de partie', () {
    test('game code parameters are valid', () {
      expect(GameConstants.gameCodeLength, 6);
      expect(GameConstants.gameCodeChars.isNotEmpty, true);
    });

    test('game code chars exclude ambiguous characters', () {
      // O, 0, I, 1 are commonly excluded to avoid confusion
      expect(GameConstants.gameCodeChars.contains('O'), false);
      expect(GameConstants.gameCodeChars.contains('0'), false);
      expect(GameConstants.gameCodeChars.contains('I'), false);
      expect(GameConstants.gameCodeChars.contains('1'), false);
    });

    test('game code chars are uppercase alphanumeric', () {
      for (final char in GameConstants.gameCodeChars.split('')) {
        final isUpperCase = char == char.toUpperCase();
        final isAlphaNumeric = RegExp(r'^[A-Z0-9]$').hasMatch(char);
        expect(
          isUpperCase && isAlphaNumeric,
          true,
          reason: 'Character "$char" should be uppercase alphanumeric',
        );
      }
    });

    test('game code has enough entropy', () {
      // With 32 characters and 6 positions: 32^6 = 1,073,741,824 possibilities
      final possibilities = GameConstants.gameCodeChars.length.toDouble();
      final codeLength = GameConstants.gameCodeLength.toDouble();
      final totalCombinations = _pow(possibilities, codeLength);

      // At least 1 billion combinations
      expect(totalCombinations, greaterThan(1000000000));
    });
  });
}

double _pow(double base, double exponent) {
  double result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
