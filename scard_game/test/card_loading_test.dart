import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  test('cards.json loads correctly with mechanics', () {
    // Load the JSON file
    final file = File('assets/data/cards.json');
    expect(file.existsSync(), true, reason: 'cards.json should exist');

    // Parse JSON
    final jsonString = file.readAsStringSync();
    final jsonData = json.decode(jsonString);

    expect(jsonData, isA<Map>());
    expect(jsonData['cards'], isA<List>());

    final cards = jsonData['cards'] as List;
    _debugPrint('✅ Loaded ${cards.length} cards');

    // Check that special cards have mechanics
    final cardsWithMechanics =
        cards
            .where(
              (card) =>
                  card['mechanics'] != null &&
                  (card['mechanics'] as List).isNotEmpty,
            )
            .toList();

    _debugPrint('✅ ${cardsWithMechanics.length} cards have mechanics defined');

    // Verify that we have some cards with mechanics
    expect(
      cardsWithMechanics.isNotEmpty,
      true,
      reason: 'At least some cards should have mechanics',
    );

    // Verify ULTIMA card exists and has mechanics (core game card)
    final red016 = cards.firstWhere(
      (card) => card['id'] == 'red_016',
      orElse: () => null,
    );
    expect(red016, isNotNull, reason: 'red_016 (ULTIMA) should exist');
    expect(red016['mechanics'], isNotEmpty);
    expect(red016['mechanics'][0]['type'], 'turnCounter');
    expect(red016['mechanics'][0]['initialCounterValue'], 3);
    _debugPrint('✅ red_016 "Ultima" has turnCounter mechanic (3 turns)');

    // Verify structure of cards with mechanics
    for (final card in cardsWithMechanics) {
      final mechanics = card['mechanics'] as List;
      for (final mechanic in mechanics) {
        expect(
          mechanic['type'],
          isNotNull,
          reason: 'Mechanic must have a type for card ${card['id']}',
        );
      }
      _debugPrint('✅ ${card['id']} has valid mechanic structure');
    }

    _debugPrint('\n🎉 All mechanics validated successfully!');
    _debugPrint('📊 Total cards: ${cards.length}');
    _debugPrint('⚙️  Cards with mechanics: ${cardsWithMechanics.length}');
  });

  test('cards.json has required fields for all cards', () {
    final file = File('assets/data/cards.json');
    final jsonData = json.decode(file.readAsStringSync());
    final cards = jsonData['cards'] as List;

    for (final card in cards) {
      expect(card['id'], isNotNull, reason: 'Card must have id');
      expect(
        card['name'],
        isNotNull,
        reason: 'Card ${card['id']} must have name',
      );
      expect(
        card['color'],
        isNotNull,
        reason: 'Card ${card['id']} must have color',
      );
    }

    _debugPrint('✅ All ${cards.length} cards have required fields');
  });

  test('cards have valid color values', () {
    final file = File('assets/data/cards.json');
    final jsonData = json.decode(file.readAsStringSync());
    final cards = jsonData['cards'] as List;

    const validColors = ['white', 'blue', 'yellow', 'red', 'green'];

    for (final card in cards) {
      expect(
        validColors.contains(card['color']),
        true,
        reason: 'Card ${card['id']} has invalid color: ${card['color']}',
      );
    }

    _debugPrint('✅ All cards have valid colors');
  });
}

// Wrapper for test output - avoids avoid_print lint in test files
void _debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
