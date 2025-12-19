import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/mechanic_type.dart';
import '../enums/target_type.dart';

part 'card_mechanic.freezed.dart';
part 'card_mechanic.g.dart';

/// Modèle représentant une mécanique spéciale d'une carte
@freezed
class CardMechanic with _$CardMechanic {
  const factory CardMechanic({
    /// Type de mécanique
    required MechanicType type,

    /// Type de cible
    @Default(TargetType.none) TargetType target,

    /// Filtre pour la sélection (ex: "color:red", "type:ritual", "name:Plaisir")
    String? filter,

    /// Nombre d'éléments concernés (cartes à piocher, enchantements à détruire, etc.)
    @Default(1) int count,

    /// Si true, remplace le sort en cours de résolution
    @Default(false) bool replaceSpell,

    /// Valeur initiale pour les compteurs (charges, tours, etc.)
    int? initialCounterValue,

    /// Source de la valeur du compteur (ex: "clothingCount" pour Piège)
    String? counterSource,

    /// Conditions pour déclencher la mécanique
    Map<String, dynamic>? conditions,

    /// Actions supplémentaires à effectuer
    Map<String, dynamic>? additionalActions,
  }) = _CardMechanic;

  factory CardMechanic.fromJson(Map<String, dynamic> json) =>
      _$CardMechanicFromJson(json);
}
