import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final inputPath = args.isNotEmpty ? args.first : 'assets/data/cards.json';
  final file = File(inputPath);

  if (!file.existsSync()) {
    stderr.writeln('ERROR: file not found: $inputPath');
    exit(1);
  }

  late final Map<String, dynamic> root;
  try {
    final raw = file.readAsStringSync();
    final decoded = json.decode(raw);
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln('ERROR: root JSON must be an object');
      exit(1);
    }
    root = decoded;
  } catch (e) {
    stderr.writeln('ERROR: invalid JSON: $e');
    exit(1);
  }

  final cardsNode = root['cards'];
  if (cardsNode is! List) {
    stderr.writeln('ERROR: "cards" must be a list');
    exit(1);
  }
  if (cardsNode.isEmpty) {
    stderr.writeln('ERROR: "cards" list is empty');
    exit(1);
  }

  final errors = <String>[];
  final warnings = <String>[];
  final seenIds = <String>{};
  final ids = <String>[];

  const requiredStringFields = <String>[
    'id',
    'name',
    'type',
    'color',
    'launcherCost',
    'gameEffect',
  ];
  const legacyIdColorOverrides = <String, String>{
    // Legacy IDs kept for backward compatibility with existing deck/session data.
    'blue_005': 'white',
    'blue_006': 'white',
  };

  for (var i = 0; i < cardsNode.length; i++) {
    final node = cardsNode[i];
    if (node is! Map<String, dynamic>) {
      errors.add('card[$i] must be an object');
      continue;
    }

    final card = node;
    final id = card['id'];
    if (id is! String || id.trim().isEmpty) {
      errors.add('card[$i] has invalid id');
      continue;
    }

    ids.add(id);
    if (!seenIds.add(id)) {
      errors.add('duplicate id: $id');
    }

    for (final key in requiredStringFields) {
      final value = card[key];
      if (value is! String || value.trim().isEmpty) {
        errors.add('$id: "$key" must be a non-empty string');
      }
    }

    final imageUrl = card['imageUrl'];
    if (imageUrl is! String || imageUrl.trim().isEmpty) {
      errors.add('$id: "imageUrl" must be a non-empty string');
    } else if (!imageUrl.startsWith('assets/')) {
      errors.add('$id: imageUrl must start with "assets/"');
    }

    _requireList(card, id, 'recurringEffects', errors);
    _requireList(card, id, 'statusModifiers', errors);
    _requireList(card, id, 'mechanics', errors);

    _requireMap(card, id, 'tierTitles', errors);
    _requireMap(card, id, 'tierImageUrls', errors);
    _requireMap(card, id, 'enchantmentTargets', errors);

    final color = card['color'];
    if (color is String) {
      final expectedLegacyColor = legacyIdColorOverrides[id];
      if (expectedLegacyColor != null && color != expectedLegacyColor) {
        errors.add(
          '$id: expected legacy color "$expectedLegacyColor", got "$color"',
        );
      }

      final prefix = id.split('_').first;
      if (prefix != color && expectedLegacyColor == null) {
        warnings.add('$id: id prefix "$prefix" != color "$color"');
      }
    }

    final gameEffect = card['gameEffect'];
    if (gameEffect is String) {
      _validateTierStatements(id, gameEffect, errors);
    }
  }

  final sortedIds = [...ids]..sort();
  if (!_sameOrder(ids, sortedIds)) {
    warnings.add('cards are not sorted by id');
  }

  for (final legacyId in legacyIdColorOverrides.keys) {
    if (!seenIds.contains(legacyId)) {
      errors.add('missing required legacy card id: $legacyId');
    }
  }

  stdout.writeln('Cards checked: ${cardsNode.length}');
  stdout.writeln('Errors: ${errors.length}');
  stdout.writeln('Warnings: ${warnings.length}');

  if (warnings.isNotEmpty) {
    stdout.writeln('\nWarnings:');
    for (final w in warnings) {
      stdout.writeln('- $w');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('\nErrors:');
    for (final e in errors) {
      stderr.writeln('- $e');
    }
    exit(1);
  }

  stdout.writeln('\nOK: cards.json is valid.');
}

void _requireList(
  Map<String, dynamic> card,
  String id,
  String key,
  List<String> errors,
) {
  final value = card[key];
  if (value is! List) {
    errors.add('$id: "$key" must be a list');
  }
}

void _requireMap(
  Map<String, dynamic> card,
  String id,
  String key,
  List<String> errors,
) {
  final value = card[key];
  if (value is! Map) {
    errors.add('$id: "$key" must be an object');
  }
}

void _validateTierStatements(
  String id,
  String gameEffect,
  List<String> errors,
) {
  final lines =
      gameEffect
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
  final tiers = <String, int>{'blanc': 0, 'bleu': 0, 'jaune': 0, 'rouge': 0};

  for (final line in lines) {
    final lower = line.toLowerCase();
    if (lower.startsWith('blanc:')) tiers['blanc'] = tiers['blanc']! + 1;
    if (lower.startsWith('bleu:')) tiers['bleu'] = tiers['bleu']! + 1;
    if (lower.startsWith('jaune:')) tiers['jaune'] = tiers['jaune']! + 1;
    if (lower.startsWith('rouge:')) tiers['rouge'] = tiers['rouge']! + 1;
  }

  final hasTieredFormat = tiers.values.any((v) => v > 0);
  if (!hasTieredFormat) return;

  for (final entry in tiers.entries) {
    if (entry.value != 1) {
      errors.add('$id: expected exactly one "${entry.key}:" statement');
    }
  }
}

bool _sameOrder(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
