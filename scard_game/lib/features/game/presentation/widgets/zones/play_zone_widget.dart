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
        // Zone de jeu principale (cartes)
        session.resolutionStack.isNotEmpty
            ? _buildResolutionStack(
              context,
              ref,
              isMobile,
              isSmallMobile,
              smallFontSize,
            )
            : _buildEmptyState(smallFontSize),

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

  /// Affichage de la pile de résolution avec les cartes jouées
  Widget _buildResolutionStack(
    BuildContext context,
    WidgetRef ref,
    bool isMobile,
    bool isSmallMobile,
    double smallFontSize,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder(
          future: ref.read(cardServiceProvider).loadAllCards(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final allCards = snapshot.data!;

            // Calcul 100% responsive basé sur l'espace disponible
            // La carte doit tenir dans la moitié de la hauteur disponible
            const cardRatio = 1.55;

            // Prendre en compte la divider (1px) + marges de sécurité
            // Plus conservateur sur petits écrans
            final dividerFactor = isSmallMobile ? 2.5 : 2.3;
            final availableHeightPerZone =
                (constraints.maxHeight - 10) / dividerFactor;
            final availableWidth =
                constraints.maxWidth *
                (isSmallMobile ? 0.50 : 0.40); // Plus large sur petit écran

            // Calculer la taille basée sur la hauteur disponible (priorité)
            double cardWidth = availableHeightPerZone / cardRatio;

            // Limiter par la largeur disponible si nécessaire
            if (cardWidth > availableWidth) {
              cardWidth = availableWidth;
            }

            // Limites min/max adaptées aux petits écrans
            // Sur très petit écran, permettre des cartes encore plus petites
            final minWidth = isSmallMobile ? 50.0 : (isMobile ? 60.0 : 80.0);
            final maxWidth = isSmallMobile ? 100.0 : (isMobile ? 140.0 : 200.0);
            cardWidth = cardWidth.clamp(minWidth, maxWidth);

            // Recalculer la hauteur après le clamp pour garder le ratio
            final cardHeight = cardWidth * cardRatio;

            // Déterminer qui a joué quelle carte
            final firstCardId = session.resolutionStack[0];
            final firstCard = allCards.firstWhere(
              (c) => c.id == firstCardId,
              orElse: () => allCards.first,
            );

            final firstCardIsMe = isMyTurn;

            Widget? responseCard;
            bool? responseCardIsMe;
            if (session.resolutionStack.length > 1) {
              final responseCardId = session.resolutionStack[1];
              final responseCardData = allCards.firstWhere(
                (c) => c.id == responseCardId,
                orElse: () => allCards.first,
              );
              responseCardIsMe = !firstCardIsMe;
              responseCard = ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: cardWidth,
                  maxHeight: cardHeight,
                ),
                child: CardWidget(
                  card: responseCardData,
                  width: cardWidth,
                  compact: true,
                  showPreviewOnHover: false,
                ),
              );
            }

            return Column(
              children: [
                // Zone adversaire (haut)
                Expanded(
                  child: Center(
                    child:
                        (!firstCardIsMe)
                            ? ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: cardWidth,
                                maxHeight: cardHeight,
                              ),
                              child: CardWidget(
                                card: firstCard,
                                width: cardWidth,
                                compact: true,
                                showPreviewOnHover: false,
                              ),
                            )
                            : (responseCardIsMe != null && !responseCardIsMe!)
                            ? responseCard!
                            : const SizedBox.shrink(),
                  ),
                ),

                const Divider(color: Colors.white24, thickness: 1),

                // Zone moi (bas) avec carte + boutons à droite
                Expanded(
                  child: Stack(
                    children: [
                      // Carte centrée
                      Center(
                        child:
                            firstCardIsMe
                                ? ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: cardWidth,
                                    maxHeight: cardHeight,
                                  ),
                                  child: CardWidget(
                                    card: firstCard,
                                    width: cardWidth,
                                    compact: true,
                                    showPreviewOnHover: false,
                                  ),
                                )
                                : (responseCardIsMe != null &&
                                    responseCardIsMe!)
                                ? responseCard!
                                : const SizedBox.shrink(),
                      ),

                      // Boutons et infos en bas à droite
                      if (!isMyTurn &&
                          session.currentPhase == GamePhase.response)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GameButton(
                                label: 'Passer',
                                icon: Icons.arrow_forward,
                                style: GameButtonStyle.secondary,
                                height: isMobile ? 35 : 40,
                                onPressed: onSkipResponse,
                              ),
                            ],
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

  /// État vide quand aucune carte n'est jouée
  Widget _buildEmptyState(double smallFontSize) {
    return Center(
      child: Text(
        'Aucune carte jouée',
        style: TextStyle(
          color: Colors.white38,
          fontSize: smallFontSize,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
