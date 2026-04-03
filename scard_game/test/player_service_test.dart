import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/features/game/data/services/player_service.dart';
import 'package:scard_game/features/game/domain/enums/game_phase.dart';
import 'package:scard_game/features/game/domain/enums/game_status.dart';
import 'package:scard_game/features/game/domain/enums/player_gender.dart';
import 'package:scard_game/features/game/domain/models/game_session.dart';
import 'package:scard_game/features/game/domain/models/player_data.dart';

import 'helpers/in_memory_game_session_service.dart';

void main() {
  late InMemoryGameSessionService gameSessionService;
  late PlayerService service;

  setUp(() {
    gameSessionService = InMemoryGameSessionService();
    service = PlayerService(gameSessionService);
  });

  group('PlayerService - updatePlayerActivity', () {
    test('updates player1 lastActivityAt', () async {
      gameSessionService.save(_buildSession());
      await service.updatePlayerActivity('S1', 'p1');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.lastActivityAt, isNotNull);
    });

    test('updates player2 lastActivityAt', () async {
      gameSessionService.save(_buildSession());
      await service.updatePlayerActivity('S1', 'p2');
      final s = await gameSessionService.getSession('S1');
      expect(s.player2Data!.lastActivityAt, isNotNull);
    });

    test('unknown playerId returns session unchanged', () async {
      gameSessionService.save(_buildSession());
      await service.updatePlayerActivity('S1', 'unknown');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.lastActivityAt, isNull);
      expect(s.player2Data!.lastActivityAt, isNull);
    });
  });

  group('PlayerService - setPlayerReady', () {
    test('sets player1 ready true', () async {
      gameSessionService.save(_buildSession());
      await service.setPlayerReady('S1', 'p1', true);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.isReady, true);
    });

    test('sets player1 ready false', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', isReady: true)),
      );
      await service.setPlayerReady('S1', 'p1', false);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.isReady, false);
    });

    test('sets player2 ready true', () async {
      gameSessionService.save(_buildSession());
      await service.setPlayerReady('S1', 'p2', true);
      final s = await gameSessionService.getSession('S1');
      expect(s.player2Data!.isReady, true);
    });
  });

  group('PlayerService - setPlayerCardsReady', () {
    test('delegates to setPlayerReady with true', () async {
      gameSessionService.save(_buildSession());
      await service.setPlayerCardsReady('S1', 'p1');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.isReady, true);
    });
  });

  group('PlayerService - determineStartingPlayer', () {
    test('female goes first when genders differ', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player('p1', gender: PlayerGender.male, isReady: true),
          player2Data: _player(
            'p2',
            gender: PlayerGender.female,
            isReady: true,
          ),
        ),
      );
      await service.determineStartingPlayer('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPlayerId, 'p2');
      expect(s.status, GameStatus.playing);
      expect(s.startedAt, isNotNull);
    });

    test('female player1 goes first when genders differ', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            gender: PlayerGender.female,
            isReady: true,
          ),
          player2Data: _player('p2', gender: PlayerGender.male, isReady: true),
        ),
      );
      await service.determineStartingPlayer('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPlayerId, 'p1');
    });

    test('picks a player when genders are the same', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player('p1', gender: PlayerGender.male, isReady: true),
          player2Data: _player('p2', gender: PlayerGender.male, isReady: true),
        ),
      );
      await service.determineStartingPlayer('S1');
      final s = await gameSessionService.getSession('S1');
      expect(['p1', 'p2'], contains(s.currentPlayerId));
      expect(s.status, GameStatus.playing);
    });

    test('resets both readiness flags when game starts', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player('p1', gender: PlayerGender.male, isReady: true),
          player2Data: _player(
            'p2',
            gender: PlayerGender.female,
            isReady: true,
          ),
        ),
      );
      await service.determineStartingPlayer('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.status, GameStatus.playing);
      expect(s.player1Data.isReady, false);
      expect(s.player2Data!.isReady, false);
    });

    test('does nothing when player2 is absent', () async {
      final now = DateTime(2026, 1, 1);
      final session = GameSession(
        sessionId: 'S1',
        player1Id: 'p1',
        player1Data: _player('p1'),
        createdAt: now,
        updatedAt: now,
      );
      gameSessionService.save(session);
      await service.determineStartingPlayer('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPlayerId, isNull);
      expect(s.status, GameStatus.waiting);
    });

    test('does nothing when both players are not ready', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            gender: PlayerGender.female,
            isReady: true,
          ),
          player2Data: _player('p2', gender: PlayerGender.male, isReady: false),
        ),
      );
      await service.determineStartingPlayer('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPlayerId, 'p1');
      expect(s.status, GameStatus.waiting);
      expect(s.startedAt, isNull);
    });
  });

  group('PlayerService - updatePlayerCards', () {
    test('updates player1 hand and deck', () async {
      gameSessionService.save(_buildSession());
      await service.updatePlayerCards(
        sessionId: 'S1',
        playerId: 'p1',
        handCardIds: ['a', 'b'],
        deckCardIds: ['c', 'd', 'e'],
      );
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.handCardIds, ['a', 'b']);
      expect(s.player1Data.deckCardIds, ['c', 'd', 'e']);
    });

    test('updates player2 hand and deck', () async {
      gameSessionService.save(_buildSession());
      await service.updatePlayerCards(
        sessionId: 'S1',
        playerId: 'p2',
        handCardIds: ['x'],
        deckCardIds: ['y', 'z'],
      );
      final s = await gameSessionService.getSession('S1');
      expect(s.player2Data!.handCardIds, ['x']);
      expect(s.player2Data!.deckCardIds, ['y', 'z']);
    });
  });

  group('PlayerService - updatePlayerPI', () {
    test('adds PI', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', inhibitionPoints: 10)),
      );
      await service.updatePlayerPI('S1', 'p1', 5);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.inhibitionPoints, 15);
    });

    test('subtracts PI', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', inhibitionPoints: 10)),
      );
      await service.updatePlayerPI('S1', 'p1', -3);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.inhibitionPoints, 7);
    });

    test('clamps PI to 0 minimum', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', inhibitionPoints: 2)),
      );
      await service.updatePlayerPI('S1', 'p1', -10);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.inhibitionPoints, 0);
    });

    test('clamps PI to 99 maximum', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', inhibitionPoints: 95)),
      );
      await service.updatePlayerPI('S1', 'p1', 10);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.inhibitionPoints, 99);
    });

    test('does nothing when pi_locked modifier is set', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            inhibitionPoints: 10,
            modifiers: {
              'pi_locked': ['ench_1'],
            },
          ),
        ),
      );
      await service.updatePlayerPI('S1', 'p1', 5);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.inhibitionPoints, 10);
    });

    test('does nothing when lockPI modifier is set', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            inhibitionPoints: 10,
            modifiers: {
              'lockPI': ['ench_2'],
            },
          ),
        ),
      );
      await service.updatePlayerPI('S1', 'p1', -3);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.inhibitionPoints, 10);
    });

    test('updates player2 PI', () async {
      gameSessionService.save(
        _buildSession(player2Data: _player('p2', inhibitionPoints: 15)),
      );
      await service.updatePlayerPI('S1', 'p2', -5);
      final s = await gameSessionService.getSession('S1');
      expect(s.player2Data!.inhibitionPoints, 10);
    });
  });

  group('PlayerService - updatePlayerTension', () {
    test('adds tension', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', tension: 20)),
      );
      await service.updatePlayerTension('S1', 'p1', 15);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.tension, 35);
    });

    test('subtracts tension', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', tension: 30)),
      );
      await service.updatePlayerTension('S1', 'p1', -10);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.tension, 20);
    });

    test('clamps tension to 0 minimum', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', tension: 5)),
      );
      await service.updatePlayerTension('S1', 'p1', -20);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.tension, 0);
    });

    test('clamps tension to 100 maximum', () async {
      gameSessionService.save(
        _buildSession(player1Data: _player('p1', tension: 90)),
      );
      await service.updatePlayerTension('S1', 'p1', 20);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.tension, 100);
    });

    test('does nothing when tension_locked modifier is set', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            tension: 30,
            modifiers: {
              'tension_locked': ['ench_1'],
            },
          ),
        ),
      );
      await service.updatePlayerTension('S1', 'p1', 10);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.tension, 30);
    });

    test('does nothing when lockTension modifier is set', () async {
      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            tension: 30,
            modifiers: {
              'lockTension': ['ench_2'],
            },
          ),
        ),
      );
      await service.updatePlayerTension('S1', 'p1', -5);
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.tension, 30);
    });

    test('updates player2 tension', () async {
      gameSessionService.save(
        _buildSession(player2Data: _player('p2', tension: 50)),
      );
      await service.updatePlayerTension('S1', 'p2', 10);
      final s = await gameSessionService.getSession('S1');
      expect(s.player2Data!.tension, 60);
    });
  });
}

GameSession _buildSession({
  String sessionId = 'S1',
  String player1Id = 'p1',
  String player2Id = 'p2',
  String currentPlayerId = 'p1',
  GamePhase currentPhase = GamePhase.draw,
  PlayerData? player1Data,
  PlayerData? player2Data,
}) {
  final now = DateTime(2026, 1, 1);
  return GameSession(
    sessionId: sessionId,
    player1Id: player1Id,
    player2Id: player2Id,
    player1Data: player1Data ?? _player(player1Id),
    player2Data: player2Data ?? _player(player2Id),
    currentPlayerId: currentPlayerId,
    currentPhase: currentPhase,
    createdAt: now,
    updatedAt: now,
  );
}

PlayerData _player(
  String id, {
  int inhibitionPoints = 20,
  double tension = 0,
  PlayerGender gender = PlayerGender.other,
  bool isReady = false,
  List<String> hand = const [],
  List<String> deck = const [],
  Map<String, List<String>> modifiers = const {},
}) {
  return PlayerData(
    playerId: id,
    name: id,
    gender: gender,
    inhibitionPoints: inhibitionPoints,
    tension: tension,
    handCardIds: hand,
    deckCardIds: deck,
    playedCardIds: const [],
    graveyardCardIds: const [],
    activeStatusModifiers: modifiers,
    isReady: isReady,
  );
}
