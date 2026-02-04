import 'package:flutter/material.dart';
import '../../domain/models/game_card.dart';
import '../../domain/models/card_mechanic.dart';
import '../../domain/enums/mechanic_type.dart';

/// Contexte passé aux handlers de mécaniques
/// Contient toutes les informations nécessaires pour traiter une mécanique
class MechanicContext {
  final BuildContext context;
  final String sessionId;
  final GameCard card;
  final CardMechanic mechanic;
  final String playerId;
  final List<String> handCardIds;
  final List<String> activeEnchantmentIds;
  final List<String> opponentEnchantmentIds;
  final String? selectedTierKey;

  const MechanicContext({
    required this.context,
    required this.sessionId,
    required this.card,
    required this.mechanic,
    required this.playerId,
    required this.handCardIds,
    required this.activeEnchantmentIds,
    required this.opponentEnchantmentIds,
    this.selectedTierKey,
  });
}

/// Résultat du traitement d'une mécanique
class MechanicResult {
  final bool success;
  final String? message;
  final List<String>? sacrificedCardIds;
  final List<String>? discardedCardIds;
  final List<String>? destroyedEnchantmentIds;
  final int? cardsDrawn;
  final int? piChange;
  final int? tensionChange;
  final bool requiresUserInput;
  final List<PendingAction>? pendingActions;

  const MechanicResult({
    this.success = true,
    this.message,
    this.sacrificedCardIds,
    this.discardedCardIds,
    this.destroyedEnchantmentIds,
    this.cardsDrawn,
    this.piChange,
    this.tensionChange,
    this.requiresUserInput = false,
    this.pendingActions,
  });

  /// Fusionne deux résultats
  MechanicResult merge(MechanicResult other) {
    return MechanicResult(
      success: success && other.success,
      message: other.message ?? message,
      sacrificedCardIds: [...?sacrificedCardIds, ...?other.sacrificedCardIds],
      discardedCardIds: [...?discardedCardIds, ...?other.discardedCardIds],
      destroyedEnchantmentIds: [
        ...?destroyedEnchantmentIds,
        ...?other.destroyedEnchantmentIds,
      ],
      cardsDrawn: (cardsDrawn ?? 0) + (other.cardsDrawn ?? 0),
      piChange: (piChange ?? 0) + (other.piChange ?? 0),
      tensionChange: (tensionChange ?? 0) + (other.tensionChange ?? 0),
      requiresUserInput: requiresUserInput || other.requiresUserInput,
      pendingActions: [...?pendingActions, ...?other.pendingActions],
    );
  }

  /// Résultat d'échec
  factory MechanicResult.failure([String? message]) {
    return MechanicResult(success: false, message: message);
  }

  /// Résultat de succès simple
  factory MechanicResult.ok([String? message]) {
    return MechanicResult(success: true, message: message);
  }
}

/// Interface pour les handlers de mécaniques
/// Applique le principe O (Open/Closed) - ouvert à l'extension, fermé à la modification
abstract class IMechanicHandler {
  /// Type de mécanique géré par ce handler
  MechanicType get type;

  /// Vérifie si ce handler peut gérer la mécanique
  bool canHandle(CardMechanic mechanic) => mechanic.type == type;

  /// Traite la mécanique et retourne le résultat
  Future<MechanicResult> handle(MechanicContext context);
}

/// Type d'action pendante (pour les effets retardés)
enum PendingActionType {
  destroyEnchantment,
  drawCards,
  replaceEnchantment,
  destroyAllEnchantments,
}

/// Action pendante à exécuter plus tard (phase résolution)
class PendingAction {
  final PendingActionType type;
  final String? targetPlayerId;
  final String? targetCardId;
  final Map<String, dynamic>? data;

  const PendingAction({
    required this.type,
    this.targetPlayerId,
    this.targetCardId,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    if (targetPlayerId != null) 'targetPlayerId': targetPlayerId,
    if (targetCardId != null) 'targetCardId': targetCardId,
    if (data != null) 'data': data,
  };

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      type: PendingActionType.values.firstWhere((t) => t.name == json['type']),
      targetPlayerId: json['targetPlayerId'] as String?,
      targetCardId: json['targetCardId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
