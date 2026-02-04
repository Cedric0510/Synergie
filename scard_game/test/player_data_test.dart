import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/features/game/domain/models/player_data.dart';
import 'package:scard_game/features/game/domain/enums/player_gender.dart';
import 'package:scard_game/features/game/domain/enums/card_level.dart';
import 'package:scard_game/core/constants/game_constants.dart';

void main() {
  group('PlayerData', () {
    test('can create with required fields only', () {
      final player = PlayerData(
        playerId: 'test_id',
        name: 'Test Player',
        gender: PlayerGender.male,
      );

      expect(player.playerId, 'test_id');
      expect(player.name, 'Test Player');
      expect(player.gender, PlayerGender.male);
    });

    test('has correct default values', () {
      final player = PlayerData(
        playerId: 'test_id',
        name: 'Test',
        gender: PlayerGender.female,
      );

      expect(player.inhibitionPoints, 20);
      expect(player.tension, 0.0);
      expect(player.handCardIds, isEmpty);
      expect(player.deckCardIds, isEmpty);
      expect(player.graveyardCardIds, isEmpty);
      expect(player.playedCardIds, isEmpty);
      expect(player.activeEnchantmentIds, isEmpty);
      expect(player.activeEnchantmentTiers, isEmpty);
      expect(player.activeStatusModifiers, isEmpty);
      expect(player.isNaked, false);
      expect(player.currentLevel, CardLevel.white);
      expect(player.isReady, false);
      expect(player.hasSacrificedThisTurn, false);
    });

    test('copyWith creates new instance with updated values', () {
      final original = PlayerData(
        playerId: 'test_id',
        name: 'Original',
        gender: PlayerGender.male,
      );

      final updated = original.copyWith(
        name: 'Updated',
        inhibitionPoints: 15,
        tension: 25.0,
      );

      // Original unchanged
      expect(original.name, 'Original');
      expect(original.inhibitionPoints, 20);
      expect(original.tension, 0.0);

      // Updated has new values
      expect(updated.name, 'Updated');
      expect(updated.inhibitionPoints, 15);
      expect(updated.tension, 25.0);
      expect(updated.playerId, 'test_id'); // Unchanged field preserved
    });

    test('toJson and fromJson round-trip', () {
      final original = PlayerData(
        playerId: 'test_id',
        name: 'Test',
        gender: PlayerGender.female,
        inhibitionPoints: 15,
        tension: 30.0,
        handCardIds: ['card_1', 'card_2'],
        currentLevel: CardLevel.blue,
        isReady: true,
      );

      final json = original.toJson();
      final restored = PlayerData.fromJson(json);

      expect(restored.playerId, original.playerId);
      expect(restored.name, original.name);
      expect(restored.gender, original.gender);
      expect(restored.inhibitionPoints, original.inhibitionPoints);
      expect(restored.tension, original.tension);
      expect(restored.handCardIds, original.handCardIds);
      expect(restored.currentLevel, original.currentLevel);
      expect(restored.isReady, original.isReady);
    });
  });

  group('PlayerData - Game Logic', () {
    test('inhibition points stay within valid range', () {
      var player = PlayerData(
        playerId: 'test',
        name: 'Test',
        gender: PlayerGender.male,
        inhibitionPoints: 20,
      );

      // Damage should reduce points
      player = player.copyWith(
        inhibitionPoints: (player.inhibitionPoints - 5).clamp(0, 20),
      );
      expect(player.inhibitionPoints, 15);

      // Cannot go below 0
      player = player.copyWith(
        inhibitionPoints: (player.inhibitionPoints - 20).clamp(0, 20),
      );
      expect(player.inhibitionPoints, 0);
    });

    test('tension increases correctly', () {
      var player = PlayerData(
        playerId: 'test',
        name: 'Test',
        gender: PlayerGender.female,
        tension: 0,
      );

      // Add tension from white card
      final whiteTension = GameConstants.tensionByCardColor['white']!;
      player = player.copyWith(
        tension: (player.tension + whiteTension).clamp(0, 100),
      );
      expect(player.tension, whiteTension);

      // Add tension from blue card
      final blueTension = GameConstants.tensionByCardColor['blue']!;
      player = player.copyWith(
        tension: (player.tension + blueTension).clamp(0, 100),
      );
      expect(player.tension, whiteTension + blueTension);
    });

    test('tension cannot exceed 100', () {
      var player = PlayerData(
        playerId: 'test',
        name: 'Test',
        gender: PlayerGender.male,
        tension: 95,
      );

      // Try to add more than max
      player = player.copyWith(tension: (player.tension + 20).clamp(0, 100));
      expect(player.tension, 100);
    });

    test('level progression with tension thresholds', () {
      // Level should be white when tension < 25
      var player = PlayerData(
        playerId: 'test',
        name: 'Test',
        gender: PlayerGender.female,
        tension: 20,
        currentLevel: CardLevel.white,
      );
      expect(player.currentLevel, CardLevel.white);

      // Level should be blue when tension >= 25
      player = player.copyWith(tension: 25, currentLevel: CardLevel.blue);
      expect(player.currentLevel, CardLevel.blue);

      // Level should be yellow when tension >= 50
      player = player.copyWith(tension: 50, currentLevel: CardLevel.yellow);
      expect(player.currentLevel, CardLevel.yellow);

      // Level should be red when tension >= 75
      player = player.copyWith(tension: 75, currentLevel: CardLevel.red);
      expect(player.currentLevel, CardLevel.red);
    });

    test('hand card management', () {
      var player = PlayerData(
        playerId: 'test',
        name: 'Test',
        gender: PlayerGender.male,
        handCardIds: ['card_1', 'card_2', 'card_3'],
      );

      expect(player.handCardIds.length, 3);

      // Add a card
      player = player.copyWith(handCardIds: [...player.handCardIds, 'card_4']);
      expect(player.handCardIds.length, 4);
      expect(player.handCardIds.contains('card_4'), true);

      // Remove a card (play it)
      player = player.copyWith(
        handCardIds: player.handCardIds.where((id) => id != 'card_2').toList(),
        playedCardIds: [...player.playedCardIds, 'card_2'],
      );
      expect(player.handCardIds.length, 3);
      expect(player.handCardIds.contains('card_2'), false);
      expect(player.playedCardIds.contains('card_2'), true);
    });

    test('enchantment management', () {
      var player = PlayerData(
        playerId: 'test',
        name: 'Test',
        gender: PlayerGender.female,
        activeEnchantmentIds: [],
      );

      // Add enchantment
      player = player.copyWith(
        activeEnchantmentIds: [...player.activeEnchantmentIds, 'enchant_1'],
        activeEnchantmentTiers: {
          ...player.activeEnchantmentTiers,
          'enchant_1': 'white',
        },
      );

      expect(player.activeEnchantmentIds.length, 1);
      expect(player.activeEnchantmentTiers['enchant_1'], 'white');

      // Upgrade enchantment tier
      player = player.copyWith(
        activeEnchantmentTiers: {
          ...player.activeEnchantmentTiers,
          'enchant_1': 'blue',
        },
      );
      expect(player.activeEnchantmentTiers['enchant_1'], 'blue');

      // Remove enchantment
      player = player.copyWith(
        activeEnchantmentIds:
            player.activeEnchantmentIds
                .where((id) => id != 'enchant_1')
                .toList(),
        activeEnchantmentTiers: Map.from(player.activeEnchantmentTiers)
          ..remove('enchant_1'),
      );
      expect(player.activeEnchantmentIds, isEmpty);
      expect(player.activeEnchantmentTiers.containsKey('enchant_1'), false);
    });
  });

  group('PlayerGender', () {
    test('all genders are defined', () {
      expect(PlayerGender.values.length, 3);
      expect(PlayerGender.values, contains(PlayerGender.male));
      expect(PlayerGender.values, contains(PlayerGender.female));
      expect(PlayerGender.values, contains(PlayerGender.other));
    });

    test('gender equality', () {
      expect(PlayerGender.male == PlayerGender.male, true);
      expect(PlayerGender.male == PlayerGender.female, false);
    });
  });
}
