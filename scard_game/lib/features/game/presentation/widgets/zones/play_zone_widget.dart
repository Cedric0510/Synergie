import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/card_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/enums/game_phase.dart';
import '../card_widget.dart';
import '../counters/ultima_counter_widget.dart';
import '../counters/deck_counter_widget.dart';
import '../../../../../core/widgets/game_button.dart';

/// Widget de la zone de jeu centrale affichant les cartes jouées ce tour
/// Gère l'affichage des cartes en résolution, compteurs Ultima et Deck
class PlayZoneWidget extends ConsumerWidget {
  final GameSession session;
  final bool isMyTurn;
  final String playerId;
  final VoidCallback onSkipResponse;

  const PlayZoneWidget({
    super.key,
    required this.session,
    required this.isMyTurn,
    required this.playerId,
    required this.onSkipResponse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380;
    final smallFontSize = isSmallMobile ? 9.0 : (isMobile ? 11.0 : 13.0);

    // Récupérer les données du joueur actuel
    final isPlayer1 = session.player1Id == playerId;
    final myData = isPlayer1 ? session.player1Data : session.player2Data!;

    return Stack(
      children: [
        // Zone de jeu principale avec slots de cartes
        _buildCardSlots(context, ref, isMobile, isSmallMobile, smallFontSize),

        // Indicateurs sur le côté droit
        Positioned(
          top: isSmallMobile ? 4 : 8,
          right: isSmallMobile ? 4 : 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info Phase en haut (compact) avec style crystal
              _buildPhaseIndicator(isMobile, isSmallMobile, smallFontSize),

              SizedBox(height: isSmallMobile ? 4 : 8),

              // === COMPTEUR ULTIMA ===
              if (session.ultimaOwnerId != null && session.ultimaTurnCount < 3)
                UltimaCounterWidget(session: session, playerId: playerId),

              if (session.ultimaOwnerId != null && session.ultimaTurnCount < 3)
                SizedBox(height: isSmallMobile ? 4 : 8),

              // === COMPTEUR DE DECK ===
              DeckCounterWidget(remainingCards: myData.deckCardIds.length),
            ],
          ),
        ),
      ],
    );
  }

  /// Zone de jeu avec les deux emplacements de cartes (adversaire en haut, moi en bas)
  Widget _buildCardSlots(
    BuildContext context,
    WidgetRef ref,
    bool isMobile,
    bool isSmallMobile,
    double smallFontSize,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul des dimensions des cartes
        const cardRatio = 1.55;
        final dividerFactor = isSmallMobile ? 2.5 : 2.3;
        final availableHeightPerZone =
            (constraints.maxHeight - 20) / dividerFactor;
        final availableWidth =
            constraints.maxWidth * (isSmallMobile ? 0.45 : 0.35);

        double cardWidth = availableHeightPerZone / cardRatio;
        if (cardWidth > availableWidth) cardWidth = availableWidth;

        final minWidth = isSmallMobile ? 55.0 : (isMobile ? 65.0 : 85.0);
        final maxWidth = isSmallMobile ? 95.0 : (isMobile ? 130.0 : 180.0);
        cardWidth = cardWidth.clamp(minWidth, maxWidth);
        final cardHeight = cardWidth * cardRatio;

        return FutureBuilder(
          future: ref.read(cardServiceProvider).loadAllCards(),
          builder: (context, snapshot) {
            // Déterminer les cartes à afficher
            Widget? opponentCard;
            Widget? myCard;

            if (snapshot.hasData && session.resolutionStack.isNotEmpty) {
              final allCards = snapshot.data!;
              final firstCardId = session.resolutionStack[0];
              final firstCard = allCards.firstWhere(
                (c) => c.id == firstCardId,
                orElse: () => allCards.first,
              );
              final firstCardIsMe = isMyTurn;

              // Première carte
              final firstCardWidget = CardWidget(
                card: firstCard,
                width: cardWidth,
                compact: true,
                showPreviewOnHover: true,
                showOnlySelectedTier: true,
                enableTapPreview: true,
                displayTierKey: session.playedCardTiers[firstCardId],
              );

              if (firstCardIsMe) {
                myCard = firstCardWidget;
              } else {
                opponentCard = firstCardWidget;
              }

              // Carte de réponse
              if (session.resolutionStack.length > 1) {
                final responseCardId = session.resolutionStack[1];
                final responseCardData = allCards.firstWhere(
                  (c) => c.id == responseCardId,
                  orElse: () => allCards.first,
                );
                final responseCardWidget = CardWidget(
                  card: responseCardData,
                  width: cardWidth,
                  compact: true,
                  showPreviewOnHover: true,
                  showOnlySelectedTier: true,
                  enableTapPreview: true,
                  displayTierKey: session.playedCardTiers[responseCardId],
                );

                if (firstCardIsMe) {
                  opponentCard = responseCardWidget;
                } else {
                  myCard = responseCardWidget;
                }
              }
            }

            return Column(
              children: [
                // === Zone adversaire (haut) ===
                Expanded(
                  child: Center(
                    child: _buildCardSlot(
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      card: opponentCard,
                      label: 'Adversaire',
                      isOpponent: true,
                      isMobile: isMobile,
                    ),
                  ),
                ),

                // Séparateur central stylisé
                _buildCenterDivider(constraints.maxWidth),

                // === Zone joueur (bas) ===
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: _buildCardSlot(
                          cardWidth: cardWidth,
                          cardHeight: cardHeight,
                          card: myCard,
                          label: 'Vous',
                          isOpponent: false,
                          isMobile: isMobile,
                        ),
                      ),
                      // Bouton Passer en phase response
                      if (!isMyTurn &&
                          session.currentPhase == GamePhase.response)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: GameButton(
                            label: 'Passer',
                            icon: Icons.arrow_forward,
                            style: GameButtonStyle.secondary,
                            height: isMobile ? 35 : 40,
                            onPressed: onSkipResponse,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Construit un emplacement de carte (slot) avec ou sans carte
  Widget _buildCardSlot({
    required double cardWidth,
    required double cardHeight,
    required Widget? card,
    required String label,
    required bool isOpponent,
    required bool isMobile,
  }) {
    final slotPadding = isMobile ? 6.0 : 10.0;
    final slotWidth = cardWidth + slotPadding * 2;
    final slotHeight = cardHeight + slotPadding * 2;
    final borderRadius = BorderRadius.circular(isMobile ? 12 : 16);
    final labelFontSize = isMobile ? 9.0 : 11.0;

    return Container(
      width: slotWidth,
      height: slotHeight,
      decoration: BoxDecoration(
        // Fond légèrement plus clair et translucide
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(card != null ? 0.15 : 0.08),
            Colors.white.withOpacity(card != null ? 0.08 : 0.03),
          ],
        ),
        borderRadius: borderRadius,
        // Bordure subtile
        border: Border.all(
          color:
              card != null
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.12),
          width: card != null ? 2 : 1,
        ),
        // Ombre douce
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (card != null)
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: -5,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Contenu : carte ou placeholder
          if (card != null)
            card
          else
            _buildEmptySlotContent(cardWidth, cardHeight, label, labelFontSize),

          // Label du slot (en haut à gauche quand vide)
          if (card == null)
            Positioned(
              top: 4,
              left: 8,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: labelFontSize - 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Contenu d'un slot vide avec icône et texte
  Widget _buildEmptySlotContent(
    double cardWidth,
    double cardHeight,
    String label,
    double fontSize,
  ) {
    return Center(
      child: Icon(
        Icons.style_outlined,
        color: Colors.white.withOpacity(0.15),
        size: cardWidth * 0.35,
      ),
    );
  }

  /// Séparateur central stylisé
  Widget _buildCenterDivider(double width) {
    return Container(
      width: width * 0.7,
      height: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  /// Indicateur de phase avec style crystal
  Widget _buildPhaseIndicator(
    bool isMobile,
    bool isSmallMobile,
    double smallFontSize,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 8 : 16,
        vertical: isSmallMobile ? 4 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.35),
            Colors.white.withOpacity(0.20),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: isSmallMobile ? 4 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        session.currentPhase.displayName,
        style: TextStyle(
          color: Colors.white,
          fontSize: smallFontSize,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 3),
          ],
        ),
      ),
    );
  }
}
