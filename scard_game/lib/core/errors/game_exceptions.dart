/// Base class for all game exceptions.
/// Provides a user-friendly [message] for display in the UI.
sealed class GameException implements Exception {
  final String message;
  final Object? cause;

  const GameException(this.message, [this.cause]);

  @override
  String toString() => message;
}

/// Session not found or expired.
class SessionNotFoundException extends GameException {
  final String sessionId;
  const SessionNotFoundException(this.sessionId) : super('Partie introuvable');
}

/// Game code is invalid or doesn't exist.
class InvalidGameCodeException extends GameException {
  const InvalidGameCodeException() : super('Code de partie invalide');
}

/// Game is already full (2 players).
class GameFullException extends GameException {
  const GameFullException() : super('Cette partie est déjà complète');
}

/// Authentication error.
class AuthException extends GameException {
  const AuthException([String message = 'Erreur de connexion', Object? cause])
    : super(message, cause);
}

/// Deck configuration or generation error.
class DeckException extends GameException {
  const DeckException(super.message);
}

/// Gameplay action that can't be performed.
class GameplayException extends GameException {
  const GameplayException(super.message);
}
