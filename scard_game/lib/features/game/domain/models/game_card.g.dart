// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameCardImpl _$$GameCardImplFromJson(Map<String, dynamic> json) =>
    _$GameCardImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CardTypeEnumMap, json['type']),
      color: $enumDecode(_$CardColorEnumMap, json['color']),
      description: json['description'] as String?,
      launcherCost: json['launcherCost'] as String,
      targetEffect: json['targetEffect'] as String?,
      damageIfRefused: (json['damageIfRefused'] as num?)?.toInt() ?? 0,
      gameEffect: json['gameEffect'] as String,
      drawCards: (json['drawCards'] as num?)?.toInt() ?? 0,
      drawCardsWhite: (json['drawCardsWhite'] as num?)?.toInt() ?? 0,
      drawCardsBlue: (json['drawCardsBlue'] as num?)?.toInt() ?? 0,
      drawCardsYellow: (json['drawCardsYellow'] as num?)?.toInt() ?? 0,
      drawCardsRed: (json['drawCardsRed'] as num?)?.toInt() ?? 0,
      drawCardsPerTurn: (json['drawCardsPerTurn'] as num?)?.toInt() ?? 0,
      removeClothing: (json['removeClothing'] as num?)?.toInt() ?? 0,
      addClothing: (json['addClothing'] as num?)?.toInt() ?? 0,
      destroyEnchantment: (json['destroyEnchantment'] as num?)?.toInt() ?? 0,
      destroyAllEnchantments: json['destroyAllEnchantments'] as bool? ?? false,
      replaceEnchantment: (json['replaceEnchantment'] as num?)?.toInt() ?? 0,
      sacrificeCard: (json['sacrificeCard'] as num?)?.toInt() ?? 0,
      discardCard: (json['discardCard'] as num?)?.toInt() ?? 0,
      opponentDraw: (json['opponentDraw'] as num?)?.toInt() ?? 0,
      opponentRemoveClothing:
          (json['opponentRemoveClothing'] as num?)?.toInt() ?? 0,
      shuffleHandIntoDeck: json['shuffleHandIntoDeck'] as bool? ?? false,
      piDamageOpponent: (json['piDamageOpponent'] as num?)?.toInt() ?? 0,
      piGainSelf: (json['piGainSelf'] as num?)?.toInt() ?? 0,
      tensionIncrease: (json['tensionIncrease'] as num?)?.toInt() ?? 0,
      piCost: (json['piCost'] as num?)?.toInt() ?? 0,
      isEnchantment: json['isEnchantment'] as bool? ?? false,
      enchantmentTargets:
          (json['enchantmentTargets'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      recurringEffects:
          (json['recurringEffects'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      statusModifiers:
          (json['statusModifiers'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      tensionPerTurn: (json['tensionPerTurn'] as num?)?.toInt(),
      maxPerDeck: (json['maxPerDeck'] as num?)?.toInt(),
      mechanics:
          (json['mechanics'] as List<dynamic>?)
              ?.map((e) => CardMechanic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      flavorText: json['flavorText'] as String?,
    );

Map<String, dynamic> _$$GameCardImplToJson(_$GameCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CardTypeEnumMap[instance.type]!,
      'color': _$CardColorEnumMap[instance.color]!,
      'description': instance.description,
      'launcherCost': instance.launcherCost,
      'targetEffect': instance.targetEffect,
      'damageIfRefused': instance.damageIfRefused,
      'gameEffect': instance.gameEffect,
      'drawCards': instance.drawCards,
      'drawCardsWhite': instance.drawCardsWhite,
      'drawCardsBlue': instance.drawCardsBlue,
      'drawCardsYellow': instance.drawCardsYellow,
      'drawCardsRed': instance.drawCardsRed,
      'drawCardsPerTurn': instance.drawCardsPerTurn,
      'removeClothing': instance.removeClothing,
      'addClothing': instance.addClothing,
      'destroyEnchantment': instance.destroyEnchantment,
      'destroyAllEnchantments': instance.destroyAllEnchantments,
      'replaceEnchantment': instance.replaceEnchantment,
      'sacrificeCard': instance.sacrificeCard,
      'discardCard': instance.discardCard,
      'opponentDraw': instance.opponentDraw,
      'opponentRemoveClothing': instance.opponentRemoveClothing,
      'shuffleHandIntoDeck': instance.shuffleHandIntoDeck,
      'piDamageOpponent': instance.piDamageOpponent,
      'piGainSelf': instance.piGainSelf,
      'tensionIncrease': instance.tensionIncrease,
      'piCost': instance.piCost,
      'isEnchantment': instance.isEnchantment,
      'enchantmentTargets': instance.enchantmentTargets,
      'recurringEffects': instance.recurringEffects,
      'statusModifiers': instance.statusModifiers,
      'tensionPerTurn': instance.tensionPerTurn,
      'maxPerDeck': instance.maxPerDeck,
      'mechanics': instance.mechanics,
      'imageUrl': instance.imageUrl,
      'flavorText': instance.flavorText,
    };

const _$CardTypeEnumMap = {
  CardType.instant: 'instant',
  CardType.ritual: 'ritual',
  CardType.enchantment: 'enchantment',
};

const _$CardColorEnumMap = {
  CardColor.white: 'white',
  CardColor.blue: 'blue',
  CardColor.yellow: 'yellow',
  CardColor.red: 'red',
  CardColor.green: 'green',
};
