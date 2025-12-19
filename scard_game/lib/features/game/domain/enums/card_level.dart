/// Niveaux de progression des cartes dans le jeu
enum CardLevel {
  /// Niveau blanc - Départ du jeu
  white,

  /// Niveau bleu - Cartes blanches + bleues
  blue,

  /// Niveau jaune - Cartes blanches + bleues + jaunes
  yellow,

  /// Niveau rouge - Toutes les cartes
  red;

  /// Retourne les couleurs de cartes disponibles pour ce niveau
  List<String> get availableColors {
    switch (this) {
      case CardLevel.white:
        return ['white', 'green']; // Vert disponible dès le début
      case CardLevel.blue:
        return ['white', 'blue', 'green'];
      case CardLevel.yellow:
        return ['white', 'blue', 'yellow', 'green'];
      case CardLevel.red:
        return ['white', 'blue', 'yellow', 'red', 'green'];
    }
  }

  /// Nom français du niveau
  String get displayName {
    switch (this) {
      case CardLevel.white:
        return 'Blanc';
      case CardLevel.blue:
        return 'Bleu';
      case CardLevel.yellow:
        return 'Jaune';
      case CardLevel.red:
        return 'Rouge';
    }
  }
}
