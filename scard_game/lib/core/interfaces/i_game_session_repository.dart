import '../../features/game/domain/models/game_session.dart';
import '../../features/game/domain/models/player_data.dart';

/// Interface abstraite pour le repository de sessions de jeu
/// Gère les opérations CRUD sur les sessions (Principe S - Single Responsibility)
abstract class IGameSessionRepository {
  /// Récupère une session par son code
  Future<GameSession?> getSessionByCode(String code);

  /// Récupère une session par son ID
  Future<GameSession> getSession(String sessionId);

  /// Observe les changements d'une session en temps réel
  Stream<GameSession> watchSession(String sessionId);

  /// Sauvegarde une session (création ou mise à jour complète)
  Future<void> saveSession(GameSession session);

  /// Met à jour les données d'un joueur
  Future<void> updatePlayerData(
    String sessionId,
    bool isPlayer1,
    PlayerData playerData,
  );

  /// Supprime une session
  Future<void> deleteSession(String sessionId);

  /// Vérifie si une session existe
  Future<bool> sessionExists(String sessionId);
}
