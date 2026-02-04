import '../../features/game/domain/models/game_card.dart';
import '../../features/game/domain/enums/card_color.dart';

/// Interface abstraite pour le service de cartes
/// Permet l'injection de dépendances et facilite les tests
abstract class ICardService {
  /// Charge toutes les cartes depuis le fichier JSON
  Future<List<GameCard>> loadAllCards();

  /// Filtre les cartes par couleur
  List<GameCard> filterByColor(List<GameCard> cards, CardColor color);

  /// Filtre les cartes par IDs
  List<GameCard> filterByIds(List<GameCard> allCards, List<String> ids);

  /// Récupère une carte par son ID
  GameCard? getCardById(List<GameCard> allCards, String id);
}
