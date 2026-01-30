import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/game_session.dart';
import '../../domain/models/player_data.dart';
import '../../domain/enums/player_gender.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/enums/response_effect.dart';

/// Provider pour le service Firebase
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Service de gestion Firebase (Firestore + Auth)
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // Exposer firestore pour CardEffectService
  FirebaseFirestore get firestore => _firestore;

  /// Connexion anonyme
  Future<String> signInAnonymously() async {
    try {
      // Vérifier si l'utilisateur est déjà connecté
      if (_auth.currentUser != null) {
        return _auth.currentUser!.uid;
      }

      // Sinon, créer une nouvelle connexion anonyme
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user!.uid;
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Génère un code de partie unique (6 caractères)
  String _generateGameCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Sans I, O, 0, 1
    final random = _uuid.v4().replaceAll('-', '');
    return List.generate(
      6,
      (i) => chars[random.codeUnitAt(i) % chars.length],
    ).join();
  }

  /// Crée une nouvelle partie
  Future<GameSession> createGame({
    required String playerName,
    required PlayerGender playerGender,
  }) async {
    try {
      // Connexion anonyme
      final playerId = await signInAnonymously();

      // Génération code unique
      String gameCode;
      bool codeExists = true;

      do {
        gameCode = _generateGameCode();
        final doc =
            await _firestore.collection('game_sessions').doc(gameCode).get();
        codeExists = doc.exists;
      } while (codeExists);

      // Création des données joueur
      final playerData = PlayerData(
        playerId: playerId,
        name: playerName,
        gender: playerGender,
        isReady: false,
        connectedAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );

      // Création de la session
      final session = GameSession.create(
        sessionId: gameCode,
        player1Id: playerId,
        player1Data: playerData,
      );

      // Sauvegarde dans Firestore avec conversion manuelle des PlayerData
      final sessionJson = session.toJson();
      sessionJson['player1Data'] = playerData.toJson();

      await _firestore
          .collection('game_sessions')
          .doc(gameCode)
          .set(sessionJson);

      return session;
    } catch (e) {
      throw Exception('Erreur lors de la création de la partie: $e');
    }
  }

  /// Rejoindre une partie existante
  Future<GameSession> joinGame({
    required String gameCode,
    required String playerName,
    required PlayerGender playerGender,
  }) async {
    try {
      // Connexion anonyme
      final playerId = await signInAnonymously();

      // Vérifier que la partie existe
      final docRef = _firestore
          .collection('game_sessions')
          .doc(gameCode.toUpperCase());
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Code de partie invalide');
      }

      final session = GameSession.fromJson(doc.data()!);

      if (session.player2Id != null) {
        throw Exception('Cette partie est déjà complète');
      }

      // Création des données joueur 2
      final playerData = PlayerData(
        playerId: playerId,
        name: playerName,
        gender: playerGender,
        isReady: false,
        connectedAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );

      // Mise à jour de la session
      final updatedSession = session.copyWith(
        player2Id: playerId,
        player2Data: playerData,
        status: GameStatus.waiting,
        updatedAt: DateTime.now(),
      );

      await docRef.update({
        'player2Id': updatedSession.player2Id,
        'player2Data': playerData.toJson(),
        'status': updatedSession.status.name,
        'updatedAt': updatedSession.updatedAt?.toIso8601String(),
      });

      return updatedSession;
    } catch (e) {
      throw Exception('Erreur lors de la connexion à la partie: $e');
    }
  }

  /// Récupère une session de jeu (une seule fois)
  Future<GameSession> getGameSession(String sessionId) async {
    final doc =
        await _firestore.collection('game_sessions').doc(sessionId).get();
    if (!doc.exists) {
      throw Exception('Session introuvable');
    }
    return GameSession.fromJson(doc.data()!);
  }

  /// Stream temps réel de la session
  Stream<GameSession> watchGameSession(String sessionId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw Exception('Session introuvable');
          }
          return GameSession.fromJson(doc.data()!);
        });
  }

  /// Met à jour l'activité du joueur (heartbeat)
  Future<void> updatePlayerActivity(String sessionId, String playerId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final session = GameSession.fromJson(doc.data()!);
    final now = DateTime.now();

    if (session.player1Id == playerId) {
      await docRef.update({
        'player1Data.lastActivityAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
    } else if (session.player2Id == playerId) {
      await docRef.update({
        'player2Data.lastActivityAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
    }
  }

  /// Marque le joueur comme prêt
  Future<void> setPlayerReady(
    String sessionId,
    String playerId,
    bool ready,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final session = GameSession.fromJson(doc.data()!);
    final isPlayer1 = session.player1Id == playerId;
    final now = DateTime.now();
    GameSession updatedSession;

    if (session.player1Id == playerId) {
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(isReady: ready),
        updatedAt: now,
      );
    } else if (session.player2Id == playerId) {
      updatedSession = session.copyWith(
        player2Data: session.player2Data?.copyWith(isReady: ready),
        updatedAt: now,
      );
    } else {
      return; // Joueur inconnu
    }

    // Conversion manuelle
    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
        'updatedAt': now.toIso8601String(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
        'updatedAt': now.toIso8601String(),
      });
    }
  }

  /// Détermine quel joueur commence
  Future<void> determineStartingPlayer(String sessionId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final session = GameSession.fromJson(doc.data()!);

    if (session.player1Data == null || session.player2Data == null) return;

    String startingPlayerId;

    // Si sexes différents, la femme commence
    if (session.player1Data!.gender != session.player2Data!.gender) {
      if (session.player1Data!.gender == PlayerGender.female) {
        startingPlayerId = session.player1Id;
      } else if (session.player2Data!.gender == PlayerGender.female) {
        startingPlayerId = session.player2Id!;
      } else {
        // Si aucun n'est female, tirage aléatoire
        startingPlayerId =
            DateTime.now().millisecond % 2 == 0
                ? session.player1Id
                : session.player2Id!;
      }
    } else {
      // Même sexe : tirage aléatoire
      startingPlayerId =
          DateTime.now().millisecond % 2 == 0
              ? session.player1Id
              : session.player2Id!;
    }

    await docRef.update({
      'currentPlayerId': startingPlayerId,
      'status': GameStatus.playing.name,
      'startedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Sauvegarde les cartes du joueur (main et deck)
  Future<void> updatePlayerCards({
    required String sessionId,
    required String playerId,
    required List<String> handCardIds,
    required List<String> deckCardIds,
  }) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final session = GameSession.fromJson(doc.data()!);
    final isPlayer1 = session.player1Id == playerId;
    final now = DateTime.now();
    GameSession updatedSession;

    if (session.player1Id == playerId) {
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(
          handCardIds: handCardIds,
          deckCardIds: deckCardIds,
        ),
        updatedAt: now,
      );
    } else if (session.player2Id == playerId) {
      updatedSession = session.copyWith(
        player2Data: session.player2Data?.copyWith(
          handCardIds: handCardIds,
          deckCardIds: deckCardIds,
        ),
        updatedAt: now,
      );
    } else {
      return; // Joueur inconnu
    }

    // Conversion manuelle
    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
        'updatedAt': now.toIso8601String(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
        'updatedAt': now.toIso8601String(),
      });
    }
  }

  /// Marque le joueur comme ayant vu ses cartes de départ et prêt à jouer
  Future<void> setPlayerCardsReady(String sessionId, String playerId) async {
    await setPlayerReady(sessionId, playerId, true);
  }

  /// Passer à la phase suivante du jeu
  Future<void> nextPhase(String sessionId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    GamePhase nextPhase;
    String? nextPlayerId;

    switch (session.currentPhase) {
      case GamePhase.draw:
        nextPhase = GamePhase.main;
        nextPlayerId = session.currentPlayerId;
        break;
      case GamePhase.main:
        nextPhase = GamePhase.response;
        nextPlayerId = session.currentPlayerId;
        break;
      case GamePhase.response:
        nextPhase = GamePhase.resolution;
        nextPlayerId = session.currentPlayerId;
        break;
      case GamePhase.resolution:
        nextPhase = GamePhase.end;
        nextPlayerId = session.currentPlayerId;
        break;
      case GamePhase.end:
        // Passer au tour de l'adversaire
        nextPhase = GamePhase.draw;
        nextPlayerId =
            session.currentPlayerId == session.player1Id
                ? session.player2Id
                : session.player1Id;
        break;
    }

    // === RESET FLAG SACRIFICE AU DÉBUT DU NOUVEAU TOUR ===
    PlayerData? updatedPlayer1Data;
    PlayerData? updatedPlayer2Data;

    if (session.currentPhase == GamePhase.end && nextPhase == GamePhase.draw) {
      // Nouveau tour : réinitialiser le flag de sacrifice pour les deux joueurs
      updatedPlayer1Data = session.player1Data.copyWith(
        hasSacrificedThisTurn: false,
      );
      updatedPlayer2Data = session.player2Data?.copyWith(
        hasSacrificedThisTurn: false,
      );
    }

    // === GESTION COMPTEUR ULTIMA ===
    int newUltimaTurnCount = session.ultimaTurnCount;
    String? newWinnerId = session.winnerId;
    GameStatus newStatus = session.status;

    // Si on passe en phase end ET qu'un joueur a le compteur Ultima actif
    if (session.currentPhase == GamePhase.resolution &&
        nextPhase == GamePhase.end) {
      if (session.ultimaOwnerId != null) {
        // Vérifier que le joueur qui a le compteur a toujours Ultima en jeu
        final isOwnerPlayer1 = session.ultimaOwnerId == session.player1Id;
        final ownerData =
            isOwnerPlayer1 ? session.player1Data : session.player2Data!;
        final ownerHasUltima = ownerData.activeEnchantmentIds.any(
          (id) => id.contains('red_016'),
        );

        if (ownerHasUltima) {
          // Incrémenter le compteur
          newUltimaTurnCount = session.ultimaTurnCount + 1;

          // Vérifier si le compteur atteint 3
          if (newUltimaTurnCount >= 3) {
            newWinnerId = session.ultimaOwnerId;
            newStatus = GameStatus.finished;
          }
        }
      }
    }

    await docRef.update({
      'currentPhase': nextPhase.name,
      'currentPlayerId': nextPlayerId,
      'ultimaTurnCount': newUltimaTurnCount,
      'winnerId': newWinnerId,
      'status': newStatus.name,
      if (nextPhase == GamePhase.draw) 'drawDoneThisTurn': false,
      if (nextPhase == GamePhase.draw) 'enchantmentEffectsDoneThisTurn': false,
      if (updatedPlayer1Data != null)
        'player1Data': updatedPlayer1Data.toJson(),
      if (updatedPlayer2Data != null)
        'player2Data': updatedPlayer2Data.toJson(),
    });
  }

  /// Piocher une carte (phase draw)
  Future<void> drawCard(String sessionId, String playerId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;
    if (_isTensionLocked(playerData)) {
      return;
    }

    GameSession updatedSession;
    if (isPlayer1) {
      final deck = List<String>.from(session.player1Data.deckCardIds);
      final hand = List<String>.from(session.player1Data.handCardIds);

      if (deck.isEmpty) {
        throw Exception('Deck vide - impossible de piocher');
      }

      final drawnCard = deck.removeAt(0);
      hand.add(drawnCard);

      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(
          deckCardIds: deck,
          handCardIds: hand,
        ),
      );
    } else {
      final deck = List<String>.from(session.player2Data!.deckCardIds);
      final hand = List<String>.from(session.player2Data!.handCardIds);

      if (deck.isEmpty) {
        throw Exception('Deck vide - impossible de piocher');
      }

      final drawnCard = deck.removeAt(0);
      hand.add(drawnCard);

      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(
          deckCardIds: deck,
          handCardIds: hand,
        ),
      );
    }

    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Marque la pioche automatique comme effectu?e pour ce tour
  Future<void> setDrawDoneThisTurn(
    String sessionId,
    bool value,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.update({'drawDoneThisTurn': value});
  }

  /// Marque les effets d'enchantements comme appliqués pour ce tour
  Future<void> setEnchantmentEffectsDoneThisTurn(
    String sessionId,
    bool value,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.update({'enchantmentEffectsDoneThisTurn': value});
  }

  Future<void> forceTurnToPlayer(String sessionId, String playerId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.update({
      'currentPlayerId': playerId,
      'currentPhase': GamePhase.draw.name,
      'drawDoneThisTurn': false,
      'enchantmentEffectsDoneThisTurn': false,
    });
  }


  /// Piocher une carte d'une couleur spécifique (pour déblocage de niveau)
  Future<bool> drawCardOfColor(
    String sessionId,
    String playerId,
    String color,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;

    // Charger toutes les cartes pour vérifier la couleur
    final cardsSnapshot = await _firestore.collection('cards').get();
    final cardsMap = {for (var doc in cardsSnapshot.docs) doc.id: doc.data()};

    GameSession updatedSession;
    if (isPlayer1) {
      final deck = List<String>.from(session.player1Data.deckCardIds);
      final hand = List<String>.from(session.player1Data.handCardIds);

      // Trouver l'index de la première carte de la couleur spécifiée
      int cardIndex = -1;
      for (int i = 0; i < deck.length; i++) {
        final cardData = cardsMap[deck[i]];
        if (cardData != null && cardData['color'] == color) {
          cardIndex = i;
          break;
        }
      }

      // Si aucune carte de cette couleur, piocher normalement
      if (cardIndex == -1 || deck.isEmpty) {
        if (deck.isEmpty) return false;
        cardIndex = 0; // Piocher la première carte du deck
      }

      final drawnCard = deck.removeAt(cardIndex);
      hand.add(drawnCard);

      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(
          deckCardIds: deck,
          handCardIds: hand,
        ),
      );
    } else {
      final deck = List<String>.from(session.player2Data!.deckCardIds);
      final hand = List<String>.from(session.player2Data!.handCardIds);

      // Trouver l'index de la première carte de la couleur spécifiée
      int cardIndex = -1;
      for (int i = 0; i < deck.length; i++) {
        final cardData = cardsMap[deck[i]];
        if (cardData != null && cardData['color'] == color) {
          cardIndex = i;
          break;
        }
      }

      // Si aucune carte de cette couleur, piocher normalement
      if (cardIndex == -1 || deck.isEmpty) {
        if (deck.isEmpty) return false;
        cardIndex = 0; // Piocher la première carte du deck
      }

      final drawnCard = deck.removeAt(cardIndex);
      hand.add(drawnCard);

      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(
          deckCardIds: deck,
          handCardIds: hand,
        ),
      );
    }

    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
    return true;
  }

  /// Jouer une carte
  Future<void> playCard(
    String sessionId,
    String playerId,
    int cardIndex, {
    String? enchantmentTierKey,
  }) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;

    final updatedPlayedCardTiers = Map<String, String>.from(
      session.playedCardTiers,
    );
    GameSession updatedSession;
    if (isPlayer1) {
      final hand = List<String>.from(session.player1Data.handCardIds);

      if (cardIndex < 0 || cardIndex >= hand.length) {
        throw Exception('Index de carte invalide');
      }

      final playedCard = hand.removeAt(cardIndex);
      final playedCards = List<String>.from(session.player1Data.playedCardIds);
      playedCards.add(playedCard);

      if (enchantmentTierKey != null) {
        updatedPlayedCardTiers[playedCard] = enchantmentTierKey;
      }
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(
          handCardIds: hand,
          playedCardIds: playedCards,
        ),
        resolutionStack: [...session.resolutionStack, playedCard],
        playedCardTiers: updatedPlayedCardTiers,
      );
    } else {
      final hand = List<String>.from(session.player2Data!.handCardIds);

      if (cardIndex < 0 || cardIndex >= hand.length) {
        throw Exception('Index de carte invalide');
      }

      final playedCard = hand.removeAt(cardIndex);
      final playedCards = List<String>.from(session.player2Data!.playedCardIds);
      playedCards.add(playedCard);

      if (enchantmentTierKey != null) {
        updatedPlayedCardTiers[playedCard] = enchantmentTierKey;
      }
      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(
          handCardIds: hand,
          playedCardIds: playedCards,
        ),
        resolutionStack: [...session.resolutionStack, playedCard],
        playedCardTiers: updatedPlayedCardTiers,
      );
    }

    await docRef.update({
      if (isPlayer1) 'player1Data': updatedSession.player1Data.toJson(),
      if (!isPlayer1) 'player2Data': updatedSession.player2Data!.toJson(),
      'resolutionStack': updatedSession.resolutionStack,
      'playedCardTiers': updatedSession.playedCardTiers,
    });
  }

  /// Sacrifier une carte (sans bonus de tension, géré séparément)
  /// Sacrifice une carte : retourne au bas du deck, +2% tension, pioche 1, fin de tour
  /// Limite : 1 sacrifice par tour. Ultima ne peut pas être sacrifiée (→ perte)
  Future<void> sacrificeCard(
    String sessionId,
    String playerId,
    int cardIndex,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    // Vérifier si déjà sacrifié ce tour
    if (playerData.hasSacrificedThisTurn) {
      throw Exception('Vous avez déjà sacrifié une carte ce tour !');
    }

    final hand = List<String>.from(playerData.handCardIds);

    if (cardIndex < 0 || cardIndex >= hand.length) {
      throw Exception('Index de carte invalide');
    }

    final sacrificedCard = hand.removeAt(cardIndex);

    // RÈGLE SPÉCIALE ULTIMA : Sacrifice interdit → Perte de la partie
    if (sacrificedCard.contains('red_016')) {
      // Déclarer l'adversaire comme gagnant
      final winnerId = isPlayer1 ? session.player2Id : session.player1Id;
      await docRef.update({
        'winnerId': winnerId,
        'status': GameStatus.finished.name,
      });
      throw Exception('❌ ULTIMA SACRIFIÉE ! Vous avez perdu la partie !');
    }

    // Retourner la carte au BAS du deck
    final deck = List<String>.from(playerData.deckCardIds);
    deck.add(sacrificedCard); // Ajout à la fin (pas mélangée)

    // +2% tension
    final newTension = (playerData.tension + 2.0).clamp(0.0, 100.0);

    // Piocher 1 carte
    String? drawnCard;
    if (deck.isNotEmpty) {
      drawnCard = deck.removeAt(0);
      hand.add(drawnCard);
    }

    // Mettre à jour les données joueur qui a sacrifié
    // RESET le flag sacrifice car c'est la fin du tour
    final updatedPlayerData = playerData.copyWith(
      handCardIds: hand,
      deckCardIds: deck,
      tension: newTension,
      hasSacrificedThisTurn: false, // Reset car fin de tour
    );

    // L'adversaire aussi doit avoir son flag reset
    final otherPlayerData =
        isPlayer1 ? session.player2Data : session.player1Data;
    final updatedOtherPlayerData = otherPlayerData?.copyWith(
      hasSacrificedThisTurn: false,
    );

    // Déterminer le joueur suivant (adversaire)
    final nextPlayerId = isPlayer1 ? session.player2Id : session.player1Id;

    // Construire la session avec TOUTES les modifications en une seule fois
    final updatedSession = session.copyWith(
      player1Data:
          isPlayer1
              ? updatedPlayerData
              : (updatedOtherPlayerData ?? session.player1Data),
      player2Data: isPlayer1 ? updatedOtherPlayerData : updatedPlayerData,
      currentPhase:
          GamePhase.draw, // Directement en phase draw du prochain joueur
      currentPlayerId: nextPlayerId,
      drawDoneThisTurn: false,
      enchantmentEffectsDoneThisTurn: false,
    );

    await docRef.update({
      'player1Data': updatedSession.player1Data.toJson(),
      if (updatedSession.player2Data != null)
        'player2Data': updatedSession.player2Data!.toJson(),
      'currentPhase': updatedSession.currentPhase.name,
      'currentPlayerId': updatedSession.currentPlayerId,
      'drawDoneThisTurn': updatedSession.drawDoneThisTurn,
      'enchantmentEffectsDoneThisTurn':
          updatedSession.enchantmentEffectsDoneThisTurn,
    });
  }

  /// Ajoute ou retire des PI d'un joueur
  Future<void> updatePlayerPI(
    String sessionId,
    String playerId,
    int amount,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;
    if (_isPiLocked(playerData)) {
      return;
    }

    GameSession updatedSession;
    if (isPlayer1) {
      final newPI = (session.player1Data.inhibitionPoints + amount).clamp(
        0,
        999,
      );
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(inhibitionPoints: newPI),
      );
    } else {
      final newPI = (session.player2Data!.inhibitionPoints + amount).clamp(
        0,
        999,
      );
      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(inhibitionPoints: newPI),
      );
    }

    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Met à jour la tension d'un joueur
  Future<void> updatePlayerTension(
    String sessionId,
    String playerId,
    double amount,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;

    GameSession updatedSession;
    if (isPlayer1) {
      final newTension = (session.player1Data.tension + amount).clamp(
        0.0,
        100.0,
      );
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(tension: newTension),
      );
    } else {
      final newTension = (session.player2Data!.tension + amount).clamp(
        0.0,
        100.0,
      );
      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(tension: newTension),
      );
    }

    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Termine le tour du joueur actuel et passe au joueur suivant
  Future<void> endTurn(String sessionId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);

    // Passer au joueur suivant
    final nextPlayerId =
        session.currentPlayerId == session.player1Id
            ? session.player2Id
            : session.player1Id;

    // Réinitialiser à la phase de pioche pour le prochain tour
    final updatedSession = session.copyWith(
      currentPlayerId: nextPlayerId,
      currentPhase: GamePhase.draw,
      drawDoneThisTurn: false,
      enchantmentEffectsDoneThisTurn: false,
    );

    await docRef.update({
      'currentPlayerId': updatedSession.currentPlayerId,
      'currentPhase': updatedSession.currentPhase.name,
      'drawDoneThisTurn': updatedSession.drawDoneThisTurn,
      'enchantmentEffectsDoneThisTurn':
          updatedSession.enchantmentEffectsDoneThisTurn,
    });
  }

  /// Parse le coût de lancement et retourne le coût en PI
  int parseLauncherCost(String launcherCost) {
    // Cherche un pattern "X PI" dans le texte
    final match = RegExp(
      r'(\d+)\s+PI',
      caseSensitive: false,
    ).firstMatch(launcherCost);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0; // Pas de coût PI trouvé
  }

  /// Vérifie si le joueur peut payer le coût et le déduit
  Future<void> payCost(String sessionId, String playerId, int cost) async {
    if (cost == 0) return;

    final session = await getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;
    if (_isPiLocked(playerData)) {
      throw Exception('PI verrouillés');
    }
    final currentPI =
        isPlayer1
            ? session.player1Data.inhibitionPoints
            : session.player2Data!.inhibitionPoints;

    if (currentPI < cost) {
      throw Exception(
        'Pas assez de PI (nécessaire: $cost, disponible: $currentPI)',
      );
    }

    final newPI = currentPI - cost;
    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: session.player1Data.copyWith(
                inhibitionPoints: newPI,
              ),
            )
            : session.copyWith(
              player2Data: session.player2Data!.copyWith(
                inhibitionPoints: newPI,
              ),
            );

    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Modifie les PI d'un joueur (pour pénalités de validation)
  Future<void> modifyPI(String sessionId, String playerId, int delta) async {
    final session = await getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;
    if (_isPiLocked(playerData)) {
      return;
    }

    final currentPI =
        isPlayer1
            ? session.player1Data.inhibitionPoints
            : session.player2Data!.inhibitionPoints;

    final newPI = (currentPI + delta).clamp(0, 20);

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: session.player1Data.copyWith(
                inhibitionPoints: newPI,
              ),
            )
            : session.copyWith(
              player2Data: session.player2Data!.copyWith(
                inhibitionPoints: newPI,
              ),
            );

    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Définit l'effet de la carte de réponse
  Future<void> setResponseEffect(
    String sessionId,
    ResponseEffect effect,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.update({'responseEffect': effect.name});
  }

  /// Vide la pile de résolution
  Future<void> clearResolutionStack(String sessionId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.update({'resolutionStack': [], 'playedCardTiers': {}});
  }

  /// Nettoie les cartes jouées sauf les enchantements
  Future<void> clearPlayedCards(String sessionId) async {
    final session = await getGameSession(sessionId);

    if (session.resolutionStack.isEmpty) return;

    // Charger toutes les cartes pour identifier les enchantements
    final cardsSnapshot = await _firestore.collection('cards').get();
    final allCards = cardsSnapshot.docs.map((doc) => doc.data()).toList();

    // Identifier les enchantements dans la pile
    final enchantments = <String>[];
    for (final cardId in session.resolutionStack) {
      final cardData = allCards.firstWhere(
        (card) => card['id'] == cardId,
        orElse: () => {},
      );

      if (cardData.isNotEmpty && cardData['isEnchantment'] == true) {
        enchantments.add(cardId);
      }
    }

    // Déterminer à qui appartiennent les enchantements
    // Pour simplifier: tous les enchantements vont au joueur actif
    final isPlayer1 = session.currentPlayerId == session.player1Id;
    final currentEnchantments =
        isPlayer1
            ? List<String>.from(session.player1Data.activeEnchantmentIds)
            : List<String>.from(session.player2Data!.activeEnchantmentIds);
    final currentEnchantmentTiers =
        isPlayer1
            ? Map<String, String>.from(
              session.player1Data.activeEnchantmentTiers,
            )
            : Map<String, String>.from(
              session.player2Data!.activeEnchantmentTiers,
            );
    final currentStatusModifiers =
        isPlayer1
            ? Map<String, List<String>>.from(
              session.player1Data.activeStatusModifiers,
            )
            : Map<String, List<String>>.from(
              session.player2Data!.activeStatusModifiers,
            );
    final otherStatusModifiers =
        isPlayer1
            ? Map<String, List<String>>.from(
              session.player2Data?.activeStatusModifiers ?? {},
            )
            : Map<String, List<String>>.from(
              session.player1Data.activeStatusModifiers,
            );

    // Ajouter les nouveaux enchantements
    currentEnchantments.addAll(enchantments);
    for (final enchantmentId in enchantments) {
      final tierKey =
          session.playedCardTiers[enchantmentId] ??
          (() {
            final cardData = allCards.firstWhere(
              (card) => card['id'] == enchantmentId,
              orElse: () => {},
            );
            final color = cardData['color'];
            if (color is String && color.isNotEmpty) return color;
            return 'white';
          })();
      currentEnchantmentTiers[enchantmentId] = tierKey;

      final cardData = allCards.firstWhere(
        (card) => card['id'] == enchantmentId,
        orElse: () => {},
      );
      final statusMods = cardData['statusModifiers'];
      if (statusMods is List) {
        for (final mod in statusMods) {
          if (mod is! Map) continue;
          final type = mod['type'];
          final target = mod['target'];
          final tier = mod['tier'];
          if (type is! String || type.isEmpty) continue;
          if (tier is String && tier.isNotEmpty && tier != tierKey) continue;

          void addTo(Map<String, List<String>> map) {
            final list = List<String>.from(map[type] ?? []);
            if (!list.contains(enchantmentId)) {
              list.add(enchantmentId);
            }
            map[type] = list;
          }

          if (target == 'both') {
            addTo(currentStatusModifiers);
            addTo(otherStatusModifiers);
          } else if (target == 'opponent') {
            addTo(otherStatusModifiers);
          } else {
            addTo(currentStatusModifiers);
          }
        }
      }
    }

    // === GESTION COMPTEUR ULTIMA ===
    String? newUltimaOwnerId = session.ultimaOwnerId;
    int newUltimaTurnCount = session.ultimaTurnCount;
    DateTime? newUltimaPlayedAt = session.ultimaPlayedAt;

    // Vérifier si Ultima vient d'être jouée
    final ultimaJustPlayed = enchantments.any((id) => id.contains('red_016'));
    if (ultimaJustPlayed) {
      final currentPlayerId = session.currentPlayerId;
      if (newUltimaOwnerId == null) {
        // Premier joueur à poser Ultima
        newUltimaOwnerId = currentPlayerId;
        newUltimaTurnCount = 0;
        newUltimaPlayedAt = DateTime.now();
      } else if (newUltimaOwnerId != currentPlayerId) {
        // Le 2ème joueur pose Ultima - le compteur reste sur le premier
        // Pas de changement
      }
    }

    // Mettre à jour la session
    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: session.player1Data.copyWith(
                activeEnchantmentIds: currentEnchantments,
                activeEnchantmentTiers: currentEnchantmentTiers,
                activeStatusModifiers: currentStatusModifiers,
              ),
              player2Data: session.player2Data?.copyWith(
                activeStatusModifiers: otherStatusModifiers,
              ),
              resolutionStack: [], // Vider la pile
              playedCardTiers: {},
              ultimaOwnerId: newUltimaOwnerId,
              ultimaTurnCount: newUltimaTurnCount,
              ultimaPlayedAt: newUltimaPlayedAt,
            )
            : session.copyWith(
              player2Data: session.player2Data!.copyWith(
                activeEnchantmentIds: currentEnchantments,
                activeEnchantmentTiers: currentEnchantmentTiers,
                activeStatusModifiers: currentStatusModifiers,
              ),
              player1Data: session.player1Data.copyWith(
                activeStatusModifiers: otherStatusModifiers,
              ),
              resolutionStack: [], // Vider la pile
              playedCardTiers: {},
              ultimaOwnerId: newUltimaOwnerId,
              ultimaTurnCount: newUltimaTurnCount,
              ultimaPlayedAt: newUltimaPlayedAt,
            );

    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.update({
      if (isPlayer1) 'player1Data': updatedSession.player1Data.toJson(),
      if (!isPlayer1) 'player2Data': updatedSession.player2Data!.toJson(),
      'resolutionStack': updatedSession.resolutionStack,
      'playedCardTiers': updatedSession.playedCardTiers,
      'ultimaOwnerId': updatedSession.ultimaOwnerId,
      'ultimaTurnCount': updatedSession.ultimaTurnCount,
      'ultimaPlayedAt': updatedSession.ultimaPlayedAt?.toIso8601String(),
    });
  }

  /// Retire une carte spécifique de la main du joueur
  Future<void> removeCardFromHand(
    String sessionId,
    String playerId,
    String cardId,
  ) async {
    final session = await getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    final updatedHand = List<String>.from(playerData.handCardIds);
    updatedHand.remove(cardId);

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: playerData.copyWith(handCardIds: updatedHand),
            )
            : session.copyWith(
              player2Data: playerData.copyWith(handCardIds: updatedHand),
            );

    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Retire un enchantement actif du joueur
  Future<void> removeEnchantment(
    String sessionId,
    String playerId,
    String enchantmentId,
  ) async {
    final session = await getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    final updatedEnchantments = List<String>.from(
      playerData.activeEnchantmentIds,
    );
    updatedEnchantments.remove(enchantmentId);
    final updatedEnchantmentTiers = Map<String, String>.from(
      playerData.activeEnchantmentTiers,
    );
    updatedEnchantmentTiers.remove(enchantmentId);

    final updatedStatusModifiers = Map<String, List<String>>.from(
      playerData.activeStatusModifiers,
    );
    final updatedOpponentStatusModifiers = Map<String, List<String>>.from(
      (isPlayer1 ? session.player2Data : session.player1Data)
              ?.activeStatusModifiers ??
          {},
    );

    try {
      final cardsSnapshot = await _firestore.collection('cards').get();
      final cardsMap = {for (var doc in cardsSnapshot.docs) doc.id: doc.data()};
      final cardData = cardsMap[enchantmentId];
      final statusMods = cardData?['statusModifiers'];
      final tierKey = playerData.activeEnchantmentTiers[enchantmentId];
      if (statusMods is List) {
        for (final mod in statusMods) {
          if (mod is! Map) continue;
          final type = mod['type'];
          final target = mod['target'];
          final tier = mod['tier'];
          if (type is! String || type.isEmpty) continue;
          if (tier is String && tierKey != null && tier != tierKey) continue;

          void removeFrom(Map<String, List<String>> map) {
            final list = List<String>.from(map[type] ?? []);
            list.remove(enchantmentId);
            if (list.isEmpty) {
              map.remove(type);
            } else {
              map[type] = list;
            }
          }

          if (target == 'both') {
            removeFrom(updatedStatusModifiers);
            removeFrom(updatedOpponentStatusModifiers);
          } else if (target == 'opponent') {
            removeFrom(updatedOpponentStatusModifiers);
          } else {
            removeFrom(updatedStatusModifiers);
          }
        }
      }
    } catch (_) {}

    // LOGIQUE SPÉCIALE POUR ULTIMA : La remettre en main au lieu de la retirer
    final updatedHand = List<String>.from(playerData.handCardIds);
    final isUltima = enchantmentId.contains('red_016');
    if (isUltima) {
      // C'est Ultima - la remettre en main
      updatedHand.add(enchantmentId);
    }

    // === RÉINITIALISATION COMPTEUR ULTIMA ===
    String? newUltimaOwnerId = session.ultimaOwnerId;
    int newUltimaTurnCount = session.ultimaTurnCount;
    DateTime? newUltimaPlayedAt = session.ultimaPlayedAt;

    if (isUltima && session.ultimaOwnerId == playerId) {
      // Le joueur qui avait le compteur actif a retiré son Ultima
      // Vérifier si l'adversaire a Ultima en jeu
      final opponentData =
          isPlayer1 ? session.player2Data! : session.player1Data;
      final opponentHasUltima = opponentData.activeEnchantmentIds.any(
        (id) => id.contains('red_016'),
      );

      if (opponentHasUltima) {
        // L'adversaire a Ultima - lui transférer le compteur en partant de 0
        newUltimaOwnerId = isPlayer1 ? session.player2Id : session.player1Id;
        newUltimaTurnCount = 0;
        newUltimaPlayedAt = DateTime.now();
      } else {
        // Personne n'a plus Ultima - réinitialiser
        newUltimaOwnerId = null;
        newUltimaTurnCount = 0;
        newUltimaPlayedAt = null;
      }
    }

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: playerData.copyWith(
                activeEnchantmentIds: updatedEnchantments,
                activeEnchantmentTiers: updatedEnchantmentTiers,
                activeStatusModifiers: updatedStatusModifiers,
                handCardIds: updatedHand,
              ),
              player2Data: session.player2Data?.copyWith(
                activeStatusModifiers: updatedOpponentStatusModifiers,
              ),
              ultimaOwnerId: newUltimaOwnerId,
              ultimaTurnCount: newUltimaTurnCount,
              ultimaPlayedAt: newUltimaPlayedAt,
            )
            : session.copyWith(
              player2Data: playerData.copyWith(
                activeEnchantmentIds: updatedEnchantments,
                activeEnchantmentTiers: updatedEnchantmentTiers,
                activeStatusModifiers: updatedStatusModifiers,
                handCardIds: updatedHand,
              ),
              player1Data: session.player1Data.copyWith(
                activeStatusModifiers: updatedOpponentStatusModifiers,
              ),
              ultimaOwnerId: newUltimaOwnerId,
              ultimaTurnCount: newUltimaTurnCount,
              ultimaPlayedAt: newUltimaPlayedAt,
            );

    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.update({
      if (isPlayer1) 'player1Data': updatedSession.player1Data.toJson(),
      if (!isPlayer1) 'player2Data': updatedSession.player2Data!.toJson(),
      'ultimaOwnerId': updatedSession.ultimaOwnerId,
      'ultimaTurnCount': updatedSession.ultimaTurnCount,
      'ultimaPlayedAt': updatedSession.ultimaPlayedAt?.toIso8601String(),
    });
  }

  /// Pioche une carte spécifique depuis le deck
  Future<void> drawSpecificCard(
    String sessionId,
    String playerId,
    String cardId,
  ) async {
    final session = await getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    final updatedDeck = List<String>.from(playerData.deckCardIds);
    final updatedHand = List<String>.from(playerData.handCardIds);

    if (updatedDeck.remove(cardId)) {
      updatedHand.add(cardId);

      final updatedSession =
          isPlayer1
              ? session.copyWith(
                player1Data: playerData.copyWith(
                  deckCardIds: updatedDeck,
                  handCardIds: updatedHand,
                ),
              )
              : session.copyWith(
                player2Data: playerData.copyWith(
                  deckCardIds: updatedDeck,
                  handCardIds: updatedHand,
                ),
              );

      final docRef = _firestore.collection('game_sessions').doc(sessionId);
      if (isPlayer1) {
        await docRef.update({
          'player1Data': updatedSession.player1Data.toJson(),
        });
      } else {
        await docRef.update({
          'player2Data': updatedSession.player2Data!.toJson(),
        });
      }
    }
  }

  /// Mélange la main du joueur dans son deck
  Future<void> shuffleHandIntoDeck(String sessionId, String playerId) async {
    final session = await getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    final updatedDeck = List<String>.from(playerData.deckCardIds);
    updatedDeck.addAll(playerData.handCardIds);
    updatedDeck.shuffle();

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: playerData.copyWith(
                deckCardIds: updatedDeck,
                handCardIds: [],
              ),
            )
            : session.copyWith(
              player2Data: playerData.copyWith(
                deckCardIds: updatedDeck,
                handCardIds: [],
              ),
            );

    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    if (isPlayer1) {
      await docRef.update({
        'player1Data': updatedSession.player1Data.toJson(),
      });
    } else {
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Stocke les actions pendantes d'un sort dans la session
  Future<void> storePendingActions(
    String sessionId,
    List pendingActions,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);

    // Convertir les PendingAction en Map
    final actionsJson =
        pendingActions.map((action) => action.toJson()).toList();

    await docRef.update({'pendingSpellActions': actionsJson});
  }

  /// Efface les actions pendantes (après exécution ou si sort contré)
  Future<void> clearPendingActions(String sessionId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.update({'pendingSpellActions': []});
  }

  /// Met à jour une session complète
  Future<void> updateSession(String sessionId, GameSession session) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final sessionJson = session.toJson();
    sessionJson['player1Data'] = session.player1Data.toJson();
    if (session.player2Data != null) {
      sessionJson['player2Data'] = session.player2Data!.toJson();
    }
    await docRef.set(sessionJson, SetOptions(merge: true));
  }

  bool _isPiLocked(PlayerData playerData) {
    final list = playerData.activeStatusModifiers['pi_locked'];
    return list != null && list.isNotEmpty;
  }

  bool _isTensionLocked(PlayerData playerData) {
    final list = playerData.activeStatusModifiers['tension_locked'];
    return list != null && list.isNotEmpty;
  }
}
