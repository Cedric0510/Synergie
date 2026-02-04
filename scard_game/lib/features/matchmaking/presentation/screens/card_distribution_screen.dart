import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../game/data/services/card_service.dart';
import '../../../game/data/services/deck_service.dart';
import '../../../game/data/services/game_session_service.dart';
import '../../../game/data/services/player_service.dart';
import '../../../game/domain/enums/card_color.dart';
import '../../../game/domain/models/game_card.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../../../game/presentation/widgets/card_widget.dart';

class CardDistributionScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String playerId;

  const CardDistributionScreen({
    super.key,
    required this.sessionId,
    required this.playerId,
  });

  @override
  ConsumerState<CardDistributionScreen> createState() =>
      _CardDistributionScreenState();
}

class _CardDistributionScreenState
    extends ConsumerState<CardDistributionScreen> {
  List<String>? _handCardIds;
  List<String>? _deckCardIds;
  bool _isLoading = true;
  bool _bothPlayersReady = false; // Flag pour éviter navigation en boucle

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  Future<void> _initializeCards() async {
    try {
      final deckService = ref.read(deckServiceProvider);
      final playerService = ref.read(playerServiceProvider);

      // IMPORTANT: Réinitialiser le flag isReady à false pour cette nouvelle phase
      await playerService.setPlayerReady(
        widget.sessionId,
        widget.playerId,
        false, // Reset à false pour la phase de distribution
      );

      // Génère le deck avec TOUTES les couleurs dès le départ
      // Le système de niveau ne fait que débloquer ce qu'on peut JOUER
      final result = await deckService.initializePlayerDeck(
        allowedColors: [
          CardColor.white,
          CardColor.blue,
          CardColor.yellow,
          CardColor.red,
          CardColor.green, // Cartes de Négociation
        ],
      );

      setState(() {
        _handCardIds = result.hand;
        _deckCardIds = result.deck;
        _isLoading = false;
      });

      // Sauvegarde dans Firebase
      await playerService.updatePlayerCards(
        sessionId: widget.sessionId,
        playerId: widget.playerId,
        handCardIds: result.hand,
        deckCardIds: result.deck,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ERREUR DISTRIBUTION: $e');
      debugPrint('❌ STACK: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameSessionService = ref.watch(gameSessionServiceProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6DD5FA),
              const Color(0xFF2980B9),
              const Color(0xFF8E44AD).withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Distribution des cartes...',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  )
                  : StreamBuilder(
                    stream: gameSessionService.watchSession(widget.sessionId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      final session = snapshot.data!;
                      final player1Ready = session.player1Data.isReady;
                      final player2Ready =
                          session.player2Data?.isReady ?? false;
                      final bothReady = player1Ready && player2Ready;

                      // Navigation automatique quand les deux joueurs sont prêts
                      if (bothReady && !_bothPlayersReady) {
                        _bothPlayersReady = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => GameScreen(
                                      sessionId: widget.sessionId,
                                      playerId: widget.playerId,
                                    ),
                              ),
                            );
                          }
                        });
                      }

                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Titre
                            const Text(
                              'Votre main de départ',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_deckCardIds!.length} cartes restantes dans le deck',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Grille de cartes 2x3
                            Expanded(child: _buildCardGrid()),

                            const SizedBox(height: 24),

                            // Bouton Commencer
                            GameButton(
                              label: 'Commencer la partie',
                              icon: Icons.play_arrow,
                              style: GameButtonStyle.success,
                              height: 56,
                              onPressed: _startGame,
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

  Widget _buildCardGrid() {
    final cardService = ref.watch(cardServiceProvider);

    return FutureBuilder(
      future: cardService.loadAllCards(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final allCards = snapshot.data!;
        final handCards = <GameCard>[];

        // Construire la liste des cartes en main en vérifiant que chaque ID existe
        for (final id in _handCardIds!) {
          try {
            final card = allCards.firstWhere((c) => c.id == id);
            handCards.add(card);
          } catch (e) {
            debugPrint('⚠️ Carte non trouvée: $id');
            // Ignorer les cartes qui n'existent pas
          }
        }

        if (handCards.isEmpty) {
          return const Center(
            child: Text(
              'Aucune carte valide en main',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.64, // Ratio largeur/hauteur des cartes
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: handCards.length,
          itemBuilder: (context, index) {
            return CardWidget(
              card: handCards[index],
              // Taille automatique selon la grille
            );
          },
        );
      },
    );
  }

  Future<void> _startGame() async {
    final playerService = ref.read(playerServiceProvider);

    // Marque ce joueur comme prêt
    await playerService.setPlayerCardsReady(widget.sessionId, widget.playerId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En attente de l\'autre joueur... ⏳'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }

    // TODO: Écouter Firebase pour savoir quand les deux joueurs sont prêts
    // TODO: puis naviguer vers l'écran de jeu principal
  }
}
