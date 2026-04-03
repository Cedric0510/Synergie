import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/core/errors/game_exceptions.dart';

void main() {
  group('GameException hierarchy', () {
    test('SessionNotFoundException has fixed message and stores sessionId', () {
      const e = SessionNotFoundException('abc123');
      expect(e.message, 'Partie introuvable');
      expect(e.sessionId, 'abc123');
      expect(e.toString(), 'Partie introuvable');
      expect(e, isA<GameException>());
    });

    test('InvalidGameCodeException has fixed message', () {
      const e = InvalidGameCodeException();
      expect(e.message, 'Code de partie invalide');
      expect(e.toString(), 'Code de partie invalide');
      expect(e, isA<GameException>());
    });

    test('GameFullException has fixed message', () {
      const e = GameFullException();
      expect(e.message, 'Cette partie est déjà complète');
      expect(e, isA<GameException>());
    });

    test('AuthException has default message', () {
      const e = AuthException();
      expect(e.message, 'Erreur de connexion');
      expect(e.cause, isNull);
    });

    test('AuthException accepts custom message and cause', () {
      final cause = Exception('token expired');
      final e = AuthException('Session expirée', cause);
      expect(e.message, 'Session expirée');
      expect(e.cause, cause);
      expect(e, isA<GameException>());
    });

    test('DeckException stores custom message', () {
      const e = DeckException('Pas assez de cartes');
      expect(e.message, 'Pas assez de cartes');
      expect(e.toString(), 'Pas assez de cartes');
    });

    test('GameplayException stores custom message', () {
      const e = GameplayException('Action non autorisée');
      expect(e.message, 'Action non autorisée');
      expect(e.toString(), 'Action non autorisée');
    });

    test('cause defaults to null', () {
      const e = DeckException('test');
      expect(e.cause, isNull);
    });
  });
}
