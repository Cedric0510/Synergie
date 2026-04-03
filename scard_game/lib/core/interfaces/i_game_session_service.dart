import '../../features/game/domain/models/game_session.dart';
import '../../features/game/domain/enums/player_gender.dart';

/// Interface pour le service de gestion des sessions de jeu
/// Permet de découpler la logique Firebase du reste de l'application
/// et facilite les tests unitaires via le mocking (Principe D - Dependency Inversion)
abstract class IGameSessionService {
  /// Crée une nouvelle partie
  Future<GameSession> createGame({
    required String playerName,
    required PlayerGender playerGender,
  });

  /// Rejoint une partie existante via son code
  Future<GameSession> joinGame({
    required String gameCode,
    required String playerName,
    required PlayerGender playerGender,
  });

  /// Récupère une session de jeu par son ID
  Future<GameSession> getSession(String sessionId);

  /// Surveille les changements d'une session en temps réel
  Stream<GameSession> watchSession(String sessionId);

  /// Met à jour une session existante
  Future<void> updateSession(String sessionId, GameSession session);

  /// Exécute une transformation atomique de la session.
  /// Le [updater] reçoit le snapshot courant et retourne la session modifiée.
  /// En production, cela utilise une transaction Firestore pour garantir
  /// qu'aucune écriture concurrente ne peut corrompre l'état.
  Future<GameSession> runTransaction(
    String sessionId,
    GameSession Function(GameSession current) updater,
  );

  /// Vérifie si une session existe
  Future<bool> sessionExists(String sessionId);

  /// Supprime une session
  Future<void> deleteSession(String sessionId);
}
