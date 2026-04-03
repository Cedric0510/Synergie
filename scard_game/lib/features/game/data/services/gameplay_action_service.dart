import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/game_exceptions.dart';
import '../../../../core/extensions/game_session_extensions.dart';
import '../../../../core/interfaces/i_game_session_service.dart';
import '../../domain/models/player_data.dart';
import 'game_session_service.dart';

/// Service dédié aux actions gameplay déclenchées par l'UI.
class GameplayActionService {
  final IGameSessionService _gameSessionService;

  GameplayActionService(this._gameSessionService);

  /// Pioche une carte. Si le deck est vide, remélange le cimetière.
  Future<void> drawCard(String sessionId, String playerId) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final playerData = session.getPlayerData(playerId);
      if (_isTensionLocked(playerData)) {
        return session;
      }

      var deck = List<String>.from(playerData.deckCardIds);
      final hand = List<String>.from(playerData.handCardIds);
      var graveyard = List<String>.from(playerData.graveyardCardIds);

      if (deck.isEmpty) {
        if (graveyard.isEmpty) {
          throw GameplayException(
            'Deck et cimetière vides - impossible de piocher',
          );
        }
        deck = List<String>.from(graveyard);
        deck.shuffle(Random());
        graveyard = [];
      }

      final drawnCard = deck.removeAt(0);
      hand.add(drawnCard);

      final updatedPlayer = playerData.copyWith(
        deckCardIds: deck,
        handCardIds: hand,
        graveyardCardIds: graveyard,
      );
      return session
          .updatePlayerData(playerId, updatedPlayer)
          .copyWith(updatedAt: DateTime.now());
    });
  }

  /// Parse le coût de lancement et retourne le coût PI.
  int parseLauncherCost(String launcherCost) {
    final match = RegExp(
      r'(\d+)\s+PI',
      caseSensitive: false,
    ).firstMatch(launcherCost);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  /// Vérifie si le joueur peut payer le coût et le déduit.
  Future<void> payCost(String sessionId, String playerId, int cost) async {
    if (cost == 0) return;

    await _gameSessionService.runTransaction(sessionId, (session) {
      final playerData = session.getPlayerData(playerId);
      if (_isPiLocked(playerData)) {
        throw GameplayException('PI verrouillés');
      }

      final currentPi = playerData.inhibitionPoints;
      if (currentPi < cost) {
        throw GameplayException(
          'Pas assez de PI (nécessaire: $cost, disponible: $currentPi)',
        );
      }

      final updatedPlayer = playerData.copyWith(
        inhibitionPoints: currentPi - cost,
      );
      return session
          .updatePlayerData(playerId, updatedPlayer)
          .copyWith(updatedAt: DateTime.now());
    });
  }

  /// Joue une carte depuis la main et l'ajoute à la pile de résolution.
  Future<void> playCard(
    String sessionId,
    String playerId,
    int handIndex, {
    String? enchantmentTierKey,
  }) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final playerData = session.getPlayerData(playerId);
      final hand = List<String>.from(playerData.handCardIds);

      if (handIndex < 0 || handIndex >= hand.length) {
        throw GameplayException('Index de carte invalide');
      }

      final playedCard = hand.removeAt(handIndex);
      final playedCards = List<String>.from(playerData.playedCardIds)
        ..add(playedCard);
      final updatedPlayedTiers = Map<String, String>.from(
        session.playedCardTiers,
      );
      if (enchantmentTierKey != null) {
        updatedPlayedTiers[playedCard] = enchantmentTierKey;
      }

      final updatedPlayer = playerData.copyWith(
        handCardIds: hand,
        playedCardIds: playedCards,
      );
      return session
          .updatePlayerData(playerId, updatedPlayer)
          .copyWith(
            resolutionStack: [...session.resolutionStack, playedCard],
            playedCardTiers: updatedPlayedTiers,
            updatedAt: DateTime.now(),
          );
    });
  }

  /// Retire une carte spécifique de la main du joueur.
  Future<void> removeCardFromHand(
    String sessionId,
    String playerId,
    String cardId,
  ) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final playerData = session.getPlayerData(playerId);
      final updatedHand = List<String>.from(playerData.handCardIds)
        ..remove(cardId);

      return session
          .updatePlayerData(
            playerId,
            playerData.copyWith(handCardIds: updatedHand),
          )
          .copyWith(updatedAt: DateTime.now());
    });
  }

  /// Pioche une carte spécifique depuis le deck du joueur.
  Future<void> drawSpecificCard(
    String sessionId,
    String playerId,
    String cardId,
  ) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final playerData = session.getPlayerData(playerId);
      final updatedDeck = List<String>.from(playerData.deckCardIds);
      final updatedHand = List<String>.from(playerData.handCardIds);

      if (!updatedDeck.remove(cardId)) {
        return session;
      }
      updatedHand.add(cardId);

      return session
          .updatePlayerData(
            playerId,
            playerData.copyWith(
              deckCardIds: updatedDeck,
              handCardIds: updatedHand,
            ),
          )
          .copyWith(updatedAt: DateTime.now());
    });
  }

  /// Mélange la main du joueur dans son deck.
  Future<void> shuffleHandIntoDeck(String sessionId, String playerId) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final playerData = session.getPlayerData(playerId);
      final updatedDeck =
          List<String>.from(playerData.deckCardIds)
            ..addAll(playerData.handCardIds)
            ..shuffle(Random());

      return session
          .updatePlayerData(
            playerId,
            playerData.copyWith(deckCardIds: updatedDeck, handCardIds: []),
          )
          .copyWith(updatedAt: DateTime.now());
    });
  }

  bool _isPiLocked(PlayerData playerData) {
    final modifiers = playerData.activeStatusModifiers;
    return (modifiers['pi_locked']?.isNotEmpty ?? false) ||
        (modifiers['lockPI']?.isNotEmpty ?? false);
  }

  bool _isTensionLocked(PlayerData playerData) {
    final modifiers = playerData.activeStatusModifiers;
    return (modifiers['tension_locked']?.isNotEmpty ?? false) ||
        (modifiers['lockTension']?.isNotEmpty ?? false);
  }
}

final gameplayActionServiceProvider = Provider<GameplayActionService>((ref) {
  final gameSessionService = ref.watch(gameSessionServiceProvider);
  return GameplayActionService(gameSessionService);
});
