import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_card.dart';
import '../../domain/models/game_session.dart';
import 'firebase_service.dart';

/// Provider pour le service d'effets de cartes
final cardEffectServiceProvider = Provider<CardEffectService>((ref) {
  return CardEffectService(ref.read(firebaseServiceProvider));
});

/// Service pour parser et appliquer les effets des cartes
class CardEffectService {
  final FirebaseService _firebaseService;

  CardEffectService(this._firebaseService);

  /// Résout tous les effets de la pile de résolution
  Future<void> resolveEffects(String sessionId) async {
    final session = await _firebaseService.getGameSession(sessionId);

    if (session.resolutionStack.isEmpty) {
      return;
    }

    // Pour chaque carte dans la pile (LIFO - Last In First Out)
    for (int i = session.resolutionStack.length - 1; i >= 0; i--) {
      final cardId = session.resolutionStack[i];
      // TODO: Charger la carte et appliquer ses effets
      // Pour l'instant, on vide juste la pile
    }

    // Vider la pile de résolution
    await _clearResolutionStack(sessionId);
  }

  /// Applique les effets d'une carte basés sur ses champs structurés
  /// NOTE: GESTION MANUELLE - Les joueurs gèrent eux-mêmes PI, pioche et tension
  Future<void> applyCardEffect(
    String sessionId,
    GameCard card,
    String playerId,
  ) async {
    /* LOGIQUE AUTOMATIQUE DÉSACTIVÉE - Gestion manuelle par les joueurs
    
    // Pioche de cartes
    if (card.drawCards > 0) {
      await _drawCards(sessionId, playerId, card.drawCards);
    }

    // Dégâts PI à l'adversaire
    if (card.piDamageOpponent > 0) {
      await _damagePI(sessionId, 'opponent', card.piDamageOpponent);
    }

    // Gain PI pour le lanceur
    if (card.piGainSelf > 0) {
      await _gainPI(sessionId, playerId, card.piGainSelf);
    }

    // Augmentation de tension
    if (card.tensionIncrease > 0) {
      await _modifyTension(sessionId, playerId, card.tensionIncrease);
    }
    */

    // Enchantement permanent (garde cette logique car c'est juste un flag)
    if (card.isEnchantment) {
      await _applyEnchantment(sessionId, playerId, card.id);
    }
  }

  /// Fait piocher des cartes au joueur
  Future<void> _drawCards(String sessionId, String playerId, int count) async {
    for (int i = 0; i < count; i++) {
      try {
        await _firebaseService.drawCard(sessionId, playerId);
      } catch (e) {
        // Si le deck est vide, arrêter
        break;
      }
    }
  }

  /// Inflige des dégâts PI
  Future<void> _damagePI(String sessionId, String target, int damage) async {
    final session = await _firebaseService.getGameSession(sessionId);

    // Déterminer qui subit les dégâts
    String targetPlayerId;
    if (target == 'opponent') {
      // L'adversaire du joueur actif
      targetPlayerId =
          session.currentPlayerId == session.player1Id
              ? session.player2Id!
              : session.player1Id;
    } else {
      targetPlayerId = session.currentPlayerId!;
    }

    await _modifyPI(sessionId, targetPlayerId, -damage);
  }

  /// Fait gagner des PI
  Future<void> _gainPI(String sessionId, String playerId, int gain) async {
    await _modifyPI(sessionId, playerId, gain);
  }

  /// Modifie les PI d'un joueur
  Future<void> _modifyPI(String sessionId, String playerId, int delta) async {
    final session = await _firebaseService.getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;

    final newPI =
        isPlayer1
            ? (session.player1Data.inhibitionPoints + delta).clamp(0, 20)
            : (session.player2Data!.inhibitionPoints + delta).clamp(0, 20);

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: session.player1Data.copyWith(
                inhibitionPoints: newPI,
              ),
            )
            : session.copyWith(
              player2Data: session.player2Data!.copyWith(
                inhibitionPoints: newPI,
              ),
            );

    await _updateSession(sessionId, updatedSession);
  }

  /// Modifie la tension d'un joueur
  Future<void> _modifyTension(
    String sessionId,
    String playerId,
    int delta,
  ) async {
    final session = await _firebaseService.getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;

    final newTension =
        isPlayer1
            ? (session.player1Data.tension + delta).clamp(0.0, 100.0)
            : (session.player2Data!.tension + delta).clamp(0.0, 100.0);

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: session.player1Data.copyWith(tension: newTension),
            )
            : session.copyWith(
              player2Data: session.player2Data!.copyWith(tension: newTension),
            );

    await _updateSession(sessionId, updatedSession);
  }

  /// Applique un enchantement
  Future<void> _applyEnchantment(
    String sessionId,
    String playerId,
    String cardId,
  ) async {
    final session = await _firebaseService.getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;

    final enchantments =
        isPlayer1
            ? List<String>.from(session.player1Data.activeEnchantmentIds)
            : List<String>.from(session.player2Data!.activeEnchantmentIds);

    enchantments.add(cardId);

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: session.player1Data.copyWith(
                activeEnchantmentIds: enchantments,
              ),
            )
            : session.copyWith(
              player2Data: session.player2Data!.copyWith(
                activeEnchantmentIds: enchantments,
              ),
            );

    await _updateSession(sessionId, updatedSession);
  }

  /// Vide la pile de résolution
  Future<void> _clearResolutionStack(String sessionId) async {
    final docRef = _firebaseService.firestore
        .collection('game_sessions')
        .doc(sessionId);
    await docRef.update({'resolutionStack': []});
  }

  /// Met à jour la session Firebase
  Future<void> _updateSession(String sessionId, GameSession session) async {
    final docRef = _firebaseService.firestore
        .collection('game_sessions')
        .doc(sessionId);

    final sessionJson = session.toJson();
    sessionJson['player1Data'] = session.player1Data.toJson();
    if (session.player2Data != null) {
      sessionJson['player2Data'] = session.player2Data!.toJson();
    }

    await docRef.set(sessionJson);
  }
}
