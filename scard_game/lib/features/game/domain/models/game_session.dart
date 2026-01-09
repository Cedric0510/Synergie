import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/game_phase.dart';
import '../enums/game_status.dart';
import '../enums/response_effect.dart';
import 'player_data.dart';

part 'game_session.freezed.dart';
part 'game_session.g.dart';

/// Session de jeu complète (document Firestore)
@freezed
class GameSession with _$GameSession {
  const factory GameSession({
    /// ID unique de la session (code de partie)
    required String sessionId,

    /// ID du joueur 1
    required String player1Id,

    /// ID du joueur 2 (null si partie pas encore rejointe)
    String? player2Id,

    /// Données du joueur 1
    required PlayerData player1Data,

    /// Données du joueur 2 (null si partie pas encore rejointe)
    PlayerData? player2Data,

    /// ID du joueur actif (qui doit jouer)
    String? currentPlayerId,

    /// Phase actuelle du jeu
    @Default(GamePhase.draw) GamePhase currentPhase,

    /// Statut de la partie
    @Default(GameStatus.waiting) GameStatus status,

    /// Pile de résolution (IDs des cartes jouées ce tour)
    @Default([]) List<String> resolutionStack,

    /// Actions pendantes du sort actif (à exécuter en Resolution si non contré)
    @Default([]) List<Map<String, dynamic>> pendingSpellActions,

    /// === VALIDATION D'ACTIONS ===

    /// Effet de la carte de réponse jouée (null si pas de réponse)
    ResponseEffect? responseEffect,

    /// ID de la carte dont l'action attend validation
    String? cardAwaitingValidation,

    /// Liste des joueurs devant valider (IDs)
    @Default([]) List<String> awaitingValidationFrom,

    /// Map des réponses de validation {playerId: actionCompleted}
    /// true = action effectuée, false = action refusée
    @Default({}) Map<String, bool> validationResponses,

    /// ID du gagnant (null si partie en cours)
    String? winnerId,

    /// === COMPTEUR ULTIMA ===

    /// ID du joueur qui a le compteur Ultima actif (premier à avoir posé Ultima)
    String? ultimaOwnerId,

    /// Nombre de tours écoulés depuis que Ultima est en jeu
    @Default(0) int ultimaTurnCount,

    /// Timestamp de pose d'Ultima pour déterminer qui l'a posé en premier
    DateTime? ultimaPlayedAt,

    /// Timestamp de création
    required DateTime createdAt,

    /// Timestamp de début de partie
    DateTime? startedAt,

    /// Timestamp de fin de partie
    DateTime? finishedAt,

    /// Timestamp de dernière mise à jour
    required DateTime updatedAt,
  }) = _GameSession;

  factory GameSession.fromJson(Map<String, dynamic> json) =>
      _$GameSessionFromJson(json);

  /// Crée une nouvelle session
  factory GameSession.create({
    required String sessionId,
    required String player1Id,
    required PlayerData player1Data,
  }) {
    final now = DateTime.now();
    return GameSession(
      sessionId: sessionId,
      player1Id: player1Id,
      player1Data: player1Data,
      createdAt: now,
      updatedAt: now,
    );
  }
}
