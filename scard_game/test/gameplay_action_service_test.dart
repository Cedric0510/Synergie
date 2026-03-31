import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/core/interfaces/i_game_session_service.dart';
import 'package:scard_game/features/game/data/services/gameplay_action_service.dart';
import 'package:scard_game/features/game/domain/enums/game_phase.dart';
import 'package:scard_game/features/game/domain/enums/game_status.dart';
import 'package:scard_game/features/game/domain/enums/player_gender.dart';
import 'package:scard_game/features/game/domain/models/game_session.dart';
import 'package:scard_game/features/game/domain/models/player_data.dart';

class InMemoryGameSessionService implements IGameSessionService {
  final Map<String, GameSession> _sessions = {};

  void save(GameSession session) {
    _sessions[session.sessionId] = session;
  }

  @override
  Future<GameSession> getSession(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) {
      throw Exception('Session introuvable');
    }
    return session;
  }

  @override
  Future<void> updateSession(String sessionId, GameSession session) async {
    _sessions[sessionId] = session;
  }

  @override
  Future<GameSession> createGame({
    required String playerName,
    required PlayerGender playerGender,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.remove(sessionId);
  }

  @override
  Future<GameSession> joinGame({
    required String gameCode,
    required String playerName,
    required PlayerGender playerGender,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> sessionExists(String sessionId) async {
    return _sessions.containsKey(sessionId);
  }

  @override
  Stream<GameSession> watchSession(String sessionId) async* {
    final session = _sessions[sessionId];
    if (session == null) {
      throw Exception('Session introuvable');
    }
    yield session;
  }
}

void main() {
  late InMemoryGameSessionService gameSessionService;
  late GameplayActionService service;

  setUp(() {
    gameSessionService = InMemoryGameSessionService();
    service = GameplayActionService(gameSessionService);
  });

  group('GameplayActionService - parseLauncherCost', () {
    test('extracts PI cost when present', () {
      expect(service.parseLauncherCost('Coût: 3 PI'), 3);
    });

    test('returns 0 when no PI cost is present', () {
      expect(service.parseLauncherCost('Aucun'), 0);
    });
  });

  group('GameplayActionService - playCard', () {
    test('moves card from hand to played + resolution stack', () async {
      final session = _buildSession(
        player1Data: _player('p1', hand: ['card_a', 'card_b'], played: []),
      );
      gameSessionService.save(session);

      await service.playCard('S1', 'p1', 1, enchantmentTierKey: 'blue');

      final updated = await gameSessionService.getSession('S1');
      expect(updated.player1Data.handCardIds, ['card_a']);
      expect(updated.player1Data.playedCardIds, ['card_b']);
      expect(updated.resolutionStack, ['card_b']);
      expect(updated.playedCardTiers['card_b'], 'blue');
    });
  });

  group('GameplayActionService - payCost', () {
    test('deducts PI when enough PI is available', () async {
      final session = _buildSession(
        player1Data: _player('p1', inhibitionPoints: 8),
      );
      gameSessionService.save(session);

      await service.payCost('S1', 'p1', 3);

      final updated = await gameSessionService.getSession('S1');
      expect(updated.player1Data.inhibitionPoints, 5);
    });

    test('throws when PI are locked', () async {
      final session = _buildSession(
        player1Data: _player(
          'p1',
          inhibitionPoints: 10,
          modifiers: {
            'pi_locked': ['ench_1'],
          },
        ),
      );
      gameSessionService.save(session);

      await expectLater(
        () => service.payCost('S1', 'p1', 2),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('PI verrouillés')),
        ),
      );

      final updated = await gameSessionService.getSession('S1');
      expect(updated.player1Data.inhibitionPoints, 10);
    });
  });

  group('GameplayActionService - drawCard', () {
    test('draws top card from deck', () async {
      final session = _buildSession(
        player1Data: _player('p1', hand: ['h1'], deck: ['d1', 'd2']),
      );
      gameSessionService.save(session);

      await service.drawCard('S1', 'p1');

      final updated = await gameSessionService.getSession('S1');
      expect(updated.player1Data.handCardIds, ['h1', 'd1']);
      expect(updated.player1Data.deckCardIds, ['d2']);
    });

    test('reshuffles graveyard when deck is empty', () async {
      final session = _buildSession(
        player1Data: _player(
          'p1',
          hand: ['h1'],
          deck: [],
          graveyard: ['g1', 'g2'],
        ),
      );
      gameSessionService.save(session);

      await service.drawCard('S1', 'p1');

      final updated = await gameSessionService.getSession('S1');
      expect(updated.player1Data.graveyardCardIds, isEmpty);
      expect(updated.player1Data.handCardIds.length, 2);
      expect(updated.player1Data.deckCardIds.length, 1);
      expect(['g1', 'g2'].contains(updated.player1Data.handCardIds.last), true);
    });
  });

  group('GameplayActionService - sacrificeCard', () {
    test('updates hand/deck/tension and passes turn', () async {
      final session = _buildSession(
        currentPhase: GamePhase.main,
        currentPlayerId: 'p1',
        player1Data: _player(
          'p1',
          hand: ['sacrifice_me', 'keep_me'],
          deck: ['drawn_card'],
          tension: 10.0,
        ),
        player2Data: _player('p2', hasSacrificedThisTurn: true),
      );
      gameSessionService.save(session);

      await service.sacrificeCard('S1', 'p1', 0);

      final updated = await gameSessionService.getSession('S1');
      expect(updated.player1Data.handCardIds, ['keep_me', 'drawn_card']);
      expect(updated.player1Data.deckCardIds, ['sacrifice_me']);
      expect(updated.player1Data.tension, 12.0);
      expect(updated.player1Data.hasSacrificedThisTurn, false);
      expect(updated.player2Data?.hasSacrificedThisTurn, false);
      expect(updated.currentPlayerId, 'p2');
      expect(updated.currentPhase, GamePhase.draw);
      expect(updated.drawDoneThisTurn, false);
      expect(updated.enchantmentEffectsDoneThisTurn, false);
    });

    test('sacrificing Ultima ends game in defeat', () async {
      final session = _buildSession(
        player1Data: _player('p1', hand: ['red_016']),
      );
      gameSessionService.save(session);

      await expectLater(
        () => service.sacrificeCard('S1', 'p1', 0),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('ULTIMA SACRIFIÉE'),
          ),
        ),
      );

      final updated = await gameSessionService.getSession('S1');
      expect(updated.winnerId, 'p2');
      expect(updated.status, GameStatus.finished);
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
  List<String> hand = const [],
  List<String> deck = const [],
  List<String> played = const [],
  List<String> graveyard = const [],
  Map<String, List<String>> modifiers = const {},
  bool hasSacrificedThisTurn = false,
}) {
  return PlayerData(
    playerId: id,
    name: id,
    gender: PlayerGender.other,
    inhibitionPoints: inhibitionPoints,
    tension: tension,
    handCardIds: hand,
    deckCardIds: deck,
    playedCardIds: played,
    graveyardCardIds: graveyard,
    activeStatusModifiers: modifiers,
    hasSacrificedThisTurn: hasSacrificedThisTurn,
  );
}
