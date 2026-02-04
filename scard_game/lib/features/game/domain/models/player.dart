import 'package:freezed_annotation/freezed_annotation.dart';
import 'active_enchantment.dart';
import '../enums/card_color.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Modèle représentant un joueur
@freezed
class Player with _$Player {
  const factory Player({
    /// ID unique du joueur
    required String id,

    /// Nom/Pseudo du joueur
    required String name,

    /// Points de vie (0-20)
    @Default(20) int health,

    /// Jauge de tension (0-100%)
    @Default(0.0) double tensionGauge,

    /// Cartes en main (IDs des cartes)
    @Default([]) List<String> hand,

    /// Deck (pile de pioche) - IDs des cartes dans l'ordre
    @Default([]) List<String> deck,

    /// Cimetière (cartes défaussées/détruites) - IDs des cartes
    @Default([]) List<String> graveyard,

    /// Enchantements actifs sur la table
    @Default([]) List<ActiveEnchantment> enchantments,
  }) = _Player;

  const Player._();

  /// Nombre de cartes dans le deck
  int get deckSize => deck.length;

  /// Nombre de cartes en main
  int get handSize => hand.length;

  /// Le joueur est-il défait ? (0 PV ou deck vide)
  bool get isDefeated => health <= 0 || deck.isEmpty;

  /// Couleur maximale que le joueur peut jouer selon sa jauge
  CardColor get maxPlayableColor {
    if (tensionGauge >= 75) return CardColor.red;
    if (tensionGauge >= 50) return CardColor.yellow;
    if (tensionGauge >= 25) return CardColor.blue;
    return CardColor.white;
  }

  /// Le joueur peut-il jouer une carte de cette couleur ?
  bool canPlayColor(CardColor color) {
    return tensionGauge >= color.requiredTension;
  }

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
