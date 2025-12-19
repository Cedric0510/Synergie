// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_mechanic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CardMechanicImpl _$$CardMechanicImplFromJson(Map<String, dynamic> json) =>
    _$CardMechanicImpl(
      type: $enumDecode(_$MechanicTypeEnumMap, json['type']),
      target:
          $enumDecodeNullable(_$TargetTypeEnumMap, json['target']) ??
          TargetType.none,
      filter: json['filter'] as String?,
      count: (json['count'] as num?)?.toInt() ?? 1,
      replaceSpell: json['replaceSpell'] as bool? ?? false,
      initialCounterValue: (json['initialCounterValue'] as num?)?.toInt(),
      counterSource: json['counterSource'] as String?,
      conditions: json['conditions'] as Map<String, dynamic>?,
      additionalActions: json['additionalActions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CardMechanicImplToJson(_$CardMechanicImpl instance) =>
    <String, dynamic>{
      'type': _$MechanicTypeEnumMap[instance.type]!,
      'target': _$TargetTypeEnumMap[instance.target]!,
      'filter': instance.filter,
      'count': instance.count,
      'replaceSpell': instance.replaceSpell,
      'initialCounterValue': instance.initialCounterValue,
      'counterSource': instance.counterSource,
      'conditions': instance.conditions,
      'additionalActions': instance.additionalActions,
    };

const _$MechanicTypeEnumMap = {
  MechanicType.sacrificeCard: 'sacrificeCard',
  MechanicType.discardCard: 'discardCard',
  MechanicType.destroyEnchantment: 'destroyEnchantment',
  MechanicType.replaceEnchantment: 'replaceEnchantment',
  MechanicType.drawUntil: 'drawUntil',
  MechanicType.shuffleHandIntoDeck: 'shuffleHandIntoDeck',
  MechanicType.drawCards: 'drawCards',
  MechanicType.counterBased: 'counterBased',
  MechanicType.turnCounter: 'turnCounter',
  MechanicType.playerChoice: 'playerChoice',
  MechanicType.destroyAllEnchantments: 'destroyAllEnchantments',
  MechanicType.replaceSpell: 'replaceSpell',
  MechanicType.conditionalCounter: 'conditionalCounter',
};

const _$TargetTypeEnumMap = {
  TargetType.anyCard: 'anyCard',
  TargetType.ownHand: 'ownHand',
  TargetType.ownEnchantment: 'ownEnchantment',
  TargetType.opponentEnchantment: 'opponentEnchantment',
  TargetType.anyEnchantment: 'anyEnchantment',
  TargetType.currentSpell: 'currentSpell',
  TargetType.none: 'none',
};
