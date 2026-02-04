import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_session.dart';
import '../../domain/models/player_data.dart';
import '../../domain/enums/player_gender.dart';
import '../../domain/enums/game_status.dart';

/// Provider pour le service de gestion des joueurs
final playerServiceProvider = Provider<PlayerService>((ref) {
  return PlayerService();
});

/// Service de gestion des joueurs (activité, prêt, cartes)
/// Extrait de FirebaseService pour respecter le principe S (Single Responsibility)
class PlayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'game_sessions';

  /// Met à jour l'activité du joueur (heartbeat)
  Future<void> updatePlayerActivity(String sessionId, String playerId) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
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
    final docRef = _firestore.collection(_collection).doc(sessionId);
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

  /// Marque le joueur comme ayant vu ses cartes de départ et prêt à jouer
  Future<void> setPlayerCardsReady(String sessionId, String playerId) async {
    await setPlayerReady(sessionId, playerId, true);
  }

  /// Détermine quel joueur commence
  Future<void> determineStartingPlayer(String sessionId) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final session = GameSession.fromJson(doc.data()!);

    // Vérifier que player2 est connecté
    if (session.player2Data == null) return;

    String startingPlayerId;

    // Si sexes différents, la femme commence
    if (session.player1Data.gender != session.player2Data!.gender) {
      if (session.player1Data.gender == PlayerGender.female) {
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
    final docRef = _firestore.collection(_collection).doc(sessionId);
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

  /// Ajoute ou retire des PI d'un joueur
  Future<void> updatePlayerPI(
    String sessionId,
    String playerId,
    int delta,
  ) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    // Vérifier le lock PI
    if (_isPiLocked(playerData)) {
      return; // PI verrouillés, ne pas modifier
    }

    final newPI = (playerData.inhibitionPoints + delta).clamp(0, 99);

    GameSession updatedSession;
    if (isPlayer1) {
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(inhibitionPoints: newPI),
      );
      await docRef.update({'player1Data': updatedSession.player1Data.toJson()});
    } else {
      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(inhibitionPoints: newPI),
      );
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Met à jour la tension d'un joueur
  Future<void> updatePlayerTension(
    String sessionId,
    String playerId,
    double delta,
  ) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) throw Exception('Session non trouvée');

    final session = GameSession.fromJson(snapshot.data()!);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    // Vérifier le lock tension
    if (_isTensionLocked(playerData)) {
      return; // Tension verrouillée, ne pas modifier
    }

    final newTension = (playerData.tension + delta).clamp(0.0, 100.0);

    GameSession updatedSession;
    if (isPlayer1) {
      updatedSession = session.copyWith(
        player1Data: session.player1Data.copyWith(tension: newTension),
      );
      await docRef.update({'player1Data': updatedSession.player1Data.toJson()});
    } else {
      updatedSession = session.copyWith(
        player2Data: session.player2Data!.copyWith(tension: newTension),
      );
      await docRef.update({
        'player2Data': updatedSession.player2Data!.toJson(),
      });
    }
  }

  /// Vérifie si les PI sont verrouillés par un enchantement
  bool _isPiLocked(PlayerData playerData) {
    return playerData.activeStatusModifiers.containsKey('lockPI');
  }

  /// Vérifie si la tension est verrouillée par un enchantement
  bool _isTensionLocked(PlayerData playerData) {
    return playerData.activeStatusModifiers.containsKey('lockTension');
  }
}
