import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/core/services/logger_service.dart';
import 'package:scard_game/features/game/data/services/card_service.dart';
import 'package:scard_game/features/game/data/services/session_state_service.dart';
import 'package:scard_game/features/game/domain/enums/card_color.dart';
import 'package:scard_game/features/game/domain/enums/card_type.dart';
import 'package:scard_game/features/game/domain/enums/game_phase.dart';
import 'package:scard_game/features/game/domain/enums/player_gender.dart';
import 'package:scard_game/features/game/domain/enums/response_effect.dart';
import 'package:scard_game/features/game/domain/models/game_card.dart';
import 'package:scard_game/features/game/domain/models/game_session.dart';
import 'package:scard_game/features/game/domain/models/player_data.dart';

import 'helpers/in_memory_game_session_service.dart';

/// Stub CardService that returns pre-configured cards without loading JSON.
class StubCardService extends CardService {
  final List<GameCard> _cards;
  StubCardService(this._cards) : super(LoggerService());

  @override
  Future<List<GameCard>> loadAllCards() async => _cards;
}

void main() {
  late InMemoryGameSessionService gameSessionService;
  late StubCardService cardService;
  late SessionStateService service;

  /// A simple enchantment card for testing
  GameCard makeEnchantment(
    String id, {
    CardColor color = CardColor.blue,
    List<Map<String, dynamic>> statusModifiers = const [],
  }) {
    return GameCard(
      id: id,
      name: 'Enchantment $id',
      type: CardType.enchantment,
      color: color,
      launcherCost: 'Aucun',
      gameEffect: 'Test effect',
      isEnchantment: true,
      statusModifiers: statusModifiers,
    );
  }

  /// A simple ritual card
  GameCard makeRitual(String id, {CardColor color = CardColor.white}) {
    return GameCard(
      id: id,
      name: 'Ritual $id',
      type: CardType.ritual,
      color: color,
      launcherCost: 'Aucun',
      gameEffect: 'Test effect',
    );
  }

  group('SessionStateService - setResponseEffect', () {
    setUp(() {
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([]);
      service = SessionStateService(gameSessionService, cardService);
    });

    test('sets response effect', () async {
      gameSessionService.save(_buildSession());
      await service.setResponseEffect('S1', ResponseEffect.cancel);
      final s = await gameSessionService.getSession('S1');
      expect(s.responseEffect, ResponseEffect.cancel);
    });

    test('sets different response effects', () async {
      gameSessionService.save(_buildSession());
      await service.setResponseEffect('S1', ResponseEffect.copy);
      final s = await gameSessionService.getSession('S1');
      expect(s.responseEffect, ResponseEffect.copy);
    });
  });

  group('SessionStateService - clearResolutionStack', () {
    setUp(() {
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([]);
      service = SessionStateService(gameSessionService, cardService);
    });

    test('empties resolution stack and playedCardTiers', () async {
      gameSessionService.save(
        _buildSession(
          resolutionStack: ['card_a', 'card_b'],
          playedCardTiers: {'card_a': 'blue', 'card_b': 'red'},
        ),
      );
      await service.clearResolutionStack('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.resolutionStack, isEmpty);
      expect(s.playedCardTiers, isEmpty);
    });
  });

  group('SessionStateService - storePendingActions', () {
    setUp(() {
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([]);
      service = SessionStateService(gameSessionService, cardService);
    });

    test('stores pending actions as JSON maps', () async {
      gameSessionService.save(_buildSession());
      final actions = [
        {
          'type': 'drawCards',
          'targetPlayerId': 'p1',
          'data': {'count': 2},
        },
      ];
      await service.storePendingActions('S1', actions);
      final s = await gameSessionService.getSession('S1');
      expect(s.pendingSpellActions, hasLength(1));
      expect(s.pendingSpellActions.first['type'], 'drawCards');
    });
  });

  group('SessionStateService - clearPendingActions', () {
    setUp(() {
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([]);
      service = SessionStateService(gameSessionService, cardService);
    });

    test('empties pending spell actions', () async {
      gameSessionService.save(
        _buildSession(
          pendingSpellActions: [
            {'type': 'test'},
          ],
        ),
      );
      await service.clearPendingActions('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.pendingSpellActions, isEmpty);
    });
  });

  group('SessionStateService - clearPlayedCards', () {
    test('empty resolution stack is a no-op', () async {
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(_buildSession(resolutionStack: []));
      await service.clearPlayedCards('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.resolutionStack, isEmpty);
    });

    test('moves enchantment to activeEnchantmentIds', () async {
      final ench = makeEnchantment('ench_1');
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ench]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          currentPlayerId: 'p1',
          resolutionStack: ['ench_1'],
          playedCardTiers: {'ench_1': 'blue'},
        ),
      );
      await service.clearPlayedCards('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.activeEnchantmentIds, contains('ench_1'));
      expect(s.player1Data.activeEnchantmentTiers['ench_1'], 'blue');
      expect(s.resolutionStack, isEmpty);
      expect(s.playedCardTiers, isEmpty);
    });

    test(
      'non-enchantment cards are not added to activeEnchantmentIds',
      () async {
        final ritual = makeRitual('ritual_1');
        gameSessionService = InMemoryGameSessionService();
        cardService = StubCardService([ritual]);
        service = SessionStateService(gameSessionService, cardService);

        gameSessionService.save(
          _buildSession(currentPlayerId: 'p1', resolutionStack: ['ritual_1']),
        );
        await service.clearPlayedCards('S1');
        final s = await gameSessionService.getSession('S1');
        expect(s.player1Data.activeEnchantmentIds, isEmpty);
        expect(s.resolutionStack, isEmpty);
      },
    );

    test('applies owner-targeted status modifiers', () async {
      final ench = makeEnchantment(
        'ench_1',
        statusModifiers: [
          {'type': 'pi_locked', 'target': 'owner'},
        ],
      );
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ench]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          currentPlayerId: 'p1',
          resolutionStack: ['ench_1'],
          playedCardTiers: {'ench_1': 'blue'},
        ),
      );
      await service.clearPlayedCards('S1');
      final s = await gameSessionService.getSession('S1');
      expect(
        s.player1Data.activeStatusModifiers['pi_locked'],
        contains('ench_1'),
      );
    });

    test('applies opponent-targeted status modifiers', () async {
      final ench = makeEnchantment(
        'ench_1',
        statusModifiers: [
          {'type': 'tension_locked', 'target': 'opponent'},
        ],
      );
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ench]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          currentPlayerId: 'p1',
          resolutionStack: ['ench_1'],
          playedCardTiers: {'ench_1': 'white'},
        ),
      );
      await service.clearPlayedCards('S1');
      final s = await gameSessionService.getSession('S1');
      expect(
        s.player2Data!.activeStatusModifiers['tension_locked'],
        contains('ench_1'),
      );
    });

    test('applies both-targeted status modifiers', () async {
      final ench = makeEnchantment(
        'ench_1',
        statusModifiers: [
          {'type': 'lockPI', 'target': 'both'},
        ],
      );
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ench]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          currentPlayerId: 'p1',
          resolutionStack: ['ench_1'],
          playedCardTiers: {'ench_1': 'blue'},
        ),
      );
      await service.clearPlayedCards('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.activeStatusModifiers['lockPI'], contains('ench_1'));
      expect(
        s.player2Data!.activeStatusModifiers['lockPI'],
        contains('ench_1'),
      );
    });

    test('sets ultimaOwnerId when Ultima (red_016) is played', () async {
      final ultima = makeEnchantment('red_016', color: CardColor.red);
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ultima]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          currentPlayerId: 'p1',
          resolutionStack: ['red_016'],
          playedCardTiers: {'red_016': 'red'},
        ),
      );
      await service.clearPlayedCards('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.ultimaOwnerId, 'p1');
      expect(s.ultimaTurnCount, 0);
      expect(s.ultimaPlayedAt, isNotNull);
    });

    test('does not override existing ultimaOwnerId', () async {
      final ultima = makeEnchantment('red_016', color: CardColor.red);
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ultima]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          currentPlayerId: 'p2',
          ultimaOwnerId: 'p1',
          ultimaTurnCount: 2,
          resolutionStack: ['red_016'],
          playedCardTiers: {'red_016': 'red'},
        ),
      );
      await service.clearPlayedCards('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.ultimaOwnerId, 'p1');
      expect(s.ultimaTurnCount, 2);
    });

    test('player2 enchantment attribution works', () async {
      final ench = makeEnchantment('ench_1');
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ench]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          currentPlayerId: 'p2',
          resolutionStack: ['ench_1'],
          playedCardTiers: {'ench_1': 'blue'},
        ),
      );
      await service.clearPlayedCards('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.player2Data!.activeEnchantmentIds, contains('ench_1'));
      expect(s.player1Data.activeEnchantmentIds, isEmpty);
    });
  });

  group('SessionStateService - removeEnchantment', () {
    test('removes enchantment from player activeEnchantmentIds', () async {
      final ench = makeEnchantment('ench_1');
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ench]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            activeEnchantmentIds: ['ench_1'],
            activeEnchantmentTiers: {'ench_1': 'blue'},
          ),
        ),
      );
      await service.removeEnchantment('S1', 'p1', 'ench_1');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.activeEnchantmentIds, isEmpty);
      expect(s.player1Data.activeEnchantmentTiers, isEmpty);
    });

    test('reverses owner status modifiers on removal', () async {
      final ench = makeEnchantment(
        'ench_1',
        statusModifiers: [
          {'type': 'pi_locked', 'target': 'owner'},
        ],
      );
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ench]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            activeEnchantmentIds: ['ench_1'],
            activeEnchantmentTiers: {'ench_1': 'blue'},
            modifiers: {
              'pi_locked': ['ench_1'],
            },
          ),
        ),
      );
      await service.removeEnchantment('S1', 'p1', 'ench_1');
      final s = await gameSessionService.getSession('S1');
      expect(
        s.player1Data.activeStatusModifiers.containsKey('pi_locked'),
        false,
      );
    });

    test('reverses opponent status modifiers on removal', () async {
      final ench = makeEnchantment(
        'ench_1',
        statusModifiers: [
          {'type': 'tension_locked', 'target': 'opponent'},
        ],
      );
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ench]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          player1Data: _player(
            'p1',
            activeEnchantmentIds: ['ench_1'],
            activeEnchantmentTiers: {'ench_1': 'blue'},
          ),
          player2Data: _player(
            'p2',
            modifiers: {
              'tension_locked': ['ench_1'],
            },
          ),
        ),
      );
      await service.removeEnchantment('S1', 'p1', 'ench_1');
      final s = await gameSessionService.getSession('S1');
      expect(
        s.player2Data!.activeStatusModifiers.containsKey('tension_locked'),
        false,
      );
    });

    test('Ultima removal returns card to hand', () async {
      final ultima = makeEnchantment('red_016', color: CardColor.red);
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ultima]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          ultimaOwnerId: 'p1',
          ultimaTurnCount: 2,
          player1Data: _player(
            'p1',
            activeEnchantmentIds: ['red_016'],
            activeEnchantmentTiers: {'red_016': 'red'},
          ),
        ),
      );
      await service.removeEnchantment('S1', 'p1', 'red_016');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.handCardIds, contains('red_016'));
      expect(s.player1Data.activeEnchantmentIds, isEmpty);
    });

    test('Ultima removal resets ownership when no other owner', () async {
      final ultima = makeEnchantment('red_016', color: CardColor.red);
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([ultima]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          ultimaOwnerId: 'p1',
          ultimaTurnCount: 2,
          player1Data: _player(
            'p1',
            activeEnchantmentIds: ['red_016'],
            activeEnchantmentTiers: {'red_016': 'red'},
          ),
        ),
      );
      await service.removeEnchantment('S1', 'p1', 'red_016');
      final s = await gameSessionService.getSession('S1');
      expect(s.ultimaOwnerId, isNull);
      expect(s.ultimaTurnCount, 0);
    });

    test(
      'Ultima removal transfers ownership to opponent when they have it',
      () async {
        final ultima = makeEnchantment('red_016', color: CardColor.red);
        gameSessionService = InMemoryGameSessionService();
        cardService = StubCardService([ultima]);
        service = SessionStateService(gameSessionService, cardService);

        gameSessionService.save(
          _buildSession(
            ultimaOwnerId: 'p1',
            ultimaTurnCount: 2,
            player1Data: _player(
              'p1',
              activeEnchantmentIds: ['red_016'],
              activeEnchantmentTiers: {'red_016': 'red'},
            ),
            player2Data: _player(
              'p2',
              activeEnchantmentIds: ['red_016'],
              activeEnchantmentTiers: {'red_016': 'red'},
            ),
          ),
        );
        await service.removeEnchantment('S1', 'p1', 'red_016');
        final s = await gameSessionService.getSession('S1');
        expect(s.ultimaOwnerId, 'p2');
        expect(s.ultimaTurnCount, 0);
      },
    );

    test('non-existent enchantment does nothing', () async {
      gameSessionService = InMemoryGameSessionService();
      cardService = StubCardService([]);
      service = SessionStateService(gameSessionService, cardService);

      gameSessionService.save(
        _buildSession(
          player1Data: _player('p1', activeEnchantmentIds: ['other']),
        ),
      );
      await service.removeEnchantment('S1', 'p1', 'non_existent');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.activeEnchantmentIds, ['other']);
    });
  });
}

GameSession _buildSession({
  String sessionId = 'S1',
  String player1Id = 'p1',
  String player2Id = 'p2',
  String currentPlayerId = 'p1',
  GamePhase currentPhase = GamePhase.resolution,
  List<String> resolutionStack = const [],
  Map<String, String> playedCardTiers = const {},
  List<Map<String, dynamic>> pendingSpellActions = const [],
  String? ultimaOwnerId,
  int ultimaTurnCount = 0,
  PlayerData? player1Data,
  PlayerData? player2Data,
}) {
  final now = DateTime(2026, 1, 1);
  return GameSession(
    sessionId: sessionId,
    player1Id: player1Id,
    player2Id: player2Id,
    player1Data: player1Data ?? _player(player1Id),
    player2Data: player2Data ?? _player(player2Id),
    currentPlayerId: currentPlayerId,
    currentPhase: currentPhase,
    resolutionStack: resolutionStack,
    playedCardTiers: playedCardTiers,
    pendingSpellActions: pendingSpellActions,
    ultimaOwnerId: ultimaOwnerId,
    ultimaTurnCount: ultimaTurnCount,
    createdAt: now,
    updatedAt: now,
  );
}

PlayerData _player(
  String id, {
  List<String> hand = const [],
  List<String> activeEnchantmentIds = const [],
  Map<String, String> activeEnchantmentTiers = const {},
  Map<String, List<String>> modifiers = const {},
}) {
  return PlayerData(
    playerId: id,
    name: id,
    gender: PlayerGender.other,
    inhibitionPoints: 20,
    tension: 0,
    handCardIds: hand,
    deckCardIds: const [],
    playedCardIds: const [],
    graveyardCardIds: const [],
    activeEnchantmentIds: activeEnchantmentIds,
    activeEnchantmentTiers: activeEnchantmentTiers,
    activeStatusModifiers: modifiers,
  );
}
