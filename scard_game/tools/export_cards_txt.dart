import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final inputPath = 'assets/data/cards.json';
  final outputPath = 'cards_catalog.txt';

  try {
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      stderr.writeln('Input file not found: $inputPath');
      exit(1);
    }

    final jsonStr = await inputFile.readAsString();
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final cards = (data['cards'] as List).cast<Map<String, dynamic>>();

    final buffer = StringBuffer();
    buffer.writeln('Catalogue des cartes');
    buffer.writeln('====================');
    buffer.writeln('Total: ${cards.length} cartes');
    buffer.writeln('');

    for (final c in cards) {
      final name = c['name']?.toString() ?? '-';
      final color = c['color']?.toString() ?? '-';
      final cost = c['launcherCost']?.toString() ?? '-';
      final gameEffect = c['gameEffect']?.toString() ?? '-';
      final targetEffect = c['targetEffect']?.toString() ?? '-';

      buffer.writeln('Nom: $name');
      buffer.writeln('Couleur: $color');
      buffer.writeln('Coût: $cost');
      buffer.writeln('En jeu: $gameEffect');
      buffer.writeln('IRL: $targetEffect');
      buffer.writeln('');
      buffer.writeln('---');
      buffer.writeln('');
    }

    final outFile = File(outputPath);
    await outFile.writeAsString(buffer.toString(), encoding: utf8);

    stdout.writeln('Export terminé → ${outFile.path}');
  } catch (e, st) {
    stderr.writeln('Erreur export: $e');
    stderr.writeln(st);
    exit(1);
  }
}
