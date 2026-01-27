import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/card_service.dart';
import '../../../data/services/tension_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/game_card.dart';
import '../../../domain/models/player_data.dart';
import '../../../domain/enums/game_phase.dart';
import '../../../domain/enums/card_type.dart';
import '../../../domain/enums/card_level.dart';
import '../../../domain/enums/card_color.dart';
import '../card_widget.dart';
import '../counters/tension_bar_widget.dart';
import '../enchantments/compact_enchantments_widget.dart';

/// Widget de la zone joueur affichant la main de cartes, les infos et actions
/// Gère l'affichage des cartes en main, sélection, PI, pioche, enchantements
class PlayerZoneWidget extends ConsumerWidget {
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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardService = ref.watch(cardServiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380;

    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 8 : (isMobile ? 12 : 16)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: Colors.green.withOpacity(0.5), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ma main de cartes
          _buildHandCards(context, ref, cardService),

          SizedBox(height: isSmallMobile ? 4 : (isMobile ? 8 : 12)),

          // Mes infos + actions
          _buildPlayerInfo(context),

          SizedBox(height: isSmallMobile ? 4 : 8),

          // Ma barre de tension
          TensionBarWidget(tension: myData.tension),
        ],
      ),
    );
  }

  /// Affichage de la main de cartes
  Widget _buildHandCards(
    BuildContext context,
    WidgetRef ref,
    CardService cardService,
  ) {
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

        return SizedBox(
          height: containerHeight,
          child:
              myData.handCardIds.isEmpty
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
                    itemCount: myData.handCardIds.length,
                    itemBuilder: (context, index) {
                      return _buildHandCard(
                        context,
                        ref,
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
  }

  /// Construction d'une carte individuelle de la main
  Widget _buildHandCard(
    BuildContext context,
    WidgetRef ref,
    CardService cardService,
    int index,
    double cardWidth,
    double cardHeight,
    bool isMobile,
  ) {
    final cardId = myData.handCardIds[index];
    final isSelected = selectedCardIndex == index;

    // Permettre la sélection en phase Main, Response, ou en mode défausse (phase Draw)
    final canSelect =
        (isMyTurn && session.currentPhase == GamePhase.main) ||
        (!isMyTurn && session.currentPhase == GamePhase.response) ||
        (isDiscardMode && isMyTurn && session.currentPhase == GamePhase.draw);

    return GestureDetector(
      onTap: canSelect ? () => onSelectCard(index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8, top: isSelected ? 0 : 20),
        transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
        child: Opacity(
          opacity: canSelect ? 1.0 : 0.5,
          child: FutureBuilder<List<GameCard>>(
            future: cardService.loadAllCards(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: 90,
                  height: 140,
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
                  session.currentPhase == GamePhase.response &&
                  !isMyTurn &&
                  card.type != CardType.instant;

              // Vérifier si la carte est verrouillée par le niveau
              final tensionService = ref.read(tensionServiceProvider);

              // Calculer le niveau actuel basé sur la tension
              CardLevel effectiveLevel = myData.currentLevel;
              if (myData.tension >= 75) {
                effectiveLevel = CardLevel.red;
              } else if (myData.tension >= 50) {
                effectiveLevel = CardLevel.yellow;
              } else if (myData.tension >= 25) {
                effectiveLevel = CardLevel.blue;
              } else {
                effectiveLevel = CardLevel.white;
              }

              final isLocked =
                  !tensionService.canPlayCard(card.color, effectiveLevel);

              // Debug: vérifier les valeurs
              if (card.color != CardColor.white) {
                print(
                  '🔍 Carte ${card.name} (${card.color}) - Niveau DB: ${myData.currentLevel} - Niveau effectif: $effectiveLevel - Tension: ${myData.tension}% - Verrouillée: $isLocked',
                );
              }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.green
                            : isPlayableInResponse
                            ? Colors.red.withOpacity(0.5)
                            : isLocked
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.transparent,
                    width:
                        isSelected
                            ? 3
                            : (isPlayableInResponse || isLocked ? 2 : 0),
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                ),
                child: Stack(
                  children: [
                    // Carte en couleur (pas de filtre gris)
                    CardWidget(
                      card: card,
                      width: cardWidth,
                      height: cardHeight,
                      compact: true,
                      showPreviewOnHover: true,
                    ),
                    // Overlay rouge pour les cartes non jouables en response
                    if (isPlayableInResponse)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.block,
                              color: Colors.white,
                              size: 30,
                            ),
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
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock,
                                color: Colors.white70,
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Affichage des infos joueur (PI, pioche, enchantements)
  Widget _buildPlayerInfo(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isSmallMobile = screenWidth < 380;

        if (isMobile) {
          return _buildMobilePlayerInfo(isSmallMobile);
        } else {
          return _buildDesktopPlayerInfo();
        }
      },
    );
  }

  /// Version mobile (2 lignes)
  Widget _buildMobilePlayerInfo(bool isSmallMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ligne 1 : Infos joueur
        Row(
          children: [
            Icon(
              myData.gender.toString().contains('male')
                  ? Icons.male
                  : Icons.female,
              color: Colors.white70,
              size: isSmallMobile ? 14 : 16,
            ),
            SizedBox(width: isSmallMobile ? 2 : 4),
            Expanded(
              child: Text(
                myData.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallMobile ? 11 : 13,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isSmallMobile ? 4 : 8),
            _buildPIControl(isMobile: true, isSmallMobile: isSmallMobile),
            SizedBox(width: isSmallMobile ? 4 : 8),
            _buildDrawButton(isMobile: true, isSmallMobile: isSmallMobile),
            if (myData.handCardIds.length >= 7)
              _buildFullHandIndicator(isSmallMobile: isSmallMobile),
          ],
        ),
        // Ligne 2 : Enchantements si présents
        if (myData.activeEnchantmentIds.isNotEmpty) ...[
          SizedBox(height: isSmallMobile ? 4 : 6),
          CompactEnchantementsWidget(
            enchantmentIds: myData.activeEnchantmentIds,
            isMyEnchantments: true,
            onEnchantmentTap: onShowDeleteEnchantmentDialog,
          ),
        ],
      ],
    );
  }

  /// Version desktop (1 ligne)
  Widget _buildDesktopPlayerInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Icon(
                  myData.gender.toString().contains('male')
                      ? Icons.male
                      : Icons.female,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  myData.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                _buildPIControl(isMobile: false),
                const SizedBox(width: 16),
                _buildDrawButton(isMobile: false),
                const SizedBox(width: 16),
                if (myData.activeEnchantmentIds.isNotEmpty)
                  CompactEnchantementsWidget(
                    enchantmentIds: myData.activeEnchantmentIds,
                    isMyEnchantments: true,
                    onEnchantmentTap: onShowDeleteEnchantmentDialog,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Contrôle des PI avec boutons +/-
  Widget _buildPIControl({required bool isMobile, bool isSmallMobile = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 4 : (isMobile ? 6 : 8),
        vertical: isSmallMobile ? 3 : (isMobile ? 4 : 6),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallMobile ? 14 : 20),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrementPI,
            child: Icon(
              Icons.remove_circle,
              color: Colors.white,
              size: isSmallMobile ? 14 : (isMobile ? 16 : 18),
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallMobile ? 2 : (isMobile ? 4 : 6)),
          Text(
            isMobile
                ? '${myData.inhibitionPoints}'
                : '${myData.inhibitionPoints} PI',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallMobile ? 10 : (isMobile ? 12 : 14),
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
          SizedBox(width: isSmallMobile ? 2 : (isMobile ? 4 : 6)),
          InkWell(
            onTap: onIncrementPI,
            child: Icon(
              Icons.add_circle,
              color: Colors.white,
              size: isSmallMobile ? 14 : (isMobile ? 16 : 18),
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

  /// Bouton de pioche
  Widget _buildDrawButton({
    required bool isMobile,
    bool isSmallMobile = false,
  }) {
    final isHandFull = myData.handCardIds.length >= 7;

    return InkWell(
      onTap: isHandFull ? null : onManualDrawCard,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 12,
          vertical: isSmallMobile ? 5 : (isMobile ? 8 : 8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            isSmallMobile ? 12 : (isMobile ? 16 : 20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isHandFull
                    ? [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.10),
                    ]
                    : [
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
        child: Icon(
          Icons.layers,
          color: isHandFull ? Colors.white38 : Colors.white,
          size: isSmallMobile ? 14 : (isMobile ? 18 : 16),
          shadows: const [
            Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 3),
          ],
        ),
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
}
