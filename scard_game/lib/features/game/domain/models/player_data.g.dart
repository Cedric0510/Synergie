// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerDataImpl _$$PlayerDataImplFromJson(Map<String, dynamic> json) =>
    _$PlayerDataImpl(
      playerId: json['playerId'] as String,
      name: json['name'] as String,
      gender: $enumDecode(_$PlayerGenderEnumMap, json['gender']),
      inhibitionPoints: (json['inhibitionPoints'] as num?)?.toInt() ?? 20,
      tension: (json['tension'] as num?)?.toDouble() ?? 0,
      handCardIds:
          (json['handCardIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      deckCardIds:
          (json['deckCardIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      graveyardCardIds:
          (json['graveyardCardIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      playedCardIds:
          (json['playedCardIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      activeEnchantmentIds:
          (json['activeEnchantmentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isNaked: json['isNaked'] as bool? ?? false,
      currentLevel:
          $enumDecodeNullable(_$CardLevelEnumMap, json['currentLevel']) ??
          CardLevel.white,
      isReady: json['isReady'] as bool? ?? false,
      hasSacrificedThisTurn: json['hasSacrificedThisTurn'] as bool? ?? false,
      connectedAt:
          json['connectedAt'] == null
              ? null
              : DateTime.parse(json['connectedAt'] as String),
      lastActivityAt:
          json['lastActivityAt'] == null
              ? null
              : DateTime.parse(json['lastActivityAt'] as String),
    );

Map<String, dynamic> _$$PlayerDataImplToJson(_$PlayerDataImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'name': instance.name,
      'gender': _$PlayerGenderEnumMap[instance.gender]!,
      'inhibitionPoints': instance.inhibitionPoints,
      'tension': instance.tension,
      'handCardIds': instance.handCardIds,
      'deckCardIds': instance.deckCardIds,
      'graveyardCardIds': instance.graveyardCardIds,
      'playedCardIds': instance.playedCardIds,
      'activeEnchantmentIds': instance.activeEnchantmentIds,
      'isNaked': instance.isNaked,
      'currentLevel': _$CardLevelEnumMap[instance.currentLevel]!,
      'isReady': instance.isReady,
      'hasSacrificedThisTurn': instance.hasSacrificedThisTurn,
      if (instance.connectedAt?.toIso8601String() case final value?)
        'connectedAt': value,
      if (instance.lastActivityAt?.toIso8601String() case final value?)
        'lastActivityAt': value,
    };

const _$PlayerGenderEnumMap = {
  PlayerGender.male: 'male',
  PlayerGender.female: 'female',
  PlayerGender.other: 'other',
};

const _$CardLevelEnumMap = {
  CardLevel.white: 'white',
  CardLevel.blue: 'blue',
  CardLevel.yellow: 'yellow',
  CardLevel.red: 'red',
};
