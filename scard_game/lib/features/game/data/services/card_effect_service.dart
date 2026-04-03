import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/interfaces/i_game_session_service.dart';
import '../../domain/models/game_card.dart';
import 'game_session_service.dart';

/// Provider pour le service d'effets de cartes.
final cardEffectServiceProvider = Provider<CardEffectService>((ref) {
  return CardEffectService(ref.read(gameSessionServiceProvider));
});

/// Service pour parser et appliquer les effets des cartes.
class CardEffectService {
  final IGameSessionService _gameSessionService;

  CardEffectService(this._gameSessionService);

  /// Résout tous les effets de la pile de résolution.
  Future<void> resolveEffects(String sessionId) async {
    final session = await _gameSessionService.getSession(sessionId);

    if (session.resolutionStack.isEmpty) {
      return;
    }

    // TODO: Charger les cartes et appliquer leurs effets.
    // Pour l'instant, on vide juste la pile.
    await _clearResolutionStack(sessionId);
  }

  /// Applique les effets d'une carte basés sur ses champs structurés.
  /// NOTE: gestion manuelle - les joueurs gèrent eux-mêmes PI, pioche et tension.
  /// Les enchantements sont finalisés uniquement via
  /// SessionStateService.clearPlayedCards() pour éviter les doublons.
  Future<void> applyCardEffect(
    String sessionId,
    GameCard card,
    String playerId,
  ) async {
    if (card.isEnchantment) {
      return;
    }
  }

  /// Vide la pile de résolution.
  Future<void> _clearResolutionStack(String sessionId) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      return session.copyWith(resolutionStack: []);
    });
  }
}
