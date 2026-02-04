import '../../features/game/domain/models/game_session.dart';
import '../../features/game/domain/models/player_data.dart';

/// Extension sur GameSession pour simplifier l'accès aux données des joueurs
/// Applique le principe KISS en évitant les répétitions isPlayer1 ? ... : ...
extension GameSessionPlayerExtension on GameSession {
  /// Vérifie si le playerId correspond au joueur 1
  bool isPlayer1(String playerId) => player1Id == playerId;

  /// Récupère les données du joueur actuel (ne peut pas être null)
  PlayerData getPlayerData(String playerId) {
    return isPlayer1(playerId) ? player1Data : player2Data!;
  }

  /// Récupère les données de l'adversaire (peut être null si pas encore rejoint)
  PlayerData? getOpponentData(String playerId) {
    return isPlayer1(playerId) ? player2Data : player1Data;
  }

  /// Récupère l'ID de l'adversaire
  String? getOpponentId(String playerId) {
    return isPlayer1(playerId) ? player2Id : player1Id;
  }

  /// Met à jour les données d'un joueur et retourne une nouvelle session
  GameSession updatePlayerData(String playerId, PlayerData newData) {
    if (isPlayer1(playerId)) {
      return copyWith(player1Data: newData);
    } else {
      return copyWith(player2Data: newData);
    }
  }

  /// Met à jour les données des deux joueurs et retourne une nouvelle session
  GameSession updateBothPlayers({
    required PlayerData player1Data,
    required PlayerData player2Data,
  }) {
    return copyWith(player1Data: player1Data, player2Data: player2Data);
  }

  /// Vérifie si c'est le tour du joueur spécifié
  bool isPlayerTurn(String playerId) {
    return currentPlayerId == playerId;
  }

  /// Récupère les données du joueur actif (celui dont c'est le tour)
  PlayerData? get activePlayerData {
    if (currentPlayerId == player1Id) return player1Data;
    if (currentPlayerId == player2Id) return player2Data;
    return null;
  }
}
