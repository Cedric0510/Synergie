// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameSessionImpl _$$GameSessionImplFromJson(
  Map<String, dynamic> json,
) => _$GameSessionImpl(
  sessionId: json['sessionId'] as String,
  player1Id: json['player1Id'] as String,
  player2Id: json['player2Id'] as String?,
  player1Data: PlayerData.fromJson(json['player1Data'] as Map<String, dynamic>),
  player2Data:
      json['player2Data'] == null
          ? null
          : PlayerData.fromJson(json['player2Data'] as Map<String, dynamic>),
  currentPlayerId: json['currentPlayerId'] as String?,
  currentPhase:
      $enumDecodeNullable(_$GamePhaseEnumMap, json['currentPhase']) ??
      GamePhase.draw,
  status:
      $enumDecodeNullable(_$GameStatusEnumMap, json['status']) ??
      GameStatus.waiting,
  resolutionStack:
      (json['resolutionStack'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  pendingSpellActions:
      (json['pendingSpellActions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  responseEffect: $enumDecodeNullable(
    _$ResponseEffectEnumMap,
    json['responseEffect'],
  ),
  cardAwaitingValidation: json['cardAwaitingValidation'] as String?,
  awaitingValidationFrom:
      (json['awaitingValidationFrom'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  validationResponses:
      (json['validationResponses'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  winnerId: json['winnerId'] as String?,
  ultimaOwnerId: json['ultimaOwnerId'] as String?,
  ultimaTurnCount: (json['ultimaTurnCount'] as num?)?.toInt() ?? 0,
  ultimaPlayedAt:
      json['ultimaPlayedAt'] == null
          ? null
          : DateTime.parse(json['ultimaPlayedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  startedAt:
      json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
  finishedAt:
      json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$GameSessionImplToJson(_$GameSessionImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'player1Id': instance.player1Id,
      'player2Id': instance.player2Id,
      'player1Data': instance.player1Data,
      'player2Data': instance.player2Data,
      'currentPlayerId': instance.currentPlayerId,
      'currentPhase': _$GamePhaseEnumMap[instance.currentPhase]!,
      'status': _$GameStatusEnumMap[instance.status]!,
      'resolutionStack': instance.resolutionStack,
      'pendingSpellActions': instance.pendingSpellActions,
      'responseEffect': _$ResponseEffectEnumMap[instance.responseEffect],
      'cardAwaitingValidation': instance.cardAwaitingValidation,
      'awaitingValidationFrom': instance.awaitingValidationFrom,
      'validationResponses': instance.validationResponses,
      'winnerId': instance.winnerId,
      'ultimaOwnerId': instance.ultimaOwnerId,
      'ultimaTurnCount': instance.ultimaTurnCount,
      'ultimaPlayedAt': instance.ultimaPlayedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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

const _$ResponseEffectEnumMap = {
  ResponseEffect.cancel: 'cancel',
  ResponseEffect.copy: 'copy',
  ResponseEffect.replace: 'replace',
  ResponseEffect.noEffect: 'noEffect',
};
