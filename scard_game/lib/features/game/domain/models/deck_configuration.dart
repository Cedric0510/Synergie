import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_configuration.freezed.dart';
part 'deck_configuration.g.dart';

/// Configuration personnalisée d'un deck
/// Permet aux joueurs de construire leur propre deck
@freezed
class DeckConfiguration with _$DeckConfiguration {
  const factory DeckConfiguration({
    /// Map de cardId -> nombre d'exemplaires (0-4, sauf Ultima: 1 max)
    required Map<String, int> cardCounts,

    /// Nom du deck (optionnel)
    @Default('Mon Deck') String name,

    /// Date de dernière modification
    DateTime? lastModified,
  }) = _DeckConfiguration;

  factory DeckConfiguration.fromJson(Map<String, dynamic> json) =>
      _$DeckConfigurationFromJson(json);

  const DeckConfiguration._();

  /// Calcule le nombre total de cartes dans le deck
  int get totalCards => cardCounts.values.fold(0, (sum, count) => sum + count);

  /// Vérifie si la configuration est valide (25 cartes exactement)
  bool get isValid => totalCards == 25;

  /// Deck par défaut (généré selon les règles actuelles)
  factory DeckConfiguration.defaultDeck() {
    return DeckConfiguration(
      name: 'Deck de base',
      cardCounts: {
        // Rituels blancs (5 × 2 = 10)
        'white_001': 2,
        'white_002': 2,
        'white_003': 2,
        'white_004': 2,
        'white_005': 2,
        // Rituels bleus (2 × 2 = 4)
        'blue_005': 2,
        'blue_006': 2,
        // Enchantements (3 × 2 + Ultima = 7)
        'white_009': 2,
        'white_010': 2,
        'white_011': 2,
        'red_016': 1, // Ultima unique
        // Négociations vertes (4 × 1 = 4)
        'green_001': 1,
        'green_002': 1,
        'green_003': 1,
        'green_004': 1,
      },
      lastModified: DateTime.now(),
    );
  }
}
