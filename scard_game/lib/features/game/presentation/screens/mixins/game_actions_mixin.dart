import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/card_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/services/mechanic_service.dart';
import '../../../data/services/tension_service.dart';
import '../../../domain/enums/card_color.dart';
import '../../../domain/enums/card_level.dart';
import '../../../domain/enums/card_type.dart';
import '../../../domain/enums/game_phase.dart';
import '../../../domain/models/game_card.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/player_data.dart';
import '../../widgets/dialogs/game_dialogs.dart';

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

  /// Défausser la carte sélectionnée
  Future<void> discardSelectedCard() async {
    if (selectedCardIndex == null) return;

    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);
      final isPlayer1 = session.player1Id == playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;

      final cardId = myData.handCardIds[selectedCardIndex!];

      // Retirer la carte de la main
      final updatedHand = List<String>.from(myData.handCardIds);
      updatedHand.removeAt(selectedCardIndex!);

      final updatedPlayerData = myData.copyWith(handCardIds: updatedHand);
      final updatedSession =
          isPlayer1
              ? session.copyWith(player1Data: updatedPlayerData)
              : session.copyWith(player2Data: updatedPlayerData);

      // Mettre à jour Firebase
      final docRef = firebaseService.firestore
          .collection('game_sessions')
          .doc(sessionId);

      final sessionJson = updatedSession.toJson();
      sessionJson['player1Data'] = updatedSession.player1Data.toJson();
      if (updatedSession.player2Data != null) {
        sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
      }

      await docRef.update(sessionJson);

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
    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      await firebaseService.updatePlayerPI(sessionId, playerId, 1);
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
    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      await firebaseService.updatePlayerPI(sessionId, playerId, -1);
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
    final firebaseService = ref.read(firebaseServiceProvider);

    // Vérifier la limite de main (7 cartes max)
    try {
      final session = await firebaseService.getGameSession(sessionId);
      final isPlayer1 = session.player1Id == playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;

      if (myData.handCardIds.length >= 7) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Main pleine (7/7) - Jouez ou sacrifiez une carte',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    } catch (e) {
      // Si erreur lors de la vérification, on laisse passer
    }

    try {
      await firebaseService.drawCard(sessionId, playerId);
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
  Future<void> playCard() async {
    if (selectedCardIndex == null) return;

    final firebaseService = ref.read(firebaseServiceProvider);
    final cardService = ref.read(cardServiceProvider);
    final tensionService = ref.read(tensionServiceProvider);

    try {
      // Vérifier le type de carte et récupérer la carte
      final session = await firebaseService.getGameSession(sessionId);
      final isPlayer1 = session.player1Id == playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;
      final cardId = myData.handCardIds[selectedCardIndex!];

      final allCards = await cardService.loadAllCards();
      final card = allCards.firstWhere((c) => c.id == cardId);

      // Calculer le niveau effectif basé sur la tension
      CardLevel effectiveLevel = myData.currentLevel;
      if (myData.tension >= 75) {
        effectiveLevel = CardLevel.red;
      } else if (myData.tension >= 50) {
        effectiveLevel = CardLevel.yellow;
      } else if (myData.tension >= 25) {
        effectiveLevel = CardLevel.blue;
      } else {
        effectiveLevel = CardLevel.white;
      }

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
        return;
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
          return;
        }

        // Logique spéciale pour les cartes vertes (Négociations)
        if (card.color == CardColor.green) {
          await _handleGreenCardNegotiation(session, isPlayer1, myData, cardId);
          return;
        }
      }

      // Vérifier et déduire le coût PI
      final cost = firebaseService.parseLauncherCost(card.launcherCost);
      if (cost > 0) {
        try {
          await firebaseService.payCost(sessionId, playerId, cost);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
            );
          }
          return;
        }
      }

      await firebaseService.playCard(sessionId, playerId, selectedCardIndex!);
      setState(() {
        selectedCardIndex = null;
      });

      // Traiter les mécaniques spéciales de la carte
      await _handleCardMechanics(card, session, isPlayer1, myData);

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Gère la négociation pour les cartes vertes
  Future<void> _handleGreenCardNegotiation(
    GameSession session,
    bool isPlayer1,
    PlayerData myData,
    String cardId,
  ) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final agreement = await GameDialogs.showNegotiationDialog(context);

    if (agreement == true) {
      // Entente trouvée → le sort est contré
      final updatedHand = List<String>.from(myData.handCardIds);
      updatedHand.removeAt(selectedCardIndex!);

      final opponentData =
          isPlayer1 ? session.player2Data! : session.player1Data;
      final updatedOpponentHand = List<String>.from(opponentData.handCardIds);

      // Logique spéciale pour Ultima
      if (session.resolutionStack.isNotEmpty) {
        final contredCardId = session.resolutionStack.last;
        if (contredCardId.contains('red_016')) {
          updatedOpponentHand.add(contredCardId);
        }
      }

      final updatedPlayerData = myData.copyWith(handCardIds: updatedHand);
      final updatedOpponentPlayerData = opponentData.copyWith(
        handCardIds: updatedOpponentHand,
      );

      final updatedSession =
          isPlayer1
              ? session.copyWith(
                player1Data: updatedPlayerData,
                player2Data: updatedOpponentPlayerData,
                resolutionStack: [],
                pendingSpellActions: [],
              )
              : session.copyWith(
                player1Data: updatedOpponentPlayerData,
                player2Data: updatedPlayerData,
                resolutionStack: [],
                pendingSpellActions: [],
              );

      final docRef = firebaseService.firestore
          .collection('game_sessions')
          .doc(sessionId);
      final sessionJson = updatedSession.toJson();
      sessionJson['player1Data'] = updatedSession.player1Data.toJson();
      if (updatedSession.player2Data != null) {
        sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
      }

      await docRef.update(sessionJson);

      setState(() {
        selectedCardIndex = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🤝 Entente trouvée ! Les deux cartes sont retirées du jeu.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      await firebaseService.nextPhase(sessionId);
    } else {
      setState(() {
        selectedCardIndex = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ Pas d\'entente. Le sort n\'est pas contré. Carte Négociations conservée en main.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }

      await firebaseService.nextPhase(sessionId);
    }
  }

  /// Traite les mécaniques spéciales de la carte
  Future<void> _handleCardMechanics(
    GameCard card,
    GameSession session,
    bool isPlayer1,
    PlayerData myData,
  ) async {
    if (card.mechanics.isEmpty) return;

    final mechanicService = ref.read(mechanicServiceProvider);
    final firebaseService = ref.read(firebaseServiceProvider);

    final updatedSession = await firebaseService.getGameSession(sessionId);
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
      await firebaseService.storePendingActions(
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
        await firebaseService.removeEnchantment(
          sessionId,
          playerId,
          mechanicResult.replacedEnchantmentId!,
        );
      } else {
        final opponentId = isPlayer1 ? session.player2Id! : session.player1Id;
        await firebaseService.removeEnchantment(
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
    final firebaseService = ref.read(firebaseServiceProvider);

    double tensionAmount = 0;
    switch (card.color) {
      case CardColor.white:
        tensionAmount = 5.0;
        break;
      case CardColor.blue:
        tensionAmount = 8.0;
        break;
      case CardColor.yellow:
        tensionAmount = 12.0;
        break;
      case CardColor.red:
        tensionAmount = 15.0;
        break;
      case CardColor.green:
        tensionAmount = 0.0;
        break;
    }

    if (tensionAmount > 0) {
      final levelChanged = await tensionService.increaseTension(
        sessionId,
        playerId,
        tensionAmount,
      );

      if (levelChanged) {
        final updatedSession = await firebaseService.getGameSession(sessionId);
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
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);

      if (session.currentPhase == GamePhase.response) {
        await firebaseService.nextPhase(sessionId);
        setState(() {
          pendingCardValidation = false;
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
        await firebaseService.nextPhase(sessionId);
        setState(() {
          pendingCardValidation = false;
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
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final currentSession = await firebaseService.getGameSession(sessionId);
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
        final updatedHand = List<String>.from(currentMyData.handCardIds);
        updatedHand.add(lastCardId);

        final updatedPlayerData = currentMyData.copyWith(
          handCardIds: updatedHand,
        );
        final updatedSession = (currentIsPlayer1
                ? currentSession.copyWith(player1Data: updatedPlayerData)
                : currentSession.copyWith(player2Data: updatedPlayerData))
            .copyWith(resolutionStack: updatedResolutionStack);

        final docRef = firebaseService.firestore
            .collection('game_sessions')
            .doc(sessionId);

        final sessionJson = updatedSession.toJson();
        sessionJson['player1Data'] = updatedSession.player1Data.toJson();
        if (updatedSession.player2Data != null) {
          sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
        }

        await docRef.update(sessionJson);

        setState(() {
          pendingCardValidation = false;
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

    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      // sacrificeCard() gère tout : retrait carte, +2% tension, pioche, fin de tour
      await firebaseService.sacrificeCard(
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
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);
      final isPlayer1 = session.player1Id == playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;

      final updatedEnchantments = List<String>.from(
        myData.activeEnchantmentIds,
      );
      updatedEnchantments.remove(enchantmentId);

      // Logique spéciale pour Ultima
      final updatedHand = List<String>.from(myData.handCardIds);
      if (enchantmentId.contains('red_016')) {
        updatedHand.add(enchantmentId);
      }

      final updatedMyData = myData.copyWith(
        activeEnchantmentIds: updatedEnchantments,
        handCardIds: updatedHand,
      );

      final updatedSession =
          isPlayer1
              ? session.copyWith(player1Data: updatedMyData)
              : session.copyWith(player2Data: updatedMyData);

      final docRef = firebaseService.firestore
          .collection('game_sessions')
          .doc(sessionId);

      final sessionJson = updatedSession.toJson();
      sessionJson['player1Data'] = updatedSession.player1Data.toJson();
      if (updatedSession.player2Data != null) {
        sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
      }

      await docRef.update(sessionJson);

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
    final firebaseService = ref.read(firebaseServiceProvider);

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

      await firebaseService.clearPendingActions(sessionId);

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
}
