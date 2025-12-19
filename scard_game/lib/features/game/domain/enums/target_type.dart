/// Types de cibles pour les mécaniques
enum TargetType {
  /// N'importe quelle carte
  anyCard,

  /// Carte de la main du lanceur
  ownHand,

  /// Enchantement du lanceur
  ownEnchantment,

  /// Enchantement de l'adversaire
  opponentEnchantment,

  /// N'importe quel enchantement
  anyEnchantment,

  /// Le sort en cours de résolution
  currentSpell,

  /// Aucune cible
  none,
}

extension TargetTypeExtension on TargetType {
  String get displayName {
    switch (this) {
      case TargetType.anyCard:
        return 'N\'importe quelle carte';
      case TargetType.ownHand:
        return 'Votre main';
      case TargetType.ownEnchantment:
        return 'Vos enchantements';
      case TargetType.opponentEnchantment:
        return 'Enchantements adverses';
      case TargetType.anyEnchantment:
        return 'Tous les enchantements';
      case TargetType.currentSpell:
        return 'Sort en cours';
      case TargetType.none:
        return 'Aucune cible';
    }
  }
}
