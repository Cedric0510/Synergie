import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/core/services/logger_service.dart';
import 'package:scard_game/features/game/data/services/card_service.dart';
import 'package:scard_game/features/game/domain/enums/card_color.dart';
import 'package:scard_game/features/game/domain/enums/card_type.dart';
import 'package:scard_game/features/game/domain/models/game_card.dart';

void main() {
  late CardService service;

  final cards = [
    _card('w1', name: 'Alpha', color: CardColor.white),
    _card('b1', name: 'Charlie', color: CardColor.blue),
    _card('b2', name: 'Bravo', color: CardColor.blue),
    _card('y1', name: 'Delta', color: CardColor.yellow),
    _card('r1', name: 'Echo', color: CardColor.red),
    _card('g1', name: 'Foxtrot', color: CardColor.green),
  ];

  setUp(() {
    service = CardService(LoggerService());
  });

  group('CardService - filterByColor', () {
    test('returns only cards matching color', () {
      final result = service.filterByColor(cards, CardColor.blue);
      expect(result.map((c) => c.id), ['b1', 'b2']);
    });

    test('returns empty list when no cards match', () {
      final whiteOnly = [_card('w1', color: CardColor.white)];
      final result = service.filterByColor(whiteOnly, CardColor.red);
      expect(result, isEmpty);
    });

    test('returns all cards when all match color', () {
      final blueCards = [
        _card('b1', color: CardColor.blue),
        _card('b2', color: CardColor.blue),
      ];
      final result = service.filterByColor(blueCards, CardColor.blue);
      expect(result, hasLength(2));
    });
  });

  group('CardService - filterByIds', () {
    test('returns cards matching given IDs', () {
      final result = service.filterByIds(cards, ['b1', 'r1']);
      expect(result.map((c) => c.id).toList(), ['b1', 'r1']);
    });

    test('returns empty list when no IDs match', () {
      final result = service.filterByIds(cards, ['unknown']);
      expect(result, isEmpty);
    });

    test('handles empty IDs list', () {
      final result = service.filterByIds(cards, []);
      expect(result, isEmpty);
    });

    test('ignores duplicate IDs', () {
      final result = service.filterByIds(cards, ['w1', 'w1']);
      // Returns all matches - w1 appears once in cards
      expect(result.map((c) => c.id), ['w1']);
    });
  });

  group('CardService - getCardById', () {
    test('returns card when found', () {
      final result = service.getCardById(cards, 'y1');
      expect(result, isNotNull);
      expect(result!.name, 'Delta');
    });

    test('returns null when not found', () {
      final result = service.getCardById(cards, 'nonexistent');
      expect(result, isNull);
    });
  });

  group('CardService - sortByName', () {
    test('sorts cards alphabetically by name', () {
      final sorted = service.sortByName(cards);
      expect(sorted.map((c) => c.name).toList(), [
        'Alpha',
        'Bravo',
        'Charlie',
        'Delta',
        'Echo',
        'Foxtrot',
      ]);
    });

    test('does not mutate original list', () {
      final original = List<GameCard>.from(cards);
      service.sortByName(cards);
      expect(cards.map((c) => c.id), original.map((c) => c.id));
    });

    test('handles empty list', () {
      final sorted = service.sortByName([]);
      expect(sorted, isEmpty);
    });

    test('handles single card', () {
      final sorted = service.sortByName([_card('a', name: 'Zulu')]);
      expect(sorted, hasLength(1));
    });
  });
}

GameCard _card(
  String id, {
  String name = 'Test',
  CardColor color = CardColor.white,
}) {
  return GameCard(
    id: id,
    name: name,
    type: CardType.ritual,
    color: color,
    launcherCost: 'Aucun',
    gameEffect: 'Test effect',
  );
}
