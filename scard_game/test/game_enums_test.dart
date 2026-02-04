import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/features/game/domain/enums/game_phase.dart';
import 'package:scard_game/features/game/domain/enums/card_level.dart';
import 'package:scard_game/features/game/domain/enums/card_color.dart';

void main() {
  group('GamePhase', () {
    test('all phases are defined', () {
      expect(GamePhase.values.length, 5);
      expect(GamePhase.values, contains(GamePhase.draw));
      expect(GamePhase.values, contains(GamePhase.main));
      expect(GamePhase.values, contains(GamePhase.response));
      expect(GamePhase.values, contains(GamePhase.resolution));
      expect(GamePhase.values, contains(GamePhase.end));
    });

    test('phases have correct display names', () {
      expect(GamePhase.draw.displayName, 'Enchantement & Pioche');
      expect(GamePhase.main.displayName, 'Phase Principale');
      expect(GamePhase.response.displayName, 'Réponse');
      expect(GamePhase.resolution.displayName, 'Résolution');
      expect(GamePhase.end.displayName, 'Fin de Tour');
    });

    test('phase order is correct for turn flow', () {
      // Turn flow: draw -> main -> response -> resolution -> end -> (next player) draw
      final phases = GamePhase.values;
      expect(phases[0], GamePhase.draw);
      expect(phases[1], GamePhase.main);
      expect(phases[2], GamePhase.response);
      expect(phases[3], GamePhase.resolution);
      expect(phases[4], GamePhase.end);
    });
  });

  group('CardLevel', () {
    test('all levels are defined', () {
      expect(CardLevel.values.length, 4);
    });

    test('levels have correct tension thresholds', () {
      // Based on GameConstants
      expect(CardLevel.white.availableColors, contains('white'));
      expect(CardLevel.blue.availableColors, contains('white'));
      expect(CardLevel.blue.availableColors, contains('blue'));
      expect(CardLevel.yellow.availableColors, contains('white'));
      expect(CardLevel.yellow.availableColors, contains('blue'));
      expect(CardLevel.yellow.availableColors, contains('yellow'));
      expect(CardLevel.red.availableColors, contains('white'));
      expect(CardLevel.red.availableColors, contains('blue'));
      expect(CardLevel.red.availableColors, contains('yellow'));
      expect(CardLevel.red.availableColors, contains('red'));
    });

    test('green cards are always available at all levels', () {
      for (final level in CardLevel.values) {
        expect(
          level.availableColors.contains('green'),
          true,
          reason: 'Green should be available at $level',
        );
      }
    });
  });

  group('CardColor', () {
    test('all colors are defined', () {
      expect(CardColor.values.length, 5);
      expect(CardColor.values, contains(CardColor.white));
      expect(CardColor.values, contains(CardColor.blue));
      expect(CardColor.values, contains(CardColor.yellow));
      expect(CardColor.values, contains(CardColor.red));
      expect(CardColor.values, contains(CardColor.green));
    });

    test('colors have display names', () {
      expect(CardColor.white.displayName, isNotEmpty);
      expect(CardColor.blue.displayName, isNotEmpty);
      expect(CardColor.yellow.displayName, isNotEmpty);
      expect(CardColor.red.displayName, isNotEmpty);
      expect(CardColor.green.displayName, isNotEmpty);
    });
  });
}
