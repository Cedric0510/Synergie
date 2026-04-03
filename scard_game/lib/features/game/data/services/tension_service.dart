import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/interfaces/i_game_session_service.dart';
import '../../../../core/interfaces/i_tension_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/enums/card_level.dart';
import '../../domain/enums/card_color.dart';
import 'game_session_service.dart';

/// Service pour gérer la tension et la progression des niveaux
/// Implémente ITensionService pour respecter le principe D (Dependency Inversion)
class TensionService implements ITensionService {
  final IGameSessionService _gameSessionService;
  final LoggerService _logger;

  TensionService(this._gameSessionService, this._logger);

  /// Incrémente la tension d'un joueur
  /// Retourne true si le niveau a changé (pour déclencher une pioche)
  Future<bool> increaseTension(
    String sessionId,
    String playerId,
    double amount,
  ) async {
    bool levelChanged = false;

    await _gameSessionService.runTransaction(sessionId, (session) {
      final playerData = session.getPlayerData(playerId);

      // Sauvegarder l'ancien niveau
      final oldLevel = playerData.currentLevel;

      // Calculer la nouvelle tension (max 100%)
      final newTension = (playerData.tension + amount).clamp(
        GameConstants.minTension,
        GameConstants.maxTension,
      );

      // Déterminer le nouveau niveau basé sur la tension
      final newLevel = getEffectiveLevel(newTension);

      // Mettre à jour
      final updatedPlayerData = playerData.copyWith(
        tension: newTension,
        currentLevel: newLevel,
      );

      levelChanged = oldLevel != newLevel;

      return session.updatePlayerData(playerId, updatedPlayerData);
    });

    return levelChanged;
  }

  /// Détermine le niveau basé sur la tension
  @override
  CardLevel getEffectiveLevel(double tension) {
    if (tension >= GameConstants.tensionThresholdRed) {
      return CardLevel.red;
    } else if (tension >= GameConstants.tensionThresholdYellow) {
      return CardLevel.yellow;
    } else if (tension >= GameConstants.tensionThresholdBlue) {
      return CardLevel.blue;
    } else {
      return CardLevel.white;
    }
  }

  /// Obtient le niveau actuel d'un joueur
  Future<CardLevel> getCurrentLevel(String sessionId, String playerId) async {
    final session = await _gameSessionService.getSession(sessionId);
    final playerData = session.getPlayerData(playerId);
    return playerData.currentLevel;
  }

  /// Vérifie si une carte peut être jouée selon le niveau actuel
  @override
  bool canPlayCard(CardColor cardColor, CardLevel currentLevel) {
    // Convertir CardColor en string pour la comparaison
    final colorString = cardColor.toString().split('.').last;
    final canPlay = currentLevel.availableColors.contains(colorString);

    _logger.debug(
      'TensionService',
      'canPlayCard - Color: $colorString, Level: $currentLevel, CanPlay: $canPlay',
    );

    return canPlay;
  }

  /// Calcule l'augmentation de tension pour une couleur de carte
  @override
  double getTensionIncrease(CardColor cardColor) {
    final colorKey = cardColor.toString().split('.').last;
    return GameConstants.tensionByCardColor[colorKey] ?? 0.0;
  }

  /// Vérifie si le niveau permet de jouer une couleur
  @override
  bool isColorUnlocked(CardColor color, CardLevel level) {
    return canPlayCard(color, level);
  }

  /// Retourne le pourcentage de progression vers le prochain niveau
  double getProgressToNextLevel(double currentTension, CardLevel currentLevel) {
    switch (currentLevel) {
      case CardLevel.white:
        // Progression de 0% à 25%
        return (currentTension / GameConstants.tensionThresholdBlue) * 100;
      case CardLevel.blue:
        // Progression de 25% à 50%
        return ((currentTension - GameConstants.tensionThresholdBlue) /
                (GameConstants.tensionThresholdYellow -
                    GameConstants.tensionThresholdBlue)) *
            100;
      case CardLevel.yellow:
        // Progression de 50% à 75%
        return ((currentTension - GameConstants.tensionThresholdYellow) /
                (GameConstants.tensionThresholdRed -
                    GameConstants.tensionThresholdYellow)) *
            100;
      case CardLevel.red:
        // Déjà au niveau max
        return 100.0;
    }
  }

  /// Retourne le nom du prochain niveau
  String? getNextLevelName(CardLevel currentLevel) {
    switch (currentLevel) {
      case CardLevel.white:
        return CardLevel.blue.displayName;
      case CardLevel.blue:
        return CardLevel.yellow.displayName;
      case CardLevel.yellow:
        return CardLevel.red.displayName;
      case CardLevel.red:
        return null; // Niveau max atteint
    }
  }
}

/// Provider pour le service de tension
final tensionServiceProvider = Provider<TensionService>((ref) {
  final gameSessionService = ref.watch(gameSessionServiceProvider);
  final logger = ref.watch(loggerServiceProvider);
  return TensionService(gameSessionService, logger);
});
