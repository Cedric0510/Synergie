/// Statut de la partie
enum GameStatus {
  /// En attente - partie pas encore commencée
  waiting,

  /// En cours - partie en cours
  playing,

  /// Terminée - partie finie
  finished,
}

extension GameStatusExtension on GameStatus {
  String get displayName {
    switch (this) {
      case GameStatus.waiting:
        return 'En attente';
      case GameStatus.playing:
        return 'En cours';
      case GameStatus.finished:
        return 'Terminée';
    }
  }
}
