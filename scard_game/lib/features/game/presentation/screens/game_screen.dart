import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/game_constants.dart';
import '../../data/services/gameplay_action_service.dart';
import '../../data/services/game_session_service.dart';
import '../../data/services/player_service.dart';
import '../../data/services/turn_service.dart';
import '../../data/services/card_service.dart';
import '../../domain/models/game_session.dart';
import '../../domain/models/game_card.dart';
import '../../domain/models/player_data.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/card_color.dart';
import '../widgets/zones/opponent_zone_widget.dart';
import '../widgets/zones/play_zone_widget.dart';
import '../widgets/zones/player_zone_widget.dart';
import '../widgets/victory_screen_widget.dart';
import '../widgets/dialogs/rules_dialog.dart';
import '../widgets/dialogs/game_dialogs.dart';
import 'mixins/game_actions_mixin.dart';
import 'mixins/game_validation_mixin.dart';
import 'mixins/game_response_effects_mixin.dart';
import 'mixins/game_utils_mixin.dart';

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
        GameUtilsMixin {
  int? _selectedCardIndex;
  bool _hasShownValidationDialog = false;
  GamePhase? _lastPhase;
  bool _hasReceivedUltima = false;
  bool _isDiscardMode = false;
  bool _pendingCardValidation = false; // Carte jouée en attente de validation
  bool _hasShownRules = false; // Pour afficher les règles au lancement
  bool _hasShownNegotiationDialog = false;
  bool _autoDrawInProgress = false;
  bool _hasShownEnchantmentEffects = false;

  // Pour le drag & drop : carte en attente d'être jouée (affichée dans le slot)
  GameCard? _pendingDroppedCard;
  int? _pendingDroppedCardIndex;

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

  // Getters/setters pour le drag & drop
  @override
  GameCard? get pendingDroppedCard => _pendingDroppedCard;

  @override
  set pendingDroppedCard(GameCard? value) => _pendingDroppedCard = value;

  @override
  int? get pendingDroppedCardIndex => _pendingDroppedCardIndex;

  @override
  set pendingDroppedCardIndex(int? value) => _pendingDroppedCardIndex = value;

  /// Gère le drop d'une carte sur la zone de jeu
  /// Affiche immédiatement la carte dans le slot puis lance le processus de jeu
  void _handleCardDropped(int cardIndex, GameCard card) {
    setState(() {
      _pendingDroppedCard = card;
      _pendingDroppedCardIndex = cardIndex;
    });

    // Lancer le processus de jeu après un court délai pour laisser l'UI se mettre à jour
    Future.delayed(const Duration(milliseconds: 100), () async {
      final success = await playCardFromDrag(cardIndex, card);
      // Si échec (annulation de la sélection de palier, etc.), on nettoie
      // pour permettre à l'utilisateur de redrag la carte.
      // Si succès, la validation est automatique côté actions.
      if (mounted && !success) {
        setState(() {
          _pendingDroppedCard = null;
          _pendingDroppedCardIndex = null;
        });
      }
    });
  }

  /// Gère le retour d'une carte depuis la zone de jeu vers la main
  /// Si la carte est déjà dans Firebase (pendingCardValidation), appelle cancelPlayedCard
  void _handleCardReturnedToHand() {
    // Si la carte est déjà dans Firebase, il faut annuler l'action
    if (_pendingCardValidation) {
      // Appeler cancelPlayedCard qui va remettre la carte en main côté Firebase
      // et nettoyer l'état local via _clearPendingDropState
      cancelPlayedCard();
    } else {
      // La carte n'était pas encore dans Firebase, juste nettoyer l'état local
      setState(() {
        _pendingDroppedCard = null;
        _pendingDroppedCardIndex = null;
        _selectedCardIndex = null;
      });
    }
  }

  // Implémentation des méthodes requises par GameValidationMixin
  // showResponseEffectDialog est maintenant fourni par GameResponseEffectsMixin

  // deleteEnchantment est déjà défini dans GameActionsMixin, pas besoin de rediriger

  @override
  Widget build(BuildContext context) {
    final gameSessionService = ref.watch(gameSessionServiceProvider);

    return Scaffold(
      body: StreamBuilder<GameSession>(
        stream: gameSessionService.watchSession(widget.sessionId),
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

          if (session.currentPhase == GamePhase.draw &&
              isMyTurn &&
              !session.drawDoneThisTurn &&
              !_autoDrawInProgress) {
            _autoDrawInProgress = true;
            Future.microtask(() => _autoDrawAtTurnStart());
          }

          if (session.currentPhase == GamePhase.draw &&
              isMyTurn &&
              !_hasShownEnchantmentEffects) {
            _hasShownEnchantmentEffects = true;
            Future.microtask(() => _maybeShowEnchantmentEffects(session));
          }

          if (session.currentPhase == GamePhase.draw &&
              isMyTurn &&
              session.drawDoneThisTurn &&
              !session.enchantmentEffectsDoneThisTurn &&
              !_autoDrawInProgress) {
            Future.microtask(() => _applyRecurringEnchantmentEffects());
          }

          // PHASE ENCHANTEMENT & PIOCHE : Passage automatique
          // Le joueur passe directement en phase Main après la pioche et la popup enchantements

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
            if (session.currentPhase != GamePhase.response) {
              _hasShownNegotiationDialog = false;
            }
            if (session.currentPhase != GamePhase.draw) {
              _hasShownEnchantmentEffects = false;
            }
          }

          if (session.currentPhase == GamePhase.response &&
              session.resolutionStack.length < 2) {
            _hasShownNegotiationDialog = false;
          }

          // ULTIMA : Donner automatiquement la carte Ultima à 100% de tension
          if (myData.tension >= 100 && !_hasReceivedUltima) {
            // Vérifier si le joueur n'a pas déjà Ultima en main ou en jeu
            final hasUltimaInHand = myData.handCardIds.contains(
              GameConstants.ultimaCardId,
            );
            final hasUltimaInPlay = myData.activeEnchantmentIds.contains(
              GameConstants.ultimaCardId,
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

          if (session.currentPhase == GamePhase.response &&
              session.resolutionStack.length > 1 &&
              isMyTurn) {
            Future.microtask(() => _maybeShowNegotiationDialog(session));
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2F87B8),
                  Color(0xFF2E6EA5),
                  Color(0xFF2C4D85),
                ],
                stops: [0.0, 0.58, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.2),
                          radius: 1.05,
                          colors: [
                            Colors.white.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.18),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.30),
                          ],
                          stops: const [0.0, 0.38, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
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
                          onCardDropped: _handleCardDropped,
                          onCardReturnedToHand: _handleCardReturnedToHand,
                          pendingCard: _pendingDroppedCard,
                          pendingCardValidation: _pendingCardValidation,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Ma zone (en bas)
                      PlayerZoneWidget(
                        myData: myData,
                        isMyTurn: isMyTurn,
                        session: session,
                        selectedCardIndex: _selectedCardIndex,
                        isDiscardMode: _isDiscardMode,
                        onSelectCard:
                            (index) => selectCard(index, _selectedCardIndex),
                        remainingDeckCards: myData.deckCardIds.length,
                        onEndTurn: skipTurn,
                        onAcceptResponse: skipResponse,
                        canEndTurn:
                            isMyTurn && session.currentPhase == GamePhase.main,
                        onIncrementPI: incrementPI,
                        onDecrementPI: decrementPI,
                        onManualDrawCard: manualDrawCard,
                        onShowDeleteEnchantmentDialog:
                            showDeleteEnchantmentDialog,
                        onCardDragged: _handleCardDropped,
                        onCardReturnedFromPlayZone: _handleCardReturnedToHand,
                        pendingCardIndex: _pendingDroppedCardIndex,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _maybeShowNegotiationDialog(GameSession session) async {
    if (_hasShownNegotiationDialog || !mounted) return;
    if (session.currentPlayerId != widget.playerId) return;
    if (session.resolutionStack.length < 2) return;

    final cardService = ref.read(cardServiceProvider);
    final allCards = await cardService.loadAllCards();
    final responseCardId = session.resolutionStack.last;
    final responseCard = allCards.firstWhere(
      (c) => c.id == responseCardId,
      orElse: () => allCards.first,
    );

    if (responseCard.color != CardColor.green) return;

    _hasShownNegotiationDialog = true;
    if (!mounted) return;
    final agreement = await GameDialogs.showNegotiationDialog(context);
    if (agreement != null) {
      await resolveNegotiation(agreement);
    }
  }

  Future<void> _maybeShowEnchantmentEffects(GameSession session) async {
    if (!mounted) return;
    if (session.currentPlayerId != widget.playerId) return;

    final cardService = ref.read(cardServiceProvider);
    final allCards = await cardService.loadAllCards();

    final notices = <_EnchantmentEffectNotice>[];
    final actionables = <_EnchantmentActionNotice>[];

    void addNoticesForOwner(String ownerId, List<String> enchantmentIds) {
      for (final id in enchantmentIds) {
        final card = allCards.firstWhere(
          (c) => c.id == id,
          orElse: () => allCards.first,
        );
        if (!card.isEnchantment) continue;

        final ownerIsPlayer1 = session.player1Id == ownerId;
        final ownerData =
            ownerIsPlayer1 ? session.player1Data : session.player2Data!;
        final storedTier = ownerData.activeEnchantmentTiers[id];
        final tierKey =
            storedTier ??
            (card.enchantmentTargets.length == 1
                ? card.enchantmentTargets.keys.first
                : _tierKeyFromTension(ownerData.tension));
        final target =
            card.enchantmentTargets[tierKey] ??
            (card.enchantmentTargets.length == 1
                ? card.enchantmentTargets.values.first
                : null);

        if (!_shouldShowEnchantmentEffect(
          target,
          ownerId,
          session.currentPlayerId!,
        )) {
          continue;
        }

        final effectText = _effectTextForTier(card.gameEffect, tierKey);
        notices.add(
          _EnchantmentEffectNotice(cardName: card.name, effectText: effectText),
        );

        for (final effect in card.recurringEffects) {
          final trigger = effect['trigger'];
          final effectTier = effect['tier'];
          if (trigger != 'turn_start') continue;
          if (effectTier != null && effectTier != tierKey) continue;

          final effectType = effect['effect']?.toString();
          if (effectType != 'require_action') continue;

          final target = effect['target']?.toString();
          if (!_shouldShowEnchantmentEffect(
            target,
            ownerId,
            session.currentPlayerId!,
          )) {
            continue;
          }

          final actionText =
              (effect['value'] is String &&
                      (effect['value'] as String).isNotEmpty)
                  ? effect['value'] as String
                  : effectText;
          final blockOnRefusal = effect['blockOnRefusal'] == true;
          actionables.add(
            _EnchantmentActionNotice(
              ownerId: ownerId,
              cardName: card.name,
              actionText: actionText,
              blockOnRefusal: blockOnRefusal,
            ),
          );
        }
      }
    }

    addNoticesForOwner(
      session.player1Id,
      session.player1Data.activeEnchantmentIds,
    );
    if (session.player2Id != null && session.player2Data != null) {
      addNoticesForOwner(
        session.player2Id!,
        session.player2Data!.activeEnchantmentIds,
      );
    }

    // Si pas d'enchantements à afficher, passer directement en phase Main
    if (notices.isEmpty) {
      final turnService = ref.read(turnServiceProvider);
      await turnService.nextPhase(sessionId);
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF2d4263), const Color(0xFF1a2332)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF6DD5FA).withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6DD5FA).withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6DD5FA).withValues(alpha: 0.3),
                        const Color(0xFF6DD5FA).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6DD5FA).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF6DD5FA),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Enchantements actifs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final notice in notices) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notice.cardName,
                                  style: const TextStyle(
                                    color: Color(0xFF6DD5FA),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notice.effectText,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6DD5FA,
                        ).withValues(alpha: 0.25),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: const Color(
                              0xFF6DD5FA,
                            ).withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6DD5FA),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    for (final action in actionables) {
      if (!mounted) return;
      final completed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            backgroundColor: const Color(0xFF2d4263),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF6DD5FA), width: 2),
            ),
            title: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Color(0xFF6DD5FA)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Action enchantement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                action.actionText,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6DD5FA,
                        ).withValues(alpha: 0.25),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Oui',
                        style: TextStyle(
                          color: Color(0xFF6DD5FA),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.20),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Non',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      if (completed == false && action.blockOnRefusal) {
        final turnService = ref.read(turnServiceProvider);
        await turnService.forceTurnToPlayer(sessionId, action.ownerId);
        return;
      }
    }

    // Après la popup des enchantements, passer automatiquement en phase Main
    if (mounted) {
      final turnService = ref.read(turnServiceProvider);
      await turnService.nextPhase(sessionId);
    }
  }

  String _tierKeyFromTension(double tension) {
    if (tension >= 75) return 'red';
    if (tension >= 50) return 'yellow';
    if (tension >= 25) return 'blue';
    return 'white';
  }

  String _effectTextForTier(String gameEffect, String tierKey) {
    final label = switch (tierKey) {
      'white' => 'Blanc',
      'blue' => 'Bleu',
      'yellow' => 'Jaune',
      'red' => 'Rouge',
      _ => '',
    };
    final lines =
        gameEffect
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
    for (final line in lines) {
      if (line.toLowerCase().startsWith('${label.toLowerCase()}:')) {
        return line.substring(line.indexOf(':') + 1).trim();
      }
    }
    return gameEffect;
  }

  bool _shouldShowEnchantmentEffect(
    String? target,
    String ownerId,
    String currentPlayerId,
  ) {
    switch (target) {
      case 'owner':
        return ownerId == currentPlayerId;
      case 'opponent':
        return ownerId != currentPlayerId;
      case 'both':
        return true;
    }
    return false;
  }

  Future<void> _applyRecurringEnchantmentEffects() async {
    final turnService = ref.read(turnServiceProvider);
    final gameSessionService = ref.read(gameSessionServiceProvider);
    final cardService = ref.read(cardServiceProvider);
    final gameplayActionService = ref.read(gameplayActionServiceProvider);
    final playerService = ref.read(playerServiceProvider);

    try {
      await turnService.setEnchantmentEffectsDoneThisTurn(sessionId, true);
      final session = await gameSessionService.getSession(sessionId);
      if (session.currentPlayerId != widget.playerId) return;

      final allCards = await cardService.loadAllCards();

      Future<void> applyForOwner(
        String ownerId,
        List<String> enchantmentIds,
      ) async {
        final ownerIsPlayer1 = session.player1Id == ownerId;
        final ownerData =
            ownerIsPlayer1 ? session.player1Data : session.player2Data!;
        for (final id in enchantmentIds) {
          final card = allCards.firstWhere(
            (c) => c.id == id,
            orElse: () => allCards.first,
          );
          if (!card.isEnchantment) continue;

          final tierKey =
              ownerData.activeEnchantmentTiers[id] ??
              (card.enchantmentTargets.length == 1
                  ? card.enchantmentTargets.keys.first
                  : _tierKeyFromTension(ownerData.tension));

          for (final effect in card.recurringEffects) {
            final trigger = effect['trigger'];
            final effectTier = effect['tier'];
            if (trigger != 'turn_start') continue;
            if (effectTier != null && effectTier != tierKey) continue;

            if (!_effectConditionMet(
              effect['condition'],
              ownerId,
              session.currentPlayerId!,
              session,
            )) {
              continue;
            }

            final target = effect['target'];
            final effectType = effect['effect'];
            final value = effect['value'];

            final targetPlayerId = _resolveTargetPlayerId(
              target?.toString(),
              ownerId,
              session.currentPlayerId!,
            );
            if (targetPlayerId == null) continue;

            if (effectType == 'draw' && value is int && value > 0) {
              for (int i = 0; i < value; i++) {
                await gameplayActionService.drawCard(sessionId, targetPlayerId);
              }
            } else if (effectType == 'pi_change' && value is int) {
              await playerService.updatePlayerPI(
                sessionId,
                targetPlayerId,
                value,
              );
            } else if (effectType == 'tension_change' &&
                (value is int || value is double)) {
              final delta = value is int ? value.toDouble() : value as double;
              await playerService.updatePlayerTension(
                sessionId,
                targetPlayerId,
                delta,
              );
            } else if (effectType == 'tension_decrease' &&
                (value is int || value is double)) {
              final delta = value is int ? value.toDouble() : value as double;
              await playerService.updatePlayerTension(
                sessionId,
                targetPlayerId,
                -delta.abs(),
              );
            } else if (effectType == 'require_action') {
              // Effet manuel : affiché via la popup, pas d'automatisation
            }
          }
        }
      }

      await applyForOwner(
        session.player1Id,
        session.player1Data.activeEnchantmentIds,
      );
      if (session.player2Id != null && session.player2Data != null) {
        await applyForOwner(
          session.player2Id!,
          session.player2Data!.activeEnchantmentIds,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur enchantements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _resolveTargetPlayerId(
    String? target,
    String ownerId,
    String currentPlayerId,
  ) {
    switch (target) {
      case 'owner':
        return ownerId == currentPlayerId ? ownerId : null;
      case 'opponent':
        return ownerId == currentPlayerId ? null : currentPlayerId;
      case 'both':
        return currentPlayerId;
    }
    return null;
  }

  bool _effectConditionMet(
    dynamic condition,
    String ownerId,
    String currentPlayerId,
    GameSession session,
  ) {
    if (condition == null) return true;
    if (condition is! Map) return false;

    final type = condition['type']?.toString();
    final value = condition['value'];

    final ownerData = _playerDataById(session, ownerId);
    final currentData = _playerDataById(session, currentPlayerId);
    final opponentId =
        ownerId == session.player1Id ? session.player2Id : session.player1Id;
    final opponentData =
        opponentId != null ? _playerDataById(session, opponentId) : null;

    switch (type) {
      case 'owner_is_naked':
        return ownerData?.isNaked == (value == true);
      case 'opponent_is_naked':
        return opponentData?.isNaked == (value == true);
      case 'owner_pi_below':
        return ownerData != null &&
            value is int &&
            ownerData.inhibitionPoints < value;
      case 'opponent_pi_below':
        return opponentData != null &&
            value is int &&
            opponentData.inhibitionPoints < value;
      case 'owner_pi_above':
        return ownerData != null &&
            value is int &&
            ownerData.inhibitionPoints > value;
      case 'opponent_pi_above':
        return opponentData != null &&
            value is int &&
            opponentData.inhibitionPoints > value;
      case 'owner_can_draw':
        return ownerData != null && ownerData.deckCardIds.isNotEmpty;
      case 'opponent_can_draw':
        return opponentData != null && opponentData.deckCardIds.isNotEmpty;
      case 'current_can_draw':
        return currentData != null && currentData.deckCardIds.isNotEmpty;
    }

    return false;
  }

  PlayerData? _playerDataById(GameSession session, String playerId) {
    if (session.player1Id == playerId) return session.player1Data;
    if (session.player2Id == playerId) return session.player2Data;
    return null;
  }

  Future<void> _autoDrawAtTurnStart() async {
    final gameplayActionService = ref.read(gameplayActionServiceProvider);
    final turnService = ref.read(turnServiceProvider);

    try {
      // Marquer d'abord pour ?viter les doubles d?clenchements
      await turnService.setDrawDoneThisTurn(sessionId, true);
      await gameplayActionService.drawCard(sessionId, playerId);
    } catch (e) {
      await turnService.setDrawDoneThisTurn(sessionId, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('Deck vide')
                  ? '?? Deck vide - pioche impossible'
                  : '? Erreur pioche auto: $e',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      _autoDrawInProgress = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _EnchantmentEffectNotice {
  final String cardName;
  final String effectText;

  const _EnchantmentEffectNotice({
    required this.cardName,
    required this.effectText,
  });
}

class _EnchantmentActionNotice {
  final String ownerId;
  final String cardName;
  final String actionText;
  final bool blockOnRefusal;

  const _EnchantmentActionNotice({
    required this.ownerId,
    required this.cardName,
    required this.actionText,
    required this.blockOnRefusal,
  });
}
