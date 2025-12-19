// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameStateImpl _$$GameStateImplFromJson(Map<String, dynamic> json) =>
    _$GameStateImpl(
      gameId: json['gameId'] as String,
      player1: Player.fromJson(json['player1'] as Map<String, dynamic>),
      player2: Player.fromJson(json['player2'] as Map<String, dynamic>),
      turn: (json['turn'] as num?)?.toInt() ?? 1,
      activePlayerId: json['activePlayerId'] as String,
      phase:
          $enumDecodeNullable(_$GamePhaseEnumMap, json['phase']) ??
          GamePhase.main,
      status:
          $enumDecodeNullable(_$GameStatusEnumMap, json['status']) ??
          GameStatus.waiting,
      responseDeadline:
          json['responseDeadline'] == null
              ? null
              : DateTime.parse(json['responseDeadline'] as String),
      winnerId: json['winnerId'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GameStateImplToJson(_$GameStateImpl instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'player1': instance.player1,
      'player2': instance.player2,
      'turn': instance.turn,
      'activePlayerId': instance.activePlayerId,
      'phase': _$GamePhaseEnumMap[instance.phase]!,
      'status': _$GameStatusEnumMap[instance.status]!,
      'responseDeadline': instance.responseDeadline?.toIso8601String(),
      'winnerId': instance.winnerId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$GamePhaseEnumMap = {
  GamePhase.draw: 'draw',
  GamePhase.main: 'main',
  GamePhase.response: 'response',
  GamePhase.resolution: 'resolution',
  GamePhase.end: 'end',
};

const _$GameStatusEnumMap = {
  GameStatus.waiting: 'waiting',
  GameStatus.playing: 'playing',
  GameStatus.finished: 'finished',
};
