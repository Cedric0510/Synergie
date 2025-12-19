import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_card.dart';
import '../../domain/enums/card_color.dart' as game;

/// Provider pour le service de cartes
final cardServiceProvider = Provider<CardService>((ref) {
  return CardService();
});

/// Provider pour charger toutes les cartes
final allCardsProvider = FutureProvider<List<GameCard>>((ref) async {
  final service = ref.watch(cardServiceProvider);
  return service.loadAllCards();
});

/// Provider pour les cartes groupées par couleur
final cardsByColorProvider =
    FutureProvider<Map<game.CardColor, List<GameCard>>>((ref) async {
      final cards = await ref.watch(allCardsProvider.future);
      return _groupCardsByColor(cards);
    });

/// Service pour gérer les cartes
class CardService {
  /// Charge toutes les cartes depuis le fichier JSON
  Future<List<GameCard>> loadAllCards() async {
    try {
      // Charger le fichier JSON
      final jsonString = await rootBundle.loadString('assets/data/cards.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Parser les cartes
      final cardsJson = jsonData['cards'] as List<dynamic>;
      final cards = <GameCard>[];

      for (var i = 0; i < cardsJson.length; i++) {
        try {
          final cardJson = cardsJson[i] as Map<String, dynamic>;
          final card = GameCard.fromJson(cardJson);
          cards.add(card);
        } catch (e) {
          print('❌ Erreur lors du chargement de la carte à l\'index $i: $e');
          print('JSON de la carte: ${cardsJson[i]}');
          rethrow;
        }
      }

      return cards;
    } catch (e) {
      print('Erreur lors du chargement des cartes: $e');
      rethrow;
    }
  }

  /// Récupère les cartes d'une couleur spécifique
  List<GameCard> filterByColor(List<GameCard> cards, game.CardColor color) {
    return cards.where((card) => card.color == color).toList();
  }

  /// Trie les cartes par nom
  List<GameCard> sortByName(List<GameCard> cards) {
    final sorted = List<GameCard>.from(cards);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }
}

/// Groupe les cartes par couleur
Map<game.CardColor, List<GameCard>> _groupCardsByColor(List<GameCard> cards) {
  final grouped = <game.CardColor, List<GameCard>>{};

  for (final color in game.CardColor.values) {
    grouped[color] = cards.where((card) => card.color == color).toList();
  }

  return grouped;
}
