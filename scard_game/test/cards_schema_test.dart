import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const legacyIdColorOverrides = <String, String>{
  'blue_005': 'white',
  'blue_006': 'white',
};

void main() {
  group('cards.json schema', () {
    test('has valid root object and cards list', () {
      final root = _loadRoot();
      expect(root, isA<Map<String, dynamic>>());
      expect(root['cards'], isA<List>());
      expect((root['cards'] as List).isNotEmpty, true);
    });

    test('cards have stable structure and field types', () {
      final cards = _loadCards();
      final ids = <String>{};

      for (final card in cards) {
        final id = _expectNonEmptyString(card, 'id');
        expect(ids.add(id), true, reason: 'Duplicate card id: $id');

        _expectNonEmptyString(card, 'name');
        _expectNonEmptyString(card, 'type');
        _expectNonEmptyString(card, 'color');
        _expectNonEmptyString(card, 'launcherCost');
        _expectNonEmptyString(card, 'gameEffect');

        final imageUrl = _expectNonEmptyString(card, 'imageUrl');
        expect(
          imageUrl.startsWith('assets/'),
          true,
          reason: '$id: imageUrl must start with assets/',
        );

        expect(card['recurringEffects'], isA<List>(), reason: id);
        expect(card['statusModifiers'], isA<List>(), reason: id);
        expect(card['mechanics'], isA<List>(), reason: id);

        expect(card['tierTitles'], isA<Map>(), reason: id);
        expect(card['tierImageUrls'], isA<Map>(), reason: id);
        expect(card['enchantmentTargets'], isA<Map>(), reason: id);
      }
    });

    test('tier statements are consistent when tiered format is used', () {
      final cards = _loadCards();
      for (final card in cards) {
        final id = card['id'] as String;
        final gameEffect = card['gameEffect'] as String;
        _expectTierConsistency(id, gameEffect);
      }
    });

    test('id prefix matches color except explicit legacy ids', () {
      final cards = _loadCards();
      final ids = <String>{};

      for (final card in cards) {
        final id = card['id'] as String;
        final color = card['color'] as String;
        ids.add(id);

        final expectedLegacyColor = legacyIdColorOverrides[id];
        if (expectedLegacyColor != null) {
          expect(
            color,
            expectedLegacyColor,
            reason: '$id should keep legacy color contract',
          );
          continue;
        }

        final prefix = id.split('_').first;
        expect(prefix, color, reason: '$id prefix must match color');
      }

      for (final legacyId in legacyIdColorOverrides.keys) {
        expect(
          ids.contains(legacyId),
          true,
          reason: 'Missing legacy id: $legacyId',
        );
      }
    });
  });
}

Map<String, dynamic> _loadRoot() {
  final file = File('assets/data/cards.json');
  expect(file.existsSync(), true, reason: 'cards.json should exist');
  final raw = file.readAsStringSync();
  final decoded = json.decode(raw);
  expect(decoded, isA<Map<String, dynamic>>());
  return decoded as Map<String, dynamic>;
}

List<Map<String, dynamic>> _loadCards() {
  final root = _loadRoot();
  final cardsNode = root['cards'] as List;
  return cardsNode
      .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
      .toList();
}

String _expectNonEmptyString(Map<String, dynamic> card, String key) {
  final value = card[key];
  expect(value, isA<String>(), reason: '${card['id']}: $key');
  final text = value as String;
  expect(text.trim().isNotEmpty, true, reason: '${card['id']}: $key empty');
  return text;
}

void _expectTierConsistency(String id, String gameEffect) {
  final lines =
      gameEffect
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

  final counts = <String, int>{'blanc': 0, 'bleu': 0, 'jaune': 0, 'rouge': 0};

  for (final line in lines) {
    final lower = line.toLowerCase();
    if (lower.startsWith('blanc:')) counts['blanc'] = counts['blanc']! + 1;
    if (lower.startsWith('bleu:')) counts['bleu'] = counts['bleu']! + 1;
    if (lower.startsWith('jaune:')) counts['jaune'] = counts['jaune']! + 1;
    if (lower.startsWith('rouge:')) counts['rouge'] = counts['rouge']! + 1;
  }

  final hasTieredFormat = counts.values.any((c) => c > 0);
  if (!hasTieredFormat) return;

  for (final entry in counts.entries) {
    expect(
      entry.value,
      1,
      reason: '$id should have exactly one "${entry.key}:" statement',
    );
  }
}
