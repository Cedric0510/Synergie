import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/game_constants.dart';
import '../../../data/services/game_session_service.dart';
import '../../../data/services/mechanic_service.dart';
import '../../../data/services/session_state_service.dart';
import '../../../data/services/turn_service.dart';
import '../../../domain/models/game_session.dart';

/// Mixin contenant les méthodes utilitaires pour la gestion du jeu
/// (Game Flow, UI State, Pending Actions, etc.)
mixin GameUtilsMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Getters requis pour accéder aux données du widget
  String get sessionId;
  String get playerId;

  // State setters requis
  set selectedCardIndex(int? value);
  set isDiscardMode(bool value);
  bool get isDiscardMode;

  /// Passe à la phase suivante
  Future<void> nextPhase() async {
    final turnService = ref.read(turnServiceProvider);
    try {
      await turnService.nextPhase(sessionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Activer/désactiver le mode défausse
  void toggleDiscardMode() {
    setState(() {
      isDiscardMode = !isDiscardMode;
      selectedCardIndex = null; // Déselectionner toute carte
    });
  }

  /// Sélectionner/déselectionner une carte
  void selectCard(int index, int? currentSelectedIndex) {
    setState(() {
      selectedCardIndex = currentSelectedIndex == index ? null : index;
    });
  }

  /// Passer le tour sans jouer de carte
  Future<void> skipTurn() async {
    final turnService = ref.read(turnServiceProvider);
    try {
      // Terminer le tour sans jouer de carte
      await turnService.endTurn(sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏭️ Tour passé'),
            backgroundColor: Colors.blue,
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

  /// Exécute les actions pendantes du sort en phase Resolution
  Future<void> executePendingActions(GameSession session) async {
    final mechanicService = ref.read(mechanicServiceProvider);
    final sessionStateService = ref.read(sessionStateServiceProvider);

    try {
      // Convertir les Map en PendingAction
      final pendingActions =
          session.pendingSpellActions
              .map(
                (json) =>
                    PendingAction.fromJson(Map<String, dynamic>.from(json)),
              )
              .toList();

      // Exécuter les actions
      await mechanicService.executePendingActions(
        sessionId: sessionId,
        actions: pendingActions,
      );

      // Effacer les actions pendantes
      await sessionStateService.clearPendingActions(sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Actions du sort exécutées'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur exécution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Passe la phase réponse sans jouer de carte
  Future<void> skipResponse() async {
    final turnService = ref.read(turnServiceProvider);
    try {
      // Réponse → Résolution
      await turnService.nextPhase(sessionId);

      // Le dialog de validation apparaîtra automatiquement via le StreamBuilder
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Donner la carte Ultima au joueur quand il atteint 100% de tension
  Future<void> giveUltimaCard() async {
    final gameSessionService = ref.read(gameSessionServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);
      final isPlayer1 = session.player1Id == playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;

      // Ajouter Ultima directement à la main (sans passer par le deck)
      final updatedHand = List<String>.from(myData.handCardIds);
      updatedHand.add(GameConstants.ultimaCardId);

      final updatedPlayerData = myData.copyWith(handCardIds: updatedHand);

      final updatedSession =
          isPlayer1
              ? session.copyWith(player1Data: updatedPlayerData)
              : session.copyWith(player2Data: updatedPlayerData);

      await gameSessionService.updateSession(sessionId, updatedSession);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '🔥 ULTIMA ! La carte Ultima a été ajoutée à votre main !',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'ajout d\'Ultima: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
