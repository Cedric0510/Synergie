// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_enchantment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActiveEnchantmentImpl _$$ActiveEnchantmentImplFromJson(
  Map<String, dynamic> json,
) => _$ActiveEnchantmentImpl(
  card: GameCard.fromJson(json['card'] as Map<String, dynamic>),
  ownerId: json['ownerId'] as String,
  targetId: json['targetId'] as String,
  playedAt: DateTime.parse(json['playedAt'] as String),
  turnsActive: (json['turnsActive'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ActiveEnchantmentImplToJson(
  _$ActiveEnchantmentImpl instance,
) => <String, dynamic>{
  'card': instance.card,
  'ownerId': instance.ownerId,
  'targetId': instance.targetId,
  'playedAt': instance.playedAt.toIso8601String(),
  'turnsActive': instance.turnsActive,
};
