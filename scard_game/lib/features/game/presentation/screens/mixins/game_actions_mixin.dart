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
          final negotiationLaunched = await _handleGreenCardNegotiation(
            session,
            isPlayer1,
            myData,
            cardId,
          );
          return negotiationLaunched;
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

      // Validation automatique : carte posée = carte jouée.
      await validatePlayedCard();
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
  Future<bool> _handleGreenCardNegotiation(
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
        pendingCardValidation = false;
        _clearPendingDropState();
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
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur négociation: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<CardColor?> _selectTierForCard(CardLevel effectiveLevel) async {
    final available = _tiersForLevel(effectiveLevel);
    if (available.isEmpty) return null;

    const accent = Color(0xFF6DD5FA);

    return showDialog<CardColor>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.82,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2d4263), Color(0xFF1a2332)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: accent.withValues(alpha: 0.45),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.28),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.30),
                            accent.withValues(alpha: 0.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.layers_outlined,
                              color: accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Choisir le palier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Sélectionnez le palier à jouer pour cette carte.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < available.length; i++) ...[
                      _buildTierChoiceButton(dialogContext, available[i]),
                      if (i < available.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTierChoiceButton(BuildContext dialogContext, CardColor tier) {
    final baseColor =
        tier == CardColor.white
            ? const Color(0xFFE0E0E0)
            : Color(_tierColorValue(tier));

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  baseColor.withValues(alpha: 0.34),
                  baseColor.withValues(alpha: 0.16),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: baseColor.withValues(alpha: 0.80),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 18,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.38),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(dialogContext, tier),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: baseColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: baseColor.withValues(alpha: 0.65),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _tierLabel(tier),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      final wasResponsePhase = session.currentPhase == GamePhase.response;

      final currentIsPlayer1 = session.currentPlayerId == session.player1Id;
      final currentData =
          currentIsPlayer1 ? session.player1Data : session.player2Data!;
      final responderData =
          currentIsPlayer1 ? session.player2Data! : session.player1Data;

      GameSession updatedSession;

      if (agreement) {
        // Entente trouvee : les 2 cartes quittent le plateau.
        final updatedCurrentHand = List<String>.from(currentData.handCardIds);
        final updatedCurrentGraveyard = List<String>.from(
          currentData.graveyardCardIds,
        );
        final updatedCurrentPlayed = List<String>.from(
          currentData.playedCardIds,
        )..remove(originalCardId);

        if (originalCardId.contains(GameConstants.ultimaCardId)) {
          updatedCurrentHand.add(originalCardId);
        } else {
          updatedCurrentGraveyard.add(originalCardId);
        }

        final updatedResponderGraveyard = List<String>.from(
          responderData.graveyardCardIds,
        )..add(negotiationCardId);
        final updatedResponderPlayed = List<String>.from(
          responderData.playedCardIds,
        )..remove(negotiationCardId);

        final updatedCurrentData = currentData.copyWith(
          handCardIds: updatedCurrentHand,
          graveyardCardIds: updatedCurrentGraveyard,
          playedCardIds: updatedCurrentPlayed,
        );

        final updatedResponderData = responderData.copyWith(
          graveyardCardIds: updatedResponderGraveyard,
          playedCardIds: updatedResponderPlayed,
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
        // Pas d'entente : la negociation est retiree, le sort initial continue.
        final updatedStack = List<String>.from(session.resolutionStack)
          ..removeLast();
        final updatedPlayedTiers = Map<String, String>.from(
          session.playedCardTiers,
        )..remove(negotiationCardId);

        final updatedResponderGraveyard = List<String>.from(
          responderData.graveyardCardIds,
        )..add(negotiationCardId);
        final updatedResponderPlayed = List<String>.from(
          responderData.playedCardIds,
        )..remove(negotiationCardId);

        final updatedResponderData = responderData.copyWith(
          graveyardCardIds: updatedResponderGraveyard,
          playedCardIds: updatedResponderPlayed,
        );

        updatedSession =
            currentIsPlayer1
                ? session.copyWith(
                  player1Data: currentData,
                  player2Data: updatedResponderData,
                  resolutionStack: updatedStack,
                  playedCardTiers: updatedPlayedTiers,
                )
                : session.copyWith(
                  player1Data: updatedResponderData,
                  player2Data: currentData,
                  resolutionStack: updatedStack,
                  playedCardTiers: updatedPlayedTiers,
                );
      }

      await gameSessionService.updateSession(sessionId, updatedSession);
      if (wasResponsePhase) {
        await turnService.nextPhase(sessionId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              agreement
                  ? 'Entente trouvee : les cartes quittent le jeu'
                  : 'Pas d\'entente : le sort initial continue',
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
            content: Text('Erreur resolution negociation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
