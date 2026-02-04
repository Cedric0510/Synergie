import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/features/game/data/services/deck_service.dart';
import 'package:scard_game/features/game/data/services/card_service.dart';
import 'package:scard_game/features/game/domain/enums/card_color.dart';
import 'package:scard_game/features/game/domain/models/game_card.dart';

// Mock CardService pour les tests
class MockCardService extends CardService {
  @override
  Future<List<GameCard>> loadAllCards() async {
    // Retourner une liste vide pour les tests de shuffle/draw
    return [];
  }
}

void main() {
  group('DeckService - shuffleDeck', () {
    late DeckService deckService;

    setUp(() {
      deckService = DeckService(MockCardService());
    });

    test('shuffleDeck returns same cards in different order', () {
      final originalDeck = ['card1', 'card2', 'card3', 'card4', 'card5'];

      // Shuffle multiple times to ensure randomization
      bool foundDifferentOrder = false;
      for (int i = 0; i < 10; i++) {
        final shuffled = deckService.shuffleDeck(originalDeck);

        // Same length
        expect(shuffled.length, originalDeck.length);

        // Same cards (content)
        expect(shuffled.toSet(), originalDeck.toSet());

        // Check if order is different at least once
        if (!_listsEqual(shuffled, originalDeck)) {
          foundDifferentOrder = true;
        }
      }

      // With 10 attempts, we should find at least one different order
      expect(
        foundDifferentOrder,
        true,
        reason: 'Shuffle should produce different order',
      );
    });

    test('shuffleDeck preserves all cards', () {
      final originalDeck = List.generate(50, (i) => 'card_$i');
      final shuffled = deckService.shuffleDeck(originalDeck);

      expect(shuffled.length, 50);
      for (final card in originalDeck) {
        expect(
          shuffled.contains(card),
          true,
          reason: 'Shuffled deck should contain $card',
        );
      }
    });

    test('shuffleDeck handles empty deck', () {
      final emptyDeck = <String>[];
      final shuffled = deckService.shuffleDeck(emptyDeck);
      expect(shuffled, isEmpty);
    });

    test('shuffleDeck handles single card deck', () {
      final singleCard = ['only_card'];
      final shuffled = deckService.shuffleDeck(singleCard);
      expect(shuffled, ['only_card']);
    });

    test('shuffleDeck does not modify original deck', () {
      final originalDeck = ['a', 'b', 'c', 'd', 'e'];
      final copyBeforeShuffle = List<String>.from(originalDeck);

      deckService.shuffleDeck(originalDeck);

      expect(
        originalDeck,
        copyBeforeShuffle,
        reason: 'Original deck should not be modified',
      );
    });
  });

  group('DeckService - drawCards', () {
    late DeckService deckService;

    setUp(() {
      deckService = DeckService(MockCardService());
    });

    test('drawCards returns correct number of cards', () {
      final deck = ['card1', 'card2', 'card3', 'card4', 'card5'];
      final result = deckService.drawCards(deck, 3);

      expect(result.drawnCards.length, 3);
      expect(result.remainingDeck.length, 2);
    });

    test('drawCards returns cards from top of deck', () {
      final deck = ['first', 'second', 'third', 'fourth', 'fifth'];
      final result = deckService.drawCards(deck, 2);

      expect(result.drawnCards, ['first', 'second']);
      expect(result.remainingDeck, ['third', 'fourth', 'fifth']);
    });

    test('drawCards with count greater than deck size returns all cards', () {
      final deck = ['card1', 'card2', 'card3'];
      final result = deckService.drawCards(deck, 10);

      expect(result.drawnCards, deck);
      expect(result.remainingDeck, isEmpty);
    });

    test('drawCards with zero count returns no cards', () {
      final deck = ['card1', 'card2', 'card3'];
      final result = deckService.drawCards(deck, 0);

      expect(result.drawnCards, isEmpty);
      expect(result.remainingDeck, deck);
    });

    test('drawCards with negative count returns no cards', () {
      final deck = ['card1', 'card2', 'card3'];
      final result = deckService.drawCards(deck, -5);

      expect(result.drawnCards, isEmpty);
      expect(result.remainingDeck, deck);
    });

    test('drawCards from empty deck returns empty', () {
      final deck = <String>[];
      final result = deckService.drawCards(deck, 3);

      expect(result.drawnCards, isEmpty);
      expect(result.remainingDeck, isEmpty);
    });

    test('drawCards total equals original deck', () {
      final deck = ['a', 'b', 'c', 'd', 'e'];
      final result = deckService.drawCards(deck, 3);

      final combined = [...result.drawnCards, ...result.remainingDeck];
      expect(combined, deck);
    });
  });

  group('DeckService - drawSingleCard', () {
    late DeckService deckService;

    setUp(() {
      deckService = DeckService(MockCardService());
    });

    test('drawSingleCard returns first card', () async {
      final deck = ['first', 'second', 'third'];
      final result = await deckService.drawSingleCard(deck);

      expect(result.card, 'first');
      expect(result.remainingDeck, ['second', 'third']);
    });

    test('drawSingleCard from empty deck returns null', () async {
      final deck = <String>[];
      final result = await deckService.drawSingleCard(deck);

      expect(result.card, isNull);
      expect(result.remainingDeck, isEmpty);
    });

    test('drawSingleCard from single card deck', () async {
      final deck = ['only_card'];
      final result = await deckService.drawSingleCard(deck);

      expect(result.card, 'only_card');
      expect(result.remainingDeck, isEmpty);
    });
  });

  group('CardColor enum integration', () {
    test('CardColor values for deck generation', () {
      // Verify all colors are available for deck generation
      expect(CardColor.white.name, 'white');
      expect(CardColor.blue.name, 'blue');
      expect(CardColor.yellow.name, 'yellow');
      expect(CardColor.red.name, 'red');
      expect(CardColor.green.name, 'green');
    });

    test('allowed colors can be filtered correctly', () {
      final allowedColors = [CardColor.white, CardColor.blue, CardColor.green];

      expect(allowedColors.contains(CardColor.white), true);
      expect(allowedColors.contains(CardColor.blue), true);
      expect(allowedColors.contains(CardColor.yellow), false);
      expect(allowedColors.contains(CardColor.red), false);
      expect(allowedColors.contains(CardColor.green), true);
    });
  });
}

/// Helper function to compare two lists for equality
bool _listsEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
