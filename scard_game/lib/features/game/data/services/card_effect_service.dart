import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interfaces/i_game_session_service.dart';
import '../../domain/models/game_card.dart';
import 'game_session_service.dart';

/// Provider pour le service d'effets de cartes
final cardEffectServiceProvider = Provider<CardEffectService>((ref) {
  return CardEffectService(ref.read(gameSessionServiceProvider));
});

/// Service pour parser et appliquer les effets des cartes
class CardEffectService {
  final IGameSessionService _gameSessionService;

  CardEffectService(this._gameSessionService);

  /// Résout tous les effets de la pile de résolution
  Future<void> resolveEffects(String sessionId) async {
    final session = await _gameSessionService.getSession(sessionId);

    if (session.resolutionStack.isEmpty) {
      return;
    }

    // TODO: Charger les cartes et appliquer leurs effets
    // Pour l'instant, on vide juste la pile
    await _clearResolutionStack(sessionId);
  }

  /// Applique les effets d'une carte basés sur ses champs structurés
  /// NOTE: GESTION MANUELLE - Les joueurs gèrent eux-mêmes PI, pioche et tension
  /// Les effets automatiques sont désactivés pour privilégier la gestion manuelle
  Future<void> applyCardEffect(
    String sessionId,
    GameCard card,
    String playerId,
  ) async {
    // Seuls les enchantements sont appliqués automatiquement
    if (card.isEnchantment) {
      await _applyEnchantment(sessionId, playerId, card.id);
    }
  }

  /// Applique un enchantement
  Future<void> _applyEnchantment(
    String sessionId,
    String playerId,
    String cardId,
  ) async {
    final session = await _gameSessionService.getSession(sessionId);
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

    await _gameSessionService.updateSession(sessionId, updatedSession);
  }

  /// Vide la pile de résolution
  Future<void> _clearResolutionStack(String sessionId) async {
    final session = await _gameSessionService.getSession(sessionId);
    final updatedSession = session.copyWith(resolutionStack: []);
    await _gameSessionService.updateSession(sessionId, updatedSession);
  }
}
