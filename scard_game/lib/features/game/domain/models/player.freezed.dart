// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return _Player.fromJson(json);
}

/// @nodoc
mixin _$Player {
  /// ID unique du joueur
  String get id => throw _privateConstructorUsedError;

  /// Nom/Pseudo du joueur
  String get name => throw _privateConstructorUsedError;

  /// Points de vie (0-20)
  int get health => throw _privateConstructorUsedError;

  /// Jauge de tension (0-100%)
  double get tensionGauge => throw _privateConstructorUsedError;

  /// Cartes en main (IDs des cartes)
  List<String> get hand => throw _privateConstructorUsedError;

  /// Deck (pile de pioche) - IDs des cartes dans l'ordre
  List<String> get deck => throw _privateConstructorUsedError;

  /// Cimetière (cartes défaussées/détruites) - IDs des cartes
  List<String> get graveyard => throw _privateConstructorUsedError;

  /// Enchantements actifs sur la table
  List<ActiveEnchantment> get enchantments =>
      throw _privateConstructorUsedError;

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerCopyWith<Player> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerCopyWith<$Res> {
  factory $PlayerCopyWith(Player value, $Res Function(Player) then) =
      _$PlayerCopyWithImpl<$Res, Player>;
  @useResult
  $Res call({
    String id,
    String name,
    int health,
    double tensionGauge,
    List<String> hand,
    List<String> deck,
    List<String> graveyard,
    List<ActiveEnchantment> enchantments,
  });
}

/// @nodoc
class _$PlayerCopyWithImpl<$Res, $Val extends Player>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? health = null,
    Object? tensionGauge = null,
    Object? hand = null,
    Object? deck = null,
    Object? graveyard = null,
    Object? enchantments = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            health:
                null == health
                    ? _value.health
                    : health // ignore: cast_nullable_to_non_nullable
                        as int,
            tensionGauge:
                null == tensionGauge
                    ? _value.tensionGauge
                    : tensionGauge // ignore: cast_nullable_to_non_nullable
                        as double,
            hand:
                null == hand
                    ? _value.hand
                    : hand // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            deck:
                null == deck
                    ? _value.deck
                    : deck // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            graveyard:
                null == graveyard
                    ? _value.graveyard
                    : graveyard // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            enchantments:
                null == enchantments
                    ? _value.enchantments
                    : enchantments // ignore: cast_nullable_to_non_nullable
                        as List<ActiveEnchantment>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerImplCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$$PlayerImplCopyWith(
    _$PlayerImpl value,
    $Res Function(_$PlayerImpl) then,
  ) = __$$PlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int health,
    double tensionGauge,
    List<String> hand,
    List<String> deck,
    List<String> graveyard,
    List<ActiveEnchantment> enchantments,
  });
}

/// @nodoc
class __$$PlayerImplCopyWithImpl<$Res>
    extends _$PlayerCopyWithImpl<$Res, _$PlayerImpl>
    implements _$$PlayerImplCopyWith<$Res> {
  __$$PlayerImplCopyWithImpl(
    _$PlayerImpl _value,
    $Res Function(_$PlayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? health = null,
    Object? tensionGauge = null,
    Object? hand = null,
    Object? deck = null,
    Object? graveyard = null,
    Object? enchantments = null,
  }) {
    return _then(
      _$PlayerImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        health:
            null == health
                ? _value.health
                : health // ignore: cast_nullable_to_non_nullable
                    as int,
        tensionGauge:
            null == tensionGauge
                ? _value.tensionGauge
                : tensionGauge // ignore: cast_nullable_to_non_nullable
                    as double,
        hand:
            null == hand
                ? _value._hand
                : hand // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        deck:
            null == deck
                ? _value._deck
                : deck // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        graveyard:
            null == graveyard
                ? _value._graveyard
                : graveyard // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        enchantments:
            null == enchantments
                ? _value._enchantments
                : enchantments // ignore: cast_nullable_to_non_nullable
                    as List<ActiveEnchantment>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerImpl extends _Player {
  const _$PlayerImpl({
    required this.id,
    required this.name,
    this.health = 20,
    this.tensionGauge = 0.0,
    final List<String> hand = const [],
    final List<String> deck = const [],
    final List<String> graveyard = const [],
    final List<ActiveEnchantment> enchantments = const [],
  }) : _hand = hand,
       _deck = deck,
       _graveyard = graveyard,
       _enchantments = enchantments,
       super._();

  factory _$PlayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerImplFromJson(json);

  /// ID unique du joueur
  @override
  final String id;

  /// Nom/Pseudo du joueur
  @override
  final String name;

  /// Points de vie (0-20)
  @override
  @JsonKey()
  final int health;

  /// Jauge de tension (0-100%)
  @override
  @JsonKey()
  final double tensionGauge;

  /// Cartes en main (IDs des cartes)
  final List<String> _hand;

  /// Cartes en main (IDs des cartes)
  @override
  @JsonKey()
  List<String> get hand {
    if (_hand is EqualUnmodifiableListView) return _hand;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hand);
  }

  /// Deck (pile de pioche) - IDs des cartes dans l'ordre
  final List<String> _deck;

  /// Deck (pile de pioche) - IDs des cartes dans l'ordre
  @override
  @JsonKey()
  List<String> get deck {
    if (_deck is EqualUnmodifiableListView) return _deck;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deck);
  }

  /// Cimetière (cartes défaussées/détruites) - IDs des cartes
  final List<String> _graveyard;

  /// Cimetière (cartes défaussées/détruites) - IDs des cartes
  @override
  @JsonKey()
  List<String> get graveyard {
    if (_graveyard is EqualUnmodifiableListView) return _graveyard;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_graveyard);
  }

  /// Enchantements actifs sur la table
  final List<ActiveEnchantment> _enchantments;

  /// Enchantements actifs sur la table
  @override
  @JsonKey()
  List<ActiveEnchantment> get enchantments {
    if (_enchantments is EqualUnmodifiableListView) return _enchantments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enchantments);
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, health: $health, tensionGauge: $tensionGauge, hand: $hand, deck: $deck, graveyard: $graveyard, enchantments: $enchantments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.health, health) || other.health == health) &&
            (identical(other.tensionGauge, tensionGauge) ||
                other.tensionGauge == tensionGauge) &&
            const DeepCollectionEquality().equals(other._hand, _hand) &&
            const DeepCollectionEquality().equals(other._deck, _deck) &&
            const DeepCollectionEquality().equals(
              other._graveyard,
              _graveyard,
            ) &&
            const DeepCollectionEquality().equals(
              other._enchantments,
              _enchantments,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    health,
    tensionGauge,
    const DeepCollectionEquality().hash(_hand),
    const DeepCollectionEquality().hash(_deck),
    const DeepCollectionEquality().hash(_graveyard),
    const DeepCollectionEquality().hash(_enchantments),
  );

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      __$$PlayerImplCopyWithImpl<_$PlayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerImplToJson(this);
  }
}

abstract class _Player extends Player {
  const factory _Player({
    required final String id,
    required final String name,
    final int health,
    final double tensionGauge,
    final List<String> hand,
    final List<String> deck,
    final List<String> graveyard,
    final List<ActiveEnchantment> enchantments,
  }) = _$PlayerImpl;
  const _Player._() : super._();

  factory _Player.fromJson(Map<String, dynamic> json) = _$PlayerImpl.fromJson;

  /// ID unique du joueur
  @override
  String get id;

  /// Nom/Pseudo du joueur
  @override
  String get name;

  /// Points de vie (0-20)
  @override
  int get health;

  /// Jauge de tension (0-100%)
  @override
  double get tensionGauge;

  /// Cartes en main (IDs des cartes)
  @override
  List<String> get hand;

  /// Deck (pile de pioche) - IDs des cartes dans l'ordre
  @override
  List<String> get deck;

  /// Cimetière (cartes défaussées/détruites) - IDs des cartes
  @override
  List<String> get graveyard;

  /// Enchantements actifs sur la table
  @override
  List<ActiveEnchantment> get enchantments;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
