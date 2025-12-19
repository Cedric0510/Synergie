import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/card_type.dart';
import '../enums/card_color.dart';
import 'card_mechanic.dart';

part 'game_card.freezed.dart';
part 'game_card.g.dart';

/// Modèle représentant une carte de jeu
@freezed
class GameCard with _$GameCard {
  const factory GameCard({
    /// ID unique de la carte
    required String id,

    /// Nom de la carte
    required String name,

    /// Type de carte (Instantané, Rituel, Enchantement)
    required CardType type,

    /// Couleur/Niveau de la carte
    required CardColor color,

    /// Description complète de la carte (optionnelle)
    String? description,

    // === COÛTS ET EFFETS ===

    /// Coût IRL pour le lanceur (ce que TU dois faire pour jouer la carte)
    /// Ex: "Aucun", "Enlever 2 vêtements", "Danse sensuelle 30 sec"
    required String launcherCost,

    /// Effet IRL sur la cible (ce que l'adversaire doit faire)
    /// Ex: "Enlever 1 vêtement", "Massage 1 minute", "Compliment sincère"
    /// Peut être null pour certaines cartes (ex: Pioche)
    String? targetEffect,

    /// Dégâts infligés si la cible refuse l'effet IRL
    @Default(0) int damageIfRefused,

    /// Description de l'effet en jeu (texte descriptif)
    /// Ex: "Piocher 2 cartes", "Détruire un enchantement ciblé"
    required String gameEffect,

    // === EFFETS STRUCTURÉS (GAMEPLAY) ===

    /// Nombre de cartes à piocher immédiatement (0 = aucune)
    @Default(0) int drawCards,

    /// Nombre de cartes à piocher par tour (enchantements uniquement)
    @Default(0) int drawCardsPerTurn,

    /// Nombre de vêtements que le lanceur retire (0 = aucun)
    @Default(0) int removeClothing,

    /// Nombre de vêtements que le lanceur remet (0 = aucun)
    @Default(0) int addClothing,

    /// Nombre d'enchantements à détruire (0 = aucun)
    @Default(0) int destroyEnchantment,

    /// Détruire tous les enchantements (false = non)
    @Default(false) bool destroyAllEnchantments,

    /// Nombre d'enchantements à remplacer (0 = aucun)
    @Default(0) int replaceEnchantment,

    /// Nombre de cartes à sacrifier (0 = aucune)
    @Default(0) int sacrificeCard,

    /// Nombre de cartes à défausser (0 = aucune)
    @Default(0) int discardCard,

    /// Nombre de cartes que l'adversaire pioche (0 = aucune)
    @Default(0) int opponentDraw,

    /// Nombre de vêtements que l'adversaire retire par tour (enchantements)
    @Default(0) int opponentRemoveClothing,

    /// Mélanger la main dans le deck (false = non)
    @Default(false) bool shuffleHandIntoDeck,

    /// Dégâts PI à l'adversaire (0 = aucun)
    @Default(0) int piDamageOpponent,

    /// Gain PI pour le lanceur (0 = aucun)
    @Default(0) int piGainSelf,

    /// Augmentation de tension pour le lanceur (0 = aucune)
    @Default(0) int tensionIncrease,

    /// Coût en PI pour lancer la carte (0 = gratuit)
    @Default(0) int piCost,

    /// Est-ce un enchantement permanent qui reste en jeu
    @Default(false) bool isEnchantment,

    // === SPÉCIFIQUE AUX ENCHANTEMENTS ===

    /// Gain de tension par tour pour le lanceur (null si pas un enchantement)
    /// Ex: 1, 3, 5, 7 ou null
    int? tensionPerTurn,

    // === DECK ===

    /// Nombre maximum d'exemplaires dans le deck
    /// null = 4 exemplaires (défaut), 1 = unique (Ultima), 2 = limité
    int? maxPerDeck,

    // === MÉCANIQUES SPÉCIALES ===

    /// Liste des mécaniques spéciales de la carte
    /// Ex: sacrifice de carte, destruction d'enchantement, pioche conditionnelle, etc.
    @Default([]) List<CardMechanic> mechanics,

    // === UI ===

    /// URL de l'image de la carte
    String? imageUrl,

    /// Texte d'ambiance / flavor text
    String? flavorText,
  }) = _GameCard;

  factory GameCard.fromJson(Map<String, dynamic> json) =>
      _$GameCardFromJson(json);
}
