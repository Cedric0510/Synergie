// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeckConfigurationImpl _$$DeckConfigurationImplFromJson(
  Map<String, dynamic> json,
) => _$DeckConfigurationImpl(
  cardCounts: Map<String, int>.from(json['cardCounts'] as Map),
  name: json['name'] as String? ?? 'Mon Deck',
  lastModified:
      json['lastModified'] == null
          ? null
          : DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$$DeckConfigurationImplToJson(
  _$DeckConfigurationImpl instance,
) => <String, dynamic>{
  'cardCounts': instance.cardCounts,
  'name': instance.name,
  'lastModified': instance.lastModified?.toIso8601String(),
};
