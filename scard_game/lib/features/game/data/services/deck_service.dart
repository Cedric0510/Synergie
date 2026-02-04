import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums/card_color.dart';
import '../../domain/models/game_card.dart';
import 'card_service.dart';

/// Provider pour le service de deck
final deckServiceProvider = Provider<DeckService>((ref) {
  final cardService = ref.watch(cardServiceProvider);
  return DeckService(cardService);
});

/// Service de gestion des decks de cartes
class DeckService {
  final CardService _cardService;
  final Random _random = Random();

  DeckService(this._cardService);

  /// Génère un deck complet selon les règles :
  /// - 2 exemplaires par carte (deck de base)
  /// - 1 exemplaire si maxPerDeck = 1 (Ultima uniquement)
  /// - Maximum 4 cartes de négociation (vertes) par deck
  /// - Filtre par niveau : white, blue, yellow, red
  Future<List<String>> generateDeck({
    required List<CardColor> allowedColors,
  }) async {
    final allCards = await _cardService.loadAllCards();
    final List<String> deck = [];

    debugPrint('📦 Génération deck - Couleurs autorisées: $allowedColors');
    debugPrint('📦 Total cartes chargées: ${allCards.length}');

    // Séparer les cartes vertes (négociations) des autres
    final greenCards =
        allCards.where((c) => c.color == CardColor.green).toList();
    final otherCards =
        allCards.where((c) => c.color != CardColor.green).toList();

    // Ajouter les cartes non-vertes normalement
    for (final card in otherCards) {
      // Vérifier si la couleur de la carte est autorisée pour ce niveau
      if (!allowedColors.contains(card.color)) {
        continue;
      }

      // Nouvelle règle : 2 exemplaires par défaut, sauf Ultima (1 seul)
      final int count = (card.maxPerDeck == 1) ? 1 : 2;
      debugPrint('  ✅ ${card.id} (${card.color}) × $count');

      // Ajouter uniquement les cartes qui existent réellement dans cards.json
      for (int i = 0; i < count; i++) {
        deck.add(card.id);
      }
    }

    // Ajouter exactement 4 cartes de négociation (vertes)
    // On mélange les cartes vertes disponibles et on en prend 4
    if (allowedColors.contains(CardColor.green) && greenCards.isNotEmpty) {
      final shuffledGreen = List<GameCard>.from(greenCards)..shuffle(_random);
      const maxGreenCards = 4;

      for (int i = 0; i < maxGreenCards && i < shuffledGreen.length; i++) {
        deck.add(shuffledGreen[i].id);
        debugPrint(
          '  ✅ ${shuffledGreen[i].id} (green) × 1 [négociation ${i + 1}/$maxGreenCards]',
        );
      }
    }

    debugPrint('📦 Deck généré: ${deck.length} cartes');
    return deck;
  }

  /// Mélange un deck
  List<String> shuffleDeck(List<String> deck) {
    final shuffled = List<String>.from(deck);
    shuffled.shuffle(_random);
    return shuffled;
  }

  /// Pioche N cartes du deck
  /// Retourne les cartes piochées et le deck restant
  ({List<String> drawnCards, List<String> remainingDeck}) drawCards(
    List<String> deck,
    int count,
  ) {
    final int actualCount = count.clamp(0, deck.length);
    final drawnCards = deck.sublist(0, actualCount);
    final remainingDeck = deck.sublist(actualCount);

    return (drawnCards: drawnCards, remainingDeck: remainingDeck);
  }

  /// Génère et mélange un deck, puis pioche la main de départ (6 cartes)
  /// Distribution intelligente : main de départ avec majorité de cartes blanches
  Future<({List<String> hand, List<String> deck})> initializePlayerDeck({
    required List<CardColor> allowedColors,
  }) async {
    // Génération du deck complet avec toutes les couleurs
    final fullDeck = await generateDeck(allowedColors: allowedColors);

    // Séparer les cartes par couleur pour la main initiale
    final whiteCards = fullDeck.where((id) => id.startsWith('white_')).toList();
    final blueCards = fullDeck.where((id) => id.startsWith('blue_')).toList();
    final otherCards =
        fullDeck
            .where((id) => !id.startsWith('white_') && !id.startsWith('blue_'))
            .toList();

    // Mélanger chaque groupe
    whiteCards.shuffle(_random);
    blueCards.shuffle(_random);
    otherCards.shuffle(_random);

    // Construire la main de départ : 4 blanches, 2 bleues (jouables rapidement)
    final List<String> startingHand = [];

    // 4 cartes blanches (jouables immédiatement)
    startingHand.addAll(whiteCards.take(4));

    // 2 cartes bleues (jouables au prochain niveau ~25%)
    startingHand.addAll(blueCards.take(2));

    if (startingHand.length < 6) {
      throw Exception(
        'Pas assez de cartes blanches et bleues pour la main de départ ! '
        'Trouvées: ${startingHand.length}, requis: 6',
      );
    }

    // Retirer les cartes de la main du deck et mélanger le reste
    final remainingDeck = List<String>.from(fullDeck);
    for (final cardId in startingHand) {
      remainingDeck.remove(cardId);
    }
    remainingDeck.shuffle(_random);

    // Mélanger la main pour ne pas avoir toutes les blanches d'abord
    startingHand.shuffle(_random);

    debugPrint('🎴 Main initiale: 4 blanches + 2 bleues');
    debugPrint('🎴 Deck restant: ${remainingDeck.length} cartes');

    return (hand: startingHand, deck: remainingDeck);
  }

  /// Pioche une seule carte
  Future<({String? card, List<String> remainingDeck})> drawSingleCard(
    List<String> deck,
  ) async {
    if (deck.isEmpty) {
      return (card: null, remainingDeck: <String>[]);
    }

    return (card: deck.first, remainingDeck: deck.sublist(1));
  }
}
