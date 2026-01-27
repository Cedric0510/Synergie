import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/card_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/services/card_effect_service.dart';
import '../../../domain/models/game_card.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/enums/card_type.dart';
import '../../widgets/dialogs/game_dialogs.dart';

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
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);

      // EXÉCUTER LES ACTIONS PENDANTES (sort non contré)
      if (session.pendingSpellActions.isNotEmpty) {
        await executePendingActions(session);
      }

      final allCards = await cardService.loadAllCards();

      // Trouver la carte principale qui nécessite validation (rituels uniquement)
      String? cardToValidate;
      for (final cardId in session.resolutionStack) {
        final card = allCards.firstWhere((c) => c.id == cardId);
        // Valider uniquement les rituels (pas les enchantements)
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

      if (!mounted) return;

      // Validation simple
      final actionCompleted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF2d4263), const Color(0xFF1a2332)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF8E44AD).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E44AD).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // En-tête avec icône
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8E44AD).withOpacity(0.3),
                              const Color(0xFF8E44AD).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E44AD).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF8E44AD),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Validation de l\'action',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Contenu
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'L\'adversaire a-t-il effectué l\'action suivante ?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF8E44AD,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '"${card.targetEffect ?? card.gameEffect}"',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Boutons
                      _buildGlassButton(
                        label: '✅ Action effectuée',
                        color: Colors.green,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                      const SizedBox(height: 12),
                      _buildGlassButton(
                        label: '❌ Action refusée',
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      );

      if (actionCompleted != null) {
        await resolveEffectsWithValidation(
          cardToValidate,
          actionCompleted,
          card.damageIfRefused,
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

  /// Affiche le dialogue de validation et gère le flow complet
  Future<void> showValidationDialog() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);

      // Pas de carte à valider si pile vide
      if (session.resolutionStack.isEmpty) {
        await resolveEffectsWithoutValidation();
        return;
      }

      final allCards = await cardService.loadAllCards();

      // Vérifier s'il y a une carte de réponse (2+ cartes dans la pile)
      if (session.resolutionStack.length > 1) {
        // Il y a une réponse - demander au joueur actif l'effet
        await showResponseEffectDialog();
        return;
      }

      // Pas de réponse - validation normale
      // Trouver la première carte qui nécessite validation (rituels uniquement)
      String? cardToValidate;
      for (final cardId in session.resolutionStack) {
        final card = allCards.firstWhere((c) => c.id == cardId);
        // Valider uniquement les rituels (pas les enchantements)
        if (card.damageIfRefused > 0 && card.type == CardType.ritual) {
          cardToValidate = cardId;
          break;
        }
      }

      if (cardToValidate == null) {
        // Aucune carte nécessite validation
        await resolveEffectsWithoutValidation();
        return;
      }

      final card = allCards.firstWhere((c) => c.id == cardToValidate);

      // Déterminer qui doit valider
      final isMyTurn = session.currentPlayerId == playerId;
      // Pour l'instant: seul le joueur actif valide
      if (!isMyTurn) {
        // Attendre que le joueur actif valide
        return;
      }

      if (mounted) {
        final actionCompleted = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2d4263),
                        const Color(0xFF1a2332),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF8E44AD).withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E44AD).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // En-tête avec icône
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF8E44AD).withOpacity(0.3),
                                const Color(0xFF8E44AD).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8E44AD,
                                  ).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: Color(0xFF8E44AD),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Validation de l\'action',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Contenu
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'L\'adversaire a-t-il effectué l\'action suivante ?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8E44AD,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '"${card.targetEffect ?? card.gameEffect}"',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Boutons
                        _buildGlassButton(
                          label: '✅ Action effectuée',
                          color: Colors.green,
                          onPressed: () => Navigator.pop(context, true),
                        ),
                        const SizedBox(height: 12),
                        _buildGlassButton(
                          label: '❌ Action refusée',
                          color: Colors.red,
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        );

        if (actionCompleted != null) {
          await resolveEffectsWithValidation(
            cardToValidate,
            actionCompleted,
            card.damageIfRefused,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);

      // EXÉCUTER LES ACTIONS PENDANTES (sort non contré)
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
      await firebaseService.clearPlayedCards(sessionId);

      // Auto-transition: Résolution → Fin de tour
      await firebaseService.nextPhase(sessionId);

      // Auto-transition: Fin → Tour suivant (Draw du prochain joueur)
      await firebaseService.nextPhase(sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Effets résolus - Tour suivant'),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur résolution: $e'),
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
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);
      final allCards = await cardService.loadAllCards();
      final isPlayer1 = session.player1Id == playerId;
      final opponentId = isPlayer1 ? session.player2Id! : session.player1Id;

      // GESTION MANUELLE : Si action refusée, c'est au joueur de retirer ses PI
      // Plus de déduction automatique

      // Résoudre les autres effets
      for (int i = session.resolutionStack.length - 1; i >= 0; i--) {
        final stackCardId = session.resolutionStack[i];
        final card = allCards.firstWhere((c) => c.id == stackCardId);

        await cardEffectService.applyCardEffect(
          sessionId,
          card,
          session.currentPlayerId!,
        );
      }

      // Nettoyer le plateau (supprimer cartes sauf enchantements)
      await firebaseService.clearPlayedCards(sessionId);

      // Auto-transition: Résolution → Fin de tour
      await firebaseService.nextPhase(sessionId);

      // Auto-transition: Fin → Tour suivant (Draw du prochain joueur)
      await firebaseService.nextPhase(sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              actionCompleted
                  ? '✅ Action validée - Effets résolus'
                  : '❌ Action refusée - N\'oubliez pas de retirer $damageIfRefused PI manuellement !',
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
            content: Text('❌ Erreur résolution: $e'),
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
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);
      final allCards = await cardService.loadAllCards();
      final isPlayer1 = session.player1Id == playerId;
      final opponentId = isPlayer1 ? session.player2Id! : session.player1Id;

      // GESTION MANUELLE : Si actions refusées, c'est aux joueurs de retirer leurs PI
      // Plus de déduction automatique

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
      await firebaseService.clearPlayedCards(sessionId);

      // Auto-transition
      await firebaseService.nextPhase(sessionId);
      await firebaseService.nextPhase(sessionId);

      if (mounted) {
        final p1Status = player1Completed ? '✅' : '❌';
        final p2Status = player2Completed ? '✅' : '❌';
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
            content: Text('❌ Erreur résolution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Widget de bouton avec effet de verre
  Widget _buildGlassButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corps principal avec gradient transparent
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.25), color.withOpacity(0.15)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
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
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.0),
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
              splashColor: color.withOpacity(0.3),
              highlightColor: color.withOpacity(0.2),
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
                        color: Colors.black.withOpacity(0.3),
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
}
