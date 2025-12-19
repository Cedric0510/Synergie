// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  health: (json['health'] as num?)?.toInt() ?? 20,
  tensionGauge: (json['tensionGauge'] as num?)?.toDouble() ?? 0.0,
  hand:
      (json['hand'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  deck:
      (json['deck'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  graveyard:
      (json['graveyard'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  enchantments:
      (json['enchantments'] as List<dynamic>?)
          ?.map((e) => ActiveEnchantment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'health': instance.health,
      'tensionGauge': instance.tensionGauge,
      'hand': instance.hand,
      'deck': instance.deck,
      'graveyard': instance.graveyard,
      'enchantments': instance.enchantments,
    };
