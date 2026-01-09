import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import '../../data/services/card_service.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/card_effect_service.dart';
import '../../data/services/mechanic_service.dart';
import '../../data/services/tension_service.dart';
import '../../domain/models/game_session.dart';
import '../../domain/models/game_card.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/card_type.dart';
import '../../domain/enums/card_level.dart';
import '../../domain/enums/card_color.dart';
import '../../domain/enums/response_effect.dart';
import '../widgets/card_widget.dart';
import '../../../../core/widgets/game_button.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String playerId;

  const GameScreen({
    super.key,
    required this.sessionId,
    required this.playerId,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _selectedCardIndex;
  bool _hasShownValidationDialog = false;
  GamePhase? _lastPhase;
  bool _hasReceivedUltima = false;
  bool _isDiscardMode = false;
  bool _pendingCardValidation = false; // Carte jouée en attente de validation
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  @override
  Widget build(BuildContext context) {
    final firebaseService = ref.watch(firebaseServiceProvider);

    return Scaffold(
      body: StreamBuilder<GameSession>(
        stream: firebaseService.watchGameSession(widget.sessionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = snapshot.data!;
          final isPlayer1 = session.player1Id == widget.playerId;
          final myData = isPlayer1 ? session.player1Data : session.player2Data!;
          final opponentData =
              isPlayer1 ? session.player2Data! : session.player1Data;
          final isMyTurn = session.currentPlayerId == widget.playerId;

          // PHASE ENCHANTEMENT & PIOCHE : Plus de passage automatique
          // Le joueur doit cliquer sur "Phase Suivante" quand il a fini

          // Afficher la modal de validation quand on entre en phase Resolution
          if (session.currentPhase == GamePhase.resolution &&
              _lastPhase != GamePhase.resolution &&
              !_hasShownValidationDialog &&
              isMyTurn) {
            _hasShownValidationDialog = true;
            // NE PAS exécuter les actions pendantes ici !
            // Elles seront exécutées dans _handleResponseEffect() après validation
            Future.microtask(() => _showValidationDialog());
          }

          // Reset du flag de validation quand on change de phase
          if (_lastPhase != session.currentPhase) {
            _lastPhase = session.currentPhase;
            if (session.currentPhase != GamePhase.resolution) {
              _hasShownValidationDialog = false;
            }
          }

          // ULTIMA : Donner automatiquement la carte Ultima à 100% de tension
          if (myData.tension >= 100 && !_hasReceivedUltima) {
            // Vérifier si le joueur n'a pas déjà Ultima en main ou en jeu
            final hasUltimaInHand = myData.handCardIds.contains('red_016');
            final hasUltimaInPlay = myData.activeEnchantmentIds.contains(
              'red_016',
            );

            if (!hasUltimaInHand && !hasUltimaInPlay) {
              _hasReceivedUltima = true;
              Future.microtask(() => _giveUltimaCard());
            }
          }

          // Réinitialiser le flag si la tension redescend sous 100%
          if (myData.tension < 100) {
            _hasReceivedUltima = false;
          }

          // === VÉRIFICATION VICTOIRE ULTIMA ===
          if (session.status == GameStatus.finished &&
              session.winnerId != null) {
            return _buildVictoryScreen(session);
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6DD5FA), // Bleu clair
                  const Color(0xFF2980B9), // Bleu moyen
                  const Color(0xFF8E44AD).withOpacity(0.7), // Violet doux
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Zone adversaire (en haut)
                  _buildOpponentZone(opponentData),

                  const SizedBox(height: 8),

                  // Zone de jeu centrale
                  Expanded(child: _buildPlayZone(session, isMyTurn)),

                  const SizedBox(height: 8),

                  // BOUTONS D'ACTION (en pleine largeur pour toutes les versions)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: _buildMobileActionButtons(session, isMyTurn),
                  ),

                  // Ma zone (en bas)
                  _buildPlayerZone(myData, isMyTurn, session),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Zone adversaire (infos + cartes en main face cachée)
  Widget _buildOpponentZone(dynamic opponentData) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.red.withOpacity(0.5), width: 2),
        ),
      ),
      child: Column(
        children: [
          // Infos adversaire
          if (isMobile)
            // Version mobile : layout vertical compact
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      opponentData.gender.toString().contains('male')
                          ? Icons.male
                          : Icons.female,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        opponentData.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
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
                                    Colors.white.withOpacity(0.5),
                                    Colors.white.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${opponentData.inhibitionPoints} PI',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              shadows: [
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
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.15),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.style,
                            color: Colors.white,
                            size: 12,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${opponentData.handCardIds.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              shadows: [
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
                    ),
                  ],
                ),
                if (opponentData.activeEnchantmentIds.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildCompactEnchantments(opponentData.activeEnchantmentIds),
                ],
              ],
            )
          else
            // Version desktop : layout horizontal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        opponentData.gender.toString().contains('male')
                            ? Icons.male
                            : Icons.female,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        opponentData.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
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
                              top: -8,
                              left: -14,
                              right: -14,
                              child: Container(
                                height: 15,
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
                              '${opponentData.inhibitionPoints} PI',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
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
                      ),
                      const SizedBox(width: 16),
                      if (opponentData.activeEnchantmentIds.isNotEmpty)
                        _buildCompactEnchantments(
                          opponentData.activeEnchantmentIds,
                        ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.style,
                              color: Colors.white,
                              size: 16,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Main: ${opponentData.handCardIds.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                shadows: [
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
                      ),
                    ],
                  ),
                ),
              ],
            ),

          SizedBox(height: isMobile ? 6 : 8),

          // Barre de tension
          _buildTensionBar(opponentData.tension),

          SizedBox(height: isMobile ? 4 : 8),
        ],
      ),
    );
  }

  /// Zone de jeu centrale (cartes jouées ce tour)
  Widget _buildPlayZone(GameSession session, bool isMyTurn) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final smallFontSize = isMobile ? 11.0 : 13.0;

    // Récupérer les données du joueur actuel
    final isPlayer1 = session.player1Id == widget.playerId;
    final myData = isPlayer1 ? session.player1Data : session.player2Data!;

    return Column(
      children: [
        // Info Phase en haut (compact) avec style crystal
        Container(
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
        ),

        const SizedBox(height: 12),

        // === COMPTEUR ULTIMA ===
        if (session.ultimaOwnerId != null && session.ultimaTurnCount < 3)
          _buildUltimaCounter(session),

        if (session.ultimaOwnerId != null && session.ultimaTurnCount < 3)
          const SizedBox(height: 12),

        // === COMPTEUR DE DECK ===
        _buildDeckCounter(myData.deckCardIds.length),

        const SizedBox(height: 12),

        // Cartes jouées - affichées côté joueur (ma carte en bas, adversaire en haut)
        Expanded(
          child:
              session.resolutionStack.isNotEmpty
                  ? FutureBuilder(
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
                                      : (responseCardIsMe != null &&
                                          !responseCardIsMe!)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GameButton(
                                          label: 'Passer',
                                          icon: Icons.arrow_forward,
                                          style: GameButtonStyle.secondary,
                                          height: isMobile ? 35 : 40,
                                          onPressed: () => _skipResponse(),
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
                  )
                  : Center(
                    child: Text(
                      'Aucune carte jouée',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: smallFontSize,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  /// Boutons d'action pour mobile (en pleine largeur)
  Widget _buildMobileActionButtons(GameSession session, bool isMyTurn) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        // Phase Suivante (en phase Draw)
        if (isMyTurn && session.currentPhase == GamePhase.draw) ...[
          _buildCrystalButton(
            label: 'Phase',
            icon: Icons.arrow_forward,
            onPressed: _nextPhase,
            gradientColors: [
              Colors.blue.withOpacity(0.45),
              Colors.blue.withOpacity(0.30),
            ],
          ),
          _buildCrystalButton(
            label: _isDiscardMode ? 'Annuler' : 'Défausser',
            icon: _isDiscardMode ? Icons.close : Icons.delete_sweep,
            onPressed: _toggleDiscardMode,
            gradientColors:
                _isDiscardMode
                    ? [
                      Colors.grey.withOpacity(0.45),
                      Colors.grey.withOpacity(0.30),
                    ]
                    : [
                      Colors.red.withOpacity(0.45),
                      Colors.red.withOpacity(0.30),
                    ],
          ),
        ],

        // Confirmer défausse
        if (_isDiscardMode &&
            _selectedCardIndex != null &&
            isMyTurn &&
            session.currentPhase == GamePhase.draw)
          _buildCrystalButton(
            label: 'Confirmer',
            icon: Icons.check,
            onPressed: _discardSelectedCard,
            gradientColors: [
              Colors.orange.withOpacity(0.45),
              Colors.orange.withOpacity(0.30),
            ],
          ),

        // Passer mon tour
        if (isMyTurn &&
            session.currentPhase == GamePhase.main &&
            _selectedCardIndex == null)
          _buildCrystalButton(
            label: 'Passer',
            icon: Icons.skip_next,
            onPressed: _skipTurn,
            gradientColors: [
              Colors.grey.withOpacity(0.45),
              Colors.grey.withOpacity(0.30),
            ],
          ),

        // Valider/Retour si carte jouée en attente, sinon Jouer/Sacrifier
        if (_pendingCardValidation) ...[
          // Boutons de validation après avoir joué une carte
          _buildCrystalButton(
            label: 'Valider',
            icon: Icons.check,
            onPressed: _validatePlayedCard,
            gradientColors: [
              Colors.blue.withOpacity(0.45),
              Colors.blue.withOpacity(0.30),
            ],
          ),
          _buildCrystalButton(
            label: 'Retour',
            icon: Icons.undo,
            onPressed: _cancelPlayedCard,
            gradientColors: [
              Colors.orange.withOpacity(0.45),
              Colors.orange.withOpacity(0.30),
            ],
          ),
        ] else if (_selectedCardIndex != null) ...[
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
                  _buildCrystalButton(
                    label: 'Jouer',
                    icon: Icons.play_arrow,
                    onPressed: canPlay ? _playCard : null,
                    gradientColors: [
                      Colors.green.withOpacity(0.45),
                      Colors.green.withOpacity(0.30),
                    ],
                  ),
                  const SizedBox(width: 4),
                  _buildCrystalButton(
                    label: 'Sacrifier',
                    icon: Icons.delete_outline,
                    onPressed: canSacrifice ? _sacrificeCard : null,
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

  /// Boutons d'action compacts (icônes uniquement) pour mobile
  Widget _buildCompactActionButtons(GameSession session, bool isMyTurn) {
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
              onPressed: _nextPhase,
              tooltip: 'Phase Suivante',
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(height: 4),
            IconButton(
              icon: Icon(
                _isDiscardMode ? Icons.close : Icons.delete_sweep,
                color: _isDiscardMode ? Colors.grey : Colors.red,
                size: 28,
              ),
              onPressed: _toggleDiscardMode,
              tooltip: _isDiscardMode ? 'Annuler' : 'Défausser',
              style: IconButton.styleFrom(
                backgroundColor: (_isDiscardMode ? Colors.grey : Colors.red)
                    .withOpacity(0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],

          // Confirmer défausse
          if (_isDiscardMode &&
              _selectedCardIndex != null &&
              isMyTurn &&
              session.currentPhase == GamePhase.draw) ...[
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.red, size: 28),
              onPressed: _discardSelectedCard,
              tooltip: 'Confirmer défausse',
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],

          // Passer mon tour
          if (isMyTurn &&
              session.currentPhase == GamePhase.main &&
              _selectedCardIndex == null) ...[
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.grey, size: 28),
              onPressed: _skipTurn,
              tooltip: 'Passer mon tour',
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],

          // Jouer et Sacrifier (carte sélectionnée)
          if (_selectedCardIndex != null) ...[
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
                      onPressed: canPlay ? _playCard : null,
                      tooltip: 'Jouer la carte',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.2),
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
                      onPressed: canSacrifice ? _sacrificeCard : null,
                      tooltip: 'Sacrifier',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
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

  /// Boutons d'action dans la zone de jeu
  Widget _buildActionButtons(GameSession session, bool isMyTurn) {
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
                    color: Colors.blue.withOpacity(0.2),
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
                  onPressed: _nextPhase,
                ),
                SizedBox(height: spaceBetween),
                // Bouton pour activer/désactiver le mode défausse
                GameButton(
                  label: _isDiscardMode ? 'Annuler' : 'Défausser une carte',
                  icon: _isDiscardMode ? Icons.close : Icons.delete_sweep,
                  style:
                      _isDiscardMode
                          ? GameButtonStyle.secondary
                          : GameButtonStyle.danger,
                  height: buttonHeight,
                  onPressed: _toggleDiscardMode,
                ),
                if (_isDiscardMode) ...[
                  SizedBox(height: spaceBetween),
                  Container(
                    padding: EdgeInsets.all(padding - 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
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
          if (_isDiscardMode &&
              _selectedCardIndex != null &&
              isMyTurn &&
              session.currentPhase == GamePhase.draw)
            Column(
              children: [
                GameButton(
                  label: 'Confirmer la défausse',
                  icon: Icons.check,
                  style: GameButtonStyle.danger,
                  height: buttonHeight,
                  onPressed: _discardSelectedCard,
                ),
                SizedBox(height: spaceBetween),
              ],
            ),

          // Bouton "Passer mon tour" (seulement en phase Main, sans carte sélectionnée)
          if (isMyTurn &&
              session.currentPhase == GamePhase.main &&
              _selectedCardIndex == null)
            GameButton(
              label: 'Passer mon tour',
              icon: Icons.skip_next,
              style: GameButtonStyle.secondary,
              height: buttonHeight,
              onPressed: _skipTurn,
            ),

          // Boutons "Jouer" et "Sacrifier" (quand une carte est sélectionnée)
          if (_selectedCardIndex != null)
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
                      onPressed: canPlay ? _playCard : null,
                    ),
                    SizedBox(height: spaceBetween),
                    GameButton(
                      label: 'Sacrifier',
                      icon: Icons.delete_outline,
                      style: GameButtonStyle.danger,
                      height: buttonHeight,
                      onPressed: canSacrifice ? _sacrificeCard : null,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  /// Affichage des enchantements actifs
  /// Affichage compact des enchantements avec chevauchement après 3 cartes
  Widget _buildCompactEnchantments(
    List<String> enchantmentIds, {
    bool isMyEnchantments = false,
  }) {
    if (enchantmentIds.isEmpty) return const SizedBox.shrink();

    final cardService = ref.watch(cardServiceProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final cardWidth = isMobile ? 40.0 : 50.0;
    final cardHeight = isMobile ? 50.0 : 65.0;
    final overlapOffset =
        isMobile ? 12.0 : 15.0; // Décalage entre cartes chevauchées

    return FutureBuilder(
      future: cardService.loadAllCards(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final allCards = snapshot.data!;

        // Créer une liste d'enchantements en respectant les doublons
        final enchantments =
            enchantmentIds.map((id) {
              return allCards.firstWhere((card) => card.id == id);
            }).toList();

        if (enchantments.isEmpty) return const SizedBox.shrink();

        // Calculer la largeur totale nécessaire
        final totalWidth =
            enchantments.length <= 3
                ? enchantments.length *
                    (cardWidth + 4) // Espacées normalement
                : (cardWidth +
                    (enchantments.length - 1) * overlapOffset); // Chevauchées

        return SizedBox(
          width: totalWidth,
          height: cardHeight + 10,
          child: Stack(
            children: [
              for (int i = 0; i < enchantments.length; i++)
                Positioned(
                  left:
                      enchantments.length <= 3
                          ? i *
                              (cardWidth + 4) // Côte à côte si <= 3
                          : i * overlapOffset, // Chevauchement si > 3
                  child: GestureDetector(
                    onTap:
                        isMyEnchantments
                            ? () => _showDeleteEnchantmentDialog(
                              enchantmentIds[i],
                              enchantments[i],
                            )
                            : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CardWidget(
                        card: enchantments[i],
                        width: cardWidth,
                        height: cardHeight,
                        compact: true,
                        showPreviewOnHover: true,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Ma zone (infos + main de cartes)
  Widget _buildPlayerZone(dynamic myData, bool isMyTurn, GameSession session) {
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
          LayoutBuilder(
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
                            final cardId = myData.handCardIds[index];
                            final isSelected = _selectedCardIndex == index;

                            // Permettre la sélection en phase Main, Response, ou en mode défausse (phase Draw)
                            final canSelect =
                                (isMyTurn &&
                                    session.currentPhase == GamePhase.main) ||
                                (!isMyTurn &&
                                    session.currentPhase ==
                                        GamePhase.response) ||
                                (_isDiscardMode &&
                                    isMyTurn &&
                                    session.currentPhase == GamePhase.draw);

                            return GestureDetector(
                              onTap:
                                  canSelect ? () => _selectCard(index) : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                  right: 8,
                                  top: isSelected ? 0 : 20,
                                ),
                                transform:
                                    Matrix4.identity()
                                      ..scale(isSelected ? 1.1 : 1.0),
                                child: Opacity(
                                  opacity: canSelect ? 1.0 : 0.5,
                                  child: FutureBuilder(
                                    future: cardService.loadAllCards(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Container(
                                          width: 90,
                                          height: 140,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2d4263),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }

                                      final allCards = snapshot.data!;
                                      final card = allCards.firstWhere(
                                        (c) => c.id == cardId,
                                        orElse: () => allCards.first,
                                      );

                                      // En phase response, vérifier si la carte est jouable
                                      final isPlayableInResponse =
                                          session.currentPhase ==
                                              GamePhase.response &&
                                          !isMyTurn &&
                                          card.type != CardType.instant;

                                      // Vérifier si la carte est verrouillée par le niveau
                                      final tensionService = ref.read(
                                        tensionServiceProvider,
                                      );

                                      // Calculer le niveau actuel basé sur la tension
                                      // (pour éviter les problèmes de synchronisation Firebase)
                                      CardLevel effectiveLevel =
                                          myData.currentLevel;
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
                                          !tensionService.canPlayCard(
                                            card.color,
                                            effectiveLevel,
                                          );

                                      // Debug: vérifier les valeurs
                                      if (card.color != CardColor.white) {
                                        print(
                                          '🔍 Carte ${card.name} (${card.color}) - Niveau DB: ${myData.currentLevel} - Niveau effectif: $effectiveLevel - Tension: ${myData.tension}% - Verrouillée: $isLocked',
                                        );
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? Colors.green
                                                    : isPlayableInResponse
                                                    ? Colors.red.withOpacity(
                                                      0.5,
                                                    )
                                                    : isLocked
                                                    ? Colors.grey.withOpacity(
                                                      0.5,
                                                    )
                                                    : Colors.transparent,
                                            width:
                                                isSelected
                                                    ? 3
                                                    : (isPlayableInResponse ||
                                                            isLocked
                                                        ? 2
                                                        : 0),
                                          ),
                                          boxShadow:
                                              isSelected
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.green
                                                          .withOpacity(0.5),
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
                                                    color: Colors.red
                                                        .withOpacity(0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
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
                                                  ignoring:
                                                      true, // Ignore les événements pour laisser passer le hover
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
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
                          },
                        ),
              );
            },
          ),

          Builder(
            builder: (context) {
              final isMobile = MediaQuery.of(context).size.width < 600;
              return SizedBox(height: isMobile ? 8 : 12);
            },
          ),

          // Mes infos + actions
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              if (isMobile) {
                // Version mobile : 2 lignes
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
                        // PI compact avec boutons +/-
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
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
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 10,
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
                                    onTap: _decrementPI,
                                    child: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.white,
                                      size: 16,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          offset: Offset(0, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${myData.inhibitionPoints}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          offset: Offset(0, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: _incrementPI,
                                    child: const Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                      size: 16,
                                      shadows: [
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
                        const SizedBox(width: 8),
                        // Bouton pioche compact
                        InkWell(
                          onTap:
                              myData.handCardIds.length >= 7
                                  ? null
                                  : _manualDrawCard,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors:
                                    myData.handCardIds.length >= 7
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
                                  left: -8,
                                  right: -8,
                                  child: Container(
                                    height: 15,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(
                                            myData.handCardIds.length >= 7
                                                ? 0.2
                                                : 0.5,
                                          ),
                                          Colors.white.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.layers,
                                  color:
                                      myData.handCardIds.length >= 7
                                          ? Colors.white38
                                          : Colors.white,
                                  size: 18,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black38,
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Indicateur main pleine
                        if (myData.handCardIds.length >= 7)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Ligne 2 : Enchantements si présents
                    if (myData.activeEnchantmentIds.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildCompactEnchantments(
                        myData.activeEnchantmentIds,
                        isMyEnchantments: true,
                      ),
                    ],
                  ],
                );
              } else {
                // Version desktop : 1 ligne
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
                            // PI avec boutons +/-
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
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
                                    top: -6,
                                    left: -8,
                                    right: -8,
                                    child: Container(
                                      height: 15,
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
                                        onTap: _decrementPI,
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.white,
                                          size: 18,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black38,
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${myData.inhibitionPoints} PI',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black38,
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: _incrementPI,
                                        child: const Icon(
                                          Icons.add_circle,
                                          color: Colors.white,
                                          size: 18,
                                          shadows: [
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
                            const SizedBox(width: 16),
                            // Bouton pioche
                            InkWell(
                              onTap:
                                  myData.handCardIds.length >= 7
                                      ? null
                                      : _manualDrawCard,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors:
                                        myData.handCardIds.length >= 7
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
                                      left: -12,
                                      right: -12,
                                      child: Container(
                                        height: 15,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withOpacity(
                                                myData.handCardIds.length >= 7
                                                    ? 0.2
                                                    : 0.5,
                                              ),
                                              Colors.white.withOpacity(0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.layers,
                                          color:
                                              myData.handCardIds.length >= 7
                                                  ? Colors.white38
                                                  : Colors.white,
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
                                          color:
                                              myData.handCardIds.length >= 7
                                                  ? Colors.white24
                                                  : Colors.white,
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
                                          myData.handCardIds.length >= 7
                                              ? 'Main pleine'
                                              : 'Piocher',
                                          style: TextStyle(
                                            color:
                                                myData.handCardIds.length >= 7
                                                    ? Colors.white38
                                                    : Colors.white,
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
                            ),
                            const SizedBox(width: 16),
                            // Enchantements actifs
                            if (myData.activeEnchantmentIds.isNotEmpty)
                              _buildCompactEnchantments(
                                myData.activeEnchantmentIds,
                                isMyEnchantments: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 8),

          // Ma barre de tension
          _buildTensionBar(myData.tension),
        ],
      ),
    );
  }

  /// Barre de tension
  Widget _buildTensionBar(double tension) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tension',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              '${tension.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: tension / 100,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTensionColor(tension),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTensionColor(double tension) {
    if (tension < 25) return Colors.white;
    if (tension < 50) return Colors.blue;
    if (tension < 75) return Colors.yellow;
    return Colors.red;
  }

  /// Widget de jauge de tension avec niveau actuel et progression
  Widget _buildTensionGauge(dynamic playerData) {
    final tension = playerData.tension ?? 0.0;
    final currentLevel = playerData.currentLevel ?? CardLevel.white;

    // Calculer le niveau suivant
    String? nextLevelName;
    if (currentLevel == CardLevel.white)
      nextLevelName = 'Bleu';
    else if (currentLevel == CardLevel.blue)
      nextLevelName = 'Jaune';
    else if (currentLevel == CardLevel.yellow)
      nextLevelName = 'Rouge';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return Container(
          padding: EdgeInsets.all(isMobile ? 4 : 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getTensionColor(tension).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Niveau actuel
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 4 : 8,
                      vertical: isMobile ? 2 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTensionColor(tension),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      currentLevel.displayName,
                      style: TextStyle(
                        color: tension < 50 ? Colors.black : Colors.white,
                        fontSize: isMobile ? 9 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (nextLevelName != null && !isMobile) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      nextLevelName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: isMobile ? 4 : 8),
              // Barre de progression
              SizedBox(
                width: isMobile ? 80 : 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isMobile)
                          const Text(
                            'Tension',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        Text(
                          '${tension.toInt()}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 9 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: tension / 100,
                        minHeight: isMobile ? 4 : 6,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTensionColor(tension),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Passer à la phase suivante
  Future<void> _nextPhase() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      await firebaseService.nextPhase(widget.sessionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Activer/désactiver le mode défausse
  void _toggleDiscardMode() {
    setState(() {
      _isDiscardMode = !_isDiscardMode;
      _selectedCardIndex = null; // Déselectionner toute carte
    });
  }

  /// Défausser la carte sélectionnée
  Future<void> _discardSelectedCard() async {
    if (_selectedCardIndex == null) return;

    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);
      final isPlayer1 = session.player1Id == widget.playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;

      final cardId = myData.handCardIds[_selectedCardIndex!];

      // Retirer la carte de la main
      final updatedHand = List<String>.from(myData.handCardIds);
      updatedHand.removeAt(_selectedCardIndex!);

      final updatedPlayerData = myData.copyWith(handCardIds: updatedHand);
      final updatedSession =
          isPlayer1
              ? session.copyWith(player1Data: updatedPlayerData)
              : session.copyWith(player2Data: updatedPlayerData);

      // Mettre à jour Firebase
      final docRef = firebaseService.firestore
          .collection('game_sessions')
          .doc(widget.sessionId);

      final sessionJson = updatedSession.toJson();
      sessionJson['player1Data'] = updatedSession.player1Data.toJson();
      if (updatedSession.player2Data != null) {
        sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
      }

      await docRef.update(sessionJson);

      setState(() {
        _selectedCardIndex = null;
        _isDiscardMode = false; // Sortir du mode défausse
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🗑️ Carte défaussée'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la défausse: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectCard(int index) {
    setState(() {
      _selectedCardIndex = _selectedCardIndex == index ? null : index;
    });
  }

  // ========== GESTION MANUELLE DES PI ==========
  Future<void> _incrementPI() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      await firebaseService.updatePlayerPI(
        widget.sessionId,
        widget.playerId,
        1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💎 +1 PI'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _decrementPI() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      await firebaseService.updatePlayerPI(
        widget.sessionId,
        widget.playerId,
        -1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💎 -1 PI'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _manualDrawCard() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    // Vérifier la limite de main (7 cartes max)
    try {
      final session = await firebaseService.getGameSession(widget.sessionId);
      final isPlayer1 = session.player1Id == widget.playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;

      if (myData.handCardIds.length >= 7) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Main pleine (7/7) - Jouez ou sacrifiez une carte',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    } catch (e) {
      // Si erreur lors de la vérification, on laisse passer
    }

    try {
      await firebaseService.drawCard(widget.sessionId, widget.playerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎴 Carte piochée'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('Plus de cartes')
                  ? '⚠️ Plus de cartes à piocher'
                  : '❌ Erreur: $e',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _playCard() async {
    if (_selectedCardIndex == null) return;

    final firebaseService = ref.read(firebaseServiceProvider);
    final cardService = ref.read(cardServiceProvider);
    final tensionService = ref.read(tensionServiceProvider);

    try {
      // Vérifier le type de carte et récupérer la carte
      final session = await firebaseService.getGameSession(widget.sessionId);
      final isPlayer1 = session.player1Id == widget.playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;
      final cardId = myData.handCardIds[_selectedCardIndex!];

      final allCards = await cardService.loadAllCards();
      final card = allCards.firstWhere((c) => c.id == cardId);

      // Calculer le niveau effectif basé sur la tension (même logique que l'affichage)
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

      // Vérifier si la carte peut être jouée selon le niveau effectif
      if (!tensionService.canPlayCard(card.color, effectiveLevel)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🔒 Carte ${card.color.displayName} verrouillée - Niveau ${effectiveLevel.displayName} requis pour débloquer',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Vérification type en phase response
      if (session.currentPhase == GamePhase.response) {
        if (card.type != CardType.instant) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '❌ Seules les cartes de Négociation (vertes) peuvent être jouées en phase de réponse',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // LOGIQUE SPÉCIALE POUR LES CARTES VERTES (Négociations)
        if (card.color == CardColor.green) {
          // Afficher la modale de négociation
          final agreement = await _showNegotiationDialog();

          if (agreement == true) {
            // Entente trouvée → le sort est contré
            // 1. Retirer la carte Négociations de la main (défausse définitive)
            final cardId = myData.handCardIds[_selectedCardIndex!];
            final updatedHand = List<String>.from(myData.handCardIds);
            updatedHand.removeAt(_selectedCardIndex!);

            // 2. LOGIQUE SPÉCIALE POUR ULTIMA : Si la carte contrée est Ultima, la remettre en main de l'adversaire
            final opponentData =
                isPlayer1 ? session.player2Data! : session.player1Data;
            final updatedOpponentHand = List<String>.from(
              opponentData.handCardIds,
            );

            if (session.resolutionStack.isNotEmpty) {
              final contredCardId = session.resolutionStack.last;
              if (contredCardId.contains('red_016')) {
                // C'est Ultima - la remettre dans la main de l'adversaire
                updatedOpponentHand.add(contredCardId);
              }
            }

            final updatedPlayerData = myData.copyWith(handCardIds: updatedHand);
            final updatedOpponentPlayerData = opponentData.copyWith(
              handCardIds: updatedOpponentHand,
            );

            // 3. Vider la pile de résolution (retire la carte contrée)
            final updatedSession =
                isPlayer1
                    ? session.copyWith(
                      player1Data: updatedPlayerData,
                      player2Data: updatedOpponentPlayerData,
                      resolutionStack: [],
                      pendingSpellActions: [],
                    )
                    : session.copyWith(
                      player1Data: updatedOpponentPlayerData,
                      player2Data: updatedPlayerData,
                      resolutionStack: [],
                      pendingSpellActions: [],
                    );

            // 4. Mettre à jour Firebase
            final docRef = firebaseService.firestore
                .collection('game_sessions')
                .doc(widget.sessionId);

            final sessionJson = updatedSession.toJson();
            sessionJson['player1Data'] = updatedSession.player1Data.toJson();
            if (updatedSession.player2Data != null) {
              sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
            }

            await docRef.update(sessionJson);

            setState(() {
              _selectedCardIndex = null;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '🤝 Entente trouvée ! Les deux cartes sont retirées du jeu.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }

            // Passer à la phase suivante
            await firebaseService.nextPhase(widget.sessionId);
            return;
          } else {
            // Pas d'entente → le sort n'est pas contré
            // La carte Négociations reste dans la main du joueur (on ne la joue pas)
            setState(() {
              _selectedCardIndex = null;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '❌ Pas d\'entente. Le sort n\'est pas contré. Carte Négociations conservée en main.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }

            // Passer à la phase suivante sans contrer
            await firebaseService.nextPhase(widget.sessionId);
            return;
          }
        }
      }

      // Vérifier et déduire le coût PI
      final cost = firebaseService.parseLauncherCost(card.launcherCost);
      if (cost > 0) {
        try {
          await firebaseService.payCost(
            widget.sessionId,
            widget.playerId,
            cost,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
            );
          }
          return;
        }
      }

      await firebaseService.playCard(
        widget.sessionId,
        widget.playerId,
        _selectedCardIndex!,
      );
      setState(() {
        _selectedCardIndex = null;
      });

      // Traiter les mécaniques spéciales de la carte
      if (card.mechanics.isNotEmpty) {
        final mechanicService = ref.read(mechanicServiceProvider);
        final updatedSession = await firebaseService.getGameSession(
          widget.sessionId,
        );
        final updatedMyData =
            isPlayer1
                ? updatedSession.player1Data
                : updatedSession.player2Data!;
        final opponentData =
            isPlayer1
                ? updatedSession.player2Data!
                : updatedSession.player1Data;

        final mechanicResult = await mechanicService.processMechanics(
          context: context,
          sessionId: widget.sessionId,
          card: card,
          playerId: widget.playerId,
          handCardIds: updatedMyData.handCardIds,
          activeEnchantmentIds: updatedMyData.activeEnchantmentIds,
          opponentEnchantmentIds: opponentData.activeEnchantmentIds,
        );

        if (!mechanicResult.success) {
          if (mounted && mechanicResult.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mechanicResult.message!),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // Stocker les actions pendantes dans la session
        if (mechanicResult.pendingActions != null &&
            mechanicResult.pendingActions!.isNotEmpty) {
          await firebaseService.storePendingActions(
            widget.sessionId,
            mechanicResult.pendingActions!,
          );
        }

        // Gérer le remplacement d'enchantement si spécifié
        if (mechanicResult.replacedEnchantmentId != null) {
          // Déterminer qui possède l'enchantement à remplacer
          final isMyEnchantment = updatedMyData.activeEnchantmentIds.contains(
            mechanicResult.replacedEnchantmentId,
          );

          if (isMyEnchantment) {
            // Retirer l'enchantement du joueur actuel
            await firebaseService.removeEnchantment(
              widget.sessionId,
              widget.playerId,
              mechanicResult.replacedEnchantmentId!,
            );
          } else {
            // Retirer l'enchantement de l'adversaire
            final opponentId =
                isPlayer1 ? session.player2Id! : session.player1Id;
            await firebaseService.removeEnchantment(
              widget.sessionId,
              opponentId,
              mechanicResult.replacedEnchantmentId!,
            );
          }
        }

        // Afficher le résultat si présent
        if (mounted && mechanicResult.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mechanicResult.message!),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // ========== APPLIQUER LES EFFETS DE LA CARTE (ATTRIBUTS) ==========
      // NOTE: Logique automatique désactivée - Les joueurs gèrent manuellement PI et pioche

      /* LOGIQUE AUTOMATIQUE DÉSACTIVÉE - À réactiver plus tard si nécessaire
      // Gérer la pioche automatique si la carte a drawCards > 0
      if (card.drawCards > 0) {
        print(
          '🎴 DEBUG: Pioche automatique - Carte ${card.name} demande ${card.drawCards} cartes',
        );
        for (int i = 0; i < card.drawCards; i++) {
          try {
            print('🎴 DEBUG: Pioche carte ${i + 1}/${card.drawCards}');
            await firebaseService.drawCard(widget.sessionId, widget.playerId);
          } catch (e) {
            // Si on ne peut plus piocher (deck vide), on arrête
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('⚠️ Plus de cartes à piocher'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            break;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎴 ${card.drawCards} carte${card.drawCards > 1 ? 's' : ''} piochée${card.drawCards > 1 ? 's' : ''}',
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      */

      /* LOGIQUE AUTOMATIQUE DÉSACTIVÉE
      // Gérer le gain de PI
      if (card.piGainSelf > 0) {
        print('💎 DEBUG: Gain de ${card.piGainSelf} PI');
        await firebaseService.updatePlayerPI(
          widget.sessionId,
          widget.playerId,
          card.piGainSelf,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('💎 +${card.piGainSelf} PI'),
              backgroundColor: Colors.purple,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      */

      /* LOGIQUE AUTOMATIQUE DÉSACTIVÉE
      // Gérer les dégâts PI à l'adversaire
      if (card.piDamageOpponent > 0) {
        print(
          '⚔️ DEBUG: ${card.piDamageOpponent} PI de dégâts à l\'adversaire',
        );
        final opponentId =
            widget.playerId == session.player1Id
                ? session.player2Id
                : session.player1Id;
        await firebaseService.updatePlayerPI(
          widget.sessionId,
          opponentId!,
          -card.piDamageOpponent,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚔️ ${card.piDamageOpponent} PI de dégâts infligés',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      */

      /* LOGIQUE AUTOMATIQUE DÉSACTIVÉE
      // Gérer la pioche adversaire
      if (card.opponentDraw > 0) {
        print('🎴 DEBUG: L\'adversaire pioche ${card.opponentDraw} carte(s)');
        final opponentId =
            widget.playerId == session.player1Id
                ? session.player2Id
                : session.player1Id;
        for (int i = 0; i < card.opponentDraw; i++) {
          try {
            await firebaseService.drawCard(widget.sessionId, opponentId!);
          } catch (e) {
            print('⚠️ L\'adversaire ne peut plus piocher');
            break;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎴 L\'adversaire pioche ${card.opponentDraw} carte(s)',
              ),
              backgroundColor: Colors.teal,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      */

      // Augmenter la tension après avoir joué la carte avec succès
      // Montant basé sur la couleur de la carte
      double tensionAmount = 0;
      switch (card.color) {
        case CardColor.white:
          tensionAmount = 5.0;
          break;
        case CardColor.blue:
          tensionAmount = 8.0;
          break;
        case CardColor.yellow:
          tensionAmount = 12.0;
          break;
        case CardColor.red:
          tensionAmount = 15.0;
          break;
        case CardColor.green:
          tensionAmount = 0.0; // Les cartes vertes ne donnent pas de tension
          break;
      }

      bool levelChanged = false;
      if (tensionAmount > 0) {
        levelChanged = await tensionService.increaseTension(
          widget.sessionId,
          widget.playerId,
          tensionAmount,
        );

        // PIOCHE MANUELLE lors du changement de niveau
        // Les joueurs piochent eux-mêmes avec le bouton "Piocher"
        if (levelChanged) {
          final updatedSession = await firebaseService.getGameSession(
            widget.sessionId,
          );
          final isPlayer1 = updatedSession.player1Id == widget.playerId;
          final playerData =
              isPlayer1
                  ? updatedSession.player1Data
                  : updatedSession.player2Data!;
          final newLevel = playerData.currentLevel;

          // Afficher seulement une notification du changement de niveau
          String colorToDraw = '';
          switch (newLevel) {
            case CardLevel.blue:
              colorToDraw = 'blue';
              break;
            case CardLevel.yellow:
              colorToDraw = 'yellow';
              break;
            case CardLevel.red:
              colorToDraw = 'red';
              break;
            case CardLevel.white:
              colorToDraw = 'white';
              break;
          }

          // Piocher une carte de cette couleur
          if (colorToDraw.isNotEmpty) {
            // PIOCHE MANUELLE - Notification uniquement
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🎉 Nouveau niveau: ${newLevel.displayName}! Utilisez le bouton "Piocher" pour vos cartes $colorToDraw!',
                  ),
                  backgroundColor: Colors.purple,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        }
      }

      // ACTIVER L'ÉTAT DE VALIDATION EN ATTENTE
      setState(() {
        _pendingCardValidation = true;
        _selectedCardIndex = null; // Désélectionner la carte
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Carte jouée ! Cliquez sur "Valider" pour confirmer ou "Retour" pour annuler',
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Ne pas passer à la phase suivante maintenant
      // L'utilisateur doit cliquer sur "Valider"
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Valider la carte jouée et passer à la phase suivante
  Future<void> _validatePlayedCard() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);

      // Si c'est une réponse en phase Response, on passe en Résolution
      // et le joueur actif choisira l'effet
      if (session.currentPhase == GamePhase.response) {
        // Réponse → Résolution
        await firebaseService.nextPhase(widget.sessionId);

        setState(() {
          _pendingCardValidation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Réponse validée - Phase Résolution'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        // Auto-transition: Phase Main → Phase Réponse
        await firebaseService.nextPhase(widget.sessionId);

        setState(() {
          _pendingCardValidation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Carte validée - Phase Réponse'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Annuler la carte jouée et la remettre en main
  Future<void> _cancelPlayedCard() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      // Récupérer la session actuelle
      final currentSession = await firebaseService.getGameSession(
        widget.sessionId,
      );
      final currentIsPlayer1 = currentSession.player1Id == widget.playerId;
      final currentMyData =
          currentIsPlayer1
              ? currentSession.player1Data
              : currentSession.player2Data!;

      // Retirer la carte de la pile de résolution
      final updatedResolutionStack = List<String>.from(
        currentSession.resolutionStack,
      );

      if (updatedResolutionStack.isNotEmpty) {
        final lastCardId = updatedResolutionStack.removeLast();

        // Remettre la carte dans la main
        final updatedHand = List<String>.from(currentMyData.handCardIds);
        updatedHand.add(lastCardId);

        final updatedPlayerData = currentMyData.copyWith(
          handCardIds: updatedHand,
        );
        final updatedSession = (currentIsPlayer1
                ? currentSession.copyWith(player1Data: updatedPlayerData)
                : currentSession.copyWith(player2Data: updatedPlayerData))
            .copyWith(resolutionStack: updatedResolutionStack);

        // Mettre à jour Firebase
        final docRef = firebaseService.firestore
            .collection('game_sessions')
            .doc(widget.sessionId);

        final sessionJson = updatedSession.toJson();
        sessionJson['player1Data'] = updatedSession.player1Data.toJson();
        if (updatedSession.player2Data != null) {
          sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
        }

        await docRef.update(sessionJson);

        setState(() {
          _pendingCardValidation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('↩️ Action annulée - Carte remise en main'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'annulation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sacrificeCard() async {
    if (_selectedCardIndex == null) return;

    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      // Sacrifier la carte
      await firebaseService.sacrificeCard(
        widget.sessionId,
        widget.playerId,
        _selectedCardIndex!,
      );

      // Gagner 2% de tension
      await firebaseService.updatePlayerTension(
        widget.sessionId,
        widget.playerId,
        2.0, // +2% de tension
      );

      // PIOCHE MANUELLE : Le joueur pioche avec le bouton "Piocher"
      // Plus de pioche automatique après sacrifice

      setState(() {
        _selectedCardIndex = null;
      });

      // Terminer le tour (passer en phase End puis au tour de l'adversaire)
      await firebaseService.endTurn(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Carte sacrifiée (+2% Tension) - Utilisez "Piocher" pour tirer une carte - Tour terminé',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _skipTurn() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      // Terminer le tour sans jouer de carte
      await firebaseService.endTurn(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏭️ Tour passé'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Exécute les actions pendantes du sort en phase Resolution
  Future<void> _executePendingActions(GameSession session) async {
    final mechanicService = ref.read(mechanicServiceProvider);
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      // Convertir les Map en PendingAction
      final pendingActions =
          session.pendingSpellActions
              .map((json) => PendingAction.fromJson(json))
              .toList();

      // Exécuter les actions
      await mechanicService.executePendingActions(
        sessionId: widget.sessionId,
        actions: pendingActions,
      );

      // Effacer les actions pendantes
      await firebaseService.clearPendingActions(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Actions du sort exécutées'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur exécution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Passe la phase réponse sans jouer de carte
  Future<void> _skipResponse() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    try {
      // Réponse → Résolution
      await firebaseService.nextPhase(widget.sessionId);

      // Le dialog de validation apparaîtra automatiquement via le StreamBuilder
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Sacrifier une carte
  /// Affiche le dialog de sélection d'effet de réponse
  Future<void> _showResponseEffectDialog() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    if (!mounted) return;

    final ResponseEffect? selectedEffect = await showDialog<ResponseEffect>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2d4263),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF6DD5FA), width: 2),
            ),
            title: Row(
              children: [
                Icon(Icons.reply, color: Color(0xFF6DD5FA), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Carte de réponse jouée',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre adversaire a joué une réponse.\nQue se passe-t-il ?',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<ResponseEffect>(
                  dropdownColor: const Color(0xFF2d4263),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Effet de la réponse',
                    labelStyle: const TextStyle(color: Color(0xFF6DD5FA)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6DD5FA)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF6DD5FA).withOpacity(0.5),
                      ),
                    ),
                  ),
                  items:
                      ResponseEffect.values.map((effect) {
                        return DropdownMenuItem(
                          value: effect,
                          child: Text(
                            effect.displayName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.pop(context, value);
                    }
                  },
                ),
              ],
            ),
          ),
    );

    if (selectedEffect != null) {
      // Sauvegarder l'effet choisi dans la session
      await firebaseService.setResponseEffect(widget.sessionId, selectedEffect);

      // Traiter selon l'effet
      await _handleResponseEffect(selectedEffect);
    }
  }

  /// Gère le traitement selon l'effet de réponse
  Future<void> _handleResponseEffect(ResponseEffect effect) async {
    switch (effect) {
      case ResponseEffect.cancel:
        // Annule tout - vider la pile et fin de tour
        await _handleCancelEffect();
        break;

      case ResponseEffect.copy:
        // Copie - validation double
        await _handleCopyEffect();
        break;

      case ResponseEffect.replace:
        // Remplacement - pour plus tard
        await _handleReplaceEffect();
        break;

      case ResponseEffect.noEffect:
        // Aucun effet - validation normale
        await _continueValidationAfterResponse();
        break;
    }
  }

  /// Gère l'annulation (Contre)
  Future<void> _handleCancelEffect() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      // Effacer les actions pendantes (le sort est contré, ne pas les exécuter)
      await firebaseService.clearPendingActions(widget.sessionId);

      // Vider la pile de résolution
      await firebaseService.clearResolutionStack(widget.sessionId);

      // Passer directement en fin de tour
      await firebaseService.nextPhase(widget.sessionId); // Resolution → End
      await firebaseService.nextPhase(widget.sessionId); // End → Draw

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Sort annulé - Tour terminé'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Gère la copie (Miroir) - validation double
  Future<void> _handleCopyEffect() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);

      // EXÉCUTER LES ACTIONS PENDANTES (sort non contré)
      if (session.pendingSpellActions.isNotEmpty) {
        await _executePendingActions(session);
      }

      final allCards = await cardService.loadAllCards();

      // Trouver la carte principale qui nécessite validation
      String? cardToValidate;
      for (final cardId in session.resolutionStack) {
        final card = allCards.firstWhere((c) => c.id == cardId);
        if (card.damageIfRefused > 0) {
          cardToValidate = cardId;
          break;
        }
      }

      if (cardToValidate == null) {
        // Pas de validation nécessaire, juste appliquer les effets
        await _resolveEffectsWithoutValidation();
        return;
      }

      final card = allCards.firstWhere((c) => c.id == cardToValidate);

      if (!mounted) return;

      // Dialog avec 2 checkboxes
      bool? player1Completed;
      bool? player2Completed;

      final result = await showDialog<Map<String, bool>>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF2d4263),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFFFC107), width: 2),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      color: Color(0xFFFFC107),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Validation (Miroir)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFC107).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Les 2 joueurs doivent effectuer :\n"${card.targetEffect ?? card.gameEffect}"',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text(
                        'Vous avez effectué l\'action',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: player1Completed ?? false,
                      activeColor: Color(0xFF6DD5FA),
                      checkColor: Colors.white,
                      onChanged: (value) {
                        setState(() => player1Completed = value);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Adversaire a effectué l\'action',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: player2Completed ?? false,
                      activeColor: Color(0xFF6DD5FA),
                      checkColor: Colors.white,
                      onChanged: (value) {
                        setState(() => player2Completed = value);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed:
                        (player1Completed != null && player2Completed != null)
                            ? () {
                              Navigator.pop(context, {
                                'player1': player1Completed!,
                                'player2': player2Completed!,
                              });
                            }
                            : null,
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF6DD5FA).withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      '✅ Valider',
                      style: TextStyle(
                        color: Color(0xFF6DD5FA),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result != null) {
        await _resolveEffectsWithCopyValidation(
          cardToValidate,
          result['player1']!,
          result['player2']!,
          card.damageIfRefused,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Gère le remplacement (Échange) - TODO
  Future<void> _handleReplaceEffect() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚧 Fonctionnalité à venir : Remplacement'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Pour l'instant, traiter comme "aucun effet"
    await _continueValidationAfterResponse();
  }

  /// Continue la validation normale après une réponse sans effet
  Future<void> _continueValidationAfterResponse() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);

      // EXÉCUTER LES ACTIONS PENDANTES (sort non contré)
      if (session.pendingSpellActions.isNotEmpty) {
        await _executePendingActions(session);
      }

      final allCards = await cardService.loadAllCards();

      // Trouver la carte principale qui nécessite validation
      String? cardToValidate;
      for (final cardId in session.resolutionStack) {
        final card = allCards.firstWhere((c) => c.id == cardId);
        if (card.damageIfRefused > 0) {
          cardToValidate = cardId;
          break;
        }
      }

      if (cardToValidate == null) {
        await _resolveEffectsWithoutValidation();
        return;
      }

      final card = allCards.firstWhere((c) => c.id == cardToValidate);

      if (!mounted) return;

      // Validation simple
      final actionCompleted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFF2d4263),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF8E44AD), width: 2),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF8E44AD),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Validation de l\'action',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF8E44AD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'L\'adversaire a-t-il effectué l\'action suivante ?\n\n'
                  '"${card.targetEffect ?? card.gameEffect}"',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        '✅ Action effectuée',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        '❌ Action refusée',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      );

      if (actionCompleted != null) {
        await _resolveEffectsWithValidation(
          cardToValidate,
          actionCompleted,
          card.damageIfRefused,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showValidationDialog() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);

      // Pas de carte à valider si pile vide
      if (session.resolutionStack.isEmpty) {
        await _resolveEffectsWithoutValidation();
        return;
      }

      final allCards = await cardService.loadAllCards();

      // Vérifier s'il y a une carte de réponse (2+ cartes dans la pile)
      if (session.resolutionStack.length > 1) {
        // Il y a une réponse - demander au joueur actif l'effet
        await _showResponseEffectDialog();
        return;
      }

      // Pas de réponse - validation normale
      // Trouver la première carte qui nécessite validation (damageIfRefused > 0)
      String? cardToValidate;
      for (final cardId in session.resolutionStack) {
        final card = allCards.firstWhere((c) => c.id == cardId);
        if (card.damageIfRefused > 0) {
          cardToValidate = cardId;
          break;
        }
      }

      if (cardToValidate == null) {
        // Aucune carte nécessite validation
        await _resolveEffectsWithoutValidation();
        return;
      }

      final card = allCards.firstWhere((c) => c.id == cardToValidate);

      // Déterminer qui doit valider
      final isMyTurn =
          session.currentPlayerId ==
          widget
              .playerId; // TODO: Gérer le cas où une carte de réponse affecte la carte Phase 2
      // Pour l'instant: seul le joueur actif valide
      if (!isMyTurn) {
        // Attendre que le joueur actif valide
        return;
      }

      if (mounted) {
        final actionCompleted = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF2d4263),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF8E44AD), width: 2),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF8E44AD),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Validation de l\'action',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF8E44AD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'L\'adversaire a-t-il effectué l\'action suivante ?\n\n'
                    '"${card.targetEffect ?? card.gameEffect}"',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          '✅ Action effectuée',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          '❌ Action refusée',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        );

        if (actionCompleted != null) {
          await _resolveEffectsWithValidation(
            cardToValidate,
            actionCompleted,
            card.damageIfRefused,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Afficher la modale de négociation pour les cartes vertes
  Future<bool?> _showNegotiationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2d4263),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.handshake, color: Color(0xFF4CAF50), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Négociations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Text(
                  '💬 Le joueur contré peut demander ce qu\'il veut en échange de son sort contré.\n\nÀ vous de négocier !',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Une entente est trouvée ?',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                '❌ Non',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                '✅ Oui',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Modale de confirmation après avoir joué une carte
  Future<bool?> _showPlayConfirmationDialog(GameCard card) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2d4263),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF6DD5FA), width: 2),
            ),
            title: Row(
              children: [
                Icon(Icons.help_outline, color: Color(0xFF6DD5FA), size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Confirmer l\'action',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF6DD5FA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Voulez-vous valider le lancement de la carte "${card.name}" ?',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Si vous annulez, la carte reviendra dans votre main.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      '✅ Oui, valider l\'action',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      '↩️ Non, annuler',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  /// Modale de confirmation pour supprimer un enchantement
  Future<bool?> _showDeleteEnchantmentDialog(
    String enchantmentId,
    GameCard enchantment,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2d4263),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF6B9D),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Supprimer l\'enchantement ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B9D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Voulez-vous supprimer l\'enchantement "${enchantment.name}" ?',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ne peut être détruit que si une carte vous le demande.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[200],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cette action est irréversible.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      '🗑️ Oui, supprimer',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      '❌ Non, annuler',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    ).then((confirmed) async {
      if (confirmed == true) {
        await _deleteEnchantment(enchantmentId);
      }
      return confirmed;
    });
  }

  /// Supprimer un enchantement du jeu
  Future<void> _deleteEnchantment(String enchantmentId) async {
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);
      final isPlayer1 = session.player1Id == widget.playerId;

      // Récupérer mes données
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;

      // Retirer l'enchantement de la liste
      final updatedEnchantments = List<String>.from(
        myData.activeEnchantmentIds,
      );
      updatedEnchantments.remove(enchantmentId);

      // LOGIQUE SPÉCIALE POUR ULTIMA : La remettre en main au lieu de la retirer
      final updatedHand = List<String>.from(myData.handCardIds);
      if (enchantmentId.contains('red_016')) {
        // C'est Ultima - la remettre en main
        updatedHand.add(enchantmentId);
      }

      // Créer une session mise à jour
      final updatedMyData = myData.copyWith(
        activeEnchantmentIds: updatedEnchantments,
        handCardIds: updatedHand,
      );

      final updatedSession =
          isPlayer1
              ? session.copyWith(player1Data: updatedMyData)
              : session.copyWith(player2Data: updatedMyData);

      // Mettre à jour la session
      await firebaseService.updateSession(widget.sessionId, updatedSession);

      if (mounted) {
        final message =
            enchantmentId.contains('red_016')
                ? '↩️ Ultima remis en main'
                : '🗑️ Enchantement supprimé avec succès';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                enchantmentId.contains('red_016') ? Colors.blue : Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resolveEffectsWithoutValidation() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);

      // EXÉCUTER LES ACTIONS PENDANTES (sort non contré)
      if (session.pendingSpellActions.isNotEmpty) {
        await _executePendingActions(session);
      }

      final allCards = await cardService.loadAllCards();

      // Résoudre les effets de chaque carte dans la pile (LIFO)
      for (int i = session.resolutionStack.length - 1; i >= 0; i--) {
        final cardId = session.resolutionStack[i];
        final card = allCards.firstWhere((c) => c.id == cardId);

        await cardEffectService.applyCardEffect(
          widget.sessionId,
          card,
          session.currentPlayerId!,
        );
      }

      // Nettoyer le plateau (supprimer cartes sauf enchantements)
      await firebaseService.clearPlayedCards(widget.sessionId);

      // Auto-transition: Résolution → Fin de tour
      await firebaseService.nextPhase(widget.sessionId);

      // Auto-transition: Fin → Tour suivant (Draw du prochain joueur)
      await firebaseService.nextPhase(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Effets résolus - Tour suivant'),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur résolution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resolveEffectsWithValidation(
    String cardId,
    bool actionCompleted,
    int damageIfRefused,
  ) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);
      final allCards = await cardService.loadAllCards();
      final isPlayer1 = session.player1Id == widget.playerId;
      final opponentId = isPlayer1 ? session.player2Id! : session.player1Id;

      // GESTION MANUELLE : Si action refusée, c'est au joueur de retirer ses PI
      // Plus de déduction automatique

      // Résoudre les autres effets
      for (int i = session.resolutionStack.length - 1; i >= 0; i--) {
        final stackCardId = session.resolutionStack[i];
        final card = allCards.firstWhere((c) => c.id == stackCardId);

        await cardEffectService.applyCardEffect(
          widget.sessionId,
          card,
          session.currentPlayerId!,
        );
      }

      // Nettoyer le plateau (supprimer cartes sauf enchantements)
      await firebaseService.clearPlayedCards(widget.sessionId);

      // Auto-transition: Résolution → Fin de tour
      await firebaseService.nextPhase(widget.sessionId);

      // Auto-transition: Fin → Tour suivant (Draw du prochain joueur)
      await firebaseService.nextPhase(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              actionCompleted
                  ? '✅ Action validée - Effets résolus'
                  : '❌ Action refusée - N\'oubliez pas de retirer $damageIfRefused PI manuellement !',
            ),
            backgroundColor: actionCompleted ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur résolution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resolveEffectsWithCopyValidation(
    String cardId,
    bool player1Completed,
    bool player2Completed,
    int damageIfRefused,
  ) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final cardEffectService = ref.read(cardEffectServiceProvider);
    final cardService = ref.read(cardServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);
      final allCards = await cardService.loadAllCards();
      final isPlayer1 = session.player1Id == widget.playerId;
      final opponentId = isPlayer1 ? session.player2Id! : session.player1Id;

      // GESTION MANUELLE : Si actions refusées, c'est aux joueurs de retirer leurs PI
      // Plus de déduction automatique

      // Résoudre les effets pour les 2 joueurs
      for (int i = session.resolutionStack.length - 1; i >= 0; i--) {
        final stackCardId = session.resolutionStack[i];
        final card = allCards.firstWhere((c) => c.id == stackCardId);

        // Appliquer pour joueur actif
        await cardEffectService.applyCardEffect(
          widget.sessionId,
          card,
          session.currentPlayerId!,
        );

        // Appliquer pour adversaire (effet copié)
        await cardEffectService.applyCardEffect(
          widget.sessionId,
          card,
          opponentId,
        );
      }

      // Nettoyer le plateau
      await firebaseService.clearPlayedCards(widget.sessionId);

      // Auto-transition
      await firebaseService.nextPhase(widget.sessionId);
      await firebaseService.nextPhase(widget.sessionId);

      if (mounted) {
        final p1Status = player1Completed ? '✅' : '❌';
        final p2Status = player2Completed ? '✅' : '❌';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Miroir - Vous: $p1Status Adversaire: $p2Status - Effets résolus',
            ),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur résolution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Donner la carte Ultima au joueur quand il atteint 100% de tension
  Future<void> _giveUltimaCard() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final session = await firebaseService.getGameSession(widget.sessionId);
      final isPlayer1 = session.player1Id == widget.playerId;
      final myData = isPlayer1 ? session.player1Data : session.player2Data!;

      // Ajouter Ultima directement à la main (sans passer par le deck)
      final updatedHand = List<String>.from(myData.handCardIds);
      updatedHand.add('red_016');

      final updatedPlayerData = myData.copyWith(handCardIds: updatedHand);

      final updatedSession =
          isPlayer1
              ? session.copyWith(player1Data: updatedPlayerData)
              : session.copyWith(player2Data: updatedPlayerData);

      // Mettre à jour dans Firebase
      final docRef = firebaseService.firestore
          .collection('game_sessions')
          .doc(widget.sessionId);

      final sessionJson = updatedSession.toJson();
      sessionJson['player1Data'] = updatedSession.player1Data.toJson();
      if (updatedSession.player2Data != null) {
        sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
      }

      await docRef.update(sessionJson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '🔥 ULTIMA ! La carte Ultima a été ajoutée à votre main !',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'ajout d\'Ultima: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Helper pour créer un bouton avec style crystal
  Widget _buildCrystalButton({
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

  /// Widget pour afficher le compteur Ultima
  Widget _buildUltimaCounter(GameSession session) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isMyUltima = session.ultimaOwnerId == widget.playerId;
    final turnCount = session.ultimaTurnCount;

    // Couleur selon le compteur
    Color getCounterColor() {
      if (turnCount == 0) return Colors.purple;
      if (turnCount == 1) return Colors.orange;
      if (turnCount == 2) return Colors.red;
      return Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            getCounterColor().withOpacity(0.4),
            getCounterColor().withOpacity(0.25),
          ],
        ),
        border: Border.all(color: getCounterColor().withOpacity(0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: getCounterColor().withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brillance en haut
          Positioned(
            top: -8,
            left: -12,
            right: -12,
            child: Container(
              height: 15,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: isMobile ? 20 : 24,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ULTIMA ${isMyUltima ? "(VOUS)" : "(ADVERSAIRE)"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tour $turnCount/3',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
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
        ],
      ),
    );
  }

  /// Widget pour afficher le compteur de cartes restantes dans le deck
  Widget _buildDeckCounter(int remainingCards) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Couleur selon le nombre de cartes restantes
    Color getCounterColor() {
      if (remainingCards > 30) return Colors.blue.shade700;
      if (remainingCards > 15) return Colors.orange.shade700;
      return Colors.red.shade700;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            getCounterColor().withOpacity(0.3),
            getCounterColor().withOpacity(0.2),
          ],
        ),
        border: Border.all(
          color: getCounterColor().withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: getCounterColor().withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brillance en haut
          Positioned(
            top: -6,
            left: -8,
            right: -8,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.style,
                color: Colors.white,
                size: isMobile ? 16 : 18,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                '$remainingCards carte${remainingCards > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
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

  /// Écran de victoire Ultima avec vidéo
  Widget _buildVictoryScreen(GameSession session) {
    final isWinner = session.winnerId == widget.playerId;

    // Initialiser et lire une vidéo aléatoire si pas encore fait
    if (!_isVideoPlaying && _videoController == null) {
      _isVideoPlaying = true;
      final random = Random();
      final videoNumber = random.nextInt(5) + 1; // 1 à 5
      final videoPath = 'assets/videos/Victory$videoNumber.mp4';

      _videoController = VideoPlayerController.asset(videoPath)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });

      // Passer automatiquement à l'écran de victoire après la vidéo
      _videoController!.addListener(() {
        if (_videoController!.value.position ==
            _videoController!.value.duration) {
          setState(() {
            _videoController?.dispose();
            _videoController = null;
          });
        }
      });
    }

    // Si la vidéo est en cours de lecture
    if (_videoController != null && _videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Vidéo en plein écran
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),

            // Bouton "Passer" en haut à droite
            Positioned(
              top: 40,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _videoController?.dispose();
                    _videoController = null;
                  });
                },
                icon: const Icon(Icons.skip_next),
                label: const Text('Passer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Écran de victoire classique (après la vidéo ou si erreur)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isWinner
                  ? [
                    const Color(0xFFFFD700), // Or
                    const Color(0xFFFF6B6B), // Rouge rosé
                  ]
                  : [
                    const Color(0xFF2C3E50), // Gris foncé
                    const Color(0xFF34495E), // Gris bleuté
                  ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône
                Icon(
                  isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 120,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Titre
                Text(
                  isWinner ? '🎉 VICTOIRE ! 🎉' : '😔 DÉFAITE',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Message Ultima
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isWinner
                            ? 'Vous avez conservé Ultima pendant 3 tours !'
                            : 'Votre adversaire a conservé Ultima pendant 3 tours',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isWinner
                            ? 'Votre adversaire vous doit un orgasme\n(vous d\'abord) 💕'
                            : 'Vous devez un orgasme à votre adversaire\n(lui/elle d\'abord) 💕',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton retour
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home, size: 24),
                  label: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}
