import 'package:flutter/material.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/enums/game_phase.dart';
import '../../../../../core/widgets/game_button.dart';

/// Type de layout pour les boutons d'action
enum ActionButtonLayout {
  /// Layout mobile avec CrystalButtons en Wrap
  mobile,

  /// Layout compact avec IconButtons en colonne
  compact,

  /// Layout standard avec GameButtons complets
  standard,
}

/// Widget affichant les boutons d'action disponibles selon le contexte de jeu
/// Gère les différents layouts (mobile, compact, standard) et états (phases, sélection)
class ActionButtonsWidget extends StatelessWidget {
  final GameSession session;
  final bool isMyTurn;
  final int? selectedCardIndex;
  final bool isDiscardMode;
  final bool pendingCardValidation;
  final ActionButtonLayout layout;
  final VoidCallback onNextPhase;
  final VoidCallback onToggleDiscardMode;
  final VoidCallback onDiscardSelectedCard;
  final VoidCallback onSkipTurn;
  final VoidCallback onPlayCard;
  final VoidCallback onSacrificeCard;
  final VoidCallback onValidatePlayedCard;
  final VoidCallback onCancelPlayedCard;

  const ActionButtonsWidget({
    super.key,
    required this.session,
    required this.isMyTurn,
    required this.selectedCardIndex,
    required this.isDiscardMode,
    required this.pendingCardValidation,
    required this.layout,
    required this.onNextPhase,
    required this.onToggleDiscardMode,
    required this.onDiscardSelectedCard,
    required this.onSkipTurn,
    required this.onPlayCard,
    required this.onSacrificeCard,
    required this.onValidatePlayedCard,
    required this.onCancelPlayedCard,
  });

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case ActionButtonLayout.mobile:
        return _buildMobileLayout();
      case ActionButtonLayout.compact:
        return _buildCompactLayout();
      case ActionButtonLayout.standard:
        return _buildStandardLayout(context);
    }
  }

  /// Layout mobile avec CrystalButtons en Wrap
  Widget _buildMobileLayout() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        // Phase Suivante (en phase Draw)
        if (isMyTurn && session.currentPhase == GamePhase.draw) ...[
          GameButton(
            label: 'Phase',
            icon: Icons.arrow_forward,
            onPressed: onNextPhase,
            style: GameButtonStyle.primary,
          ),
          GameButton(
            label: isDiscardMode ? 'Annuler' : 'Défausser',
            icon: isDiscardMode ? Icons.close : Icons.delete_sweep,
            onPressed: onToggleDiscardMode,
            style:
                isDiscardMode
                    ? GameButtonStyle.secondary
                    : GameButtonStyle.danger,
          ),
        ],

        // Confirmer défausse
        if (isDiscardMode &&
            selectedCardIndex != null &&
            isMyTurn &&
            session.currentPhase == GamePhase.draw)
          GameButton(
            label: 'Confirmer',
            icon: Icons.check,
            onPressed: onDiscardSelectedCard,
            style: GameButtonStyle.warning,
          ),

        // Passer mon tour
        if (isMyTurn &&
            session.currentPhase == GamePhase.main &&
            selectedCardIndex == null)
          GameButton(
            label: 'Passer',
            icon: Icons.skip_next,
            onPressed: onSkipTurn,
            style: GameButtonStyle.secondary,
          ),

        // Valider/Retour si carte jouée en attente, sinon Jouer/Sacrifier
        if (pendingCardValidation) ...[
          // Boutons de validation après avoir joué une carte
          GameButton(
            label: 'Valider',
            icon: Icons.check,
            onPressed: onValidatePlayedCard,
            style: GameButtonStyle.primary,
          ),
          GameButton(
            label: 'Retour',
            icon: Icons.undo,
            onPressed: onCancelPlayedCard,
            style: GameButtonStyle.warning,
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
                  GameButton(
                    label: 'Jouer',
                    icon: Icons.play_arrow,
                    onPressed: canPlay ? onPlayCard : null,
                    style: GameButtonStyle.success,
                  ),
                  const SizedBox(width: 4),
                  GameButton(
                    label: 'Sacrifier',
                    icon: Icons.delete_outline,
                    onPressed: canSacrifice ? onSacrificeCard : null,
                    style: GameButtonStyle.danger,
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  /// Layout compact avec IconButtons en colonne (icônes uniquement)
  Widget _buildCompactLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 4),

          // Phase Suivante (en phase Draw)
          if (isMyTurn && session.currentPhase == GamePhase.draw) ...[
            IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.blue,
                size: 28,
              ),
              onPressed: onNextPhase,
              tooltip: 'Phase Suivante',
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(height: 4),
            IconButton(
              icon: Icon(
                isDiscardMode ? Icons.close : Icons.delete_sweep,
                color: isDiscardMode ? Colors.grey : Colors.red,
                size: 28,
              ),
              onPressed: onToggleDiscardMode,
              tooltip: isDiscardMode ? 'Annuler' : 'Défausser',
              style: IconButton.styleFrom(
                backgroundColor: (isDiscardMode ? Colors.grey : Colors.red)
                    .withValues(alpha: 0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],

          // Confirmer défausse
          if (isDiscardMode &&
              selectedCardIndex != null &&
              isMyTurn &&
              session.currentPhase == GamePhase.draw) ...[
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.red, size: 28),
              onPressed: onDiscardSelectedCard,
              tooltip: 'Confirmer défausse',
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],

          // Passer mon tour
          if (isMyTurn &&
              session.currentPhase == GamePhase.main &&
              selectedCardIndex == null) ...[
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.grey, size: 28),
              onPressed: onSkipTurn,
              tooltip: 'Passer mon tour',
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],

          // Jouer et Sacrifier (carte sélectionnée)
          if (selectedCardIndex != null) ...[
            Builder(
              builder: (context) {
                final canPlay =
                    (isMyTurn && session.currentPhase == GamePhase.main) ||
                    (!isMyTurn && session.currentPhase == GamePhase.response);
                final canSacrifice =
                    isMyTurn && session.currentPhase == GamePhase.main;

                return Column(
                  children: [
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.green,
                        size: 28,
                      ),
                      onPressed: canPlay ? onPlayCard : null,
                      tooltip: 'Jouer la carte',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withValues(alpha: 0.2),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 28,
                      ),
                      onPressed: canSacrifice ? onSacrificeCard : null,
                      tooltip: 'Sacrifier',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.2),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// Layout standard avec GameButtons complets
  Widget _buildStandardLayout(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final buttonHeight = isMobile ? 40.0 : 50.0;
    final fontSize = isMobile ? 12.0 : 14.0;
    final iconSize = isMobile ? 18.0 : 24.0;
    final padding = isMobile ? 8.0 : 12.0;
    final spaceBetween = isMobile ? 6.0 : 12.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton "Phase Suivante" (en phase Draw/Enchantement)
          if (isMyTurn && session.currentPhase == GamePhase.draw)
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(padding),
                  margin: EdgeInsets.only(bottom: spaceBetween),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: iconSize,
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(
                        'Phase Enchantement & Pioche',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        'Gérez vos enchantements\net piochez vos cartes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: fontSize - 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                GameButton(
                  label: 'Phase Suivante',
                  icon: Icons.arrow_forward,
                  style: GameButtonStyle.primary,
                  height: buttonHeight,
                  onPressed: onNextPhase,
                ),
                SizedBox(height: spaceBetween),
                // Bouton pour activer/désactiver le mode défausse
                GameButton(
                  label: isDiscardMode ? 'Annuler' : 'Défausser une carte',
                  icon: isDiscardMode ? Icons.close : Icons.delete_sweep,
                  style:
                      isDiscardMode
                          ? GameButtonStyle.secondary
                          : GameButtonStyle.danger,
                  height: buttonHeight,
                  onPressed: onToggleDiscardMode,
                ),
                if (isDiscardMode) ...[
                  SizedBox(height: spaceBetween),
                  Container(
                    padding: EdgeInsets.all(padding - 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Text(
                      'Sélectionnez une carte\nà défausser',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: fontSize - 2,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(height: spaceBetween),
              ],
            ),

          // Bouton "Défausser" si une carte est sélectionnée en mode défausse
          if (isDiscardMode &&
              selectedCardIndex != null &&
              isMyTurn &&
              session.currentPhase == GamePhase.draw)
            Column(
              children: [
                GameButton(
                  label: 'Confirmer la défausse',
                  icon: Icons.check,
                  style: GameButtonStyle.danger,
                  height: buttonHeight,
                  onPressed: onDiscardSelectedCard,
                ),
                SizedBox(height: spaceBetween),
              ],
            ),

          // Bouton "Passer mon tour" (seulement en phase Main, sans carte sélectionnée)
          if (isMyTurn &&
              session.currentPhase == GamePhase.main &&
              selectedCardIndex == null)
            GameButton(
              label: 'Passer mon tour',
              icon: Icons.skip_next,
              style: GameButtonStyle.secondary,
              height: buttonHeight,
              onPressed: onSkipTurn,
            ),

          // Boutons "Jouer" et "Sacrifier" (quand une carte est sélectionnée)
          if (selectedCardIndex != null)
            Builder(
              builder: (context) {
                final canPlay =
                    (isMyTurn && session.currentPhase == GamePhase.main) ||
                    (!isMyTurn && session.currentPhase == GamePhase.response);
                final canSacrifice =
                    isMyTurn && session.currentPhase == GamePhase.main;

                return Column(
                  children: [
                    GameButton(
                      label: 'Jouer la carte',
                      icon: Icons.play_arrow,
                      style: GameButtonStyle.success,
                      height: buttonHeight,
                      onPressed: canPlay ? onPlayCard : null,
                    ),
                    SizedBox(height: spaceBetween),
                    GameButton(
                      label: 'Sacrifier',
                      icon: Icons.delete_outline,
                      style: GameButtonStyle.danger,
                      height: buttonHeight,
                      onPressed: canSacrifice ? onSacrificeCard : null,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
