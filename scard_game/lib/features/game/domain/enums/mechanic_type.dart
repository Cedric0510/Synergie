/// Types de mécaniques spéciales pour les cartes
enum MechanicType {
  /// Sacrifier une carte de la main
  sacrificeCard,

  /// Se défausser d'une carte
  discardCard,

  /// Détruire un enchantement ciblé
  destroyEnchantment,

  /// Remplacer un enchantement existant
  replaceEnchantment,

  /// Piocher jusqu'à trouver une carte spécifique
  drawUntil,

  /// Mélanger la main dans le deck
  shuffleHandIntoDeck,

  /// Piocher X cartes
  drawCards,

  /// Enchantement avec compteur de charges
  counterBased,

  /// Enchantement avec compteur de tours
  turnCounter,

  /// Choix du joueur entre plusieurs options
  playerChoice,

  /// Détruire tous les enchantements d'un joueur
  destroyAllEnchantments,

  /// Remplacer le sort en cours
  replaceSpell,

  /// Contre le sort si condition respectée
  conditionalCounter,
}

extension MechanicTypeExtension on MechanicType {
  String get displayName {
    switch (this) {
      case MechanicType.sacrificeCard:
        return 'Sacrifier une carte';
      case MechanicType.discardCard:
        return 'Défausser une carte';
      case MechanicType.destroyEnchantment:
        return 'Détruire un enchantement';
      case MechanicType.replaceEnchantment:
        return 'Remplacer un enchantement';
      case MechanicType.drawUntil:
        return 'Piocher jusqu\'à...';
      case MechanicType.shuffleHandIntoDeck:
        return 'Mélanger la main';
      case MechanicType.drawCards:
        return 'Piocher des cartes';
      case MechanicType.counterBased:
        return 'Compteur de charges';
      case MechanicType.turnCounter:
        return 'Compteur de tours';
      case MechanicType.playerChoice:
        return 'Choix du joueur';
      case MechanicType.destroyAllEnchantments:
        return 'Détruire tous les enchantements';
      case MechanicType.replaceSpell:
        return 'Remplacer le sort';
      case MechanicType.conditionalCounter:
        return 'Contre conditionnel';
    }
  }
}
