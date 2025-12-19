/// Couleur/Niveau de la carte
/// Détermine à quel niveau de tension la carte peut être jouée
enum CardColor {
  /// Blanc - Niveau innocent (0-24% tension)
  white,

  /// Bleu - Niveau séduction (25-49% tension)
  blue,

  /// Jaune - Niveau passion (50-74% tension)
  yellow,

  /// Rouge - Niveau extase (75-100% tension)
  red,

  /// Vert - Cartes de négociation (jouables uniquement en réponse)
  green,
}

extension CardColorExtension on CardColor {
  String get displayName {
    switch (this) {
      case CardColor.white:
        return 'Blanc';
      case CardColor.blue:
        return 'Bleu';
      case CardColor.yellow:
        return 'Jaune';
      case CardColor.red:
        return 'Rouge';
      case CardColor.green:
        return 'Vert';
    }
  }

  String get emoji {
    switch (this) {
      case CardColor.white:
        return '🤍';
      case CardColor.blue:
        return '💙';
      case CardColor.yellow:
        return '💛';
      case CardColor.red:
        return '❤️';
      case CardColor.green:
        return '💚';
    }
  }

  /// Niveau de tension minimum requis pour jouer cette couleur (0-100)
  double get requiredTension {
    switch (this) {
      case CardColor.white:
        return 0.0;
      case CardColor.blue:
        return 25.0;
      case CardColor.yellow:
        return 50.0;
      case CardColor.red:
        return 75.0;
      case CardColor.green:
        return 0.0; // Toujours disponible pour les négociations
    }
  }

  /// Couleur pour l'UI
  int get colorValue {
    switch (this) {
      case CardColor.white:
        return 0xFFE8E8E8;
      case CardColor.blue:
        return 0xFF64B5F6;
      case CardColor.yellow:
        return 0xFFFFEB3B;
      case CardColor.red:
        return 0xFFE53935;
      case CardColor.green:
        return 0xFF4CAF50;
    }
  }
}
