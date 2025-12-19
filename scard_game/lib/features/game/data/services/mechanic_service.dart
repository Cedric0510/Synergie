import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_card.dart';
import '../../domain/models/card_mechanic.dart';
import '../../domain/enums/mechanic_type.dart';
import '../../domain/enums/target_type.dart';
import '../../presentation/widgets/card_widget.dart';
import 'firebase_service.dart';
import 'card_service.dart';

/// Service pour traiter les mécaniques spéciales des cartes
class MechanicService {
  final FirebaseService _firebaseService;
  final CardService _cardService;

  MechanicService(this._firebaseService, this._cardService);

  /// Exécute les actions pendantes d'un sort (appelé en phase Resolution si le sort n'est pas contré)
  Future<void> executePendingActions({
    required String sessionId,
    required List<PendingAction> actions,
  }) async {
    for (final action in actions) {
      switch (action.type) {
        case PendingActionType.destroyEnchantment:
          if (action.targetPlayerId != null && action.targetCardId != null) {
            await _firebaseService.removeEnchantment(
              sessionId,
              action.targetPlayerId!,
              action.targetCardId!,
            );
          }
          break;
        case PendingActionType.replaceEnchantment:
          // TODO: Implémenter le remplacement
          break;
        case PendingActionType.destroyAllEnchantments:
          // Géré par des actions individuelles destroyEnchantment
          break;
      }
    }
  }

  /// Traite toutes les mécaniques d'une carte
  Future<MechanicResult> processMechanics({
    required BuildContext context,
    required String sessionId,
    required GameCard card,
    required String playerId,
    required List<String> handCardIds,
    required List<String> activeEnchantmentIds,
    required List<String> opponentEnchantmentIds,
  }) async {
    if (card.mechanics.isEmpty) {
      return MechanicResult(success: true);
    }

    MechanicResult result = MechanicResult(success: true);

    for (final mechanic in card.mechanics) {
      final mechanicResult = await _processMechanic(
        context: context,
        sessionId: sessionId,
        card: card,
        mechanic: mechanic,
        playerId: playerId,
        handCardIds: handCardIds,
        activeEnchantmentIds: activeEnchantmentIds,
        opponentEnchantmentIds: opponentEnchantmentIds,
      );

      if (!mechanicResult.success) {
        return mechanicResult;
      }

      // Accumuler les résultats
      result = result.merge(mechanicResult);
    }

    return result;
  }

  /// Traite une mécanique spécifique
  Future<MechanicResult> _processMechanic({
    required BuildContext context,
    required String sessionId,
    required GameCard card,
    required CardMechanic mechanic,
    required String playerId,
    required List<String> handCardIds,
    required List<String> activeEnchantmentIds,
    required List<String> opponentEnchantmentIds,
  }) async {
    switch (mechanic.type) {
      case MechanicType.sacrificeCard:
        return await _handleSacrificeCard(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
          handCardIds: handCardIds,
        );

      case MechanicType.discardCard:
        return await _handleDiscardCard(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
          handCardIds: handCardIds,
        );

      case MechanicType.destroyEnchantment:
        return await _handleDestroyEnchantment(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
          activeEnchantmentIds: activeEnchantmentIds,
          opponentEnchantmentIds: opponentEnchantmentIds,
        );

      case MechanicType.replaceEnchantment:
        return await _handleReplaceEnchantment(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
          activeEnchantmentIds: activeEnchantmentIds,
          opponentEnchantmentIds: opponentEnchantmentIds,
        );

      case MechanicType.drawUntil:
        return await _handleDrawUntil(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
        );

      case MechanicType.shuffleHandIntoDeck:
        return await _handleShuffleHandIntoDeck(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
        );

      case MechanicType.counterBased:
        return await _handleCounterBased(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
        );

      case MechanicType.turnCounter:
        return await _handleTurnCounter(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
        );

      case MechanicType.playerChoice:
        return await _handlePlayerChoice(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
        );

      case MechanicType.destroyAllEnchantments:
        return await _handleDestroyAllEnchantments(
          context: context,
          sessionId: sessionId,
          mechanic: mechanic,
          playerId: playerId,
          activeEnchantmentIds: activeEnchantmentIds,
          opponentEnchantmentIds: opponentEnchantmentIds,
        );

      default:
        return MechanicResult(
          success: true,
          message:
              'Mécanique ${mechanic.type.displayName} pas encore implémentée',
        );
    }
  }

  // === HANDLERS POUR CHAQUE MÉCANIQUE ===

  Future<MechanicResult> _handleSacrificeCard({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
    required List<String> handCardIds,
  }) async {
    // Afficher un dialog pour sélectionner une carte de la main
    final selectedCardId = await _showCardSelectionDialog(
      context: context,
      title: 'Sacrifier une carte',
      cardIds: handCardIds,
      filter: mechanic.filter,
    );

    if (selectedCardId == null) {
      return MechanicResult(success: false, message: 'Sacrifice annulé');
    }

    // Récupérer la carte sacrifiée
    final allCards = await _cardService.loadAllCards();
    final sacrificedCard = allCards.firstWhere((c) => c.id == selectedCardId);

    // Retirer la carte de la main
    await _firebaseService.removeCardFromHand(
      sessionId,
      playerId,
      selectedCardId,
    );

    return MechanicResult(
      success: true,
      sacrificedCard: sacrificedCard,
      message: '${sacrificedCard.name} a été sacrifiée',
    );
  }

  Future<MechanicResult> _handleDiscardCard({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
    required List<String> handCardIds,
  }) async {
    // Même logique que sacrifice mais sans effet de remplacement
    final selectedCardId = await _showCardSelectionDialog(
      context: context,
      title: 'Se défausser d\'une carte',
      cardIds: handCardIds,
      filter: mechanic.filter,
    );

    if (selectedCardId == null) {
      return MechanicResult(success: false, message: 'Défausse annulée');
    }

    // Retirer la carte de la main (même effet que sacrifice)
    await _firebaseService.removeCardFromHand(
      sessionId,
      playerId,
      selectedCardId,
    );

    return MechanicResult(
      success: true,
      discardedCardId: selectedCardId,
      message: 'Carte défaussée',
    );
  }

  Future<MechanicResult> _handleDestroyEnchantment({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
    required List<String> activeEnchantmentIds,
    required List<String> opponentEnchantmentIds,
  }) async {
    // Déterminer quelle liste utiliser selon le target
    List<String> targetEnchantments;
    String targetPlayerId;

    switch (mechanic.target) {
      case TargetType.ownEnchantment:
        targetEnchantments = activeEnchantmentIds;
        targetPlayerId = playerId;
        break;
      case TargetType.opponentEnchantment:
        targetEnchantments = opponentEnchantmentIds;
        // Récupérer l'ID de l'adversaire
        final session = await _firebaseService.getGameSession(sessionId);
        targetPlayerId =
            session.player1Id == playerId
                ? session.player2Data!.playerId
                : session.player1Id;
        break;
      case TargetType.anyEnchantment:
      default:
        // Tous les enchantements (propres + adversaires)
        targetEnchantments = [
          ...activeEnchantmentIds,
          ...opponentEnchantmentIds,
        ];
        targetPlayerId = playerId; // Sera déterminé après sélection
        break;
    }

    if (targetEnchantments.isEmpty) {
      return MechanicResult(
        success: false,
        message: 'Aucun enchantement disponible',
      );
    }

    // Sélectionner un enchantement à détruire
    final selectedEnchantmentId = await _showCardSelectionDialog(
      context: context,
      title: 'Détruire un enchantement',
      cardIds: targetEnchantments,
      filter: mechanic.filter,
    );

    if (selectedEnchantmentId == null) {
      return MechanicResult(success: false, message: 'Destruction annulée');
    }

    // Si anyEnchantment, déterminer le propriétaire
    if (mechanic.target == TargetType.anyEnchantment) {
      if (opponentEnchantmentIds.contains(selectedEnchantmentId)) {
        final session = await _firebaseService.getGameSession(sessionId);
        targetPlayerId =
            session.player1Id == playerId
                ? session.player2Data!.playerId
                : session.player1Id;
      }
    }

    // NE PAS détruire immédiatement - créer une action pendante
    // La destruction se fera en phase Resolution si le sort n'est pas contré
    return MechanicResult(
      success: true,
      destroyedEnchantmentId: selectedEnchantmentId,
      message: 'Enchantement sélectionné pour destruction',
      pendingActions: [
        PendingAction(
          type: PendingActionType.destroyEnchantment,
          targetPlayerId: targetPlayerId,
          targetCardId: selectedEnchantmentId,
        ),
      ],
    );
  }

  Future<MechanicResult> _handleReplaceEnchantment({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
    required List<String> activeEnchantmentIds,
    required List<String> opponentEnchantmentIds,
  }) async {
    // Déterminer quelle liste utiliser selon le target
    List<String> targetEnchantments;

    switch (mechanic.target) {
      case TargetType.ownEnchantment:
        targetEnchantments = activeEnchantmentIds;
        break;
      case TargetType.opponentEnchantment:
        targetEnchantments = opponentEnchantmentIds;
        break;
      case TargetType.anyEnchantment:
      default:
        targetEnchantments = [
          ...activeEnchantmentIds,
          ...opponentEnchantmentIds,
        ];
        break;
    }

    if (targetEnchantments.isEmpty) {
      return MechanicResult(
        success: false,
        message: 'Aucun enchantement disponible',
      );
    }

    // Sélectionner un enchantement à remplacer
    final selectedEnchantmentId = await _showCardSelectionDialog(
      context: context,
      title: 'Remplacer un enchantement',
      cardIds: targetEnchantments,
      filter: mechanic.filter,
    );

    if (selectedEnchantmentId == null) {
      return MechanicResult(success: false, message: 'Remplacement annulé');
    }

    return MechanicResult(
      success: true,
      replacedEnchantmentId: selectedEnchantmentId,
      message: 'Enchantement remplacé',
    );
  }

  Future<MechanicResult> _handleDrawUntil({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
  }) async {
    final drawnCards = <GameCard>[];
    final allCards = await _cardService.loadAllCards();
    final session = await _firebaseService.getGameSession(sessionId);

    // Déterminer le deck du joueur
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    // Piocher jusqu'à trouver une carte correspondant au filtre
    for (final cardId in playerData.deckCardIds) {
      final card = allCards.firstWhere((c) => c.id == cardId);
      drawnCards.add(card);

      // Ajouter à la main
      await _firebaseService.drawSpecificCard(sessionId, playerId, cardId);

      // Vérifier si la carte correspond au filtre
      if (mechanic.filter != null) {
        final filtered = _applyFilter([card], mechanic.filter!);
        if (filtered.isNotEmpty) {
          break; // Carte trouvée
        }
      }
    }

    return MechanicResult(
      success: true,
      drawnCards: drawnCards,
      message:
          'Piocher jusqu\'au filtre ${mechanic.filter} : ${drawnCards.length} carte(s)',
    );
  }

  Future<MechanicResult> _handleShuffleHandIntoDeck({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
  }) async {
    // Récupérer la session et les données du joueur
    final session = await _firebaseService.getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;
    final handSize = playerData.handCardIds.length;

    // Mélanger la main dans le deck
    await _firebaseService.shuffleHandIntoDeck(sessionId, playerId);

    // Piocher le même nombre de cartes si spécifié
    if (mechanic.additionalActions?['drawCount'] == 'handSize') {
      for (int i = 0; i < handSize; i++) {
        await _firebaseService.drawCard(sessionId, playerId);
      }
    }

    return MechanicResult(
      success: true,
      message: 'Main mélangée dans le deck et $handSize carte(s) repiochée(s)',
    );
  }

  Future<MechanicResult> _handleCounterBased({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
  }) async {
    // Initialiser un enchantement avec des charges
    int counterValue = mechanic.initialCounterValue ?? 0;

    // Si counterSource est défini, calculer la valeur
    if (mechanic.counterSource == 'clothingCount') {
      final session = await _firebaseService.getGameSession(sessionId);
      final isPlayer1 = session.player1Id == playerId;
      final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

      // Supposons un champ clothingCount dans PlayerData (TODO: ajouter si nécessaire)
      // Pour l'instant, valeur par défaut
      counterValue = mechanic.initialCounterValue ?? 1;
    }

    return MechanicResult(
      success: true,
      counterValue: counterValue,
      message: 'Enchantement avec $counterValue charges',
    );
  }

  Future<MechanicResult> _handleTurnCounter({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
  }) async {
    // Initialiser un compteur de tours
    final turns = mechanic.initialCounterValue ?? 3;

    return MechanicResult(
      success: true,
      counterValue: turns,
      message: 'Compteur initialisé à $turns tours',
    );
  }

  Future<MechanicResult> _handlePlayerChoice({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
  }) async {
    // Afficher un dialog avec des choix
    // TODO: Implémenter le dialog de choix

    return MechanicResult(success: true, message: 'Choix du joueur');
  }

  Future<MechanicResult> _handleDestroyAllEnchantments({
    required BuildContext context,
    required String sessionId,
    required CardMechanic mechanic,
    required String playerId,
    required List<String> activeEnchantmentIds,
    required List<String> opponentEnchantmentIds,
  }) async {
    // Déterminer quelle liste utiliser selon le target
    List<String> targetEnchantments;
    String targetPlayerId;

    switch (mechanic.target) {
      case TargetType.ownEnchantment:
        targetEnchantments = activeEnchantmentIds;
        targetPlayerId = playerId;
        break;
      case TargetType.opponentEnchantment:
        targetEnchantments = opponentEnchantmentIds;
        // Récupérer l'ID de l'adversaire
        final session = await _firebaseService.getGameSession(sessionId);
        targetPlayerId =
            session.player1Id == playerId
                ? session.player2Data!.playerId
                : session.player1Id;
        break;
      case TargetType.anyEnchantment:
      default:
        // Pour destroyAll avec anyEnchantment, créer des actions pendantes pour les deux joueurs
        final session = await _firebaseService.getGameSession(sessionId);
        final opponentId =
            session.player1Id == playerId
                ? session.player2Data!.playerId
                : session.player1Id;

        final pendingActions = <PendingAction>[];

        // Actions pour les enchantements du joueur
        for (final enchantmentId in activeEnchantmentIds) {
          pendingActions.add(
            PendingAction(
              type: PendingActionType.destroyEnchantment,
              targetPlayerId: playerId,
              targetCardId: enchantmentId,
            ),
          );
        }

        // Actions pour les enchantements de l'adversaire
        for (final enchantmentId in opponentEnchantmentIds) {
          pendingActions.add(
            PendingAction(
              type: PendingActionType.destroyEnchantment,
              targetPlayerId: opponentId,
              targetCardId: enchantmentId,
            ),
          );
        }

        final totalCount =
            activeEnchantmentIds.length + opponentEnchantmentIds.length;
        return MechanicResult(
          success: true,
          message: '$totalCount enchantements sélectionnés pour destruction',
          additionalData: {'destroyedCount': totalCount},
          pendingActions: pendingActions,
        );
    }

    // Créer des actions pendantes pour tous les enchantements de la liste ciblée
    final pendingActions = <PendingAction>[];
    for (final enchantmentId in targetEnchantments) {
      pendingActions.add(
        PendingAction(
          type: PendingActionType.destroyEnchantment,
          targetPlayerId: targetPlayerId,
          targetCardId: enchantmentId,
        ),
      );
    }

    return MechanicResult(
      success: true,
      message:
          '${targetEnchantments.length} enchantements sélectionnés pour destruction',
      additionalData: {'destroyedCount': targetEnchantments.length},
      pendingActions: pendingActions,
    );
  }

  // === DIALOGS ===

  Future<String?> _showCardSelectionDialog({
    required BuildContext context,
    required String title,
    required List<String> cardIds,
    String? filter,
  }) async {
    final allCards = await _cardService.loadAllCards();
    List<GameCard> availableCards =
        allCards.where((card) => cardIds.contains(card.id)).toList();

    // Appliquer le filtre si présent
    if (filter != null) {
      availableCards = _applyFilter(availableCards, filter);
    }

    if (availableCards.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune carte disponible')),
        );
      }
      return null;
    }

    if (!context.mounted) return null;

    return await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableCards.length,
                itemBuilder: (context, index) {
                  final card = availableCards[index];
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      richMessage: WidgetSpan(
                        child: Material(
                          color: Colors.transparent,
                          child: _buildCardPreview(card),
                        ),
                      ),
                      decoration: const BoxDecoration(),
                      padding: EdgeInsets.zero,
                      preferBelow: false,
                      verticalOffset: 20,
                      child: ListTile(
                        title: Text(card.name),
                        subtitle: Text(
                          card.gameEffect,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.of(context).pop(card.id),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ],
          ),
    );
  }

  /// Construit une prévisualisation de carte pour le tooltip
  Widget _buildCardPreview(GameCard card) {
    return CardWidget(card: card, width: 280, height: 440, compact: false);
  }

  List<GameCard> _applyFilter(List<GameCard> cards, String filter) {
    if (filter.startsWith('color:')) {
      final color = filter.substring(6);
      return cards.where((c) => c.color.name == color).toList();
    } else if (filter.startsWith('type:')) {
      final type = filter.substring(5);
      return cards.where((c) => c.type.name == type).toList();
    } else if (filter.startsWith('name:')) {
      final name = filter.substring(5);
      return cards.where((c) => c.name.contains(name)).toList();
    }
    return cards;
  }
}

/// Résultat du traitement d'une mécanique
class MechanicResult {
  final bool success;
  final String? message;
  final GameCard? sacrificedCard;
  final String? discardedCardId;
  final String? destroyedEnchantmentId;
  final String? replacedEnchantmentId;
  final List<GameCard>? drawnCards;
  final int? counterValue;
  final Map<String, dynamic>? additionalData;

  /// Actions à exécuter APRÈS la phase de réponse (si le sort n'est pas contré)
  final List<PendingAction>? pendingActions;

  MechanicResult({
    required this.success,
    this.message,
    this.sacrificedCard,
    this.discardedCardId,
    this.destroyedEnchantmentId,
    this.replacedEnchantmentId,
    this.drawnCards,
    this.counterValue,
    this.additionalData,
    this.pendingActions,
  });

  MechanicResult merge(MechanicResult other) {
    return MechanicResult(
      success: success && other.success,
      message: [message, other.message].where((m) => m != null).join('\n'),
      sacrificedCard: sacrificedCard ?? other.sacrificedCard,
      discardedCardId: discardedCardId ?? other.discardedCardId,
      destroyedEnchantmentId:
          destroyedEnchantmentId ?? other.destroyedEnchantmentId,
      replacedEnchantmentId:
          replacedEnchantmentId ?? other.replacedEnchantmentId,
      drawnCards: [...?drawnCards, ...?other.drawnCards],
      counterValue: counterValue ?? other.counterValue,
      additionalData: {...?additionalData, ...?other.additionalData},
      pendingActions: [...?pendingActions, ...?other.pendingActions],
    );
  }
}

/// Action à exécuter après la phase de réponse
class PendingAction {
  final PendingActionType type;
  final String? targetPlayerId;
  final String? targetCardId;
  final Map<String, dynamic>? data;

  PendingAction({
    required this.type,
    this.targetPlayerId,
    this.targetCardId,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'targetPlayerId': targetPlayerId,
    'targetCardId': targetCardId,
    'data': data,
  };

  factory PendingAction.fromJson(Map<String, dynamic> json) => PendingAction(
    type: PendingActionType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    targetPlayerId: json['targetPlayerId'],
    targetCardId: json['targetCardId'],
    data: json['data'],
  );
}

enum PendingActionType {
  destroyEnchantment,
  replaceEnchantment,
  destroyAllEnchantments,
}

/// Provider pour le service de mécaniques
final mechanicServiceProvider = Provider<MechanicService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final cardService = ref.watch(cardServiceProvider);
  return MechanicService(firebaseService, cardService);
});
