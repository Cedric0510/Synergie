import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interfaces/i_game_session_repository.dart';
import '../../domain/models/game_session.dart';
import '../../domain/models/player_data.dart';

/// Provider pour le repository de sessions de jeu
final gameSessionRepositoryProvider = Provider<IGameSessionRepository>((ref) {
  return GameSessionRepository();
});

/// Repository pour la gestion des sessions de jeu (CRUD)
/// Implémente IGameSessionRepository pour respecter le principe D (Dependency Inversion)
class GameSessionRepository implements IGameSessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Nom de la collection Firestore
  static const String _collectionName = 'game_sessions';

  /// Collection Firestore pour les sessions
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  /// Récupère une session par son code
  @override
  Future<GameSession?> getSessionByCode(String code) async {
    final query =
        await _collection
            .where('sessionId', isEqualTo: code.toUpperCase())
            .limit(1)
            .get();

    if (query.docs.isEmpty) return null;
    return GameSession.fromJson(query.docs.first.data());
  }

  /// Récupère une session par son ID
  @override
  Future<GameSession> getSession(String sessionId) async {
    final doc = await _collection.doc(sessionId).get();
    if (!doc.exists) {
      throw Exception('Session non trouvée: $sessionId');
    }
    return GameSession.fromJson(doc.data()!);
  }

  /// Écoute les changements d'une session en temps réel
  @override
  Stream<GameSession> watchSession(String sessionId) {
    return _collection.doc(sessionId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Session non trouvée: $sessionId');
      }
      return GameSession.fromJson(snapshot.data()!);
    });
  }

  /// Sauvegarde une session (création ou mise à jour complète)
  @override
  Future<void> saveSession(GameSession session) async {
    final sessionJson = session.toJson();
    sessionJson['player1Data'] = session.player1Data.toJson();
    if (session.player2Data != null) {
      sessionJson['player2Data'] = session.player2Data!.toJson();
    }
    await _collection.doc(session.sessionId).set(sessionJson);
  }

  /// Met à jour les données d'un joueur
  @override
  Future<void> updatePlayerData(
    String sessionId,
    bool isPlayer1,
    PlayerData playerData,
  ) async {
    final fieldName = isPlayer1 ? 'player1Data' : 'player2Data';
    await _collection.doc(sessionId).update({fieldName: playerData.toJson()});
  }

  /// Supprime une session
  @override
  Future<void> deleteSession(String sessionId) async {
    await _collection.doc(sessionId).delete();
  }

  /// Vérifie si une session existe
  @override
  Future<bool> sessionExists(String sessionId) async {
    final doc = await _collection.doc(sessionId).get();
    return doc.exists;
  }
}
