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
    print('✅ Loaded ${cards.length} cards');

    // Check that special cards have mechanics
    final cardsWithMechanics =
        cards
            .where(
              (card) =>
                  card['mechanics'] != null &&
                  (card['mechanics'] as List).isNotEmpty,
            )
            .toList();

    print('✅ ${cardsWithMechanics.length} cards have mechanics defined');

    // Verify specific cards
    final white008 = cards.firstWhere((card) => card['id'] == 'white_008');
    expect(white008['mechanics'], isNotEmpty);
    expect(white008['mechanics'][0]['type'], 'sacrificeCard');
    print('✅ white_008 "Echange" has sacrificeCard mechanic');

    final blue008 = cards.firstWhere((card) => card['id'] == 'blue_008');
    expect(blue008['mechanics'], isNotEmpty);
    expect(blue008['mechanics'][0]['type'], 'drawUntil');
    print('✅ blue_008 "Ping Pong" has drawUntil mechanic');

    final yellow011 = cards.firstWhere((card) => card['id'] == 'yellow_011');
    expect(yellow011['mechanics'], isNotEmpty);
    expect(yellow011['mechanics'][0]['type'], 'counterBased');
    print('✅ yellow_011 "Piège" has counterBased mechanic');

    final red016 = cards.firstWhere((card) => card['id'] == 'red_016');
    expect(red016['mechanics'], isNotEmpty);
    expect(red016['mechanics'][0]['type'], 'turnCounter');
    expect(red016['mechanics'][0]['initialCounterValue'], 3);
    print('✅ red_016 "Ultima" has turnCounter mechanic (3 turns)');

    print('\n🎉 All mechanics validated successfully!');
    print('📊 Total cards: ${cards.length}');
    print('⚙️  Cards with mechanics: ${cardsWithMechanics.length}');
  });
}
