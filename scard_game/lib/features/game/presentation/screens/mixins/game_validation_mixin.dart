import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/game_timer_notifier.dart';
import '../../../../../core/models/timer_state.dart';
import '../../../data/services/card_service.dart';
import '../../../data/services/game_session_service.dart';
import '../../../data/services/player_service.dart';
import '../../../data/services/turn_service.dart';
import '../../../data/services/card_effect_service.dart';
import '../../../data/services/session_state_service.dart';
import '../../../domain/models/game_card.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/enums/card_type.dart';
import '../../widgets/dialogs/game_dialogs.dart';
import '../../widgets/dialogs/timer_countdown_dialog.dart';

/// Mixin contenant la logique de validation et résolution des effets de cartes
mixin GameValidationMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  // Getters requis pour accéder aux données du widget
  String get sessionId;
  String get playerId;

  // Méthode requise définie dans GameActionsMixin
  Future<void> executePendingActions(GameSession session);

  // Méthode requise définie dans game_screen.dart
  Future<void> deleteEnchantment(String enchantmentId);

  /// Continue la validation après une réponse
  Future<void> continueValidationAfterResponse() async {
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);

      if (session.pendingSpellActions.isNotEmpty) {
        await executePendingActions(session);
      }

      final allCards = await cardService.loadAllCards();

      String? cardToValidate;
      for (final cardId in session.resolutionStack) {
        final card = allCards.firstWhere((c) => c.id == cardId);
        if (card.damageIfRefused > 0 && card.type == CardType.ritual) {
          cardToValidate = cardId;
          break;
        }
      }

      if (cardToValidate == null) {
        await resolveEffectsWithoutValidation();
        return;
      }

      final card = allCards.firstWhere((c) => c.id == cardToValidate);
      final selectedTierKey = session.playedCardTiers[cardToValidate];
      final tierTitle =
          selectedTierKey != null ? card.tierTitles[selectedTierKey] : null;
      final effectText = _getEffectTextForTier(card, selectedTierKey);

      dynamic actionCompleted;
      do {
        if (!mounted) return;
        actionCompleted = await _showActionValidationDialog(
          effectText: effectText,
          selectedTierKey: selectedTierKey,
          tierTitle: tierTitle,
        );
        await _handleValidationTimerIfNeeded(actionCompleted);
      } while (actionCompleted == 'timer');

      if (actionCompleted is bool) {
        await resolveEffectsWithValidation(
          cardToValidate,
          actionCompleted,
          card.damageIfRefused,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Affiche le dialogue de validation et gère le flow complet
  Future<void> showValidationDialog() async {
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);

      if (session.resolutionStack.isEmpty) {
        await resolveEffectsWithoutValidation();
        return;
      }

      final allCards = await cardService.loadAllCards();

      if (session.resolutionStack.length > 1) {
        await showResponseEffectDialog();
        return;
      }

      String? cardToValidate;
      for (final cardId in session.resolutionStack) {
        final card = allCards.firstWhere((c) => c.id == cardId);
        if (card.damageIfRefused > 0 && card.type == CardType.ritual) {
          cardToValidate = cardId;
          break;
        }
      }

      if (cardToValidate == null) {
        await resolveEffectsWithoutValidation();
        return;
      }

      final card = allCards.firstWhere((c) => c.id == cardToValidate);
      final selectedTierKey = session.playedCardTiers[cardToValidate];
      final tierTitle =
          selectedTierKey != null ? card.tierTitles[selectedTierKey] : null;
      final effectText = _getEffectTextForTier(card, selectedTierKey);

      final isMyTurn = session.currentPlayerId == playerId;
      if (!isMyTurn) {
        return;
      }

      dynamic actionCompleted;
      do {
        if (!mounted) return;
        actionCompleted = await _showActionValidationDialog(
          effectText: effectText,
          selectedTierKey: selectedTierKey,
          tierTitle: tierTitle,
        );
        await _handleValidationTimerIfNeeded(actionCompleted);
      } while (actionCompleted == 'timer');

      if (actionCompleted is bool) {
        await resolveEffectsWithValidation(
          cardToValidate,
          actionCompleted,
          card.damageIfRefused,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<dynamic> _showActionValidationDialog({
    required String effectText,
    required String? selectedTierKey,
    String? tierTitle,
  }) {
    const accent = Color(0xFF6DD5FA);

    return showDialog<dynamic>(
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
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.84,
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
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
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
                              color: accent.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Validation de l\'action',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'L\'adversaire a-t-il effectué l\'action suivante ?',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          if (tierTitle != null) ...[
                            Text(
                              tierTitle,
                              style: TextStyle(
                                fontSize: 16,
                                color: _getTierColor(selectedTierKey),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                          ],
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Text(
                              '"$effectText"',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFFE0E0E0),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Demarrer un timer',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTimerShortcut(dialogContext, ref, 0.5, '30s'),
                        _buildTimerShortcut(dialogContext, ref, 1, '1 min'),
                        _buildTimerShortcut(dialogContext, ref, 2, '2 min'),
                        _buildTimerShortcut(dialogContext, ref, 3, '3 min'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGlassButton(
                      label: 'Action effectuée',
                      color: Colors.green,
                      onPressed: () => Navigator.pop(dialogContext, true),
                    ),
                    const SizedBox(height: 10),
                    _buildGlassButton(
                      label: 'Action refusée',
                      color: Colors.red,
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleValidationTimerIfNeeded(dynamic actionCompleted) async {
    if (actionCompleted != 'timer' || !mounted) return;

    var timerDialogStillOpen = true;
    var timerFinishedNaturally = false;

    final timerDialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TimerCountdownDialog(),
    ).whenComplete(() {
      timerDialogStillOpen = false;
    });

    await Future.doWhile(() async {
      final timerState = ref.read(gameTimerProvider);
      if (timerState.status == TimerStatus.finished) {
        timerFinishedNaturally = true;
        return false;
      }
      if (timerState.status == TimerStatus.idle) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    });

    if (timerFinishedNaturally) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && timerDialogStillOpen) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await timerDialogFuture;
  }

  /// Affiche le dialogue d'effet de réponse
  Future<void> showResponseEffectDialog();

  /// Modale de confirmation pour supprimer un enchantement
  Future<bool?> showDeleteEnchantmentDialog(
    String enchantmentId,
    GameCard enchantment,
  ) async {
    final confirmed = await GameDialogs.showDeleteEnchantmentDialog(
      context,
      enchantmentId,
      enchantment,
    );

    if (confirmed == true) {
      await deleteEnchantment(enchantmentId);
    }
    return confirmed;
  }

  /// Résoudre les effets sans validation
  Future<void> resolveEffectsWithoutValidation() async {
    final sessionStateService = ref.read(sessionStateServiceProvider);
    final turnService = ref.read(turnServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);

      // EXECUTER LES ACTIONS PENDANTES (sort non contre)
      if (session.pendingSpellActions.isNotEmpty) {
        await executePendingActions(session);
      }

      final allCards = await cardService.loadAllCards();

      // Résoudre les effets de chaque carte dans la pile (LIFO)
      for (int i = session.resolutionStack.length - 1; i >= 0; i--) {
        final cardId = session.resolutionStack[i];
        final card = allCards.firstWhere((c) => c.id == cardId);

        await cardEffectService.applyCardEffect(
          sessionId,
          card,
          session.currentPlayerId!,
        );
      }

      // Nettoyer le plateau (supprimer cartes sauf enchantements)
      await sessionStateService.clearPlayedCards(sessionId);

      // Auto-transition: Resolution -> Fin de tour
      await turnService.nextPhase(sessionId);

      // Auto-transition: Fin -> Tour suivant (Draw du prochain joueur)
      await turnService.nextPhase(sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Effets resolus - Tour suivant'),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur resolution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Résoudre les effets avec validation
  Future<void> resolveEffectsWithValidation(
    String cardId,
    bool actionCompleted,
    int damageIfRefused,
  ) async {
    final sessionStateService = ref.read(sessionStateServiceProvider);
    final turnService = ref.read(turnServiceProvider);
    final playerService = ref.read(playerServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);

      // Exécuter les actions pendantes (sort non contré)
      if (session.pendingSpellActions.isNotEmpty) {
        await executePendingActions(session);
      }

      // Déduction automatique des PI si l'action est refusée
      if (!actionCompleted) {
        await playerService.updatePlayerPI(sessionId, playerId, -3);
      }

      // Charger les cartes pour la résolution
      final cards = await cardService.loadAllCards();

      // Résoudre les autres effets
      for (int i = session.resolutionStack.length - 1; i >= 0; i--) {
        final stackCardId = session.resolutionStack[i];
        final card = cards.firstWhere((c) => c.id == stackCardId);

        await cardEffectService.applyCardEffect(
          sessionId,
          card,
          session.currentPlayerId!,
        );
      }

      // Nettoyer le plateau (supprimer cartes sauf enchantements)
      await sessionStateService.clearPlayedCards(sessionId);

      // Auto-transition: Resolution -> Fin de tour
      await turnService.nextPhase(sessionId);

      // Auto-transition: Fin -> Tour suivant (Draw du prochain joueur)
      await turnService.nextPhase(sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              actionCompleted
                  ? 'Action validee - Effets resolus'
                  : 'Action refusee - 3 PI retires',
            ),
            backgroundColor: actionCompleted ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur resolution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Résoudre les effets avec validation de copie (miroir)
  Future<void> resolveEffectsWithCopyValidation(
    String cardId,
    bool player1Completed,
    bool player2Completed,
    int damageIfRefused,
  ) async {
    final sessionStateService = ref.read(sessionStateServiceProvider);
    final turnService = ref.read(turnServiceProvider);
    final playerService = ref.read(playerServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await gameSessionService.getSession(sessionId);
      final allCards = await cardService.loadAllCards();
      final isPlayer1 = session.player1Id == playerId;
      final opponentId = isPlayer1 ? session.player2Id! : session.player1Id;

      // Déduction automatique des PI si actions refusées
      if (!player1Completed) {
        await playerService.updatePlayerPI(sessionId, playerId, -3);
      }
      if (!player2Completed) {
        await playerService.updatePlayerPI(sessionId, opponentId, -3);
      }

      // Résoudre les effets pour les 2 joueurs
      for (int i = session.resolutionStack.length - 1; i >= 0; i--) {
        final stackCardId = session.resolutionStack[i];
        final card = allCards.firstWhere((c) => c.id == stackCardId);

        // Appliquer pour joueur actif
        await cardEffectService.applyCardEffect(
          sessionId,
          card,
          session.currentPlayerId!,
        );

        // Appliquer pour adversaire (effet copié)
        await cardEffectService.applyCardEffect(sessionId, card, opponentId);
      }

      // Nettoyer le plateau
      await sessionStateService.clearPlayedCards(sessionId);

      // Auto-transition
      await turnService.nextPhase(sessionId);
      await turnService.nextPhase(sessionId);

      if (mounted) {
        final p1Status = player1Completed ? 'OK' : 'KO';
        final p2Status = player2Completed ? 'OK' : 'KO';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Miroir - Vous: $p1Status Adversaire: $p2Status - Effets résolus',
            ),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur resolution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Widget de bouton avec effet crystal
  Widget _buildGlassButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    // Style crystal uniforme avec accent de couleur
    const crystalColor = Color(0xFF6DD5FA);

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: crystalColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corps principal avec gradient crystal
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  crystalColor.withValues(alpha: 0.20),
                  crystalColor.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: crystalColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
          ),
          // Reflet/brillance en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 20,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          // Bouton cliquable
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              splashColor: crystalColor.withValues(alpha: 0.3),
              highlightColor: crystalColor.withValues(alpha: 0.2),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
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

  /// Widget de raccourci timer compact
  Widget _buildTimerShortcut(
    BuildContext context,
    WidgetRef ref,
    num minutes,
    String label,
  ) {
    const crystalColor = Color(0xFF6DD5FA);

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            crystalColor.withValues(alpha: 0.15),
            crystalColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: crystalColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(gameTimerProvider.notifier).start(minutes);
            Navigator.pop(
              context,
              'timer',
            ); // Fermer le popup et signaler timer
          },
          borderRadius: BorderRadius.circular(10),
          splashColor: crystalColor.withValues(alpha: 0.3),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: crystalColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Extrait l'énoncé correspondant au tier sélectionné
  String _getEffectTextForTier(GameCard card, String? tierKey) {
    if (tierKey == null) {
      return card.targetEffect ?? card.gameEffect;
    }

    // Mapper tierKey (white/blue/yellow/red) vers le label français
    final labelMap = {
      'white': 'blanc',
      'blue': 'bleu',
      'yellow': 'jaune',
      'red': 'rouge',
    };
    final targetLabel = labelMap[tierKey.toLowerCase()];
    if (targetLabel == null) {
      return card.targetEffect ?? card.gameEffect;
    }

    // Parser le gameEffect pour trouver l'énoncé correspondant
    final lines = card.gameEffect.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.toLowerCase().startsWith('$targetLabel:')) {
        // Retourner le texte après le ":"
        final colonIndex = trimmedLine.indexOf(':');
        if (colonIndex != -1) {
          return trimmedLine.substring(colonIndex + 1).trim();
        }
      }
    }

    // Fallback si le tier n'est pas trouvé
    return card.targetEffect ?? card.gameEffect;
  }

  /// Retourne la couleur correspondant au tier
  Color _getTierColor(String? tierKey) {
    switch (tierKey?.toLowerCase()) {
      case 'white':
        return Colors.grey[300]!;
      case 'blue':
        return const Color(0xFF1E88E5);
      case 'yellow':
        return const Color(0xFFF9A825);
      case 'red':
        return const Color(0xFFE53935);
      default:
        return Colors.white;
    }
  }
}
