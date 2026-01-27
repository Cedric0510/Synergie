import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/firebase_service.dart';
import '../../domain/models/game_session.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/enums/game_status.dart';
import '../widgets/zones/opponent_zone_widget.dart';
import '../widgets/zones/play_zone_widget.dart';
import '../widgets/zones/player_zone_widget.dart';
import '../widgets/victory_screen_widget.dart';
import '../widgets/dialogs/rules_dialog.dart';
import 'mixins/game_actions_mixin.dart';
import 'mixins/game_validation_mixin.dart';
import 'mixins/game_response_effects_mixin.dart';
import 'mixins/game_utils_mixin.dart';
import 'mixins/game_ui_mixin.dart';

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

class _GameScreenState extends ConsumerState<GameScreen>
    with
        GameActionsMixin,
        GameValidationMixin,
        GameResponseEffectsMixin,
        GameUtilsMixin,
        GameUIMixin {
  int? _selectedCardIndex;
  bool _hasShownValidationDialog = false;
  GamePhase? _lastPhase;
  bool _hasReceivedUltima = false;
  bool _isDiscardMode = false;
  bool _pendingCardValidation = false; // Carte jouée en attente de validation
  bool _hasShownRules = false; // Pour afficher les règles au lancement

  @override
  void initState() {
    super.initState();
    // Afficher les règles au lancement après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasShownRules) {
        _hasShownRules = true;
        RulesDialog.show(context);
      }
    });
  }

  // Implémentation des getters/setters requis par GameActionsMixin
  @override
  String get sessionId => widget.sessionId;

  @override
  String get playerId => widget.playerId;

  @override
  int? get selectedCardIndex => _selectedCardIndex;

  @override
  set selectedCardIndex(int? value) => _selectedCardIndex = value;

  @override
  bool get pendingCardValidation => _pendingCardValidation;

  @override
  set pendingCardValidation(bool value) => _pendingCardValidation = value;

  @override
  bool get isDiscardMode => _isDiscardMode;

  @override
  set isDiscardMode(bool value) => _isDiscardMode = value;

  // Implémentation des méthodes requises par GameValidationMixin
  // showResponseEffectDialog est maintenant fourni par GameResponseEffectsMixin

  // deleteEnchantment est déjà défini dans GameActionsMixin, pas besoin de rediriger

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
            // Elles seront exécutées dans handleResponseEffect() après validation
            Future.microtask(() => showValidationDialog());
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
              Future.microtask(() => giveUltimaCard());
            }
          }

          // Réinitialiser le flag si la tension redescend sous 100%
          if (myData.tension < 100) {
            _hasReceivedUltima = false;
          }

          // === VÉRIFICATION VICTOIRE ULTIMA ===
          if (session.status == GameStatus.finished &&
              session.winnerId != null) {
            return VictoryScreenWidget(
              session: session,
              playerId: widget.playerId,
            );
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
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      // Zone adversaire (en haut)
                      OpponentZoneWidget(opponentData: opponentData),

                      const SizedBox(height: 8),

                      // Zone de jeu centrale
                      Expanded(
                        child: PlayZoneWidget(
                          session: session,
                          isMyTurn: isMyTurn,
                          playerId: widget.playerId,
                          onSkipResponse: skipResponse,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // BOUTONS D'ACTION (en pleine largeur pour toutes les versions)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: buildMobileActionButtons(session, isMyTurn),
                      ),

                      // Ma zone (en bas)
                      PlayerZoneWidget(
                        myData: myData,
                        isMyTurn: isMyTurn,
                        session: session,
                        selectedCardIndex: _selectedCardIndex,
                        isDiscardMode: _isDiscardMode,
                        onSelectCard:
                            (index) => selectCard(index, _selectedCardIndex),
                        onIncrementPI: incrementPI,
                        onDecrementPI: decrementPI,
                        onManualDrawCard: manualDrawCard,
                        onShowDeleteEnchantmentDialog:
                            showDeleteEnchantmentDialog,
                      ),
                    ],
                  ),
                ),

                // Bouton "?" pour réouvrir les règles (en haut à droite)
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => RulesDialog.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.15),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
