import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/card_level.dart';
import '../enums/player_gender.dart';

part 'player_data.freezed.dart';
part 'player_data.g.dart';

/// Données d'un joueur dans une session
@freezed
class PlayerData with _$PlayerData {
  const factory PlayerData({
    /// ID unique du joueur (Firebase Auth UID)
    required String playerId,

    /// Nom du joueur
    required String name,

    /// Sexe du joueur
    required PlayerGender gender,

    /// Points d'Inhibition (0-20)
    @Default(20) int inhibitionPoints,

    /// Tension accumulée (0-100%)
    @Default(0) double tension,

    /// IDs des cartes en main
    @Default([]) List<String> handCardIds,

    /// IDs des cartes dans le deck
    @Default([]) List<String> deckCardIds,

    /// IDs des cartes au cimetière
    @Default([]) List<String> graveyardCardIds,

    /// IDs des cartes jouées ce tour
    @Default([]) List<String> playedCardIds,

    /// IDs des enchantements actifs
    @Default([]) List<String> activeEnchantmentIds,

    /// Palier actif pour chaque enchantement (white/blue/yellow/red)
    @Default({}) Map<String, String> activeEnchantmentTiers,

    /// Modificateurs persistants actifs (type -> liste d'enchantements)
    @Default({}) Map<String, List<String>> activeStatusModifiers,

    /// Le joueur est-il nu ? (important pour Ultima)
    @Default(false) bool isNaked,

    /// Niveau de progression des cartes (white/blue/yellow/red)
    @Default(CardLevel.white) CardLevel currentLevel,

    /// Le joueur est-il prêt ?
    @Default(false) bool isReady,

    /// Le joueur a-t-il déjà sacrifié une carte ce tour ?
    @Default(false) bool hasSacrificedThisTurn,

    /// Timestamp de connexion
    @JsonKey(includeIfNull: false) DateTime? connectedAt,

    /// Timestamp de dernière activité (pour détecter déconnexion)
    @JsonKey(includeIfNull: false) DateTime? lastActivityAt,
  }) = _PlayerData;

  factory PlayerData.fromJson(Map<String, dynamic> json) =>
      _$PlayerDataFromJson(json);
}
