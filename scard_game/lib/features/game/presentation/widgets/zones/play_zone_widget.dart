import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/card_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/game_card.dart';
import '../../../domain/enums/game_phase.dart';
import '../card_widget.dart';
import '../counters/ultima_counter_widget.dart';
import '../counters/deck_counter_widget.dart';
import '../../../../../core/widgets/game_button.dart';
import '../../../../../core/widgets/game_timer_widget.dart';
import '../dialogs/rules_dialog.dart';
import 'player_zone_widget.dart';

/// Widget de la zone de jeu centrale affichant les cartes jouées ce tour
/// Gère l'affichage des cartes en résolution, compteurs Ultima et Deck
class PlayZoneWidget extends ConsumerStatefulWidget {
  final GameSession session;
  final bool isMyTurn;
  final String playerId;
  final VoidCallback onSkipResponse;

  /// Callback appelé quand une carte est droppée sur la zone de jeu
  final Function(int cardIndex, GameCard card)? onCardDropped;

  /// Callback appelé quand une carte est retirée de la zone de jeu (drag retour)
  final VoidCallback? onCardReturnedToHand;

  /// Carte en attente de validation (affichée dans le slot avant confirmation)
  final GameCard? pendingCard;

  /// Indique si une carte est en attente de validation (bouton Valider/Retour visible)
  final bool pendingCardValidation;

  const PlayZoneWidget({
    super.key,
    required this.session,
    required this.isMyTurn,
    required this.playerId,
    required this.onSkipResponse,
    this.onCardDropped,
    this.onCardReturnedToHand,
    this.pendingCard,
    this.pendingCardValidation = false,
  });

  @override
  ConsumerState<PlayZoneWidget> createState() => _PlayZoneWidgetState();
}

class _PlayZoneWidgetState extends ConsumerState<PlayZoneWidget> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380;
    final smallFontSize = isSmallMobile ? 9.0 : (isMobile ? 11.0 : 13.0);

    // Récupérer les données du joueur actuel
    final isPlayer1 = widget.session.player1Id == widget.playerId;
    final myData =
        isPlayer1 ? widget.session.player1Data : widget.session.player2Data!;

    return Stack(
      children: [
        // Zone de jeu principale avec slots de cartes
        _buildCardSlots(context, isMobile, isSmallMobile, smallFontSize),

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
              if (widget.session.ultimaOwnerId != null &&
                  widget.session.ultimaTurnCount < 3)
                UltimaCounterWidget(
                  session: widget.session,
                  playerId: widget.playerId,
                ),

              if (widget.session.ultimaOwnerId != null &&
                  widget.session.ultimaTurnCount < 3)
                SizedBox(height: isSmallMobile ? 4 : 8),

              // === COMPTEUR DE DECK ===
              DeckCounterWidget(remainingCards: myData.deckCardIds.length),

              SizedBox(height: isSmallMobile ? 4 : 8),

              // === BOUTON RÈGLES ===
              _buildRulesButton(isSmallMobile),

              SizedBox(height: isSmallMobile ? 4 : 8),

              // === BOUTON MINUTEUR ===
              GameTimerWidget(isSmallMobile: isSmallMobile),
            ],
          ),
        ),
      ],
    );
  }

  /// Zone de jeu avec les deux emplacements de cartes (adversaire en haut, moi en bas)
  Widget _buildCardSlots(
    BuildContext context,
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
            GameCard? myCardData; // Pour le drag de retour

            if (snapshot.hasData && widget.session.resolutionStack.isNotEmpty) {
              final allCards = snapshot.data!;
              final firstCardId = widget.session.resolutionStack[0];
              final firstCard = allCards.firstWhere(
                (c) => c.id == firstCardId,
                orElse: () => allCards.first,
              );
              final firstCardIsMe = widget.isMyTurn;

              // Première carte
              final firstCardWidget = CardWidget(
                card: firstCard,
                width: cardWidth,
                compact: true,
                showPreviewOnHover: true,
                showOnlySelectedTier: true,
                enableTapPreview: true,
                displayTierKey: widget.session.playedCardTiers[firstCardId],
              );

              if (firstCardIsMe) {
                myCard = firstCardWidget;
                myCardData = firstCard;
              } else {
                opponentCard = firstCardWidget;
              }

              // Carte de réponse
              if (widget.session.resolutionStack.length > 1) {
                final responseCardId = widget.session.resolutionStack[1];
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
                  displayTierKey:
                      widget.session.playedCardTiers[responseCardId],
                );

                if (firstCardIsMe) {
                  opponentCard = responseCardWidget;
                } else {
                  myCard = responseCardWidget;
                  myCardData = responseCardData;
                }
              }
            }

            // Si une carte est en attente de validation (vient d'être droppée)
            // On track si c'est une pendingCard pour le drag-back
            final bool isPendingCard =
                widget.pendingCard != null && myCard == null;
            if (isPendingCard) {
              myCardData = widget.pendingCard;
              myCard = CardWidget(
                card: widget.pendingCard!,
                width: cardWidth,
                compact: true,
                showPreviewOnHover: true,
              );
            }

            // Vérifier si on peut dropper une carte (phase main ou response, pas déjà une carte jouée)
            final canAcceptDrop =
                widget.onCardDropped != null &&
                (widget.isMyTurn &&
                        widget.session.currentPhase == GamePhase.main ||
                    !widget.isMyTurn &&
                        widget.session.currentPhase == GamePhase.response) &&
                myCard == null;

            // La carte peut être retirée si:
            // 1. C'est une pendingCard (pas encore dans Firebase) OU
            // 2. La carte est dans Firebase mais pendingCardValidation est true
            //    (l'utilisateur n'a pas encore cliqué Valider/Retour)
            final canDragBack =
                widget.onCardReturnedToHand != null &&
                (isPendingCard || widget.pendingCardValidation) &&
                myCard != null &&
                myCardData != null;

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

                // === Zone joueur (bas) avec DragTarget ===
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: DragTarget<DraggedCardData>(
                          onWillAcceptWithDetails: (details) {
                            if (canAcceptDrop) {
                              setState(() => _isDragOver = true);
                              return true;
                            }
                            return false;
                          },
                          onLeave: (_) {
                            setState(() => _isDragOver = false);
                          },
                          onAcceptWithDetails: (details) {
                            setState(() => _isDragOver = false);
                            HapticFeedback.heavyImpact();
                            widget.onCardDropped?.call(
                              details.data.cardIndex,
                              details.data.card,
                            );
                          },
                          builder: (context, candidateData, rejectedData) {
                            // Si canDragBack, rendre la carte draggable pour le retour
                            if (canDragBack && myCardData != null) {
                              final cardData =
                                  myCardData; // Capture pour analyse null-safety
                              return LongPressDraggable<DraggedCardData>(
                                data: DraggedCardData(
                                  cardIndex:
                                      -1, // Index spécial pour carte en zone de jeu
                                  cardId: cardData.id,
                                  card: cardData,
                                ),
                                delay: const Duration(milliseconds: 150),
                                hapticFeedbackOnStart: true,
                                feedback: Transform.scale(
                                  scale: 1.2,
                                  child: Material(
                                    color: Colors.transparent,
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(12),
                                    child: CardWidget(
                                      card: cardData,
                                      width: cardWidth * 1.3,
                                      compact: true,
                                    ),
                                  ),
                                ),
                                childWhenDragging: _buildCardSlot(
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                  card: null, // Slot vide pendant le drag
                                  label: 'Vous',
                                  isOpponent: false,
                                  isMobile: isMobile,
                                  isHighlighted: false,
                                ),
                                onDragStarted: () {
                                  HapticFeedback.mediumImpact();
                                },
                                child: _buildCardSlot(
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                  card: myCard,
                                  label: 'Vous',
                                  isOpponent: false,
                                  isMobile: isMobile,
                                  isHighlighted: _isDragOver,
                                  isPending: true, // Indicateur visuel
                                ),
                              );
                            }

                            return _buildCardSlot(
                              cardWidth: cardWidth,
                              cardHeight: cardHeight,
                              card: myCard,
                              label: 'Vous',
                              isOpponent: false,
                              isMobile: isMobile,
                              isHighlighted: _isDragOver,
                            );
                          },
                        ),
                      ),
                      // Bouton Accepter en phase response (accepte l'action du partenaire)
                      if (!widget.isMyTurn &&
                          widget.session.currentPhase == GamePhase.response)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: GameButton(
                            label: 'Accepter',
                            style: GameButtonStyle.secondary,
                            height: isMobile ? 35 : 40,
                            onPressed: widget.onSkipResponse,
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
    bool isHighlighted = false,
    bool isPending = false,
  }) {
    final slotPadding = isMobile ? 6.0 : 10.0;
    final slotWidth = cardWidth + slotPadding * 2;
    final slotHeight = cardHeight + slotPadding * 2;
    final borderRadius = BorderRadius.circular(isMobile ? 12 : 16);
    final labelFontSize = isMobile ? 9.0 : 11.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: slotWidth,
      height: slotHeight,
      decoration: BoxDecoration(
        // Fond qui s'illumine quand on drag dessus ou si pending
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isHighlighted
                  ? [
                    Colors.green.withValues(alpha: 0.4),
                    Colors.green.withValues(alpha: 0.2),
                  ]
                  : isPending
                  ? [
                    Colors.amber.withValues(alpha: 0.3),
                    Colors.amber.withValues(alpha: 0.15),
                  ]
                  : [
                    Colors.white.withValues(alpha: card != null ? 0.15 : 0.08),
                    Colors.white.withValues(alpha: card != null ? 0.08 : 0.03),
                  ],
        ),
        borderRadius: borderRadius,
        // Bordure qui s'illumine
        border: Border.all(
          color:
              isHighlighted
                  ? Colors.greenAccent
                  : isPending
                  ? Colors.amber
                  : card != null
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.12),
          width: isHighlighted ? 3 : (card != null ? 2 : 1),
        ),
        // Ombre douce (plus forte quand highlighted)
        boxShadow: [
          BoxShadow(
            color:
                isHighlighted
                    ? Colors.greenAccent.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.2),
            blurRadius: isHighlighted ? 20 : 12,
            offset: const Offset(0, 4),
          ),
          if (card != null || isHighlighted)
            BoxShadow(
              color:
                  isHighlighted
                      ? Colors.greenAccent.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: isHighlighted ? 5 : -5,
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
                  color: Colors.white.withValues(alpha: 0.3),
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
        color: Colors.white.withValues(alpha: 0.15),
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
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.3),
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
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.20),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: isSmallMobile ? 4 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.session.currentPhase.displayName,
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

  /// Bouton "?" pour afficher les règles du jeu
  Widget _buildRulesButton(bool isSmallMobile) {
    final size = isSmallMobile ? 32.0 : 40.0;
    final fontSize = isSmallMobile ? 16.0 : 20.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => RulesDialog.show(context),
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.15),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
