import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/game_constants.dart';
import '../../../../../core/extensions/game_session_extensions.dart';
import '../../../data/services/card_service.dart';
import '../../../data/services/game_session_service.dart';
import '../../../data/services/gameplay_action_service.dart';
import '../../../data/services/player_service.dart';
import '../../../data/services/turn_service.dart';
import '../../../data/services/mechanic_service.dart';
import '../../../data/services/session_state_service.dart';
import '../../../data/services/tension_service.dart';
import '../../../domain/enums/card_color.dart';
import '../../../domain/enums/card_level.dart';
import '../../../domain/enums/card_type.dart';
import '../../../domain/enums/game_phase.dart';
import '../../../domain/models/game_card.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/player_data.dart';

/// Mixin contenant toutes les actions de jeu (jouer carte, valider, annuler, etc.)
mixin GameActionsMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Ces propriétés doivent être implémentées par GameScreen
  String get sessionId;
  String get playerId;
  int? get selectedCardIndex;
  set selectedCardIndex(int? value);
  bool get pendingCardValidation;
  set pendingCardValidation(bool value);
  bool get isDiscardMode;
  set isDiscardMode(bool value);

  // État pour le drag & drop - permet de nettoyer quand la validation est terminée
  GameCard? get pendingDroppedCard;
  set pendingDroppedCard(GameCard? value);
  int? get pendingDroppedCardIndex;
  set pendingDroppedCardIndex(int? value);

  /// Nettoie l'état de pending (drag & drop)
  void _clearPendingDropState() {
    pendingDroppedCard = null;
    pendingDroppedCardIndex = null;
  }

  /// Défausser la carte sélectionnée
  Future<void> discardSelectedCard() async {
    if (selectedCardIndex == null) return;

    final gameSessionService = ref.read(gameSessionServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);
      final myData = session.getPlayerData(playerId);

      // Retirer la carte de la main
      final updatedHand = List<String>.from(myData.handCardIds);
      updatedHand.removeAt(selectedCardIndex!);

      final updatedPlayerData = myData.copyWith(handCardIds: updatedHand);
      final updatedSession = session.updatePlayerData(
        playerId,
        updatedPlayerData,
      );

      await gameSessionService.updateSession(sessionId, updatedSession);

      setState(() {
        selectedCardIndex = null;
        isDiscardMode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Carte défaussée'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la défausse: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Incrémenter les PI manuellement
  Future<void> incrementPI() async {
    final playerService = ref.read(playerServiceProvider);
    try {
      await playerService.updatePlayerPI(sessionId, playerId, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💎 +1 PI'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Décrémenter les PI manuellement
  Future<void> decrementPI() async {
    final playerService = ref.read(playerServiceProvider);
    try {
      await playerService.updatePlayerPI(sessionId, playerId, -1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💎 -1 PI'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Piocher une carte manuellement
  Future<void> manualDrawCard() async {
    final gameplayActionService = ref.read(gameplayActionServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);

    // Vérifier la limite de main (7 cartes max)
    try {
      final session = await gameSessionService.getSession(sessionId);
      final myData = session.getPlayerData(playerId);

      if (myData.handCardIds.length >= GameConstants.maxHandSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ Main pleine (${GameConstants.maxHandSize}/${GameConstants.maxHandSize}) - Jouez ou sacrifiez une carte',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    } catch (e) {
      // Si erreur lors de la vérification, on laisse passer
    }

    try {
      await gameplayActionService.drawCard(sessionId, playerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎴 Carte piochée'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('Plus de cartes')
                  ? '⚠️ Plus de cartes à piocher'
                  : '❌ Erreur: $e',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Jouer la carte sélectionnée
  /// Jouer une carte - wrapper qui ne retourne pas de valeur
  Future<void> playCard() async {
    await _playCardInternal();
  }

  /// Jouer une carte et retourner true si succès, false sinon
  Future<bool> _playCardInternal() async {
    if (selectedCardIndex == null) return false;

    final gameplayActionService = ref.read(gameplayActionServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final cardService = ref.read(cardServiceProvider);
    final tensionService = ref.read(tensionServiceProvider);

    try {
      // Vérifier le type de carte et récupérer la carte
      final session = await gameSessionService.getSession(sessionId);
      final isPlayer1 = session.player1Id == playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;
      final cardId = myData.handCardIds[selectedCardIndex!];

      final allCards = await cardService.loadAllCards();
      final card = allCards.firstWhere((c) => c.id == cardId);

      // Calculer le niveau effectif basé sur la tension
      // Utilise TensionService pour respecter le principe DRY
      final effectiveLevel = tensionService.getEffectiveLevel(myData.tension);

      // Vérifier si la carte peut être jouée selon le niveau effectif
      if (!tensionService.canPlayCard(card.color, effectiveLevel)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🔒 Carte ${card.color.displayName} verrouillée - Niveau ${effectiveLevel.displayName} requis pour débloquer',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }

      // Vérification type en phase response
      if (session.currentPhase == GamePhase.response) {
        if (card.type != CardType.instant) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '❌ Seules les cartes de Négociation (vertes) peuvent être jouées en phase de réponse',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return false;
        }

        // Logique spéciale pour les cartes vertes (Négociations)
        if (card.color == CardColor.green) {
          await _handleGreenCardNegotiation(session, isPlayer1, myData, cardId);
          return true; // Green card negotiation launched successfully
        }
      }

      // Vérifier et déduire le coût PI
      // Choisir le palier d'effet (cartes fusionn?es uniquement)
      CardColor? selectedTier;
      if (card.color != CardColor.green && _hasTierEffects(card)) {
        selectedTier = await _selectTierForCard(effectiveLevel);
        if (selectedTier == null) {
          return false; // User cancelled tier selection
        }
      }

      final cost = gameplayActionService.parseLauncherCost(card.launcherCost);
      if (cost > 0) {
        try {
          await gameplayActionService.payCost(sessionId, playerId, cost);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
            );
          }
          return false;
        }
      }

      final tierKey =
          selectedTier != null
              ? _tierKeyFromColor(selectedTier)
              : (card.isEnchantment ? _tierKeyFromColor(card.color) : null);
      await gameplayActionService.playCard(
        sessionId,
        playerId,
        selectedCardIndex!,
        // Toujours passer le tierKey pour afficher le bon énoncé sur la carte jouée
        enchantmentTierKey: tierKey,
      );

      setState(() {
        selectedCardIndex = null;
      });

      // Traiter les mécaniques spéciales de la carte
      await _handleCardMechanics(
        card,
        session,
        isPlayer1,
        myData,
        selectedTierKey: tierKey,
      );
      if (selectedTier != null) {
        await _queuePendingDrawForTier(card, selectedTier);
      }

      // Augmenter la tension
      await _handleTensionIncrease(card);

      // Activer l'état de validation en attente
      setState(() {
        pendingCardValidation = true;
        selectedCardIndex = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Carte jouée ! Cliquez sur "Valider" pour confirmer ou "Retour" pour annuler',
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return true; // Card played successfully
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  /// Jouer une carte via drag & drop (depuis PlayerZoneWidget ou PlayZoneWidget)
  /// Cette méthode est appelée quand une carte est droppée sur la zone de jeu
  /// Retourne true si la carte a été jouée avec succès, false sinon
  Future<bool> playCardFromDrag(int cardIndex, GameCard card) async {
    // Sélectionner la carte et jouer directement
    setState(() {
      selectedCardIndex = cardIndex;
    });

    // Petit délai pour laisser le state se mettre à jour
    await Future.delayed(const Duration(milliseconds: 50));

    // Appeler _playCardInternal qui retourne le résultat
    return await _playCardInternal();
  }

  /// Gère la négociation pour les cartes vertes
  Future<void> _handleGreenCardNegotiation(
    GameSession session,
    bool isPlayer1,
    PlayerData myData,
    String cardId,
  ) async {
    final gameSessionService = ref.read(gameSessionServiceProvider);

    try {
      final updatedHand = List<String>.from(myData.handCardIds);
      updatedHand.removeAt(selectedCardIndex!);

      final updatedResolutionStack = [...session.resolutionStack, cardId];

      final updatedPlayerData = myData.copyWith(handCardIds: updatedHand);
      final updatedSession =
          isPlayer1
              ? session.copyWith(
                player1Data: updatedPlayerData,
                resolutionStack: updatedResolutionStack,
              )
              : session.copyWith(
                player2Data: updatedPlayerData,
                resolutionStack: updatedResolutionStack,
              );

      await gameSessionService.updateSession(sessionId, updatedSession);

      setState(() {
        selectedCardIndex = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "🤝 Négociation proposée - En attente de l'adversaire",
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur négociation: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<CardColor?> _selectTierForCard(CardLevel effectiveLevel) async {
    final available = _tiersForLevel(effectiveLevel);
    if (available.isEmpty) return null;

    return showDialog<CardColor>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2d4263),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF6DD5FA), width: 2),
          ),
          title: const Text(
            'Choisir le palier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final tier in available)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(_tierColorValue(tier)),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context, tier),
                    child: Text(_tierLabel(tier)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<CardColor> _tiersForLevel(CardLevel level) {
    switch (level) {
      case CardLevel.white:
        return [CardColor.white];
      case CardLevel.blue:
        return [CardColor.white, CardColor.blue];
      case CardLevel.yellow:
        return [CardColor.white, CardColor.blue, CardColor.yellow];
      case CardLevel.red:
        return [
          CardColor.white,
          CardColor.blue,
          CardColor.yellow,
          CardColor.red,
        ];
    }
  }

  String _tierLabel(CardColor tier) {
    switch (tier) {
      case CardColor.white:
        return 'Blanc';
      case CardColor.blue:
        return 'Bleu';
      case CardColor.yellow:
        return 'Jaune';
      case CardColor.red:
        return 'Rouge';
      case CardColor.green:
        return 'Vert';
    }
  }

  int _tierColorValue(CardColor tier) {
    switch (tier) {
      case CardColor.white:
        return 0xFF9E9E9E;
      case CardColor.blue:
        return 0xFF2196F3;
      case CardColor.yellow:
        return 0xFFFFC107;
      case CardColor.red:
        return 0xFFF44336;
      case CardColor.green:
        return 0xFF4CAF50;
    }
  }

  bool _hasTierEffects(GameCard card) {
    return card.gameEffect.contains('Blanc:') &&
        card.gameEffect.contains('Bleu:') &&
        card.gameEffect.contains('Jaune:') &&
        card.gameEffect.contains('Rouge:');
  }

  Future<void> _queuePendingDrawForTier(GameCard card, CardColor tier) async {
    final count = _getDrawCountForTier(card, tier);
    if (count <= 0) return;

    final sessionStateService = ref.read(sessionStateServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final session = await gameSessionService.getSession(sessionId);

    final pendingActions =
        session.pendingSpellActions
            .map<PendingAction>(
              (json) => PendingAction.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

    pendingActions.add(
      PendingAction(
        type: PendingActionType.drawCards,
        targetPlayerId: playerId,
        data: {'count': count},
      ),
    );

    await sessionStateService.storePendingActions(sessionId, pendingActions);
  }

  String _tierKeyFromColor(CardColor tier) {
    switch (tier) {
      case CardColor.white:
        return 'white';
      case CardColor.blue:
        return 'blue';
      case CardColor.yellow:
        return 'yellow';
      case CardColor.red:
        return 'red';
      case CardColor.green:
        return 'green';
    }
  }

  int _getDrawCountForTier(GameCard card, CardColor tier) {
    switch (tier) {
      case CardColor.white:
        return card.drawCardsWhite;
      case CardColor.blue:
        return card.drawCardsBlue;
      case CardColor.yellow:
        return card.drawCardsYellow;
      case CardColor.red:
        return card.drawCardsRed;
      case CardColor.green:
        return 0;
    }
  }

  /// Traite les mécaniques spéciales de la carte
  Future<void> _handleCardMechanics(
    GameCard card,
    GameSession session,
    bool isPlayer1,
    PlayerData myData, {
    String? selectedTierKey,
  }) async {
    if (card.mechanics.isEmpty) return;

    final mechanicService = ref.read(mechanicServiceProvider);
    final sessionStateService = ref.read(sessionStateServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);

    final updatedSession = await gameSessionService.getSession(sessionId);
    if (!mounted) return;

    final updatedMyData =
        isPlayer1 ? updatedSession.player1Data : updatedSession.player2Data!;
    final opponentData =
        isPlayer1 ? updatedSession.player2Data! : updatedSession.player1Data;

    final mechanicResult = await mechanicService.processMechanics(
      context: context,
      sessionId: sessionId,
      card: card,
      playerId: playerId,
      handCardIds: updatedMyData.handCardIds,
      activeEnchantmentIds: updatedMyData.activeEnchantmentIds,
      opponentEnchantmentIds: opponentData.activeEnchantmentIds,
      selectedTierKey: selectedTierKey,
    );

    if (!mechanicResult.success) {
      if (mounted && mechanicResult.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mechanicResult.message!),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Stocker les actions pendantes
    if (mechanicResult.pendingActions != null &&
        mechanicResult.pendingActions!.isNotEmpty) {
      await sessionStateService.storePendingActions(
        sessionId,
        mechanicResult.pendingActions!,
      );
    }

    // Gérer le remplacement d'enchantement
    if (mechanicResult.replacedEnchantmentId != null) {
      final isMyEnchantment = updatedMyData.activeEnchantmentIds.contains(
        mechanicResult.replacedEnchantmentId,
      );

      if (isMyEnchantment) {
        await sessionStateService.removeEnchantment(
          sessionId,
          playerId,
          mechanicResult.replacedEnchantmentId!,
        );
      } else {
        final opponentId = isPlayer1 ? session.player2Id! : session.player1Id;
        await sessionStateService.removeEnchantment(
          sessionId,
          opponentId,
          mechanicResult.replacedEnchantmentId!,
        );
      }
    }

    if (mounted && mechanicResult.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mechanicResult.message!),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Augmente la tension après avoir joué une carte
  Future<void> _handleTensionIncrease(GameCard card) async {
    final tensionService = ref.read(tensionServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);

    final tensionAmount = tensionService.getTensionIncrease(card.color);

    if (tensionAmount > 0) {
      final levelChanged = await tensionService.increaseTension(
        sessionId,
        playerId,
        tensionAmount,
      );

      if (levelChanged) {
        final updatedSession = await gameSessionService.getSession(sessionId);
        final isPlayer1 = updatedSession.player1Id == playerId;
        final playerData =
            isPlayer1
                ? updatedSession.player1Data
                : updatedSession.player2Data!;
        final newLevel = playerData.currentLevel;

        String colorToDraw = '';
        switch (newLevel) {
          case CardLevel.blue:
            colorToDraw = 'blue';
            break;
          case CardLevel.yellow:
            colorToDraw = 'yellow';
            break;
          case CardLevel.red:
            colorToDraw = 'red';
            break;
          case CardLevel.white:
            colorToDraw = 'white';
            break;
        }

        if (colorToDraw.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Nouveau niveau: ${newLevel.displayName}! Utilisez le bouton "Piocher" pour vos cartes $colorToDraw!',
              ),
              backgroundColor: Colors.purple,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  /// Valider la carte jouée
  Future<void> validatePlayedCard() async {
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final turnService = ref.read(turnServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);

      if (session.currentPhase == GamePhase.response) {
        await turnService.nextPhase(sessionId);
        setState(() {
          pendingCardValidation = false;
          _clearPendingDropState();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Réponse validée - Phase Résolution'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await turnService.nextPhase(sessionId);
        setState(() {
          pendingCardValidation = false;
          _clearPendingDropState();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Carte validée - Phase Réponse'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Annuler la carte jouée
  Future<void> cancelPlayedCard() async {
    final sessionStateService = ref.read(sessionStateServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);

    try {
      final currentSession = await gameSessionService.getSession(sessionId);
      final currentIsPlayer1 = currentSession.player1Id == playerId;
      final currentMyData =
          currentIsPlayer1
              ? currentSession.player1Data
              : currentSession.player2Data!;

      final updatedResolutionStack = List<String>.from(
        currentSession.resolutionStack,
      );

      if (updatedResolutionStack.isNotEmpty) {
        final lastCardId = updatedResolutionStack.removeLast();
        final updatedPlayedTiers = Map<String, String>.from(
          currentSession.playedCardTiers,
        );
        updatedPlayedTiers.remove(lastCardId);
        final updatedHand = List<String>.from(currentMyData.handCardIds);
        updatedHand.add(lastCardId);

        final updatedPlayerData = currentMyData.copyWith(
          handCardIds: updatedHand,
        );
        final updatedSession = (currentIsPlayer1
                ? currentSession.copyWith(player1Data: updatedPlayerData)
                : currentSession.copyWith(player2Data: updatedPlayerData))
            .copyWith(
              resolutionStack: updatedResolutionStack,
              playedCardTiers: updatedPlayedTiers,
            );

        await gameSessionService.updateSession(sessionId, updatedSession);
        await sessionStateService.clearPendingActions(sessionId);

        setState(() {
          pendingCardValidation = false;
          _clearPendingDropState();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('↩️ Action annulée - Carte remise en main'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'annulation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Sacrifier une carte
  Future<void> sacrificeCard() async {
    if (selectedCardIndex == null) return;

    final gameplayActionService = ref.read(gameplayActionServiceProvider);
    try {
      // sacrificeCard() gère tout : retrait carte, +2% tension, pioche, fin de tour
      await gameplayActionService.sacrificeCard(
        sessionId,
        playerId,
        selectedCardIndex!,
      );

      setState(() {
        selectedCardIndex = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Carte sacrifiée (+2% Tension, +1 carte piochée) - Tour terminé',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Supprimer un enchantement
  Future<void> deleteEnchantment(String enchantmentId) async {
    final sessionStateService = ref.read(sessionStateServiceProvider);

    try {
      await sessionStateService.removeEnchantment(
        sessionId,
        playerId,
        enchantmentId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Enchantement supprimé'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Exécute les actions pendantes du sort en phase Resolution
  Future<void> executePendingActions(GameSession session) async {
    final mechanicService = ref.read(mechanicServiceProvider);
    final sessionStateService = ref.read(sessionStateServiceProvider);

    try {
      final pendingActions =
          session.pendingSpellActions
              .map<PendingAction>(
                (json) =>
                    PendingAction.fromJson(Map<String, dynamic>.from(json)),
              )
              .toList();

      await mechanicService.executePendingActions(
        sessionId: sessionId,
        actions: pendingActions,
      );

      await sessionStateService.clearPendingActions(sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Actions du sort exécutées'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Résout la négociation (décision prise par le joueur ciblé)
  /// - Accord trouvé : sort contré, carte négociation défaussée (perdue)
  /// - Pas d'accord : sort joué normalement, carte négociation remélangée dans le deck
  Future<void> resolveNegotiation(bool agreement) async {
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final turnService = ref.read(turnServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);

      if (session.resolutionStack.length < 2) return;

      final originalCardId = session.resolutionStack.first;
      final negotiationCardId = session.resolutionStack.last;

      final currentIsPlayer1 = session.currentPlayerId == session.player1Id;
      final currentData =
          currentIsPlayer1 ? session.player1Data : session.player2Data!;
      final responderData =
          currentIsPlayer1 ? session.player2Data! : session.player1Data;

      GameSession updatedSession;

      if (agreement) {
        // Entente trouvée → sort contré, carte négociation DÉFAUSSÉE (perdue)
        final updatedCurrentHand = List<String>.from(currentData.handCardIds);
        if (originalCardId.contains(GameConstants.ultimaCardId)) {
          updatedCurrentHand.add(originalCardId);
        }

        // Ajouter la carte négociation au cimetière du répondeur
        final updatedResponderGraveyard = List<String>.from(
          responderData.graveyardCardIds,
        )..add(negotiationCardId);

        final updatedCurrentData = currentData.copyWith(
          handCardIds: updatedCurrentHand,
        );

        final updatedResponderData = responderData.copyWith(
          graveyardCardIds: updatedResponderGraveyard,
        );

        updatedSession =
            currentIsPlayer1
                ? session.copyWith(
                  player1Data: updatedCurrentData,
                  player2Data: updatedResponderData,
                  resolutionStack: [],
                  playedCardTiers: {},
                  pendingSpellActions: [],
                )
                : session.copyWith(
                  player1Data: updatedResponderData,
                  player2Data: updatedCurrentData,
                  resolutionStack: [],
                  playedCardTiers: {},
                  pendingSpellActions: [],
                );
      } else {
        // Pas d'entente → retirer la négociation de la pile, la REMÉLANGER dans le deck
        final updatedStack = List<String>.from(session.resolutionStack)
          ..removeLast();

        // Remettre la carte négociation dans le deck et mélanger
        final updatedResponderDeck =
            List<String>.from(responderData.deckCardIds)
              ..add(negotiationCardId)
              ..shuffle();

        final updatedResponderData = responderData.copyWith(
          deckCardIds: updatedResponderDeck,
        );

        updatedSession =
            currentIsPlayer1
                ? session.copyWith(
                  player1Data: currentData,
                  player2Data: updatedResponderData,
                  resolutionStack: updatedStack,
                )
                : session.copyWith(
                  player1Data: updatedResponderData,
                  player2Data: currentData,
                  resolutionStack: updatedStack,
                );
      }

      await gameSessionService.updateSession(sessionId, updatedSession);
      await turnService.nextPhase(sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              agreement
                  ? "🤝 Entente trouvée - Sort contré (négociation perdue)"
                  : "❌ Pas d'entente - Le sort se résout (négociation remélangée)",
            ),
            backgroundColor: agreement ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur résolution négociation: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
