import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/features/game/domain/models/game_session.dart';
import 'package:scard_game/features/game/domain/models/player_data.dart';
import 'package:scard_game/features/game/domain/enums/player_gender.dart';
import 'package:scard_game/features/game/domain/enums/game_status.dart';
import 'package:scard_game/features/game/domain/enums/game_phase.dart';
import 'package:scard_game/features/game/domain/enums/response_effect.dart';

void main() {
  group('GameSession', () {
    late PlayerData player1;
    late PlayerData player2;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      player1 = PlayerData(
        playerId: 'player1_id',
        name: 'Alice',
        gender: PlayerGender.female,
      );
      player2 = PlayerData(
        playerId: 'player2_id',
        name: 'Bob',
        gender: PlayerGender.male,
      );
    });

    test('can create minimal session with factory', () {
      final session = GameSession.create(
        sessionId: 'TEST01',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.sessionId, 'TEST01');
      expect(session.player1Id, 'player1_id');
      expect(session.player1Data.name, 'Alice');
      expect(session.player2Id, isNull);
      expect(session.player2Data, isNull);
      expect(session.status, GameStatus.waiting);
      expect(session.currentPhase, GamePhase.draw);
    });

    test('can create full session with constructor', () {
      final session = GameSession(
        sessionId: 'TEST02',
        player1Id: 'player1_id',
        player1Data: player1,
        player2Id: 'player2_id',
        player2Data: player2,
        status: GameStatus.playing,
        currentPlayerId: 'player1_id',
        currentPhase: GamePhase.main,
        createdAt: now,
        updatedAt: now,
      );

      expect(session.player1Data.name, 'Alice');
      expect(session.player2Data?.name, 'Bob');
      expect(session.status, GameStatus.playing);
      expect(session.currentPhase, GamePhase.main);
    });

    test('copyWith preserves unchanged fields', () {
      final original = GameSession.create(
        sessionId: 'TEST03',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      final updated = original.copyWith(
        player2Id: 'player2_id',
        player2Data: player2,
        status: GameStatus.playing,
      );

      expect(updated.sessionId, original.sessionId);
      expect(updated.player1Id, original.player1Id);
      expect(updated.player1Data.name, 'Alice');
      expect(updated.player2Data?.name, 'Bob');
      expect(updated.status, GameStatus.playing);
      expect(updated.createdAt, original.createdAt);
    });

    test('copyWith can update phase', () {
      final session = GameSession.create(
        sessionId: 'TEST04',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.currentPhase, GamePhase.draw);

      final updated = session.copyWith(currentPhase: GamePhase.main);
      expect(updated.currentPhase, GamePhase.main);
    });

    test('resolution stack management', () {
      var session = GameSession(
        sessionId: 'TEST05',
        player1Id: 'player1_id',
        player1Data: player1,
        player2Id: 'player2_id',
        player2Data: player2,
        status: GameStatus.playing,
        currentPlayerId: 'player1_id',
        currentPhase: GamePhase.main,
        createdAt: now,
        updatedAt: now,
      );

      expect(session.resolutionStack, isEmpty);

      // Add cards to resolution stack
      session = session.copyWith(resolutionStack: ['card_1']);
      expect(session.resolutionStack.length, 1);

      // Add response card on top
      session = session.copyWith(
        resolutionStack: [...session.resolutionStack, 'card_2'],
      );
      expect(session.resolutionStack.length, 2);
      expect(session.resolutionStack.last, 'card_2');

      // Resolve from top (LIFO)
      final topCard = session.resolutionStack.last;
      expect(topCard, 'card_2');

      session = session.copyWith(
        resolutionStack: session.resolutionStack.sublist(
          0,
          session.resolutionStack.length - 1,
        ),
      );
      expect(session.resolutionStack.length, 1);
      expect(session.resolutionStack.first, 'card_1');
    });

    test('played card tiers tracking', () {
      var session = GameSession.create(
        sessionId: 'TEST06',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.playedCardTiers, isEmpty);

      session = session.copyWith(
        playedCardTiers: {'card_1': 'white', 'card_2': 'blue'},
      );

      expect(session.playedCardTiers['card_1'], 'white');
      expect(session.playedCardTiers['card_2'], 'blue');
    });

    test('ultima counter tracking', () {
      var session = GameSession.create(
        sessionId: 'TEST07',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.ultimaOwnerId, isNull);
      expect(session.ultimaTurnCount, 0);
      expect(session.ultimaPlayedAt, isNull);

      // Player activates Ultima
      final ultimaTime = DateTime.now();
      session = session.copyWith(
        ultimaOwnerId: 'player1_id',
        ultimaPlayedAt: ultimaTime,
        ultimaTurnCount: 1,
      );

      expect(session.ultimaOwnerId, 'player1_id');
      expect(session.ultimaTurnCount, 1);
      expect(session.ultimaPlayedAt, ultimaTime);

      // Increment turn count
      session = session.copyWith(ultimaTurnCount: session.ultimaTurnCount + 1);
      expect(session.ultimaTurnCount, 2);
    });

    test('response effect tracking', () {
      var session = GameSession.create(
        sessionId: 'TEST08',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.responseEffect, isNull);

      session = session.copyWith(responseEffect: ResponseEffect.cancel);
      expect(session.responseEffect, ResponseEffect.cancel);
    });

    test('game lifecycle timestamps', () {
      var session = GameSession.create(
        sessionId: 'TEST09',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.createdAt, isNotNull);
      expect(session.updatedAt, isNotNull);
      expect(session.startedAt, isNull);
      expect(session.finishedAt, isNull);

      // Game starts
      final startTime = DateTime.now();
      session = session.copyWith(
        startedAt: startTime,
        status: GameStatus.playing,
      );
      expect(session.startedAt, startTime);

      // Game ends
      final endTime = DateTime.now();
      session = session.copyWith(
        finishedAt: endTime,
        status: GameStatus.finished,
        winnerId: 'player1_id',
      );
      expect(session.finishedAt, endTime);
      expect(session.winnerId, 'player1_id');
      expect(session.status, GameStatus.finished);
    });

    test('validation flow tracking', () {
      var session = GameSession(
        sessionId: 'TEST10',
        player1Id: 'player1_id',
        player1Data: player1,
        player2Id: 'player2_id',
        player2Data: player2,
        status: GameStatus.playing,
        currentPlayerId: 'player1_id',
        currentPhase: GamePhase.main,
        createdAt: now,
        updatedAt: now,
      );

      expect(session.cardAwaitingValidation, isNull);
      expect(session.awaitingValidationFrom, isEmpty);
      expect(session.validationResponses, isEmpty);

      // Card needs validation
      session = session.copyWith(
        cardAwaitingValidation: 'special_card',
        awaitingValidationFrom: ['player2_id'],
      );

      expect(session.cardAwaitingValidation, 'special_card');
      expect(session.awaitingValidationFrom, ['player2_id']);

      // Validation received
      session = session.copyWith(
        validationResponses: {'player2_id': true},
        awaitingValidationFrom: [],
        cardAwaitingValidation: null,
      );

      expect(session.validationResponses['player2_id'], true);
      expect(session.awaitingValidationFrom, isEmpty);
    });

    test('pending spell actions', () {
      var session = GameSession.create(
        sessionId: 'TEST11',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.pendingSpellActions, isEmpty);

      session = session.copyWith(
        pendingSpellActions: [
          {'action': 'damage', 'amount': 3},
          {'action': 'draw', 'count': 1},
        ],
      );

      expect(session.pendingSpellActions.length, 2);
      expect(session.pendingSpellActions.first['action'], 'damage');
    });

    test('draw and enchantment flags', () {
      var session = GameSession.create(
        sessionId: 'TEST12',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.drawDoneThisTurn, false);
      expect(session.enchantmentEffectsDoneThisTurn, false);

      session = session.copyWith(
        drawDoneThisTurn: true,
        enchantmentEffectsDoneThisTurn: true,
      );

      expect(session.drawDoneThisTurn, true);
      expect(session.enchantmentEffectsDoneThisTurn, true);
    });

    test('default values are set correctly', () {
      final session = GameSession.create(
        sessionId: 'TEST13',
        player1Id: 'player1_id',
        player1Data: player1,
      );

      expect(session.currentPhase, GamePhase.draw);
      expect(session.status, GameStatus.waiting);
      expect(session.resolutionStack, isEmpty);
      expect(session.playedCardTiers, isEmpty);
      expect(session.pendingSpellActions, isEmpty);
      expect(session.drawDoneThisTurn, false);
      expect(session.enchantmentEffectsDoneThisTurn, false);
      expect(session.awaitingValidationFrom, isEmpty);
      expect(session.validationResponses, isEmpty);
      expect(session.ultimaTurnCount, 0);
    });
  });

  group('GameSession JSON Serialization', () {
    test('can serialize to JSON', () {
      final player = PlayerData(
        playerId: 'player1_id',
        name: 'Alice',
        gender: PlayerGender.female,
      );

      final session = GameSession.create(
        sessionId: 'JSONTEST',
        player1Id: 'player1_id',
        player1Data: player,
      );

      final json = session.toJson();

      expect(json['sessionId'], 'JSONTEST');
      expect(json['player1Id'], 'player1_id');
      expect(json.containsKey('player1Data'), true);
      expect(json['status'], 'waiting');
      expect(json['currentPhase'], 'draw');
    });

    test('can deserialize from JSON', () {
      final json = {
        'sessionId': 'JSONTEST2',
        'player1Id': 'player1_id',
        'player1Data': {
          'playerId': 'player1_id',
          'name': 'Bob',
          'gender': 'male',
          'inhibitionPoints': 20,
          'tension': 0,
          'handCardIds': <String>[],
          'deckCardIds': <String>[],
          'graveyardCardIds': <String>[],
          'activeEnchantmentIds': <String>[],
          'isReady': false,
          'isNaked': false,
        },
        'status': 'playing',
        'currentPhase': 'main',
        'resolutionStack': <String>[],
        'playedCardTiers': <String, String>{},
        'pendingSpellActions': <Map<String, dynamic>>[],
        'drawDoneThisTurn': false,
        'enchantmentEffectsDoneThisTurn': false,
        'awaitingValidationFrom': <String>[],
        'validationResponses': <String, bool>{},
        'ultimaTurnCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final session = GameSession.fromJson(json);

      expect(session.sessionId, 'JSONTEST2');
      expect(session.player1Data.name, 'Bob');
      expect(session.status, GameStatus.playing);
      expect(session.currentPhase, GamePhase.main);
    });
  });
}
