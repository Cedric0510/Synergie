import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/game_exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/enums/card_color.dart';
import '../../domain/models/deck_configuration.dart';
import '../../domain/models/game_card.dart';
import 'card_service.dart';
import 'custom_deck_service.dart';

/// Provider pour le service de deck
final deckServiceProvider = Provider<DeckService>((ref) {
  final cardService = ref.watch(cardServiceProvider);
  final customDeckService = ref.watch(customDeckServiceProvider);
  final logger = ref.watch(loggerServiceProvider);
  return DeckService(cardService, customDeckService, logger);
});

/// Service de gestion des decks de cartes
class DeckService {
  final CardService _cardService;
  final CustomDeckService _customDeckService;
  final LoggerService _logger;
  final Random _random = Random();

  DeckService(this._cardService, this._customDeckService, this._logger);

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

    _logger.debug(
      'DeckService',
      'Génération deck - Couleurs: $allowedColors, ${allCards.length} cartes chargées',
    );

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
      _logger.debug('DeckService', '${card.id} (${card.color}) × $count');

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
        _logger.debug(
          'DeckService',
          '${shuffledGreen[i].id} (green) × 1 [négociation ${i + 1}/$maxGreenCards]',
        );
      }
    }

    _logger.info('DeckService', 'Deck généré: ${deck.length} cartes');
    return deck;
  }

  /// Génère un deck à partir d'une configuration personnalisée
  /// Respecte les choix du joueur (nombre d'exemplaires par carte)
  Future<List<String>> generateDeckFromConfig({
    required DeckConfiguration config,
  }) async {
    final List<String> deck = [];

    _logger.debug(
      'DeckService',
      'Génération deck personnalisé: ${config.name}, ${config.totalCards} cartes',
    );

    // Vérifier que la config est valide
    if (!config.isValid) {
      throw DeckException(
        'Configuration de deck invalide : ${config.totalCards} cartes '
        '(25 requises)',
      );
    }

    // Construire le deck selon la configuration
    for (final entry in config.cardCounts.entries) {
      final cardId = entry.key;
      final count = entry.value;

      if (count > 0) {
        // Ajouter le nombre d'exemplaires spécifié
        for (int i = 0; i < count; i++) {
          deck.add(cardId);
        }
        _logger.debug('DeckService', '$cardId × $count');
      }
    }

    _logger.info(
      'DeckService',
      'Deck personnalisé généré: ${deck.length} cartes',
    );
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
  /// Utilise automatiquement le deck personnalisé s'il existe
  Future<({List<String> hand, List<String> deck})> initializePlayerDeck({
    required List<CardColor> allowedColors,
    DeckConfiguration? customConfig,
  }) async {
    // Génération du deck complet
    final List<String> fullDeck;

    // Essayer de charger le deck personnalisé si pas fourni
    if (customConfig == null) {
      try {
        customConfig = await _customDeckService.loadDeckConfiguration();
      } catch (e) {
        _logger.warning('DeckService', 'Pas de deck personnalisé trouvé');
      }
    }

    if (customConfig != null && customConfig.isValid) {
      // Utiliser la configuration personnalisée
      _logger.info('DeckService', 'Deck personnalisé: ${customConfig.name}');
      fullDeck = await generateDeckFromConfig(config: customConfig);
    } else {
      // Utiliser la génération par défaut
      _logger.info('DeckService', 'Deck par défaut');
      fullDeck = await generateDeck(allowedColors: allowedColors);
    }

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
      throw DeckException(
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

    _logger.info(
      'DeckService',
      'Main initiale: 4 blanches + 2 bleues, deck restant: ${remainingDeck.length}',
    );

    return (hand: startingHand, deck: remainingDeck);
  }

  /// Génère un deck en utilisant le deck personnalisé s'il existe, sinon le deck par défaut
  Future<List<String>> generatePlayerDeck({
    required List<CardColor> allowedColors,
  }) async {
    _logger.debug('DeckService', 'Chargement deck joueur...');

    try {
      // Essayer de charger le deck personnalisé
      final customConfig = await _customDeckService.loadDeckConfiguration();

      if (customConfig.isValid && customConfig.cardCounts.isNotEmpty) {
        _logger.info(
          'DeckService',
          'Deck personnalisé trouvé: ${customConfig.name}',
        );
        return await generateDeckFromConfig(config: customConfig);
      }
    } catch (e) {
      _logger.warning(
        'DeckService',
        'Pas de deck personnalisé, utilisation du deck par défaut',
      );
    }

    // Sinon, utiliser le deck par défaut
    _logger.info('DeckService', 'Utilisation du deck par défaut');
    return await generateDeck(allowedColors: allowedColors);
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
