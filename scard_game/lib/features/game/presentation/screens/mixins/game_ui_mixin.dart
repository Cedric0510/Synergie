import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/game_card.dart';
import '../../../domain/enums/game_phase.dart';
import '../../widgets/dialogs/game_dialogs.dart';

/// Mixin pour la gestion de l'interface utilisateur du GameScreen
mixin GameUIMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Getters requis pour accéder à l'état
  int? get selectedCardIndex;
  bool get isDiscardMode;
  bool get pendingCardValidation;

  // Méthodes requises de navigation/actions (déjà implémentées dans GameActionsMixin et GameUtilsMixin)
  Future<void> nextPhase();
  void toggleDiscardMode();
  Future<void> skipTurn();
  Future<void> discardSelectedCard();
  Future<void> validatePlayedCard();
  Future<void> cancelPlayedCard();
  Future<void> playCard();
  Future<void> sacrificeCard();
  Future<void> deleteEnchantment(String enchantmentId);
  Future<void> incrementPI();
  Future<void> decrementPI();

  /// Boutons d'action pour mobile (en pleine largeur)
  Widget buildMobileActionButtons(GameSession session, bool isMyTurn) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        // Phase Draw est maintenant automatisée - pas de boutons
        // Le joueur passe directement en phase Main après la pioche et les enchantements

        // Passer mon tour
        if (isMyTurn &&
            session.currentPhase == GamePhase.main &&
            selectedCardIndex == null)
          buildCrystalButton(
            label: 'Passer',
            icon: Icons.skip_next,
            onPressed: skipTurn,
            gradientColors: [
              Colors.grey.withOpacity(0.45),
              Colors.grey.withOpacity(0.30),
            ],
          ),

        // Valider/Retour si carte jouée en attente, sinon Jouer/Sacrifier
        if (pendingCardValidation) ...[
          // Boutons de validation après avoir joué une carte
          buildCrystalButton(
            label: 'Valider',
            icon: Icons.check,
            onPressed: validatePlayedCard,
            gradientColors: [
              Colors.blue.withOpacity(0.45),
              Colors.blue.withOpacity(0.30),
            ],
          ),
          buildCrystalButton(
            label: 'Retour',
            icon: Icons.undo,
            onPressed: cancelPlayedCard,
            gradientColors: [
              Colors.orange.withOpacity(0.45),
              Colors.orange.withOpacity(0.30),
            ],
          ),
        ] else if (selectedCardIndex != null) ...[
          Builder(
            builder: (context) {
              final canPlay =
                  (isMyTurn && session.currentPhase == GamePhase.main) ||
                  (!isMyTurn && session.currentPhase == GamePhase.response);
              final canSacrifice =
                  isMyTurn && session.currentPhase == GamePhase.main;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCrystalButton(
                    label: 'Jouer',
                    icon: Icons.play_arrow,
                    onPressed: canPlay ? playCard : null,
                    gradientColors: [
                      Colors.green.withOpacity(0.45),
                      Colors.green.withOpacity(0.30),
                    ],
                  ),
                  const SizedBox(width: 4),
                  buildCrystalButton(
                    label: 'Sacrifier',
                    icon: Icons.delete_outline,
                    onPressed: canSacrifice ? sacrificeCard : null,
                    gradientColors: [
                      Colors.red.withOpacity(0.45),
                      Colors.red.withOpacity(0.30),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  /// Helper pour créer un bouton avec style crystal
  Widget buildCrystalButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required List<Color> gradientColors,
  }) {
    final isDisabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        constraints: const BoxConstraints(minWidth: 70, minHeight: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDisabled
                    ? [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.10),
                    ]
                    : gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Brillance en haut
            Positioned(
              top: -6,
              left: -10,
              right: -10,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(isDisabled ? 0.2 : 0.5),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isDisabled ? Colors.white38 : Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? Colors.white38 : Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne la couleur selon le niveau de tension
  Color getTensionColor(double tension) {
    if (tension >= 75) return Colors.red;
    if (tension >= 50) return Colors.orange;
    if (tension >= 25) return Colors.blue;
    return Colors.white;
  }

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
}
