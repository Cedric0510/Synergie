import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/game_constants.dart';
import '../../domain/models/game_session.dart';
import '../../domain/models/player_data.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/enums/game_status.dart';

/// Provider pour le service de gestion des tours
final turnServiceProvider = Provider<TurnService>((ref) {
  return TurnService();
});

/// Service de gestion des phases et tours de jeu
/// Extrait de FirebaseService pour respecter le principe S (Single Responsibility)
class TurnService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'game_sessions';

  /// Passer à la phase suivante du jeu
  Future<void> nextPhase(String sessionId) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    GamePhase nextPhase;
    String? nextPlayerId;

    switch (session.currentPhase) {
      case GamePhase.draw:
        nextPhase = GamePhase.main;
        nextPlayerId = session.currentPlayerId;
        break;
      case GamePhase.main:
        nextPhase = GamePhase.response;
        nextPlayerId = session.currentPlayerId;
        break;
      case GamePhase.response:
        nextPhase = GamePhase.resolution;
        nextPlayerId = session.currentPlayerId;
        break;
      case GamePhase.resolution:
        nextPhase = GamePhase.end;
        nextPlayerId = session.currentPlayerId;
        break;
      case GamePhase.end:
        // Passer au tour de l'adversaire
        nextPhase = GamePhase.draw;
        nextPlayerId =
            session.currentPlayerId == session.player1Id
                ? session.player2Id
                : session.player1Id;
        break;
    }

    // === RESET FLAG SACRIFICE AU DÉBUT DU NOUVEAU TOUR ===
    PlayerData? updatedPlayer1Data;
    PlayerData? updatedPlayer2Data;

    if (session.currentPhase == GamePhase.end && nextPhase == GamePhase.draw) {
      // Nouveau tour : réinitialiser le flag de sacrifice pour les deux joueurs
      updatedPlayer1Data = session.player1Data.copyWith(
        hasSacrificedThisTurn: false,
      );
      updatedPlayer2Data = session.player2Data?.copyWith(
        hasSacrificedThisTurn: false,
      );
    }

    // === GESTION COMPTEUR ULTIMA ===
    int newUltimaTurnCount = session.ultimaTurnCount;
    String? newWinnerId = session.winnerId;
    GameStatus newStatus = session.status;

    // Si on passe en phase end ET qu'un joueur a le compteur Ultima actif
    if (session.currentPhase == GamePhase.resolution &&
        nextPhase == GamePhase.end) {
      if (session.ultimaOwnerId != null) {
        // Vérifier que le joueur qui a le compteur a toujours Ultima en jeu
        final isOwnerPlayer1 = session.ultimaOwnerId == session.player1Id;
        final ownerData =
            isOwnerPlayer1 ? session.player1Data : session.player2Data!;
        final ownerHasUltima = ownerData.activeEnchantmentIds.any(
          (id) => id.contains(GameConstants.ultimaCardId),
        );

        if (ownerHasUltima) {
          // Incrémenter le compteur
          newUltimaTurnCount = session.ultimaTurnCount + 1;

          // Vérifier si le compteur atteint 3
          if (newUltimaTurnCount >= 3) {
            newWinnerId = session.ultimaOwnerId;
            newStatus = GameStatus.finished;
          }
        }
      }
    }

    await docRef.update({
      'currentPhase': nextPhase.name,
      'currentPlayerId': nextPlayerId,
      'ultimaTurnCount': newUltimaTurnCount,
      'winnerId': newWinnerId,
      'status': newStatus.name,
      if (nextPhase == GamePhase.draw) 'drawDoneThisTurn': false,
      if (nextPhase == GamePhase.draw) 'enchantmentEffectsDoneThisTurn': false,
      if (updatedPlayer1Data != null)
        'player1Data': updatedPlayer1Data.toJson(),
      if (updatedPlayer2Data != null)
        'player2Data': updatedPlayer2Data.toJson(),
    });
  }

  /// Termine le tour du joueur actuel et passe au joueur suivant
  Future<void> endTurn(String sessionId) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);

    // Passer au joueur suivant
    final nextPlayerId =
        session.currentPlayerId == session.player1Id
            ? session.player2Id
            : session.player1Id;

    // Réinitialiser à la phase de pioche pour le prochain tour
    await docRef.update({
      'currentPlayerId': nextPlayerId,
      'currentPhase': GamePhase.draw.name,
      'drawDoneThisTurn': false,
      'enchantmentEffectsDoneThisTurn': false,
    });
  }

  /// Marque la pioche automatique comme effectuée pour ce tour
  Future<void> setDrawDoneThisTurn(String sessionId, bool value) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    await docRef.update({'drawDoneThisTurn': value});
  }

  /// Marque les effets d'enchantements comme appliqués pour ce tour
  Future<void> setEnchantmentEffectsDoneThisTurn(
    String sessionId,
    bool value,
  ) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    await docRef.update({'enchantmentEffectsDoneThisTurn': value});
  }

  /// Force le tour à un joueur spécifique (pour certains effets)
  Future<void> forceTurnToPlayer(String sessionId, String playerId) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    await docRef.update({
      'currentPlayerId': playerId,
      'currentPhase': GamePhase.draw.name,
      'drawDoneThisTurn': false,
      'enchantmentEffectsDoneThisTurn': false,
    });
  }
}
