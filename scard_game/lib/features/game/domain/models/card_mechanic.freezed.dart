// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_mechanic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CardMechanic _$CardMechanicFromJson(Map<String, dynamic> json) {
  return _CardMechanic.fromJson(json);
}

/// @nodoc
mixin _$CardMechanic {
  /// Type de mécanique
  MechanicType get type => throw _privateConstructorUsedError;

  /// Type de cible
  TargetType get target => throw _privateConstructorUsedError;

  /// Filtre pour la sélection (ex: "color:red", "type:ritual", "name:Plaisir")
  String? get filter => throw _privateConstructorUsedError;

  /// Nombre d'éléments concernés (cartes à piocher, enchantements à détruire, etc.)
  int get count => throw _privateConstructorUsedError;

  /// Si true, remplace le sort en cours de résolution
  bool get replaceSpell => throw _privateConstructorUsedError;

  /// Valeur initiale pour les compteurs (charges, tours, etc.)
  int? get initialCounterValue => throw _privateConstructorUsedError;

  /// Source de la valeur du compteur (ex: "clothingCount" pour Piège)
  String? get counterSource => throw _privateConstructorUsedError;

  /// Conditions pour déclencher la mécanique
  Map<String, dynamic>? get conditions => throw _privateConstructorUsedError;

  /// Actions supplémentaires à effectuer
  Map<String, dynamic>? get additionalActions =>
      throw _privateConstructorUsedError;

  /// Serializes this CardMechanic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardMechanic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardMechanicCopyWith<CardMechanic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardMechanicCopyWith<$Res> {
  factory $CardMechanicCopyWith(
    CardMechanic value,
    $Res Function(CardMechanic) then,
  ) = _$CardMechanicCopyWithImpl<$Res, CardMechanic>;
  @useResult
  $Res call({
    MechanicType type,
    TargetType target,
    String? filter,
    int count,
    bool replaceSpell,
    int? initialCounterValue,
    String? counterSource,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? additionalActions,
  });
}

/// @nodoc
class _$CardMechanicCopyWithImpl<$Res, $Val extends CardMechanic>
    implements $CardMechanicCopyWith<$Res> {
  _$CardMechanicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardMechanic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? target = null,
    Object? filter = freezed,
    Object? count = null,
    Object? replaceSpell = null,
    Object? initialCounterValue = freezed,
    Object? counterSource = freezed,
    Object? conditions = freezed,
    Object? additionalActions = freezed,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as MechanicType,
            target:
                null == target
                    ? _value.target
                    : target // ignore: cast_nullable_to_non_nullable
                        as TargetType,
            filter:
                freezed == filter
                    ? _value.filter
                    : filter // ignore: cast_nullable_to_non_nullable
                        as String?,
            count:
                null == count
                    ? _value.count
                    : count // ignore: cast_nullable_to_non_nullable
                        as int,
            replaceSpell:
                null == replaceSpell
                    ? _value.replaceSpell
                    : replaceSpell // ignore: cast_nullable_to_non_nullable
                        as bool,
            initialCounterValue:
                freezed == initialCounterValue
                    ? _value.initialCounterValue
                    : initialCounterValue // ignore: cast_nullable_to_non_nullable
                        as int?,
            counterSource:
                freezed == counterSource
                    ? _value.counterSource
                    : counterSource // ignore: cast_nullable_to_non_nullable
                        as String?,
            conditions:
                freezed == conditions
                    ? _value.conditions
                    : conditions // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            additionalActions:
                freezed == additionalActions
                    ? _value.additionalActions
                    : additionalActions // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CardMechanicImplCopyWith<$Res>
    implements $CardMechanicCopyWith<$Res> {
  factory _$$CardMechanicImplCopyWith(
    _$CardMechanicImpl value,
    $Res Function(_$CardMechanicImpl) then,
  ) = __$$CardMechanicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MechanicType type,
    TargetType target,
    String? filter,
    int count,
    bool replaceSpell,
    int? initialCounterValue,
    String? counterSource,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? additionalActions,
  });
}

/// @nodoc
class __$$CardMechanicImplCopyWithImpl<$Res>
    extends _$CardMechanicCopyWithImpl<$Res, _$CardMechanicImpl>
    implements _$$CardMechanicImplCopyWith<$Res> {
  __$$CardMechanicImplCopyWithImpl(
    _$CardMechanicImpl _value,
    $Res Function(_$CardMechanicImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CardMechanic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? target = null,
    Object? filter = freezed,
    Object? count = null,
    Object? replaceSpell = null,
    Object? initialCounterValue = freezed,
    Object? counterSource = freezed,
    Object? conditions = freezed,
    Object? additionalActions = freezed,
  }) {
    return _then(
      _$CardMechanicImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as MechanicType,
        target:
            null == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                    as TargetType,
        filter:
            freezed == filter
                ? _value.filter
                : filter // ignore: cast_nullable_to_non_nullable
                    as String?,
        count:
            null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int,
        replaceSpell:
            null == replaceSpell
                ? _value.replaceSpell
                : replaceSpell // ignore: cast_nullable_to_non_nullable
                    as bool,
        initialCounterValue:
            freezed == initialCounterValue
                ? _value.initialCounterValue
                : initialCounterValue // ignore: cast_nullable_to_non_nullable
                    as int?,
        counterSource:
            freezed == counterSource
                ? _value.counterSource
                : counterSource // ignore: cast_nullable_to_non_nullable
                    as String?,
        conditions:
            freezed == conditions
                ? _value._conditions
                : conditions // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        additionalActions:
            freezed == additionalActions
                ? _value._additionalActions
                : additionalActions // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CardMechanicImpl implements _CardMechanic {
  const _$CardMechanicImpl({
    required this.type,
    this.target = TargetType.none,
    this.filter,
    this.count = 1,
    this.replaceSpell = false,
    this.initialCounterValue,
    this.counterSource,
    final Map<String, dynamic>? conditions,
    final Map<String, dynamic>? additionalActions,
  }) : _conditions = conditions,
       _additionalActions = additionalActions;

  factory _$CardMechanicImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardMechanicImplFromJson(json);

  /// Type de mécanique
  @override
  final MechanicType type;

  /// Type de cible
  @override
  @JsonKey()
  final TargetType target;

  /// Filtre pour la sélection (ex: "color:red", "type:ritual", "name:Plaisir")
  @override
  final String? filter;

  /// Nombre d'éléments concernés (cartes à piocher, enchantements à détruire, etc.)
  @override
  @JsonKey()
  final int count;

  /// Si true, remplace le sort en cours de résolution
  @override
  @JsonKey()
  final bool replaceSpell;

  /// Valeur initiale pour les compteurs (charges, tours, etc.)
  @override
  final int? initialCounterValue;

  /// Source de la valeur du compteur (ex: "clothingCount" pour Piège)
  @override
  final String? counterSource;

  /// Conditions pour déclencher la mécanique
  final Map<String, dynamic>? _conditions;

  /// Conditions pour déclencher la mécanique
  @override
  Map<String, dynamic>? get conditions {
    final value = _conditions;
    if (value == null) return null;
    if (_conditions is EqualUnmodifiableMapView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Actions supplémentaires à effectuer
  final Map<String, dynamic>? _additionalActions;

  /// Actions supplémentaires à effectuer
  @override
  Map<String, dynamic>? get additionalActions {
    final value = _additionalActions;
    if (value == null) return null;
    if (_additionalActions is EqualUnmodifiableMapView)
      return _additionalActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CardMechanic(type: $type, target: $target, filter: $filter, count: $count, replaceSpell: $replaceSpell, initialCounterValue: $initialCounterValue, counterSource: $counterSource, conditions: $conditions, additionalActions: $additionalActions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardMechanicImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.replaceSpell, replaceSpell) ||
                other.replaceSpell == replaceSpell) &&
            (identical(other.initialCounterValue, initialCounterValue) ||
                other.initialCounterValue == initialCounterValue) &&
            (identical(other.counterSource, counterSource) ||
                other.counterSource == counterSource) &&
            const DeepCollectionEquality().equals(
              other._conditions,
              _conditions,
            ) &&
            const DeepCollectionEquality().equals(
              other._additionalActions,
              _additionalActions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    target,
    filter,
    count,
    replaceSpell,
    initialCounterValue,
    counterSource,
    const DeepCollectionEquality().hash(_conditions),
    const DeepCollectionEquality().hash(_additionalActions),
  );

  /// Create a copy of CardMechanic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardMechanicImplCopyWith<_$CardMechanicImpl> get copyWith =>
      __$$CardMechanicImplCopyWithImpl<_$CardMechanicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardMechanicImplToJson(this);
  }
}

abstract class _CardMechanic implements CardMechanic {
  const factory _CardMechanic({
    required final MechanicType type,
    final TargetType target,
    final String? filter,
    final int count,
    final bool replaceSpell,
    final int? initialCounterValue,
    final String? counterSource,
    final Map<String, dynamic>? conditions,
    final Map<String, dynamic>? additionalActions,
  }) = _$CardMechanicImpl;

  factory _CardMechanic.fromJson(Map<String, dynamic> json) =
      _$CardMechanicImpl.fromJson;

  /// Type de mécanique
  @override
  MechanicType get type;

  /// Type de cible
  @override
  TargetType get target;

  /// Filtre pour la sélection (ex: "color:red", "type:ritual", "name:Plaisir")
  @override
  String? get filter;

  /// Nombre d'éléments concernés (cartes à piocher, enchantements à détruire, etc.)
  @override
  int get count;

  /// Si true, remplace le sort en cours de résolution
  @override
  bool get replaceSpell;

  /// Valeur initiale pour les compteurs (charges, tours, etc.)
  @override
  int? get initialCounterValue;

  /// Source de la valeur du compteur (ex: "clothingCount" pour Piège)
  @override
  String? get counterSource;

  /// Conditions pour déclencher la mécanique
  @override
  Map<String, dynamic>? get conditions;

  /// Actions supplémentaires à effectuer
  @override
  Map<String, dynamic>? get additionalActions;

  /// Create a copy of CardMechanic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardMechanicImplCopyWith<_$CardMechanicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
