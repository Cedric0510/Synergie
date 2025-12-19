// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_enchantment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActiveEnchantment _$ActiveEnchantmentFromJson(Map<String, dynamic> json) {
  return _ActiveEnchantment.fromJson(json);
}

/// @nodoc
mixin _$ActiveEnchantment {
  /// La carte enchantement
  GameCard get card => throw _privateConstructorUsedError;

  /// ID du joueur qui a posé l'enchantement
  String get ownerId => throw _privateConstructorUsedError;

  /// ID du joueur qui subit l'enchantement
  String get targetId => throw _privateConstructorUsedError;

  /// Timestamp de quand l'enchantement a été posé
  DateTime get playedAt => throw _privateConstructorUsedError;

  /// Nombre de tours pendant lesquels l'enchantement a été actif
  int get turnsActive => throw _privateConstructorUsedError;

  /// Serializes this ActiveEnchantment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActiveEnchantment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActiveEnchantmentCopyWith<ActiveEnchantment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveEnchantmentCopyWith<$Res> {
  factory $ActiveEnchantmentCopyWith(
    ActiveEnchantment value,
    $Res Function(ActiveEnchantment) then,
  ) = _$ActiveEnchantmentCopyWithImpl<$Res, ActiveEnchantment>;
  @useResult
  $Res call({
    GameCard card,
    String ownerId,
    String targetId,
    DateTime playedAt,
    int turnsActive,
  });

  $GameCardCopyWith<$Res> get card;
}

/// @nodoc
class _$ActiveEnchantmentCopyWithImpl<$Res, $Val extends ActiveEnchantment>
    implements $ActiveEnchantmentCopyWith<$Res> {
  _$ActiveEnchantmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActiveEnchantment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? card = null,
    Object? ownerId = null,
    Object? targetId = null,
    Object? playedAt = null,
    Object? turnsActive = null,
  }) {
    return _then(
      _value.copyWith(
            card:
                null == card
                    ? _value.card
                    : card // ignore: cast_nullable_to_non_nullable
                        as GameCard,
            ownerId:
                null == ownerId
                    ? _value.ownerId
                    : ownerId // ignore: cast_nullable_to_non_nullable
                        as String,
            targetId:
                null == targetId
                    ? _value.targetId
                    : targetId // ignore: cast_nullable_to_non_nullable
                        as String,
            playedAt:
                null == playedAt
                    ? _value.playedAt
                    : playedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            turnsActive:
                null == turnsActive
                    ? _value.turnsActive
                    : turnsActive // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }

  /// Create a copy of ActiveEnchantment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameCardCopyWith<$Res> get card {
    return $GameCardCopyWith<$Res>(_value.card, (value) {
      return _then(_value.copyWith(card: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActiveEnchantmentImplCopyWith<$Res>
    implements $ActiveEnchantmentCopyWith<$Res> {
  factory _$$ActiveEnchantmentImplCopyWith(
    _$ActiveEnchantmentImpl value,
    $Res Function(_$ActiveEnchantmentImpl) then,
  ) = __$$ActiveEnchantmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GameCard card,
    String ownerId,
    String targetId,
    DateTime playedAt,
    int turnsActive,
  });

  @override
  $GameCardCopyWith<$Res> get card;
}

/// @nodoc
class __$$ActiveEnchantmentImplCopyWithImpl<$Res>
    extends _$ActiveEnchantmentCopyWithImpl<$Res, _$ActiveEnchantmentImpl>
    implements _$$ActiveEnchantmentImplCopyWith<$Res> {
  __$$ActiveEnchantmentImplCopyWithImpl(
    _$ActiveEnchantmentImpl _value,
    $Res Function(_$ActiveEnchantmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActiveEnchantment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? card = null,
    Object? ownerId = null,
    Object? targetId = null,
    Object? playedAt = null,
    Object? turnsActive = null,
  }) {
    return _then(
      _$ActiveEnchantmentImpl(
        card:
            null == card
                ? _value.card
                : card // ignore: cast_nullable_to_non_nullable
                    as GameCard,
        ownerId:
            null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                    as String,
        targetId:
            null == targetId
                ? _value.targetId
                : targetId // ignore: cast_nullable_to_non_nullable
                    as String,
        playedAt:
            null == playedAt
                ? _value.playedAt
                : playedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        turnsActive:
            null == turnsActive
                ? _value.turnsActive
                : turnsActive // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActiveEnchantmentImpl extends _ActiveEnchantment {
  const _$ActiveEnchantmentImpl({
    required this.card,
    required this.ownerId,
    required this.targetId,
    required this.playedAt,
    this.turnsActive = 0,
  }) : super._();

  factory _$ActiveEnchantmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActiveEnchantmentImplFromJson(json);

  /// La carte enchantement
  @override
  final GameCard card;

  /// ID du joueur qui a posé l'enchantement
  @override
  final String ownerId;

  /// ID du joueur qui subit l'enchantement
  @override
  final String targetId;

  /// Timestamp de quand l'enchantement a été posé
  @override
  final DateTime playedAt;

  /// Nombre de tours pendant lesquels l'enchantement a été actif
  @override
  @JsonKey()
  final int turnsActive;

  @override
  String toString() {
    return 'ActiveEnchantment(card: $card, ownerId: $ownerId, targetId: $targetId, playedAt: $playedAt, turnsActive: $turnsActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveEnchantmentImpl &&
            (identical(other.card, card) || other.card == card) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt) &&
            (identical(other.turnsActive, turnsActive) ||
                other.turnsActive == turnsActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, card, ownerId, targetId, playedAt, turnsActive);

  /// Create a copy of ActiveEnchantment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveEnchantmentImplCopyWith<_$ActiveEnchantmentImpl> get copyWith =>
      __$$ActiveEnchantmentImplCopyWithImpl<_$ActiveEnchantmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActiveEnchantmentImplToJson(this);
  }
}

abstract class _ActiveEnchantment extends ActiveEnchantment {
  const factory _ActiveEnchantment({
    required final GameCard card,
    required final String ownerId,
    required final String targetId,
    required final DateTime playedAt,
    final int turnsActive,
  }) = _$ActiveEnchantmentImpl;
  const _ActiveEnchantment._() : super._();

  factory _ActiveEnchantment.fromJson(Map<String, dynamic> json) =
      _$ActiveEnchantmentImpl.fromJson;

  /// La carte enchantement
  @override
  GameCard get card;

  /// ID du joueur qui a posé l'enchantement
  @override
  String get ownerId;

  /// ID du joueur qui subit l'enchantement
  @override
  String get targetId;

  /// Timestamp de quand l'enchantement a été posé
  @override
  DateTime get playedAt;

  /// Nombre de tours pendant lesquels l'enchantement a été actif
  @override
  int get turnsActive;

  /// Create a copy of ActiveEnchantment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActiveEnchantmentImplCopyWith<_$ActiveEnchantmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
