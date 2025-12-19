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
      // Force une nouvelle connexion en se déconnectant d'abord
      await _auth.signOut();
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

      // Conversion manuelle des PlayerData
      final sessionJson = updatedSession.toJson();
      sessionJson['player1Data'] = updatedSession.player1Data.toJson();
      sessionJson['player2Data'] = playerData.toJson();

      await docRef.set(sessionJson, SetOptions(merge: true));

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
    GameSession updatedSession;

    if (session.player1Id == playerId) {
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(isReady: ready),
        updatedAt: DateTime.now(),
      );
    } else if (session.player2Id == playerId) {
      updatedSession = session.copyWith(
        player2Data: session.player2Data?.copyWith(isReady: ready),
        updatedAt: DateTime.now(),
      );
    } else {
      return; // Joueur inconnu
    }

    // Conversion manuelle
    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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
    GameSession updatedSession;

    if (session.player1Id == playerId) {
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(
          handCardIds: handCardIds,
          deckCardIds: deckCardIds,
        ),
        updatedAt: DateTime.now(),
      );
    } else if (session.player2Id == playerId) {
      updatedSession = session.copyWith(
        player2Data: session.player2Data?.copyWith(
          handCardIds: handCardIds,
          deckCardIds: deckCardIds,
        ),
        updatedAt: DateTime.now(),
      );
    } else {
      return; // Joueur inconnu
    }

    // Conversion manuelle
    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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

    await docRef.update({
      'currentPhase': nextPhase.name,
      'currentPlayerId': nextPlayerId,
    });
  }

  /// Piocher une carte (phase draw)
  Future<void> drawCard(String sessionId, String playerId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;

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

    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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

    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
    return true;
  }

  /// Jouer une carte
  Future<void> playCard(
    String sessionId,
    String playerId,
    int cardIndex,
  ) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;

    GameSession updatedSession;
    if (isPlayer1) {
      final hand = List<String>.from(session.player1Data.handCardIds);

      if (cardIndex < 0 || cardIndex >= hand.length) {
        throw Exception('Index de carte invalide');
      }

      final playedCard = hand.removeAt(cardIndex);
      final playedCards = List<String>.from(session.player1Data.playedCardIds);
      playedCards.add(playedCard);

      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(
          handCardIds: hand,
          playedCardIds: playedCards,
        ),
        resolutionStack: [...session.resolutionStack, playedCard],
      );
    } else {
      final hand = List<String>.from(session.player2Data!.handCardIds);

      if (cardIndex < 0 || cardIndex >= hand.length) {
        throw Exception('Index de carte invalide');
      }

      final playedCard = hand.removeAt(cardIndex);
      final playedCards = List<String>.from(session.player2Data!.playedCardIds);
      playedCards.add(playedCard);

      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(
          handCardIds: hand,
          playedCardIds: playedCards,
        ),
        resolutionStack: [...session.resolutionStack, playedCard],
      );
    }

    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
  }

  /// Sacrifier une carte (sans bonus de tension, géré séparément)
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

    GameSession updatedSession;
    if (isPlayer1) {
      final hand = List<String>.from(session.player1Data.handCardIds);

      if (cardIndex < 0 || cardIndex >= hand.length) {
        throw Exception('Index de carte invalide');
      }

      final sacrificedCard = hand.removeAt(cardIndex);
      final graveyard = List<String>.from(session.player1Data.graveyardCardIds);
      graveyard.add(sacrificedCard);

      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(
          handCardIds: hand,
          graveyardCardIds: graveyard,
        ),
      );
    } else {
      final hand = List<String>.from(session.player2Data!.handCardIds);

      if (cardIndex < 0 || cardIndex >= hand.length) {
        throw Exception('Index de carte invalide');
      }

      final sacrificedCard = hand.removeAt(cardIndex);
      final graveyard = List<String>.from(
        session.player2Data!.graveyardCardIds,
      );
      graveyard.add(sacrificedCard);

      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(
          handCardIds: hand,
          graveyardCardIds: graveyard,
        ),
      );
    }

    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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

    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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

    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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
    );

    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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
    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
  }

  /// Modifie les PI d'un joueur (pour pénalités de validation)
  Future<void> modifyPI(String sessionId, String playerId, int delta) async {
    final session = await getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;

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
    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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
    await docRef.update({'resolutionStack': []});
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

    // Ajouter les nouveaux enchantements
    currentEnchantments.addAll(enchantments);

    // Mettre à jour la session
    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: session.player1Data.copyWith(
                activeEnchantmentIds: currentEnchantments,
              ),
              resolutionStack: [], // Vider la pile
            )
            : session.copyWith(
              player2Data: session.player2Data!.copyWith(
                activeEnchantmentIds: currentEnchantments,
              ),
              resolutionStack: [], // Vider la pile
            );

    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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
    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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

    // LOGIQUE SPÉCIALE POUR ULTIMA : La remettre en main au lieu de la retirer
    final updatedHand = List<String>.from(playerData.handCardIds);
    if (enchantmentId.contains('red_016')) {
      // C'est Ultima - la remettre en main
      updatedHand.add(enchantmentId);
    }

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: playerData.copyWith(
                activeEnchantmentIds: updatedEnchantments,
                handCardIds: updatedHand,
              ),
            )
            : session.copyWith(
              player2Data: playerData.copyWith(
                activeEnchantmentIds: updatedEnchantments,
                handCardIds: updatedHand,
              ),
            );

    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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
      final sessionJson = updatedSession.toJson();
      sessionJson['player1Data'] = updatedSession.player1Data.toJson();
      if (updatedSession.player2Data != null) {
        sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
      }

      await docRef.set(sessionJson, SetOptions(merge: true));
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
    final sessionJson = updatedSession.toJson();
    sessionJson['player1Data'] = updatedSession.player1Data.toJson();
    if (updatedSession.player2Data != null) {
      sessionJson['player2Data'] = updatedSession.player2Data!.toJson();
    }

    await docRef.set(sessionJson, SetOptions(merge: true));
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
}
