import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/deck_configuration.dart';
import '../../domain/models/game_card.dart';
import '../../data/services/card_service.dart';
import '../../data/services/custom_deck_service.dart';

/// État du deck builder
class DeckBuilderState {
  final DeckConfiguration config;
  final List<GameCard> allCards;
  final bool isLoading;
  final String? errorMessage;

  DeckBuilderState({
    required this.config,
    required this.allCards,
    this.isLoading = false,
    this.errorMessage,
  });

  DeckBuilderState copyWith({
    DeckConfiguration? config,
    List<GameCard>? allCards,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DeckBuilderState(
      config: config ?? this.config,
      allCards: allCards ?? this.allCards,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Nombre total de cartes dans le deck actuel
  int get totalCards => config.totalCards;

  /// Vérifie si le deck est valide (25 cartes)
  bool get isValid => config.isValid;

  /// Obtient le nombre d'exemplaires d'une carte
  int getCardCount(String cardId) => config.cardCounts[cardId] ?? 0;
}

/// Provider pour le deck builder
final deckBuilderProvider =
    StateNotifierProvider<DeckBuilderNotifier, DeckBuilderState>((ref) {
  return DeckBuilderNotifier(
    ref.watch(cardServiceProvider),
    ref.watch(customDeckServiceProvider),
  );
});

/// Notifier pour gérer le deck builder
class DeckBuilderNotifier extends StateNotifier<DeckBuilderState> {
  final CardService _cardService;
  final CustomDeckService _customDeckService;

  DeckBuilderNotifier(this._cardService, this._customDeckService)
      : super(DeckBuilderState(
          config: DeckConfiguration.defaultDeck(),
          allCards: [],
          isLoading: true,
        )) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Charger toutes les cartes
      final allCards = await _cardService.loadAllCards();

      // Charger la configuration actuelle
      final config = await _customDeckService.loadDeckConfiguration();

      state = state.copyWith(
        allCards: allCards,
        config: config,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur de chargement: $e',
      );
    }
  }

  /// Augmente le nombre d'exemplaires d'une carte (+1)
  void incrementCard(String cardId) {
    final currentCount = state.config.cardCounts[cardId] ?? 0;
    final card = state.allCards.firstWhere((c) => c.id == cardId);

    // Vérifier la limite par carte (4 max, sauf Ultima: 1 max)
    final maxPerCard = card.maxPerDeck ?? 4;
    if (currentCount >= maxPerCard) {
      state = state.copyWith(
        errorMessage: 'Maximum $maxPerCard exemplaire(s) pour cette carte',
      );
      return;
    }

    // Vérifier la limite totale (25 cartes)
    if (state.totalCards >= 25) {
      state = state.copyWith(
        errorMessage: 'Deck complet (25 cartes maximum)',
      );
      return;
    }

    // Mettre à jour la configuration
    final newCounts = Map<String, int>.from(state.config.cardCounts);
    newCounts[cardId] = currentCount + 1;

    state = state.copyWith(
      config: state.config.copyWith(
        cardCounts: newCounts,
        lastModified: DateTime.now(),
      ),
      errorMessage: null,
    );
  }

  /// Diminue le nombre d'exemplaires d'une carte (-1)
  void decrementCard(String cardId) {
    final currentCount = state.config.cardCounts[cardId] ?? 0;

    // Ne pas descendre en dessous de 0
    if (currentCount <= 0) {
      return;
    }

    // Mettre à jour la configuration
    final newCounts = Map<String, int>.from(state.config.cardCounts);
    newCounts[cardId] = currentCount - 1;

    // Retirer l'entrée si count = 0
    if (newCounts[cardId] == 0) {
      newCounts.remove(cardId);
    }

    state = state.copyWith(
      config: state.config.copyWith(
        cardCounts: newCounts,
        lastModified: DateTime.now(),
      ),
      errorMessage: null,
    );
  }

  /// Sauvegarde la configuration actuelle
  Future<void> saveConfiguration() async {
    if (!state.isValid) {
      state = state.copyWith(
        errorMessage:
            'Deck invalide: ${state.totalCards}/25 cartes. '
            'Ajustez pour avoir exactement 25 cartes.',
      );
      return;
    }

    try {
      await _customDeckService.saveDeckConfiguration(state.config);
      state = state.copyWith(errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erreur de sauvegarde: $e');
    }
  }

  /// Réinitialise au deck par défaut
  Future<void> resetToDefault() async {
    final defaultConfig = DeckConfiguration.defaultDeck();
    state = state.copyWith(
      config: defaultConfig,
      errorMessage: null,
    );
    await _customDeckService.saveDeckConfiguration(defaultConfig);
  }

  /// Efface le message d'erreur
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
