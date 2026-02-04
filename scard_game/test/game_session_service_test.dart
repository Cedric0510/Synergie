import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/core/interfaces/i_game_session_service.dart';
import 'package:scard_game/features/game/domain/models/game_session.dart';
import 'package:scard_game/features/game/domain/models/player_data.dart';
import 'package:scard_game/features/game/domain/enums/player_gender.dart';
import 'package:scard_game/features/game/domain/enums/game_status.dart';
import 'package:scard_game/features/game/domain/enums/game_phase.dart';

/// Mock implementation of IGameSessionService for testing
class MockGameSessionService implements IGameSessionService {
  final Map<String, GameSession> _sessions = {};
  int _sessionCounter = 0;

  @override
  Future<GameSession> createGame({
    required String playerName,
    required PlayerGender playerGender,
  }) async {
    final sessionId = 'TEST${_sessionCounter++}'.padLeft(6, '0');
    final playerId = 'player_${DateTime.now().millisecondsSinceEpoch}';

    final playerData = PlayerData(
      playerId: playerId,
      name: playerName,
      gender: playerGender,
    );

    final session = GameSession.create(
      sessionId: sessionId,
      player1Id: playerId,
      player1Data: playerData,
    );

    _sessions[sessionId] = session;
    return session;
  }

  @override
  Future<GameSession> joinGame({
    required String gameCode,
    required String playerName,
    required PlayerGender playerGender,
  }) async {
    final session = _sessions[gameCode];
    if (session == null) {
      throw Exception('Code de partie invalide');
    }
    if (session.player2Id != null) {
      throw Exception('Cette partie est déjà complète');
    }

    final playerId = 'player2_${DateTime.now().millisecondsSinceEpoch}';
    final playerData = PlayerData(
      playerId: playerId,
      name: playerName,
      gender: playerGender,
    );

    final updatedSession = session.copyWith(
      player2Id: playerId,
      player2Data: playerData,
      status: GameStatus.waiting,
    );

    _sessions[gameCode] = updatedSession;
    return updatedSession;
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
  Stream<GameSession> watchSession(String sessionId) {
    return Stream.value(_sessions[sessionId]!);
  }

  @override
  Future<void> updateSession(String sessionId, GameSession session) async {
    _sessions[sessionId] = session;
  }

  @override
  Future<bool> sessionExists(String sessionId) async {
    return _sessions.containsKey(sessionId);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.remove(sessionId);
  }

  void reset() {
    _sessions.clear();
    _sessionCounter = 0;
  }
}

void main() {
  late MockGameSessionService mockService;

  setUp(() {
    mockService = MockGameSessionService();
  });

  tearDown(() {
    mockService.reset();
  });

  group('Game Session Flow', () {
    test('create game returns valid session', () async {
      final session = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      expect(session.sessionId, isNotEmpty);
      expect(session.player1Data.name, 'Alice');
      expect(session.player1Data.gender, PlayerGender.female);
      expect(session.player2Id, isNull);
      expect(session.status, GameStatus.waiting);
    });

    test('join game adds second player', () async {
      final createdSession = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      final joinedSession = await mockService.joinGame(
        gameCode: createdSession.sessionId,
        playerName: 'Bob',
        playerGender: PlayerGender.male,
      );

      expect(joinedSession.player2Id, isNotNull);
      expect(joinedSession.player2Data?.name, 'Bob');
      expect(joinedSession.player2Data?.gender, PlayerGender.male);
    });

    test('join game with invalid code throws', () async {
      expect(
        () => mockService.joinGame(
          gameCode: 'INVALID',
          playerName: 'Bob',
          playerGender: PlayerGender.male,
        ),
        throwsException,
      );
    });

    test('join game when already full throws', () async {
      final session = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      await mockService.joinGame(
        gameCode: session.sessionId,
        playerName: 'Bob',
        playerGender: PlayerGender.male,
      );

      expect(
        () => mockService.joinGame(
          gameCode: session.sessionId,
          playerName: 'Charlie',
          playerGender: PlayerGender.male,
        ),
        throwsException,
      );
    });

    test('get session returns correct session', () async {
      final created = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      final retrieved = await mockService.getSession(created.sessionId);

      expect(retrieved.sessionId, created.sessionId);
      expect(retrieved.player1Data.name, 'Alice');
    });

    test('update session persists changes', () async {
      final session = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      final updatedSession = session.copyWith(
        status: GameStatus.playing,
        currentPhase: GamePhase.main,
      );

      await mockService.updateSession(session.sessionId, updatedSession);

      final retrieved = await mockService.getSession(session.sessionId);
      expect(retrieved.status, GameStatus.playing);
      expect(retrieved.currentPhase, GamePhase.main);
    });

    test('delete session removes session', () async {
      final session = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      await mockService.deleteSession(session.sessionId);

      expect(() => mockService.getSession(session.sessionId), throwsException);
    });

    test('session exists returns correct value', () async {
      final session = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      expect(await mockService.sessionExists(session.sessionId), true);
      expect(await mockService.sessionExists('NONEXISTENT'), false);
    });
  });

  group('Player Data Initialization', () {
    test('new player has correct default values', () async {
      final session = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      final player = session.player1Data;

      expect(player.inhibitionPoints, 20);
      expect(player.tension, 0);
      expect(player.handCardIds, isEmpty);
      expect(player.deckCardIds, isEmpty);
      expect(player.graveyardCardIds, isEmpty);
      expect(player.activeEnchantmentIds, isEmpty);
      expect(player.isReady, false);
      expect(player.isNaked, false);
    });
  });

  group('Game Phase Flow', () {
    test('game starts with draw phase', () async {
      final session = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      expect(session.currentPhase, GamePhase.draw);
    });

    test('phase transitions work correctly', () async {
      var session = await mockService.createGame(
        playerName: 'Alice',
        playerGender: PlayerGender.female,
      );

      final phases = [
        GamePhase.main,
        GamePhase.response,
        GamePhase.resolution,
        GamePhase.end,
      ];

      for (final phase in phases) {
        session = session.copyWith(currentPhase: phase);
        await mockService.updateSession(session.sessionId, session);

        final retrieved = await mockService.getSession(session.sessionId);
        expect(retrieved.currentPhase, phase);
      }
    });
  });
}
