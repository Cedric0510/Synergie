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
          TensionBarWidget(tension: widget.myData.tension),
        ],
      ),
    );
  }

  /// Affichage de la main de cartes
  Widget _buildHandCards(BuildContext context, CardService cardService) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul de la taille des cartes avec ratio fixe
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isSmallMobile = screenWidth < 380;

        // Ratio fixe des cartes (1:1.55)
        final cardRatio = 1.55;

        // Largeur de carte basée sur l'écran
        final baseCardWidth =
            isSmallMobile
                ? (screenWidth / 6.0)
                : isMobile
                ? (screenWidth / 6.5)
                : (screenWidth / 8.0);
        final cardWidth = baseCardWidth.clamp(
          isSmallMobile ? 38.0 : 45.0,
          isSmallMobile ? 55.0 : 80.0,
        );
        final cardHeight = cardWidth * cardRatio;

        // Hauteur du conteneur légèrement plus grande pour l'effet hover
        final containerHeight = cardHeight + (isSmallMobile ? 15 : 30);

        // Accepter le retour de carte depuis la zone de jeu (cardIndex == -1)
        final canAcceptReturn = widget.onCardReturnedFromPlayZone != null;

        return DragTarget<DraggedCardData>(
          onWillAcceptWithDetails: (details) {
            // Accepter seulement les cartes venant de la zone de jeu (index -1)
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
                  widget.myData.handCardIds.isEmpty
                      ? Center(
                        child: Text(
                          'Aucune carte en main',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: isSmallMobile ? 11 : 14,
                          ),
                        ),
                      )
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.myData.handCardIds.length,
                        itemBuilder: (context, index) {
                          // Masquer la carte qui est en pending (en cours de drag vers la zone de jeu)
                          if (widget.pendingCardIndex == index) {
                            return const SizedBox.shrink();
                          }
                          return _buildHandCard(
                            context,
                            cardService,
                            index,
                            cardWidth,
                            cardHeight,
                            isMobile,
                          );
                        },
                      ),
            );
          },
        );
      },
    );
  }

  /// Construction d'une carte individuelle de la main
  Widget _buildHandCard(
    BuildContext context,
    CardService cardService,
    int index,
    double cardWidth,
    double cardHeight,
    bool isMobile,
  ) {
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

    return FutureBuilder<List<GameCard>>(
      future: cardService.loadAllCards(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: cardWidth,
            height: cardHeight,
            margin: const EdgeInsets.only(right: 8, top: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2d4263),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final allCards = snapshot.data!;
        final card = allCards.firstWhere(
          (c) => c.id == cardId,
          orElse: () => allCards.first,
        );

        // En phase response, vérifier si la carte est jouable
        final isPlayableInResponse =
            widget.session.currentPhase == GamePhase.response &&
            !widget.isMyTurn &&
            card.type != CardType.instant;

        // Vérifier si la carte est verrouillée par le niveau
        final tensionService = ref.read(tensionServiceProvider);

        // Calculer le niveau actuel basé sur la tension
        CardLevel effectiveLevel = widget.myData.currentLevel;
        if (widget.myData.tension >= 75) {
          effectiveLevel = CardLevel.red;
        } else if (widget.myData.tension >= 50) {
          effectiveLevel = CardLevel.yellow;
        } else if (widget.myData.tension >= 25) {
          effectiveLevel = CardLevel.blue;
        } else {
          effectiveLevel = CardLevel.white;
        }

        final isLocked =
            !tensionService.canPlayCard(card.color, effectiveLevel);

        // La carte peut être draguée si elle n'est pas verrouillée et pas en response invalide
        final isDraggable = canDrag && !isLocked && !isPlayableInResponse;

        // Widget de la carte
        final cardWidget = _buildCardContent(
          card: card,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          isSelected: isSelected,
          isPlayableInResponse: isPlayableInResponse,
          isLocked: isLocked,
          effectiveLevel: effectiveLevel,
        );

        // Si draggable, wrapper dans LongPressDraggable
        if (isDraggable) {
          return LongPressDraggable<DraggedCardData>(
            data: DraggedCardData(cardIndex: index, cardId: cardId, card: card),
            delay: const Duration(milliseconds: 150),
            hapticFeedbackOnStart: true,
            // Feedback : carte agrandie qui suit le doigt
            feedback: Transform.scale(
              scale: 1.2,
              child: Material(
                color: Colors.transparent,
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: CardWidget(
                  card: card,
                  width: cardWidth * 1.3,
                  compact: true,
                  currentLevel: effectiveLevel,
                ),
              ),
            ),
            // Carte grisée quand on drag
            childWhenDragging: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8, top: isSelected ? 0 : 20),
              child: Opacity(opacity: 0.3, child: cardWidget),
            ),
            onDragStarted: () {
              HapticFeedback.mediumImpact();
            },
            child: GestureDetector(
              onTap: canSelect ? () => widget.onSelectCard(index) : null,
              onDoubleTap:
                  () => _showCardPreviewDialog(context, cardService, cardId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8, top: isSelected ? 0 : 20),
                transform: Matrix4.diagonal3Values(
                  isSelected ? 1.1 : 1.0,
                  isSelected ? 1.1 : 1.0,
                  1.0,
                ),
                child: Opacity(
                  opacity: canSelect ? 1.0 : 0.5,
                  child: cardWidget,
                ),
              ),
            ),
          );
        }

        // Sinon, juste le GestureDetector comme avant
        return GestureDetector(
          onTap: canSelect ? () => widget.onSelectCard(index) : null,
          onDoubleTap:
              () => _showCardPreviewDialog(context, cardService, cardId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: 8, top: isSelected ? 0 : 20),
            transform: Matrix4.diagonal3Values(
              isSelected ? 1.1 : 1.0,
              isSelected ? 1.1 : 1.0,
              1.0,
            ),
            child: Opacity(opacity: canSelect ? 1.0 : 0.5, child: cardWidget),
          ),
        );
      },
    );
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
