import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums/card_level.dart';
import '../../domain/enums/card_color.dart';
import 'firebase_service.dart';

/// Service pour gérer la tension et la progression des niveaux
class TensionService {
  final FirebaseService _firebaseService;

  TensionService(this._firebaseService);

  /// Seuils de tension pour débloquer les niveaux (%)
  static const double blueThreshold = 25.0; // 25% pour débloquer bleu
  static const double yellowThreshold = 50.0; // 50% pour débloquer jaune
  static const double redThreshold = 75.0; // 75% pour débloquer rouge

  /// Incrémente la tension d'un joueur
  /// Retourne true si le niveau a changé (pour déclencher une pioche)
  Future<bool> increaseTension(
    String sessionId,
    String playerId,
    double amount,
  ) async {
    final session = await _firebaseService.getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;

    // Sauvegarder l'ancien niveau
    final oldLevel = playerData.currentLevel;

    // Calculer la nouvelle tension (max 100%)
    final newTension = (playerData.tension + amount).clamp(0.0, 100.0);

    // Déterminer le nouveau niveau basé sur la tension
    final newLevel = _getLevelFromTension(newTension);

    // Mettre à jour
    final updatedPlayerData = playerData.copyWith(
      tension: newTension,
      currentLevel: newLevel,
    );

    final updatedSession =
        isPlayer1
            ? session.copyWith(player1Data: updatedPlayerData)
            : session.copyWith(player2Data: updatedPlayerData);

    // Debug
    print(
      '📊 increaseTension - Ancienne tension: ${playerData.tension}%, Nouveau: $newTension% - Ancien niveau: $oldLevel, Nouveau: $newLevel',
    );

    // Sauvegarder
    await _firebaseService.updateSession(sessionId, updatedSession);

    // Retourner true si le niveau a changé
    return oldLevel != newLevel;
  }

  /// Détermine le niveau basé sur la tension
  CardLevel _getLevelFromTension(double tension) {
    if (tension >= redThreshold) {
      return CardLevel.red;
    } else if (tension >= yellowThreshold) {
      return CardLevel.yellow;
    } else if (tension >= blueThreshold) {
      return CardLevel.blue;
    } else {
      return CardLevel.white;
    }
  }

  /// Obtient le niveau actuel d'un joueur
  Future<CardLevel> getCurrentLevel(String sessionId, String playerId) async {
    final session = await _firebaseService.getGameSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data!;
    return playerData.currentLevel;
  }

  /// Vérifie si une carte peut être jouée selon le niveau actuel
  bool canPlayCard(CardColor cardColor, CardLevel currentLevel) {
    // Convertir CardColor en string pour la comparaison
    final colorString = cardColor.toString().split('.').last;
    final canPlay = currentLevel.availableColors.contains(colorString);

    // Debug
    print(
      '🎴 canPlayCard - Color: $colorString, Level: $currentLevel, Available: ${currentLevel.availableColors}, CanPlay: $canPlay',
    );

    return canPlay;
  }

  /// Retourne le pourcentage de progression vers le prochain niveau
  double getProgressToNextLevel(double currentTension, CardLevel currentLevel) {
    switch (currentLevel) {
      case CardLevel.white:
        // Progression de 0% à 25%
        return (currentTension / blueThreshold) * 100;
      case CardLevel.blue:
        // Progression de 25% à 50%
        return ((currentTension - blueThreshold) /
                (yellowThreshold - blueThreshold)) *
            100;
      case CardLevel.yellow:
        // Progression de 50% à 75%
        return ((currentTension - yellowThreshold) /
                (redThreshold - yellowThreshold)) *
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
  final firebaseService = ref.watch(firebaseServiceProvider);
  return TensionService(firebaseService);
});
