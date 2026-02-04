import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';
import '../enums/game_phase.dart';
import '../enums/game_status.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

/// Modèle représentant l'état complet d'une partie
@freezed
class GameState with _$GameState {
  const factory GameState({
    /// ID unique de la partie
    required String gameId,

    /// Joueur 1
    required Player player1,

    /// Joueur 2
    required Player player2,

    /// Numéro du tour actuel
    @Default(1) int turn,

    /// ID du joueur actif (dont c'est le tour)
    required String activePlayerId,

    /// Phase actuelle du jeu
    @Default(GamePhase.main) GamePhase phase,

    /// Statut de la partie
    @Default(GameStatus.waiting) GameStatus status,

    /// Deadline pour répondre (null si pas de timer actif)
    DateTime? responseDeadline,

    /// ID du gagnant (null si partie pas terminée)
    String? winnerId,

    /// Timestamp de création de la partie
    DateTime? createdAt,
  }) = _GameState;

  const GameState._();

  /// Récupérer un joueur par son ID
  Player getPlayer(String playerId) {
    return player1.id == playerId ? player1 : player2;
  }

  /// Récupérer l'adversaire d'un joueur
  Player getOpponent(String playerId) {
    return player1.id == playerId ? player2 : player1;
  }

  /// Le joueur peut-il jouer une carte de cette couleur ?
  bool canPlayColor(String playerId, int colorValue) {
    // Conversion de colorValue en CardColor à faire dans l'extension
    return true; // Simplifié pour l'instant
  }

  /// La partie est-elle terminée ?
  bool get isFinished => status == GameStatus.finished;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}
