import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/interfaces/i_auth_service.dart';
import '../../../../core/interfaces/i_game_session_service.dart';
import '../../domain/models/game_session.dart';
import '../../domain/models/player_data.dart';
import '../../domain/enums/player_gender.dart';
import '../../domain/enums/game_status.dart';
import 'auth_service.dart';

/// Provider pour le service de gestion des sessions de jeu
final gameSessionServiceProvider = Provider<IGameSessionService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GameSessionService(authService);
});

/// Service de gestion des sessions de jeu (création, rejoindre, CRUD)
/// Extrait de FirebaseService pour respecter le principe S (Single Responsibility)
/// Implémente IGameSessionService pour permettre le mocking dans les tests
class GameSessionService implements IGameSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IAuthService _authService;
  final _uuid = const Uuid();

  static const String _collection = 'game_sessions';

  GameSessionService(this._authService);

  /// Accès au Firestore (pour les services qui en ont besoin)
  FirebaseFirestore get firestore => _firestore;

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
  @override
  Future<GameSession> createGame({
    required String playerName,
    required PlayerGender playerGender,
  }) async {
    try {
      // Connexion anonyme
      final playerId = await _authService.signInAnonymously();

      // Génération code unique
      String gameCode;
      bool codeExists = true;

      do {
        gameCode = _generateGameCode();
        final doc =
            await _firestore.collection(_collection).doc(gameCode).get();
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

      await _firestore.collection(_collection).doc(gameCode).set(sessionJson);

      return session;
    } catch (e) {
      throw Exception('Erreur lors de la création de la partie: $e');
    }
  }

  /// Rejoindre une partie existante
  @override
  Future<GameSession> joinGame({
    required String gameCode,
    required String playerName,
    required PlayerGender playerGender,
  }) async {
    try {
      // Connexion anonyme
      final playerId = await _authService.signInAnonymously();

      // Vérifier que la partie existe
      final docRef = _firestore
          .collection(_collection)
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
        'updatedAt': updatedSession.updatedAt.toIso8601String(),
      });

      return updatedSession;
    } catch (e) {
      throw Exception('Erreur lors de la connexion à la partie: $e');
    }
  }

  /// Récupère une session de jeu (une seule fois)
  @override
  Future<GameSession> getSession(String sessionId) async {
    final doc = await _firestore.collection(_collection).doc(sessionId).get();
    if (!doc.exists) {
      throw Exception('Session introuvable');
    }
    return GameSession.fromJson(doc.data()!);
  }

  /// Stream temps réel de la session
  @override
  Stream<GameSession> watchSession(String sessionId) {
    return _firestore.collection(_collection).doc(sessionId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) {
        throw Exception('Session introuvable');
      }
      return GameSession.fromJson(doc.data()!);
    });
  }

  /// Met à jour une session complète
  @override
  Future<void> updateSession(String sessionId, GameSession session) async {
    final sessionJson = session.toJson();
    sessionJson['player1Data'] = session.player1Data.toJson();
    if (session.player2Data != null) {
      sessionJson['player2Data'] = session.player2Data!.toJson();
    }
    await _firestore.collection(_collection).doc(sessionId).set(sessionJson);
  }

  /// Vérifie si une session existe
  @override
  Future<bool> sessionExists(String sessionId) async {
    final doc = await _firestore.collection(_collection).doc(sessionId).get();
    return doc.exists;
  }

  /// Supprime une session
  @override
  Future<void> deleteSession(String sessionId) async {
    await _firestore.collection(_collection).doc(sessionId).delete();
  }
}
