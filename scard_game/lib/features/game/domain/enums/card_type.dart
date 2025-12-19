/// Type de carte dans le jeu
enum CardType {
  /// Sort instantané - Peut être joué à tout moment (ton tour, tour adverse, en réponse)
  instant,

  /// Rituel - Uniquement pendant ton tour, effet immédiat puis va au cimetière
  ritual,

  /// Enchantement - Reste sur la table jusqu'à destruction, effet continu
  enchantment,
}

extension CardTypeExtension on CardType {
  String get displayName {
    switch (this) {
      case CardType.instant:
        return 'Sort Instantané';
      case CardType.ritual:
        return 'Rituel';
      case CardType.enchantment:
        return 'Enchantement';
    }
  }

  String get emoji {
    switch (this) {
      case CardType.instant:
        return '⚡';
      case CardType.ritual:
        return '🔮';
      case CardType.enchantment:
        return '✨';
    }
  }
}
