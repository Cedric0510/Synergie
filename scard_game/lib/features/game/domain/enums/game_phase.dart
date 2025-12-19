/// Phase du tour de jeu
enum GamePhase {
  /// Phase d'enchantement et pioche - début du tour
  draw,

  /// Phase principale - jouer des cartes
  main,

  /// Phase de réponse - l'adversaire peut répondre
  response,

  /// Phase de résolution - résolution des effets
  resolution,

  /// Phase de fin de tour
  end,
}

extension GamePhaseExtension on GamePhase {
  String get displayName {
    switch (this) {
      case GamePhase.draw:
        return 'Enchantement & Pioche';
      case GamePhase.main:
        return 'Phase Principale';
      case GamePhase.response:
        return 'Réponse';
      case GamePhase.resolution:
        return 'Résolution';
      case GamePhase.end:
        return 'Fin de Tour';
    }
  }
}
