import 'package:flutter_test/flutter_test.dart';
import 'package:scard_game/core/constants/game_constants.dart';
import 'package:scard_game/features/game/data/services/turn_service.dart';
import 'package:scard_game/features/game/domain/enums/game_phase.dart';
import 'package:scard_game/features/game/domain/enums/game_status.dart';
import 'package:scard_game/features/game/domain/enums/player_gender.dart';
import 'package:scard_game/features/game/domain/models/game_session.dart';
import 'package:scard_game/features/game/domain/models/player_data.dart';

import 'helpers/in_memory_game_session_service.dart';

void main() {
  late InMemoryGameSessionService gameSessionService;
  late TurnService service;

  setUp(() {
    gameSessionService = InMemoryGameSessionService();
    service = TurnService(gameSessionService);
  });

  group('TurnService - nextPhase', () {
    test('draw → main', () async {
      gameSessionService.save(_buildSession(currentPhase: GamePhase.draw));
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPhase, GamePhase.main);
      expect(s.currentPlayerId, 'p1');
    });

    test('main → response', () async {
      gameSessionService.save(_buildSession(currentPhase: GamePhase.main));
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPhase, GamePhase.response);
      expect(s.currentPlayerId, 'p1');
    });

    test('response → resolution', () async {
      gameSessionService.save(_buildSession(currentPhase: GamePhase.response));
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPhase, GamePhase.resolution);
      expect(s.currentPlayerId, 'p1');
    });

    test('resolution → end', () async {
      gameSessionService.save(
        _buildSession(currentPhase: GamePhase.resolution),
      );
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPhase, GamePhase.end);
      expect(s.currentPlayerId, 'p1');
    });

    test('end → draw switches to opponent', () async {
      gameSessionService.save(
        _buildSession(currentPhase: GamePhase.end, currentPlayerId: 'p1'),
      );
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPhase, GamePhase.draw);
      expect(s.currentPlayerId, 'p2');
    });

    test('end → draw resets drawDoneThisTurn', () async {
      gameSessionService.save(
        _buildSession(currentPhase: GamePhase.end, drawDoneThisTurn: true),
      );
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.drawDoneThisTurn, false);
    });

    test('end → draw resets enchantmentEffectsDoneThisTurn', () async {
      gameSessionService.save(
        _buildSession(
          currentPhase: GamePhase.end,
          enchantmentEffectsDoneThisTurn: true,
        ),
      );
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.enchantmentEffectsDoneThisTurn, false);
    });

    test('end → draw resets hasSacrificedThisTurn for both players', () async {
      gameSessionService.save(
        _buildSession(
          currentPhase: GamePhase.end,
          player1Data: _player('p1', hasSacrificedThisTurn: true),
          player2Data: _player('p2', hasSacrificedThisTurn: true),
        ),
      );
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.player1Data.hasSacrificedThisTurn, false);
      expect(s.player2Data!.hasSacrificedThisTurn, false);
    });

    test('draw → main preserves drawDoneThisTurn', () async {
      gameSessionService.save(
        _buildSession(currentPhase: GamePhase.draw, drawDoneThisTurn: true),
      );
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.drawDoneThisTurn, true);
    });
  });

  group('TurnService - nextPhase - Ultima counter', () {
    test(
      'increments ultima counter when resolution → end and owner has Ultima',
      () async {
        gameSessionService.save(
          _buildSession(
            currentPhase: GamePhase.resolution,
            ultimaOwnerId: 'p1',
            ultimaTurnCount: 0,
            player1Data: _player(
              'p1',
              activeEnchantmentIds: [GameConstants.ultimaCardId],
            ),
          ),
        );
        await service.nextPhase('S1');
        final s = await gameSessionService.getSession('S1');
        expect(s.ultimaTurnCount, 1);
        expect(s.status, GameStatus.waiting);
      },
    );

    test(
      'does not increment when owner no longer has Ultima in play',
      () async {
        gameSessionService.save(
          _buildSession(
            currentPhase: GamePhase.resolution,
            ultimaOwnerId: 'p1',
            ultimaTurnCount: 1,
            player1Data: _player('p1', activeEnchantmentIds: []),
          ),
        );
        await service.nextPhase('S1');
        final s = await gameSessionService.getSession('S1');
        expect(s.ultimaTurnCount, 1);
      },
    );

    test('triggers victory when ultima counter reaches max', () async {
      gameSessionService.save(
        _buildSession(
          currentPhase: GamePhase.resolution,
          ultimaOwnerId: 'p1',
          ultimaTurnCount: GameConstants.ultimaMaxCount - 1,
          player1Data: _player(
            'p1',
            activeEnchantmentIds: [GameConstants.ultimaCardId],
          ),
        ),
      );
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.ultimaTurnCount, GameConstants.ultimaMaxCount);
      expect(s.winnerId, 'p1');
      expect(s.status, GameStatus.finished);
    });

    test('does not increment on non-resolution → end transitions', () async {
      gameSessionService.save(
        _buildSession(
          currentPhase: GamePhase.main,
          ultimaOwnerId: 'p1',
          ultimaTurnCount: 1,
          player1Data: _player(
            'p1',
            activeEnchantmentIds: [GameConstants.ultimaCardId],
          ),
        ),
      );
      await service.nextPhase('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.ultimaTurnCount, 1);
    });
  });

  group('TurnService - endTurn', () {
    test('switches to opponent and resets to draw', () async {
      gameSessionService.save(
        _buildSession(currentPhase: GamePhase.main, currentPlayerId: 'p1'),
      );
      await service.endTurn('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPlayerId, 'p2');
      expect(s.currentPhase, GamePhase.draw);
    });

    test('resets draw and enchantment flags', () async {
      gameSessionService.save(
        _buildSession(
          currentPhase: GamePhase.main,
          drawDoneThisTurn: true,
          enchantmentEffectsDoneThisTurn: true,
        ),
      );
      await service.endTurn('S1');
      final s = await gameSessionService.getSession('S1');
      expect(s.drawDoneThisTurn, false);
      expect(s.enchantmentEffectsDoneThisTurn, false);
    });
  });

  group('TurnService - setDrawDoneThisTurn', () {
    test('sets flag to true', () async {
      gameSessionService.save(_buildSession());
      await service.setDrawDoneThisTurn('S1', true);
      final s = await gameSessionService.getSession('S1');
      expect(s.drawDoneThisTurn, true);
    });

    test('sets flag to false', () async {
      gameSessionService.save(_buildSession(drawDoneThisTurn: true));
      await service.setDrawDoneThisTurn('S1', false);
      final s = await gameSessionService.getSession('S1');
      expect(s.drawDoneThisTurn, false);
    });
  });

  group('TurnService - setEnchantmentEffectsDoneThisTurn', () {
    test('sets flag to true', () async {
      gameSessionService.save(_buildSession());
      await service.setEnchantmentEffectsDoneThisTurn('S1', true);
      final s = await gameSessionService.getSession('S1');
      expect(s.enchantmentEffectsDoneThisTurn, true);
    });

    test('sets flag to false', () async {
      gameSessionService.save(
        _buildSession(enchantmentEffectsDoneThisTurn: true),
      );
      await service.setEnchantmentEffectsDoneThisTurn('S1', false);
      final s = await gameSessionService.getSession('S1');
      expect(s.enchantmentEffectsDoneThisTurn, false);
    });
  });

  group('TurnService - forceTurnToPlayer', () {
    test('forces turn to specified player', () async {
      gameSessionService.save(_buildSession(currentPlayerId: 'p1'));
      await service.forceTurnToPlayer('S1', 'p2');
      final s = await gameSessionService.getSession('S1');
      expect(s.currentPlayerId, 'p2');
      expect(s.currentPhase, GamePhase.draw);
    });

    test('resets draw and enchantment flags', () async {
      gameSessionService.save(
        _buildSession(
          drawDoneThisTurn: true,
          enchantmentEffectsDoneThisTurn: true,
        ),
      );
      await service.forceTurnToPlayer('S1', 'p2');
      final s = await gameSessionService.getSession('S1');
      expect(s.drawDoneThisTurn, false);
      expect(s.enchantmentEffectsDoneThisTurn, false);
    });
  });
}

GameSession _buildSession({
  String sessionId = 'S1',
  String player1Id = 'p1',
  String player2Id = 'p2',
  String currentPlayerId = 'p1',
  GamePhase currentPhase = GamePhase.draw,
  bool drawDoneThisTurn = false,
  bool enchantmentEffectsDoneThisTurn = false,
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
    drawDoneThisTurn: drawDoneThisTurn,
    enchantmentEffectsDoneThisTurn: enchantmentEffectsDoneThisTurn,
    ultimaOwnerId: ultimaOwnerId,
    ultimaTurnCount: ultimaTurnCount,
    createdAt: now,
    updatedAt: now,
  );
}

PlayerData _player(
  String id, {
  bool hasSacrificedThisTurn = false,
  List<String> activeEnchantmentIds = const [],
}) {
  return PlayerData(
    playerId: id,
    name: id,
    gender: PlayerGender.other,
    inhibitionPoints: 20,
    tension: 0,
    handCardIds: [],
    deckCardIds: [],
    playedCardIds: [],
    graveyardCardIds: [],
    hasSacrificedThisTurn: hasSacrificedThisTurn,
    activeEnchantmentIds: activeEnchantmentIds,
  );
}
