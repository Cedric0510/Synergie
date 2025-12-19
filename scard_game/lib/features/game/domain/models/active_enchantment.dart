import 'package:freezed_annotation/freezed_annotation.dart';
import 'game_card.dart';

part 'active_enchantment.freezed.dart';
part 'active_enchantment.g.dart';

/// Modèle représentant un enchantement actif sur la table
@freezed
class ActiveEnchantment with _$ActiveEnchantment {
  const factory ActiveEnchantment({
    /// La carte enchantement
    required GameCard card,

    /// ID du joueur qui a posé l'enchantement
    required String ownerId,

    /// ID du joueur qui subit l'enchantement
    required String targetId,

    /// Timestamp de quand l'enchantement a été posé
    required DateTime playedAt,

    /// Nombre de tours pendant lesquels l'enchantement a été actif
    @Default(0) int turnsActive,
  }) = _ActiveEnchantment;

  const ActiveEnchantment._();

  /// Gain de tension pour le propriétaire quand l'effet est accepté
  int get tensionGainOnAccept => card.tensionPerTurn ?? 0;

  factory ActiveEnchantment.fromJson(Map<String, dynamic> json) =>
      _$ActiveEnchantmentFromJson(json);
}
