import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/card_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../domain/enums/response_effect.dart';
import '../../../domain/models/game_session.dart';

/// Mixin contenant la logique des effets de réponse (Contre, Copie, Remplacement)
mixin GameResponseEffectsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  // Getters requis pour accéder aux données du widget
  String get sessionId;
  String get playerId;

  // Méthodes requises définies dans d'autres mixins
  Future<void> executePendingActions(GameSession session);
  Future<void> continueValidationAfterResponse();
  Future<void> resolveEffectsWithoutValidation();
  Future<void> resolveEffectsWithCopyValidation(
    String cardId,
    bool player1Completed,
    bool player2Completed,
    int damageIfRefused,
  );

  /// Affiche le dialogue de sélection d'effet de réponse
  Future<void> showResponseEffectDialog() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    if (!mounted) return;

    final ResponseEffect? selectedEffect = await showDialog<ResponseEffect>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2d4263),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF6DD5FA), width: 2),
            ),
            title: Row(
              children: [
                Icon(Icons.reply, color: Color(0xFF6DD5FA), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Carte de réponse jouée',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre adversaire a joué une réponse.\nQue se passe-t-il ?',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<ResponseEffect>(
                  dropdownColor: const Color(0xFF2d4263),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Effet de la réponse',
                    labelStyle: const TextStyle(color: Color(0xFF6DD5FA)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6DD5FA)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF6DD5FA).withOpacity(0.5),
                      ),
                    ),
                  ),
                  items:
                      ResponseEffect.values.map((effect) {
                        return DropdownMenuItem(
                          value: effect,
                          child: Text(
                            effect.displayName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.pop(context, value);
                    }
                  },
                ),
              ],
            ),
          ),
    );

    if (selectedEffect != null) {
      // Sauvegarder l'effet choisi dans la session
      await firebaseService.setResponseEffect(sessionId, selectedEffect);

      // Traiter selon l'effet
      await handleResponseEffect(selectedEffect);
    }
  }

  /// Gère le traitement selon l'effet de réponse
  Future<void> handleResponseEffect(ResponseEffect effect) async {
    switch (effect) {
      case ResponseEffect.cancel:
        // Annule tout - vider la pile et fin de tour
        await handleCancelEffect();
        break;

      case ResponseEffect.copy:
        // Copie - validation double
        await handleCopyEffect();
        break;

      case ResponseEffect.replace:
        // Remplacement - pour plus tard
        await handleReplaceEffect();
        break;

      case ResponseEffect.noEffect:
        // Aucun effet - validation normale
        await continueValidationAfterResponse();
        break;
    }
  }

  /// Gère l'annulation (Contre)
  Future<void> handleCancelEffect() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      // Effacer les actions pendantes (le sort est contré, ne pas les exécuter)
      await firebaseService.clearPendingActions(sessionId);

      // Vider la pile de résolution
      await firebaseService.clearResolutionStack(sessionId);

      // Passer directement en fin de tour
      await firebaseService.nextPhase(sessionId); // Resolution → End
      await firebaseService.nextPhase(sessionId); // End → Draw

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Sort annulé - Tour terminé'),
            backgroundColor: Colors.red,
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

  /// Gère la copie (Miroir) - validation double
  Future<void> handleCopyEffect() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(sessionId);

      // EXÉCUTER LES ACTIONS PENDANTES (sort non contré)
      if (session.pendingSpellActions.isNotEmpty) {
        await executePendingActions(session);
      }

      final allCards = await cardService.loadAllCards();

      // Trouver la carte principale qui nécessite validation
      String? cardToValidate;
      for (final cardId in session.resolutionStack) {
        final card = allCards.firstWhere((c) => c.id == cardId);
        if (card.damageIfRefused > 0) {
          cardToValidate = cardId;
          break;
        }
      }

      if (cardToValidate == null) {
        // Pas de validation nécessaire, juste appliquer les effets
        await resolveEffectsWithoutValidation();
        return;
      }

      final card = allCards.firstWhere((c) => c.id == cardToValidate);

      if (!mounted) return;

      // Dialog avec 2 checkboxes
      bool? player1Completed;
      bool? player2Completed;

      final result = await showDialog<Map<String, bool>>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF2d4263),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFFFC107), width: 2),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      color: Color(0xFFFFC107),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Validation (Miroir)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFC107).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Les 2 joueurs doivent effectuer :\n"${card.targetEffect ?? card.gameEffect}"',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text(
                        'Vous avez effectué l\'action',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: player1Completed ?? false,
                      activeColor: Color(0xFF6DD5FA),
                      checkColor: Colors.white,
                      onChanged: (value) {
                        setState(() => player1Completed = value);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Adversaire a effectué l\'action',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: player2Completed ?? false,
                      activeColor: Color(0xFF6DD5FA),
                      checkColor: Colors.white,
                      onChanged: (value) {
                        setState(() => player2Completed = value);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed:
                        (player1Completed != null && player2Completed != null)
                            ? () {
                              Navigator.pop(context, {
                                'player1': player1Completed!,
                                'player2': player2Completed!,
                              });
                            }
                            : null,
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF6DD5FA).withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      '✅ Valider',
                      style: TextStyle(
                        color: Color(0xFF6DD5FA),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result != null) {
        await resolveEffectsWithCopyValidation(
          cardToValidate,
          result['player1']!,
          result['player2']!,
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

  /// Gère le remplacement (Échange) - TODO
  Future<void> handleReplaceEffect() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚧 Fonctionnalité à venir : Remplacement'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Pour l'instant, traiter comme "aucun effet"
    await continueValidationAfterResponse();
  }
}
