/// Type d'effet de la carte de réponse
enum ResponseEffect {
  /// Annule complètement le sort (ex: Contre)
  cancel,

  /// Copie le sort (ex: Miroir)
  copy,

  /// Remplace le sort par un autre (ex: Échange)
  replace,

  /// Aucun effet sur le sort principal
  noEffect,
}

extension ResponseEffectExtension on ResponseEffect {
  String get displayName {
    switch (this) {
      case ResponseEffect.cancel:
        return 'Il annule votre sort';
      case ResponseEffect.copy:
        return 'Il copie votre sort';
      case ResponseEffect.replace:
        return 'Il remplace votre sort';
      case ResponseEffect.noEffect:
        return 'Aucun effet sur votre sort';
    }
  }
}
