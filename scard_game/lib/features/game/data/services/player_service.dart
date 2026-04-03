import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interfaces/i_game_session_service.dart';
import '../../domain/models/player_data.dart';
import '../../domain/enums/player_gender.dart';
import '../../domain/enums/game_status.dart';
import 'game_session_service.dart';

/// Provider pour le service de gestion des joueurs
final playerServiceProvider = Provider<PlayerService>((ref) {
  final gameSessionService = ref.watch(gameSessionServiceProvider);
  return PlayerService(gameSessionService);
});

/// Service de gestion des joueurs (activité, prêt, cartes).
class PlayerService {
  final IGameSessionService _gameSessionService;

  PlayerService(this._gameSessionService);

  /// Met à jour l'activité du joueur (heartbeat)
  Future<void> updatePlayerActivity(String sessionId, String playerId) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final now = DateTime.now();

      if (session.player1Id == playerId) {
        return session.copyWith(
          player1Data: session.player1Data.copyWith(lastActivityAt: now),
          updatedAt: now,
        );
      } else if (session.player2Id == playerId) {
        return session.copyWith(
          player2Data: session.player2Data?.copyWith(lastActivityAt: now),
          updatedAt: now,
        );
      }
      return session;
    });
  }

  /// Marque le joueur comme prêt
  Future<void> setPlayerReady(
    String sessionId,
    String playerId,
    bool ready,
  ) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final now = DateTime.now();

      if (session.player1Id == playerId) {
        return session.copyWith(
          player1Data: session.player1Data.copyWith(isReady: ready),
          updatedAt: now,
        );
      } else if (session.player2Id == playerId) {
        return session.copyWith(
          player2Data: session.player2Data?.copyWith(isReady: ready),
          updatedAt: now,
        );
      }
      return session;
    });
  }

  /// Marque le joueur comme ayant vu ses cartes de départ et prêt à jouer
  Future<void> setPlayerCardsReady(String sessionId, String playerId) async {
    await setPlayerReady(sessionId, playerId, true);
  }

  /// Détermine quel joueur commence
  Future<void> determineStartingPlayer(String sessionId) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      // Vérifier que player2 est connecté
      if (session.player2Data == null) return session;
      // Les deux joueurs doivent etre prets
      if (!session.player1Data.isReady || !session.player2Data!.isReady) {
        return session;
      }
      // Ne demarrer qu\'une seule fois (idempotent)
      if (session.status != GameStatus.waiting) {
        return session;
      }

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

      final now = DateTime.now();
      return session.copyWith(
        currentPlayerId: startingPlayerId,
        status: GameStatus.playing,
        player1Data: session.player1Data.copyWith(isReady: false),
        player2Data: session.player2Data!.copyWith(isReady: false),
        startedAt: now,
        updatedAt: now,
      );
    });
  }

  /// Sauvegarde les cartes du joueur (main et deck)
  Future<void> updatePlayerCards({
    required String sessionId,
    required String playerId,
    required List<String> handCardIds,
    required List<String> deckCardIds,
  }) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final now = DateTime.now();

      if (session.player1Id == playerId) {
        return session.copyWith(
          player1Data: session.player1Data.copyWith(
            handCardIds: handCardIds,
            deckCardIds: deckCardIds,
          ),
          updatedAt: now,
        );
      } else if (session.player2Id == playerId) {
        return session.copyWith(
          player2Data: session.player2Data?.copyWith(
            handCardIds: handCardIds,
            deckCardIds: deckCardIds,
          ),
          updatedAt: now,
        );
      }
      return session;
    });
  }

  /// Ajoute ou retire des PI d'un joueur
  Future<void> updatePlayerPI(
    String sessionId,
    String playerId,
    int delta,
  ) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final isPlayer1 = session.player1Id == playerId;
      final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

      // Vérifier le lock PI
      if (_isPiLocked(playerData)) {
        return session; // PI verrouillés, ne pas modifier
      }

      final newPI = (playerData.inhibitionPoints + delta).clamp(0, 99);

      if (isPlayer1) {
        return session.copyWith(
          player1Data: session.player1Data.copyWith(inhibitionPoints: newPI),
          updatedAt: DateTime.now(),
        );
      } else {
        return session.copyWith(
          player2Data: session.player2Data!.copyWith(inhibitionPoints: newPI),
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  /// Met à jour la tension d'un joueur
  Future<void> updatePlayerTension(
    String sessionId,
    String playerId,
    double delta,
  ) async {
    await _gameSessionService.runTransaction(sessionId, (session) {
      final isPlayer1 = session.player1Id == playerId;
      final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

      // Vérifier le lock tension
      if (_isTensionLocked(playerData)) {
        return session; // Tension verrouillée, ne pas modifier
      }

      final newTension = (playerData.tension + delta).clamp(0.0, 100.0);

      if (isPlayer1) {
        return session.copyWith(
          player1Data: session.player1Data.copyWith(tension: newTension),
          updatedAt: DateTime.now(),
        );
      } else {
        return session.copyWith(
          player2Data: session.player2Data!.copyWith(tension: newTension),
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  /// Vérifie si les PI sont verrouillés par un enchantement
  bool _isPiLocked(PlayerData playerData) {
    final modifiers = playerData.activeStatusModifiers;
    return (modifiers['pi_locked']?.isNotEmpty ?? false) ||
        (modifiers['lockPI']?.isNotEmpty ?? false);
  }

  /// Vérifie si la tension est verrouillée par un enchantement
  bool _isTensionLocked(PlayerData playerData) {
    final modifiers = playerData.activeStatusModifiers;
    return (modifiers['tension_locked']?.isNotEmpty ?? false) ||
        (modifiers['lockTension']?.isNotEmpty ?? false);
  }
}
