// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeckConfiguration _$DeckConfigurationFromJson(Map<String, dynamic> json) {
  return _DeckConfiguration.fromJson(json);
}

/// @nodoc
mixin _$DeckConfiguration {
  /// Map de cardId -> nombre d'exemplaires (0-4, sauf Ultima: 1 max)
  Map<String, int> get cardCounts => throw _privateConstructorUsedError;

  /// Nom du deck (optionnel)
  String get name => throw _privateConstructorUsedError;

  /// Date de dernière modification
  DateTime? get lastModified => throw _privateConstructorUsedError;

  /// Serializes this DeckConfiguration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeckConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeckConfigurationCopyWith<DeckConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeckConfigurationCopyWith<$Res> {
  factory $DeckConfigurationCopyWith(
    DeckConfiguration value,
    $Res Function(DeckConfiguration) then,
  ) = _$DeckConfigurationCopyWithImpl<$Res, DeckConfiguration>;
  @useResult
  $Res call({Map<String, int> cardCounts, String name, DateTime? lastModified});
}

/// @nodoc
class _$DeckConfigurationCopyWithImpl<$Res, $Val extends DeckConfiguration>
    implements $DeckConfigurationCopyWith<$Res> {
  _$DeckConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeckConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardCounts = null,
    Object? name = null,
    Object? lastModified = freezed,
  }) {
    return _then(
      _value.copyWith(
            cardCounts:
                null == cardCounts
                    ? _value.cardCounts
                    : cardCounts // ignore: cast_nullable_to_non_nullable
                        as Map<String, int>,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            lastModified:
                freezed == lastModified
                    ? _value.lastModified
                    : lastModified // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeckConfigurationImplCopyWith<$Res>
    implements $DeckConfigurationCopyWith<$Res> {
  factory _$$DeckConfigurationImplCopyWith(
    _$DeckConfigurationImpl value,
    $Res Function(_$DeckConfigurationImpl) then,
  ) = __$$DeckConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, int> cardCounts, String name, DateTime? lastModified});
}

/// @nodoc
class __$$DeckConfigurationImplCopyWithImpl<$Res>
    extends _$DeckConfigurationCopyWithImpl<$Res, _$DeckConfigurationImpl>
    implements _$$DeckConfigurationImplCopyWith<$Res> {
  __$$DeckConfigurationImplCopyWithImpl(
    _$DeckConfigurationImpl _value,
    $Res Function(_$DeckConfigurationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeckConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardCounts = null,
    Object? name = null,
    Object? lastModified = freezed,
  }) {
    return _then(
      _$DeckConfigurationImpl(
        cardCounts:
            null == cardCounts
                ? _value._cardCounts
                : cardCounts // ignore: cast_nullable_to_non_nullable
                    as Map<String, int>,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        lastModified:
            freezed == lastModified
                ? _value.lastModified
                : lastModified // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeckConfigurationImpl extends _DeckConfiguration {
  const _$DeckConfigurationImpl({
    required final Map<String, int> cardCounts,
    this.name = 'Mon Deck',
    this.lastModified,
  }) : _cardCounts = cardCounts,
       super._();

  factory _$DeckConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeckConfigurationImplFromJson(json);

  /// Map de cardId -> nombre d'exemplaires (0-4, sauf Ultima: 1 max)
  final Map<String, int> _cardCounts;

  /// Map de cardId -> nombre d'exemplaires (0-4, sauf Ultima: 1 max)
  @override
  Map<String, int> get cardCounts {
    if (_cardCounts is EqualUnmodifiableMapView) return _cardCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cardCounts);
  }

  /// Nom du deck (optionnel)
  @override
  @JsonKey()
  final String name;

  /// Date de dernière modification
  @override
  final DateTime? lastModified;

  @override
  String toString() {
    return 'DeckConfiguration(cardCounts: $cardCounts, name: $name, lastModified: $lastModified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeckConfigurationImpl &&
            const DeepCollectionEquality().equals(
              other._cardCounts,
              _cardCounts,
            ) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.lastModified, lastModified) ||
                other.lastModified == lastModified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_cardCounts),
    name,
    lastModified,
  );

  /// Create a copy of DeckConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeckConfigurationImplCopyWith<_$DeckConfigurationImpl> get copyWith =>
      __$$DeckConfigurationImplCopyWithImpl<_$DeckConfigurationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeckConfigurationImplToJson(this);
  }
}

abstract class _DeckConfiguration extends DeckConfiguration {
  const factory _DeckConfiguration({
    required final Map<String, int> cardCounts,
    final String name,
    final DateTime? lastModified,
  }) = _$DeckConfigurationImpl;
  const _DeckConfiguration._() : super._();

  factory _DeckConfiguration.fromJson(Map<String, dynamic> json) =
      _$DeckConfigurationImpl.fromJson;

  /// Map de cardId -> nombre d'exemplaires (0-4, sauf Ultima: 1 max)
  @override
  Map<String, int> get cardCounts;

  /// Nom du deck (optionnel)
  @override
  String get name;

  /// Date de dernière modification
  @override
  DateTime? get lastModified;

  /// Create a copy of DeckConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeckConfigurationImplCopyWith<_$DeckConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
