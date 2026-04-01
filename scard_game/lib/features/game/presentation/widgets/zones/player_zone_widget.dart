import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/card_service.dart';
import '../../../data/services/tension_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/game_card.dart';
import '../../../domain/models/player_data.dart';
import '../../../domain/enums/game_phase.dart';
import '../../../domain/enums/card_type.dart';
import '../../../domain/enums/card_level.dart';
import '../card_widget.dart';
import '../counters/deck_counter_widget.dart';
import '../counters/tension_bar_widget.dart';
import '../enchantments/compact_enchantments_widget.dart';

/// Données transportées lors du drag d'une carte
class DraggedCardData {
  final int cardIndex;
  final String cardId;
  final GameCard card;

  DraggedCardData({
    required this.cardIndex,
    required this.cardId,
    required this.card,
  });
}

/// Widget de la zone joueur affichant la main de cartes, les infos et actions
/// Gère l'affichage des cartes en main, sélection, PI, pioche, enchantements
class PlayerZoneWidget extends ConsumerStatefulWidget {
  final PlayerData myData;
  final bool isMyTurn;
  final GameSession session;
  final int? selectedCardIndex;
  final bool isDiscardMode;
  final Function(int) onSelectCard;
  final int remainingDeckCards;
  final VoidCallback onEndTurn;
  final bool canEndTurn;
  final VoidCallback onIncrementPI;
  final VoidCallback onDecrementPI;
  final VoidCallback onManualDrawCard;
  final Function(String, GameCard) onShowDeleteEnchantmentDialog;

  /// Callback appelé quand une carte est droppée sur la zone de jeu
  final Function(int cardIndex, GameCard card)? onCardDragged;

  /// Callback appelé quand une carte est retournée depuis la zone de jeu
  final VoidCallback? onCardReturnedFromPlayZone;

  /// Index de la carte actuellement en pending (à masquer de la main)
  final int? pendingCardIndex;

  const PlayerZoneWidget({
    super.key,
    required this.myData,
    required this.isMyTurn,
    required this.session,
    required this.selectedCardIndex,
    required this.isDiscardMode,
    required this.onSelectCard,
    required this.remainingDeckCards,
    required this.onEndTurn,
    required this.canEndTurn,
    required this.onIncrementPI,
    required this.onDecrementPI,
    required this.onManualDrawCard,
    required this.onShowDeleteEnchantmentDialog,
    this.onCardDragged,
    this.onCardReturnedFromPlayZone,
    this.pendingCardIndex,
  });

  @override
  ConsumerState<PlayerZoneWidget> createState() => _PlayerZoneWidgetState();
}

class _PlayerZoneWidgetState extends ConsumerState<PlayerZoneWidget> {
  bool _isDragOverHand = false;
  int? _hoveredCardIndex;
  int? _pressedCardIndex;

  @override
  Widget build(BuildContext context) {
    final cardService = ref.watch(cardServiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isSmallMobile ? 6 : (isMobile ? 8 : 10),
        isSmallMobile ? 6 : (isMobile ? 8 : 10),
        isSmallMobile ? 6 : (isMobile ? 8 : 10),
        isSmallMobile ? 4 : (isMobile ? 6 : 8),
      ),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ma main de cartes
          _buildHandCards(context, cardService),

          SizedBox(height: isSmallMobile ? 2 : (isMobile ? 4 : 6)),

          // Enchantements si présents
          if (widget.myData.activeEnchantmentIds.isNotEmpty) ...[
            CompactEnchantementsWidget(
              enchantmentIds: widget.myData.activeEnchantmentIds,
              isMyEnchantments: true,
              onEnchantmentTap: widget.onShowDeleteEnchantmentDialog,
              scale: 0.7,
              enchantmentTiers: widget.myData.activeEnchantmentTiers,
            ),
            SizedBox(height: isSmallMobile ? 2 : 4),
          ],

          // Infos compactes + barre de tension (collées en bas)
          _buildCompactStatus(context),
          SizedBox(height: isSmallMobile ? 2 : 4),
          _buildDeckAndTurnControls(isSmallMobile),
          SizedBox(height: isSmallMobile ? 2 : 4),
          TensionBarWidget(tension: widget.myData.tension),
        ],
      ),
    );
  }

  /// Affichage de la main de cartes
  Widget _buildHandCards(BuildContext context, CardService cardService) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isSmallMobile = screenWidth < 380;
        final cardRatio = 1.55;
        // Cartes volontairement plus grandes; le chevauchement compense la place.
        final baseCardWidth =
            isSmallMobile
                ? (screenWidth / 4.9)
                : isMobile
                ? (screenWidth / 5.4)
                : (screenWidth / 7.0);
        final cardWidth = baseCardWidth.clamp(
          isSmallMobile ? 48.0 : 64.0,
          isSmallMobile ? 72.0 : 105.0,
        );
        final cardHeight = cardWidth * cardRatio;
        final containerHeight = cardHeight + (isSmallMobile ? 26 : 42);
        final canAcceptReturn = widget.onCardReturnedFromPlayZone != null;
        final visibleIndexes = <int>[
          for (int i = 0; i < widget.myData.handCardIds.length; i++)
            if (widget.pendingCardIndex != i) i,
        ];

        return DragTarget<DraggedCardData>(
          onWillAcceptWithDetails: (details) {
            if (canAcceptReturn && details.data.cardIndex == -1) {
              setState(() => _isDragOverHand = true);
              return true;
            }
            return false;
          },
          onLeave: (_) {
            setState(() => _isDragOverHand = false);
          },
          onAcceptWithDetails: (details) {
            setState(() => _isDragOverHand = false);
            HapticFeedback.heavyImpact();
            widget.onCardReturnedFromPlayZone?.call();
          },
          builder: (context, candidateData, rejectedData) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: containerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border:
                    _isDragOverHand
                        ? Border.all(color: Colors.amber, width: 2)
                        : null,
                color:
                    _isDragOverHand
                        ? Colors.amber.withValues(alpha: 0.1)
                        : Colors.transparent,
              ),
              child:
                  visibleIndexes.isEmpty
                      ? Center(
                        child: Text(
                          'Aucune carte en main',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: isSmallMobile ? 11 : 14,
                          ),
                        ),
                      )
                      : FutureBuilder<List<GameCard>>(
                        future: cardService.loadAllCards(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return _buildOverlappedHand(
                            context: context,
                            cardService: cardService,
                            allCards: snapshot.data!,
                            visibleIndexes: visibleIndexes,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            maxWidth: constraints.maxWidth,
                          );
                        },
                      ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverlappedHand({
    required BuildContext context,
    required CardService cardService,
    required List<GameCard> allCards,
    required List<int> visibleIndexes,
    required double cardWidth,
    required double cardHeight,
    required double maxWidth,
  }) {
    final cardsById = {for (final c in allCards) c.id: c};
    final displayPosByIndex = <int, int>{
      for (int i = 0; i < visibleIndexes.length; i++) visibleIndexes[i]: i,
    };

    final count = visibleIndexes.length;
    final minSpacing = cardWidth * 0.34;
    final maxSpacing = cardWidth * 0.86;
    final availableWidth = (maxWidth - 6).clamp(cardWidth, double.infinity);
    final spacing =
        count <= 1
            ? cardWidth
            : ((availableWidth - cardWidth) / (count - 1)).clamp(
              minSpacing,
              maxSpacing,
            );
    final totalWidth =
        count <= 1 ? cardWidth : cardWidth + (count - 1) * spacing;

    final stackedIndexes = List<int>.from(visibleIndexes)..sort((a, b) {
      final priorityDiff = _interactionPriority(a) - _interactionPriority(b);
      if (priorityDiff != 0) return priorityDiff;
      return displayPosByIndex[a]!.compareTo(displayPosByIndex[b]!);
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth + (cardWidth * 0.25),
        height: cardHeight + 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final index in stackedIndexes)
              AnimatedPositioned(
                key: ValueKey('hand_card_$index'),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                left: displayPosByIndex[index]! * spacing,
                top: _verticalOffsetFor(index),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  scale: _scaleFor(index),
                  child: _buildHandCard(
                    context: context,
                    cardService: cardService,
                    index: index,
                    card: cardsById[widget.myData.handCardIds[index]],
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construction d'une carte individuelle de la main
  Widget _buildHandCard({
    required BuildContext context,
    required CardService cardService,
    required int index,
    required GameCard? card,
    required double cardWidth,
    required double cardHeight,
  }) {
    final cardId = widget.myData.handCardIds[index];
    final isSelected = widget.selectedCardIndex == index;

    // Permettre la sélection en phase Main, Response, ou en mode défausse (phase Draw)
    final canSelect =
        (widget.isMyTurn && widget.session.currentPhase == GamePhase.main) ||
        (!widget.isMyTurn &&
            widget.session.currentPhase == GamePhase.response) ||
        (widget.isDiscardMode &&
            widget.isMyTurn &&
            widget.session.currentPhase == GamePhase.draw);

    // Permettre le drag uniquement si on peut jouer (pas en mode défausse)
    final canDrag =
        canSelect && !widget.isDiscardMode && widget.onCardDragged != null;
    final resolvedCard = card;
    if (resolvedCard == null) {
      return Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF2d4263),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // En phase response, vérifier si la carte est jouable
    final isPlayableInResponse =
        widget.session.currentPhase == GamePhase.response &&
        !widget.isMyTurn &&
        resolvedCard.type != CardType.instant;

    final tensionService = ref.read(tensionServiceProvider);
    final effectiveLevel = _effectiveLevelFromTension(widget.myData.tension);
    final isLocked =
        !tensionService.canPlayCard(resolvedCard.color, effectiveLevel);
    final isDraggable = canDrag && !isLocked && !isPlayableInResponse;

    final cardWidget = _buildCardContent(
      card: resolvedCard,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      isSelected: isSelected,
      isPlayableInResponse: isPlayableInResponse,
      isLocked: isLocked,
      effectiveLevel: effectiveLevel,
    );

    final interactiveChild = MouseRegion(
      onEnter: (_) {
        if (_hoveredCardIndex != index) {
          setState(() => _hoveredCardIndex = index);
        }
      },
      onExit: (_) {
        if (_hoveredCardIndex == index) {
          setState(() => _hoveredCardIndex = null);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (_pressedCardIndex != index) {
            setState(() => _pressedCardIndex = index);
          }
        },
        onTapUp: (_) {
          if (_pressedCardIndex == index) {
            setState(() => _pressedCardIndex = null);
          }
        },
        onTapCancel: () {
          if (_pressedCardIndex == index) {
            setState(() => _pressedCardIndex = null);
          }
        },
        onTap:
            canSelect
                ? () {
                  final isNewSelection = widget.selectedCardIndex != index;
                  widget.onSelectCard(index);
                  if (isNewSelection) {
                    _showCardPreviewDialog(context, cardService, cardId);
                  }
                }
                : null,
        onDoubleTap: () => _showCardPreviewDialog(context, cardService, cardId),
        child: Opacity(opacity: canSelect ? 1.0 : 0.5, child: cardWidget),
      ),
    );

    if (!isDraggable) {
      return interactiveChild;
    }

    return LongPressDraggable<DraggedCardData>(
      data: DraggedCardData(
        cardIndex: index,
        cardId: cardId,
        card: resolvedCard,
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
            card: resolvedCard,
            width: cardWidth * 1.3,
            compact: true,
            currentLevel: effectiveLevel,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.28, child: cardWidget),
      onDragStarted: () {
        HapticFeedback.mediumImpact();
        if (_pressedCardIndex == index) {
          setState(() => _pressedCardIndex = null);
        }
      },
      child: interactiveChild,
    );
  }

  CardLevel _effectiveLevelFromTension(double tension) {
    if (tension >= 75) return CardLevel.red;
    if (tension >= 50) return CardLevel.yellow;
    if (tension >= 25) return CardLevel.blue;
    return CardLevel.white;
  }

  int _interactionPriority(int index) {
    if (widget.selectedCardIndex == index) return 2;
    if (_hoveredCardIndex == index || _pressedCardIndex == index) return 1;
    return 0;
  }

  double _verticalOffsetFor(int index) {
    if (widget.selectedCardIndex == index) return 0;
    if (_hoveredCardIndex == index || _pressedCardIndex == index) return 6;
    return 16;
  }

  double _scaleFor(int index) {
    if (widget.selectedCardIndex == index) return 1.16;
    if (_hoveredCardIndex == index || _pressedCardIndex == index) return 1.09;
    return 1.0;
  }

  /// Construit le contenu visuel de la carte
  Widget _buildCardContent({
    required GameCard card,
    required double cardWidth,
    required double cardHeight,
    required bool isSelected,
    required bool isPlayableInResponse,
    required bool isLocked,
    required CardLevel effectiveLevel,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isSelected
                  ? Colors.green
                  : isPlayableInResponse
                  ? Colors.red.withValues(alpha: 0.5)
                  : isLocked
                  ? Colors.grey.withValues(alpha: 0.5)
                  : Colors.transparent,
          width: isSelected ? 3 : (isPlayableInResponse || isLocked ? 2 : 0),
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
                : null,
      ),
      child: Stack(
        children: [
          CardWidget(
            card: card,
            width: cardWidth,
            height: cardHeight,
            compact: true,
            showPreviewOnHover: true,
            currentLevel: effectiveLevel,
          ),
          // Overlay rouge pour les cartes non jouables en response
          if (isPlayableInResponse)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.block, color: Colors.white, size: 30),
                ),
              ),
            ),
          // Overlay de cadenas pour les cartes verrouillées par niveau
          if (isLocked)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white70, size: 35),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Ligne compacte (sexe + nom + PI)
  Widget _buildCompactStatus(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380;

    return Row(
      children: [
        Icon(
          widget.myData.gender.toString().contains('male')
              ? Icons.male
              : Icons.female,
          color: Colors.white70,
          size: isSmallMobile ? 12 : (isMobile ? 14 : 16),
        ),
        SizedBox(width: isSmallMobile ? 3 : 5),
        Expanded(
          child: Text(
            widget.myData.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallMobile ? 11 : (isMobile ? 12 : 14),
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: isSmallMobile ? 4 : 8),
        _buildPIBadge(isMobile: isMobile, isSmallMobile: isSmallMobile),
        if (widget.myData.handCardIds.length >= 7)
          _buildFullHandIndicator(isSmallMobile: isSmallMobile),
      ],
    );
  }

  /// Ligne deck + fin de tour en bas pour éviter d'encombrer la zone centrale
  Widget _buildDeckAndTurnControls(bool isSmallMobile) {
    return Row(
      children: [
        DeckCounterWidget(remainingCards: widget.remainingDeckCards),
        const Spacer(),
        if (widget.isMyTurn) _buildEndTurnButton(isSmallMobile),
      ],
    );
  }

  Widget _buildEndTurnButton(bool isSmallMobile) {
    final enabled = widget.canEndTurn;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? widget.onEndTurn : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 8 : 10,
            vertical: isSmallMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  enabled
                      ? [
                        const Color(0xFF6DD5FA).withValues(alpha: 0.36),
                        const Color(0xFF6DD5FA).withValues(alpha: 0.20),
                      ]
                      : [
                        Colors.white.withValues(alpha: 0.20),
                        Colors.white.withValues(alpha: 0.10),
                      ],
            ),
            border: Border.all(
              color:
                  enabled
                      ? const Color(0xFF6DD5FA).withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    enabled
                        ? const Color(0xFF6DD5FA).withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.16),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.skip_next_rounded,
                size: isSmallMobile ? 14 : 16,
                color: enabled ? Colors.white : Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                'Passer',
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.white54,
                  fontSize: isSmallMobile ? 10 : 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Badge PI sans boutons +/-
  Widget _buildPIBadge({required bool isMobile, bool isSmallMobile = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 4 : (isMobile ? 6 : 8),
        vertical: isSmallMobile ? 3 : (isMobile ? 4 : 6),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
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
            blurRadius: isSmallMobile ? 3 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isMobile
                ? '${widget.myData.inhibitionPoints}'
                : '${widget.myData.inhibitionPoints} PI',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallMobile ? 10 : (isMobile ? 11 : 12),
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

  /// Indicateur main pleine (mobile)
  Widget _buildFullHandIndicator({bool isSmallMobile = false}) {
    return Container(
      margin: EdgeInsets.only(left: isSmallMobile ? 2 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 5 : 8,
        vertical: isSmallMobile ? 2 : 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 12),
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
        '7/7',
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallMobile ? 8 : 10,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 3),
          ],
        ),
      ),
    );
  }

  /// Affiche un dialog avec la preview détaillée de la carte (pour mobile - double tap)
  void _showCardPreviewDialog(
    BuildContext context,
    CardService cardService,
    String cardId,
  ) async {
    final allCards = await cardService.loadAllCards();
    final card = allCards.firstWhere(
      (c) => c.id == cardId,
      orElse: () => allCards.first,
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder:
          (context) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: CardWidget(
                card: card,
                width: 280,
                height: 440,
                compact: false,
                currentLevel: widget.myData.currentLevel,
              ),
            ),
          ),
    );
  }
}
