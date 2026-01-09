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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final smallFontSize = isMobile ? 11.0 : 13.0;

    // Récupérer les données du joueur actuel
    final isPlayer1 = session.player1Id == playerId;
    final myData = isPlayer1 ? session.player1Data : session.player2Data!;

    return Column(
      children: [
        // Info Phase en haut (compact) avec style crystal
        _buildPhaseIndicator(isMobile, smallFontSize),

        const SizedBox(height: 12),

        // === COMPTEUR ULTIMA ===
        if (session.ultimaOwnerId != null && session.ultimaTurnCount < 3)
          UltimaCounterWidget(session: session, playerId: playerId),

        if (session.ultimaOwnerId != null && session.ultimaTurnCount < 3)
          const SizedBox(height: 12),

        // === COMPTEUR DE DECK ===
        DeckCounterWidget(remainingCards: myData.deckCardIds.length),

        const SizedBox(height: 12),

        // Cartes jouées - affichées côté joueur (ma carte en bas, adversaire en haut)
        Expanded(
          child:
              session.resolutionStack.isNotEmpty
                  ? _buildResolutionStack(context, ref, isMobile, smallFontSize)
                  : _buildEmptyState(smallFontSize),
        ),
      ],
    );
  }

  /// Indicateur de phase avec style crystal
  Widget _buildPhaseIndicator(bool isMobile, double smallFontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brillance en haut
          Positioned(
            top: -8,
            left: -16,
            right: -16,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Text(
            session.currentPhase.displayName,
            style: TextStyle(
              color: Colors.white,
              fontSize: smallFontSize,
              fontWeight: FontWeight.bold,
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
    );
  }

  /// Affichage de la pile de résolution avec les cartes jouées
  Widget _buildResolutionStack(
    BuildContext context,
    WidgetRef ref,
    bool isMobile,
    double smallFontSize,
  ) {
    return FutureBuilder(
      future: ref.read(cardServiceProvider).loadAllCards(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final allCards = snapshot.data!;
        // Cartes réduites pour voir les 2 si réponse
        final cardWidth = isMobile ? 140.0 : 200.0;
        final cardHeight = isMobile ? 196.0 : 280.0;

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
          responseCard = CardWidget(
            card: responseCardData,
            width: cardWidth,
            height: cardHeight,
            showPreviewOnHover: false,
          );
        }

        return Column(
          children: [
            // Zone adversaire (haut)
            Expanded(
              child: Center(
                child:
                    (!firstCardIsMe)
                        ? CardWidget(
                          card: firstCard,
                          width: cardWidth,
                          height: cardHeight,
                          showPreviewOnHover: false,
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
                            ? CardWidget(
                              card: firstCard,
                              width: cardWidth,
                              height: cardHeight,
                              showPreviewOnHover: false,
                            )
                            : (responseCardIsMe != null && responseCardIsMe!)
                            ? responseCard!
                            : const SizedBox.shrink(),
                  ),

                  // Boutons et infos en bas à droite
                  if (!isMyTurn && session.currentPhase == GamePhase.response)
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
