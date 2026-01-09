import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/card_service.dart';
import '../../../data/services/tension_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/game_card.dart';
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
  final dynamic myData;
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: Colors.green.withOpacity(0.5), width: 2),
        ),
      ),
      child: Column(
        children: [
          // Ma main de cartes
          _buildHandCards(context, ref, cardService),

          Builder(
            builder: (context) {
              final isMobile = MediaQuery.of(context).size.width < 600;
              return SizedBox(height: isMobile ? 8 : 12);
            },
          ),

          // Mes infos + actions
          _buildPlayerInfo(context),

          const SizedBox(height: 8),

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
    dynamic cardService,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul de la taille des cartes en fonction de la largeur disponible
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final cardWidth =
            isMobile
                ? (screenWidth / 6.5).clamp(55.0, 70.0)
                : (screenWidth / 5.5).clamp(70.0, 95.0);
        final cardHeight = cardWidth * 1.55;

        return SizedBox(
          height:
              isMobile
                  ? cardHeight.clamp(90.0, 110.0)
                  : cardHeight.clamp(110.0, 150.0),
          child:
              myData.handCardIds.isEmpty
                  ? const Center(
                    child: Text(
                      'Aucune carte en main',
                      style: TextStyle(color: Colors.white38),
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
    dynamic cardService,
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
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return _buildMobilePlayerInfo();
        } else {
          return _buildDesktopPlayerInfo();
        }
      },
    );
  }

  /// Version mobile (2 lignes)
  Widget _buildMobilePlayerInfo() {
    return Column(
      children: [
        // Ligne 1 : Infos joueur
        Row(
          children: [
            Icon(
              myData.gender.toString().contains('male')
                  ? Icons.male
                  : Icons.female,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                myData.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildPIControl(isMobile: true),
            const SizedBox(width: 8),
            _buildDrawButton(isMobile: true),
            if (myData.handCardIds.length >= 7) _buildFullHandIndicator(),
          ],
        ),
        // Ligne 2 : Enchantements si présents
        if (myData.activeEnchantmentIds.isNotEmpty) ...[
          const SizedBox(height: 6),
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
  Widget _buildPIControl({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 4 : 6,
      ),
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
            top: isMobile ? 0 : -6,
            left: isMobile ? 0 : -8,
            right: isMobile ? 0 : -8,
            child: Container(
              height: isMobile ? 10 : 15,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onDecrementPI,
                child: Icon(
                  Icons.remove_circle,
                  color: Colors.white,
                  size: isMobile ? 16 : 18,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                isMobile
                    ? '${myData.inhibitionPoints}'
                    : '${myData.inhibitionPoints} PI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 12 : 14,
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
              SizedBox(width: isMobile ? 4 : 6),
              InkWell(
                onTap: onIncrementPI,
                child: Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: isMobile ? 16 : 18,
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
    );
  }

  /// Bouton de pioche
  Widget _buildDrawButton({required bool isMobile}) {
    final isHandFull = myData.handCardIds.length >= 7;

    return InkWell(
      onTap: isHandFull ? null : onManualDrawCard,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 12,
          vertical: isMobile ? 8 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
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
              left: isMobile ? -8 : -12,
              right: isMobile ? -8 : -12,
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMobile ? 16 : 20),
                    topRight: Radius.circular(isMobile ? 16 : 20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(isHandFull ? 0.2 : 0.5),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            if (isMobile)
              Icon(
                Icons.layers,
                color: isHandFull ? Colors.white38 : Colors.white,
                size: 18,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.layers,
                    color: isHandFull ? Colors.white38 : Colors.white,
                    size: 16,
                    shadows: const [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.touch_app,
                    color: isHandFull ? Colors.white24 : Colors.white,
                    size: 14,
                    shadows: const [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isHandFull ? 'Main pleine' : 'Piocher',
                    style: TextStyle(
                      color: isHandFull ? Colors.white38 : Colors.white,
                      fontSize: 12,
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
          ],
        ),
      ),
    );
  }

  /// Indicateur main pleine (mobile)
  Widget _buildFullHandIndicator() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
      child: const Text(
        '7/7',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 3),
          ],
        ),
      ),
    );
  }
}
