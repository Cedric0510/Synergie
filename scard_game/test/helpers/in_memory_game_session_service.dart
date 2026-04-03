import 'package:scard_game/core/interfaces/i_game_session_service.dart';
import 'package:scard_game/features/game/domain/enums/player_gender.dart';
import 'package:scard_game/features/game/domain/models/game_session.dart';

/// In-memory implementation of IGameSessionService for unit tests.
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
  Future<GameSession> runTransaction(
    String sessionId,
    GameSession Function(GameSession current) updater,
  ) async {
    final current = _sessions[sessionId];
    if (current == null) throw Exception('Session introuvable');
    final updated = updater(current);
    _sessions[sessionId] = updated;
    return updated;
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
