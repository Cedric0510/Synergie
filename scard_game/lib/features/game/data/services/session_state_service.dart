import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/interfaces/i_game_session_service.dart';
import '../../domain/enums/response_effect.dart';
import 'card_service.dart';
import 'game_session_service.dart';

/// Service dédié aux mutations d'état de session (pile, effets, enchantements).
class SessionStateService {
  final IGameSessionService _gameSessionService;
  final CardService _cardService;

  SessionStateService(this._gameSessionService, this._cardService);

  Future<void> setResponseEffect(
    String sessionId,
    ResponseEffect effect,
  ) async {
    final session = await _gameSessionService.getSession(sessionId);
    final updatedSession = session.copyWith(
      responseEffect: effect,
      updatedAt: DateTime.now(),
    );
    await _gameSessionService.updateSession(sessionId, updatedSession);
  }

  Future<void> clearResolutionStack(String sessionId) async {
    final session = await _gameSessionService.getSession(sessionId);
    final updatedSession = session.copyWith(
      resolutionStack: [],
      playedCardTiers: {},
      updatedAt: DateTime.now(),
    );
    await _gameSessionService.updateSession(sessionId, updatedSession);
  }

  Future<void> clearPlayedCards(String sessionId) async {
    final session = await _gameSessionService.getSession(sessionId);
    if (session.resolutionStack.isEmpty) return;

    final allCards = await _cardService.loadAllCards();
    final cardsById = {for (final card in allCards) card.id: card};

    final enchantments = <String>[
      for (final cardId in session.resolutionStack)
        if (cardsById[cardId]?.isEnchantment ?? false) cardId,
    ];

    final currentPlayerId = session.currentPlayerId;
    if (currentPlayerId == null) {
      final updatedSession = session.copyWith(
        resolutionStack: [],
        playedCardTiers: {},
        updatedAt: DateTime.now(),
      );
      await _gameSessionService.updateSession(sessionId, updatedSession);
      return;
    }

    final isPlayer1 = currentPlayerId == session.player1Id;
    final ownerData = isPlayer1 ? session.player1Data : session.player2Data;
    if (ownerData == null) return;

    final currentEnchantments = LinkedHashSet<String>.from(
      ownerData.activeEnchantmentIds,
    )..addAll(enchantments);
    final currentEnchantmentTiers = Map<String, String>.from(
      ownerData.activeEnchantmentTiers,
    );
    final currentStatusModifiers = _cloneStatusModifiers(
      ownerData.activeStatusModifiers,
    );
    final opponentData = isPlayer1 ? session.player2Data : session.player1Data;
    final otherStatusModifiers = _cloneStatusModifiers(
      opponentData?.activeStatusModifiers ?? const <String, List<String>>{},
    );

    for (final enchantmentId in LinkedHashSet<String>.from(enchantments)) {
      final card = cardsById[enchantmentId];
      final tierKey =
          session.playedCardTiers[enchantmentId] ?? card?.color.name ?? 'white';
      currentEnchantmentTiers[enchantmentId] = tierKey;
      if (card != null) {
        _applyStatusModifiers(
          modifiers: card.statusModifiers,
          enchantmentId: enchantmentId,
          tierKey: tierKey,
          ownerStatusModifiers: currentStatusModifiers,
          opponentStatusModifiers: otherStatusModifiers,
          add: true,
        );
      }
    }

    String? newUltimaOwnerId = session.ultimaOwnerId;
    int newUltimaTurnCount = session.ultimaTurnCount;
    DateTime? newUltimaPlayedAt = session.ultimaPlayedAt;

    final ultimaJustPlayed = enchantments.any((id) => id.contains('red_016'));
    if (ultimaJustPlayed) {
      if (newUltimaOwnerId == null) {
        newUltimaOwnerId = currentPlayerId;
        newUltimaTurnCount = 0;
        newUltimaPlayedAt = DateTime.now();
      }
    }

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: session.player1Data.copyWith(
                activeEnchantmentIds: currentEnchantments.toList(),
                activeEnchantmentTiers: currentEnchantmentTiers,
                activeStatusModifiers: currentStatusModifiers,
              ),
              player2Data: session.player2Data?.copyWith(
                activeStatusModifiers: otherStatusModifiers,
              ),
              resolutionStack: [],
              playedCardTiers: {},
              ultimaOwnerId: newUltimaOwnerId,
              ultimaTurnCount: newUltimaTurnCount,
              ultimaPlayedAt: newUltimaPlayedAt,
              updatedAt: DateTime.now(),
            )
            : session.copyWith(
              player2Data: session.player2Data!.copyWith(
                activeEnchantmentIds: currentEnchantments.toList(),
                activeEnchantmentTiers: currentEnchantmentTiers,
                activeStatusModifiers: currentStatusModifiers,
              ),
              player1Data: session.player1Data.copyWith(
                activeStatusModifiers: otherStatusModifiers,
              ),
              resolutionStack: [],
              playedCardTiers: {},
              ultimaOwnerId: newUltimaOwnerId,
              ultimaTurnCount: newUltimaTurnCount,
              ultimaPlayedAt: newUltimaPlayedAt,
              updatedAt: DateTime.now(),
            );

    await _gameSessionService.updateSession(sessionId, updatedSession);
  }

  Future<void> storePendingActions(
    String sessionId,
    List pendingActions,
  ) async {
    final session = await _gameSessionService.getSession(sessionId);
    final actionsJson = pendingActions.map(_toActionJson).toList();
    final updatedSession = session.copyWith(
      pendingSpellActions: actionsJson,
      updatedAt: DateTime.now(),
    );
    await _gameSessionService.updateSession(sessionId, updatedSession);
  }

  Future<void> clearPendingActions(String sessionId) async {
    final session = await _gameSessionService.getSession(sessionId);
    final updatedSession = session.copyWith(
      pendingSpellActions: [],
      updatedAt: DateTime.now(),
    );
    await _gameSessionService.updateSession(sessionId, updatedSession);
  }

  Future<void> removeEnchantment(
    String sessionId,
    String playerId,
    String enchantmentId,
  ) async {
    final session = await _gameSessionService.getSession(sessionId);
    final isPlayer1 = session.player1Id == playerId;
    final playerData = isPlayer1 ? session.player1Data : session.player2Data;
    if (playerData == null) return;

    final updatedEnchantments = List<String>.from(
      playerData.activeEnchantmentIds,
    )..removeWhere((id) => id == enchantmentId);
    final updatedEnchantmentTiers = Map<String, String>.from(
      playerData.activeEnchantmentTiers,
    )..remove(enchantmentId);
    final updatedStatusModifiers = _cloneStatusModifiers(
      playerData.activeStatusModifiers,
    );

    final opponentData = isPlayer1 ? session.player2Data : session.player1Data;
    final updatedOpponentStatusModifiers = _cloneStatusModifiers(
      opponentData?.activeStatusModifiers ?? const <String, List<String>>{},
    );

    final allCards = await _cardService.loadAllCards();
    final cardsById = {for (final card in allCards) card.id: card};
    final card = cardsById[enchantmentId];
    final tierKey = playerData.activeEnchantmentTiers[enchantmentId];
    if (card != null) {
      _applyStatusModifiers(
        modifiers: card.statusModifiers,
        enchantmentId: enchantmentId,
        tierKey: tierKey,
        ownerStatusModifiers: updatedStatusModifiers,
        opponentStatusModifiers: updatedOpponentStatusModifiers,
        add: false,
      );
    }

    final updatedHand = List<String>.from(playerData.handCardIds);
    final isUltima = enchantmentId.contains('red_016');
    if (isUltima) {
      updatedHand.add(enchantmentId);
    }

    String? newUltimaOwnerId = session.ultimaOwnerId;
    int newUltimaTurnCount = session.ultimaTurnCount;
    DateTime? newUltimaPlayedAt = session.ultimaPlayedAt;

    if (isUltima && session.ultimaOwnerId == playerId) {
      final opponentHasUltima =
          opponentData?.activeEnchantmentIds.any(
            (id) => id.contains('red_016'),
          ) ??
          false;

      if (opponentHasUltima) {
        newUltimaOwnerId = isPlayer1 ? session.player2Id : session.player1Id;
        newUltimaTurnCount = 0;
        newUltimaPlayedAt = DateTime.now();
      } else {
        newUltimaOwnerId = null;
        newUltimaTurnCount = 0;
        newUltimaPlayedAt = null;
      }
    }

    final updatedSession =
        isPlayer1
            ? session.copyWith(
              player1Data: playerData.copyWith(
                activeEnchantmentIds: updatedEnchantments,
                activeEnchantmentTiers: updatedEnchantmentTiers,
                activeStatusModifiers: updatedStatusModifiers,
                handCardIds: updatedHand,
              ),
              player2Data: session.player2Data?.copyWith(
                activeStatusModifiers: updatedOpponentStatusModifiers,
              ),
              ultimaOwnerId: newUltimaOwnerId,
              ultimaTurnCount: newUltimaTurnCount,
              ultimaPlayedAt: newUltimaPlayedAt,
              updatedAt: DateTime.now(),
            )
            : session.copyWith(
              player2Data: playerData.copyWith(
                activeEnchantmentIds: updatedEnchantments,
                activeEnchantmentTiers: updatedEnchantmentTiers,
                activeStatusModifiers: updatedStatusModifiers,
                handCardIds: updatedHand,
              ),
              player1Data: session.player1Data.copyWith(
                activeStatusModifiers: updatedOpponentStatusModifiers,
              ),
              ultimaOwnerId: newUltimaOwnerId,
              ultimaTurnCount: newUltimaTurnCount,
              ultimaPlayedAt: newUltimaPlayedAt,
              updatedAt: DateTime.now(),
            );

    await _gameSessionService.updateSession(sessionId, updatedSession);
  }

  Map<String, dynamic> _toActionJson(dynamic action) {
    if (action is Map<String, dynamic>) {
      return action;
    }
    if (action is Map) {
      return Map<String, dynamic>.from(action);
    }

    final dynamic dynamicAction = action;
    final dynamic json = dynamicAction.toJson();
    if (json is Map<String, dynamic>) {
      return json;
    }
    if (json is Map) {
      return Map<String, dynamic>.from(json);
    }
    throw ArgumentError(
      'Unsupported pending action type: ${action.runtimeType}',
    );
  }

  Map<String, List<String>> _cloneStatusModifiers(
    Map<String, List<String>> input,
  ) {
    return {
      for (final entry in input.entries)
        entry.key: List<String>.from(entry.value),
    };
  }

  void _applyStatusModifiers({
    required List<Map<String, dynamic>> modifiers,
    required String enchantmentId,
    required String? tierKey,
    required Map<String, List<String>> ownerStatusModifiers,
    required Map<String, List<String>> opponentStatusModifiers,
    required bool add,
  }) {
    for (final modifier in modifiers) {
      final type = modifier['type'];
      final target = modifier['target'];
      final tier = modifier['tier'];
      if (type is! String || type.isEmpty) continue;
      if (tier is String && tierKey != null && tier != tierKey) continue;

      if (target == 'both') {
        _updateModifierList(
          ownerStatusModifiers,
          type,
          enchantmentId,
          add: add,
        );
        _updateModifierList(
          opponentStatusModifiers,
          type,
          enchantmentId,
          add: add,
        );
      } else if (target == 'opponent') {
        _updateModifierList(
          opponentStatusModifiers,
          type,
          enchantmentId,
          add: add,
        );
      } else {
        _updateModifierList(
          ownerStatusModifiers,
          type,
          enchantmentId,
          add: add,
        );
      }
    }
  }

  void _updateModifierList(
    Map<String, List<String>> modifiers,
    String type,
    String enchantmentId, {
    required bool add,
  }) {
    final list = List<String>.from(modifiers[type] ?? const <String>[]);

    if (add) {
      if (!list.contains(enchantmentId)) {
        list.add(enchantmentId);
      }
      modifiers[type] = list;
      return;
    }

    list.remove(enchantmentId);
    if (list.isEmpty) {
      modifiers.remove(type);
    } else {
      modifiers[type] = list;
    }
  }
}

final sessionStateServiceProvider = Provider<SessionStateService>((ref) {
  final gameSessionService = ref.watch(gameSessionServiceProvider);
  final cardService = ref.watch(cardServiceProvider);
  return SessionStateService(gameSessionService, cardService);
});
