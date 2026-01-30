// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayerData _$PlayerDataFromJson(Map<String, dynamic> json) {
  return _PlayerData.fromJson(json);
}

/// @nodoc
mixin _$PlayerData {
  /// ID unique du joueur (Firebase Auth UID)
  String get playerId => throw _privateConstructorUsedError;

  /// Nom du joueur
  String get name => throw _privateConstructorUsedError;

  /// Sexe du joueur
  PlayerGender get gender => throw _privateConstructorUsedError;

  /// Points d'Inhibition (0-20)
  int get inhibitionPoints => throw _privateConstructorUsedError;

  /// Tension accumulée (0-100%)
  double get tension => throw _privateConstructorUsedError;

  /// IDs des cartes en main
  List<String> get handCardIds => throw _privateConstructorUsedError;

  /// IDs des cartes dans le deck
  List<String> get deckCardIds => throw _privateConstructorUsedError;

  /// IDs des cartes au cimetière
  List<String> get graveyardCardIds => throw _privateConstructorUsedError;

  /// IDs des cartes jouées ce tour
  List<String> get playedCardIds => throw _privateConstructorUsedError;

  /// IDs des enchantements actifs
  List<String> get activeEnchantmentIds => throw _privateConstructorUsedError;

  /// Palier actif pour chaque enchantement (white/blue/yellow/red)
  Map<String, String> get activeEnchantmentTiers =>
      throw _privateConstructorUsedError;

  /// Modificateurs persistants actifs (type -> liste d'enchantements)
  Map<String, List<String>> get activeStatusModifiers =>
      throw _privateConstructorUsedError;

  /// Le joueur est-il nu ? (important pour Ultima)
  bool get isNaked => throw _privateConstructorUsedError;

  /// Niveau de progression des cartes (white/blue/yellow/red)
  CardLevel get currentLevel => throw _privateConstructorUsedError;

  /// Le joueur est-il prêt ?
  bool get isReady => throw _privateConstructorUsedError;

  /// Le joueur a-t-il déjà sacrifié une carte ce tour ?
  bool get hasSacrificedThisTurn => throw _privateConstructorUsedError;

  /// Timestamp de connexion
  @JsonKey(includeIfNull: false)
  DateTime? get connectedAt => throw _privateConstructorUsedError;

  /// Timestamp de dernière activité (pour détecter déconnexion)
  @JsonKey(includeIfNull: false)
  DateTime? get lastActivityAt => throw _privateConstructorUsedError;

  /// Serializes this PlayerData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerDataCopyWith<PlayerData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerDataCopyWith<$Res> {
  factory $PlayerDataCopyWith(
    PlayerData value,
    $Res Function(PlayerData) then,
  ) = _$PlayerDataCopyWithImpl<$Res, PlayerData>;
  @useResult
  $Res call({
    String playerId,
    String name,
    PlayerGender gender,
    int inhibitionPoints,
    double tension,
    List<String> handCardIds,
    List<String> deckCardIds,
    List<String> graveyardCardIds,
    List<String> playedCardIds,
    List<String> activeEnchantmentIds,
    Map<String, String> activeEnchantmentTiers,
    Map<String, List<String>> activeStatusModifiers,
    bool isNaked,
    CardLevel currentLevel,
    bool isReady,
    bool hasSacrificedThisTurn,
    @JsonKey(includeIfNull: false) DateTime? connectedAt,
    @JsonKey(includeIfNull: false) DateTime? lastActivityAt,
  });
}

/// @nodoc
class _$PlayerDataCopyWithImpl<$Res, $Val extends PlayerData>
    implements $PlayerDataCopyWith<$Res> {
  _$PlayerDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? name = null,
    Object? gender = null,
    Object? inhibitionPoints = null,
    Object? tension = null,
    Object? handCardIds = null,
    Object? deckCardIds = null,
    Object? graveyardCardIds = null,
    Object? playedCardIds = null,
    Object? activeEnchantmentIds = null,
    Object? activeEnchantmentTiers = null,
    Object? activeStatusModifiers = null,
    Object? isNaked = null,
    Object? currentLevel = null,
    Object? isReady = null,
    Object? hasSacrificedThisTurn = null,
    Object? connectedAt = freezed,
    Object? lastActivityAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            playerId:
                null == playerId
                    ? _value.playerId
                    : playerId // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            gender:
                null == gender
                    ? _value.gender
                    : gender // ignore: cast_nullable_to_non_nullable
                        as PlayerGender,
            inhibitionPoints:
                null == inhibitionPoints
                    ? _value.inhibitionPoints
                    : inhibitionPoints // ignore: cast_nullable_to_non_nullable
                        as int,
            tension:
                null == tension
                    ? _value.tension
                    : tension // ignore: cast_nullable_to_non_nullable
                        as double,
            handCardIds:
                null == handCardIds
                    ? _value.handCardIds
                    : handCardIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            deckCardIds:
                null == deckCardIds
                    ? _value.deckCardIds
                    : deckCardIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            graveyardCardIds:
                null == graveyardCardIds
                    ? _value.graveyardCardIds
                    : graveyardCardIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            playedCardIds:
                null == playedCardIds
                    ? _value.playedCardIds
                    : playedCardIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            activeEnchantmentIds:
                null == activeEnchantmentIds
                    ? _value.activeEnchantmentIds
                    : activeEnchantmentIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            activeEnchantmentTiers:
                null == activeEnchantmentTiers
                    ? _value.activeEnchantmentTiers
                    : activeEnchantmentTiers // ignore: cast_nullable_to_non_nullable
                        as Map<String, String>,
            activeStatusModifiers:
                null == activeStatusModifiers
                    ? _value.activeStatusModifiers
                    : activeStatusModifiers // ignore: cast_nullable_to_non_nullable
                        as Map<String, List<String>>,
            isNaked:
                null == isNaked
                    ? _value.isNaked
                    : isNaked // ignore: cast_nullable_to_non_nullable
                        as bool,
            currentLevel:
                null == currentLevel
                    ? _value.currentLevel
                    : currentLevel // ignore: cast_nullable_to_non_nullable
                        as CardLevel,
            isReady:
                null == isReady
                    ? _value.isReady
                    : isReady // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasSacrificedThisTurn:
                null == hasSacrificedThisTurn
                    ? _value.hasSacrificedThisTurn
                    : hasSacrificedThisTurn // ignore: cast_nullable_to_non_nullable
                        as bool,
            connectedAt:
                freezed == connectedAt
                    ? _value.connectedAt
                    : connectedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            lastActivityAt:
                freezed == lastActivityAt
                    ? _value.lastActivityAt
                    : lastActivityAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerDataImplCopyWith<$Res>
    implements $PlayerDataCopyWith<$Res> {
  factory _$$PlayerDataImplCopyWith(
    _$PlayerDataImpl value,
    $Res Function(_$PlayerDataImpl) then,
  ) = __$$PlayerDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String playerId,
    String name,
    PlayerGender gender,
    int inhibitionPoints,
    double tension,
    List<String> handCardIds,
    List<String> deckCardIds,
    List<String> graveyardCardIds,
    List<String> playedCardIds,
    List<String> activeEnchantmentIds,
    Map<String, String> activeEnchantmentTiers,
    Map<String, List<String>> activeStatusModifiers,
    bool isNaked,
    CardLevel currentLevel,
    bool isReady,
    bool hasSacrificedThisTurn,
    @JsonKey(includeIfNull: false) DateTime? connectedAt,
    @JsonKey(includeIfNull: false) DateTime? lastActivityAt,
  });
}

/// @nodoc
class __$$PlayerDataImplCopyWithImpl<$Res>
    extends _$PlayerDataCopyWithImpl<$Res, _$PlayerDataImpl>
    implements _$$PlayerDataImplCopyWith<$Res> {
  __$$PlayerDataImplCopyWithImpl(
    _$PlayerDataImpl _value,
    $Res Function(_$PlayerDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? name = null,
    Object? gender = null,
    Object? inhibitionPoints = null,
    Object? tension = null,
    Object? handCardIds = null,
    Object? deckCardIds = null,
    Object? graveyardCardIds = null,
    Object? playedCardIds = null,
    Object? activeEnchantmentIds = null,
    Object? activeEnchantmentTiers = null,
    Object? activeStatusModifiers = null,
    Object? isNaked = null,
    Object? currentLevel = null,
    Object? isReady = null,
    Object? hasSacrificedThisTurn = null,
    Object? connectedAt = freezed,
    Object? lastActivityAt = freezed,
  }) {
    return _then(
      _$PlayerDataImpl(
        playerId:
            null == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        gender:
            null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                    as PlayerGender,
        inhibitionPoints:
            null == inhibitionPoints
                ? _value.inhibitionPoints
                : inhibitionPoints // ignore: cast_nullable_to_non_nullable
                    as int,
        tension:
            null == tension
                ? _value.tension
                : tension // ignore: cast_nullable_to_non_nullable
                    as double,
        handCardIds:
            null == handCardIds
                ? _value._handCardIds
                : handCardIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        deckCardIds:
            null == deckCardIds
                ? _value._deckCardIds
                : deckCardIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        graveyardCardIds:
            null == graveyardCardIds
                ? _value._graveyardCardIds
                : graveyardCardIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        playedCardIds:
            null == playedCardIds
                ? _value._playedCardIds
                : playedCardIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        activeEnchantmentIds:
            null == activeEnchantmentIds
                ? _value._activeEnchantmentIds
                : activeEnchantmentIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        activeEnchantmentTiers:
            null == activeEnchantmentTiers
                ? _value._activeEnchantmentTiers
                : activeEnchantmentTiers // ignore: cast_nullable_to_non_nullable
                    as Map<String, String>,
        activeStatusModifiers:
            null == activeStatusModifiers
                ? _value._activeStatusModifiers
                : activeStatusModifiers // ignore: cast_nullable_to_non_nullable
                    as Map<String, List<String>>,
        isNaked:
            null == isNaked
                ? _value.isNaked
                : isNaked // ignore: cast_nullable_to_non_nullable
                    as bool,
        currentLevel:
            null == currentLevel
                ? _value.currentLevel
                : currentLevel // ignore: cast_nullable_to_non_nullable
                    as CardLevel,
        isReady:
            null == isReady
                ? _value.isReady
                : isReady // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasSacrificedThisTurn:
            null == hasSacrificedThisTurn
                ? _value.hasSacrificedThisTurn
                : hasSacrificedThisTurn // ignore: cast_nullable_to_non_nullable
                    as bool,
        connectedAt:
            freezed == connectedAt
                ? _value.connectedAt
                : connectedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        lastActivityAt:
            freezed == lastActivityAt
                ? _value.lastActivityAt
                : lastActivityAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerDataImpl implements _PlayerData {
  const _$PlayerDataImpl({
    required this.playerId,
    required this.name,
    required this.gender,
    this.inhibitionPoints = 20,
    this.tension = 0,
    final List<String> handCardIds = const [],
    final List<String> deckCardIds = const [],
    final List<String> graveyardCardIds = const [],
    final List<String> playedCardIds = const [],
    final List<String> activeEnchantmentIds = const [],
    final Map<String, String> activeEnchantmentTiers = const {},
    final Map<String, List<String>> activeStatusModifiers = const {},
    this.isNaked = false,
    this.currentLevel = CardLevel.white,
    this.isReady = false,
    this.hasSacrificedThisTurn = false,
    @JsonKey(includeIfNull: false) this.connectedAt,
    @JsonKey(includeIfNull: false) this.lastActivityAt,
  }) : _handCardIds = handCardIds,
       _deckCardIds = deckCardIds,
       _graveyardCardIds = graveyardCardIds,
       _playedCardIds = playedCardIds,
       _activeEnchantmentIds = activeEnchantmentIds,
       _activeEnchantmentTiers = activeEnchantmentTiers,
       _activeStatusModifiers = activeStatusModifiers;

  factory _$PlayerDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerDataImplFromJson(json);

  /// ID unique du joueur (Firebase Auth UID)
  @override
  final String playerId;

  /// Nom du joueur
  @override
  final String name;

  /// Sexe du joueur
  @override
  final PlayerGender gender;

  /// Points d'Inhibition (0-20)
  @override
  @JsonKey()
  final int inhibitionPoints;

  /// Tension accumulée (0-100%)
  @override
  @JsonKey()
  final double tension;

  /// IDs des cartes en main
  final List<String> _handCardIds;

  /// IDs des cartes en main
  @override
  @JsonKey()
  List<String> get handCardIds {
    if (_handCardIds is EqualUnmodifiableListView) return _handCardIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_handCardIds);
  }

  /// IDs des cartes dans le deck
  final List<String> _deckCardIds;

  /// IDs des cartes dans le deck
  @override
  @JsonKey()
  List<String> get deckCardIds {
    if (_deckCardIds is EqualUnmodifiableListView) return _deckCardIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deckCardIds);
  }

  /// IDs des cartes au cimetière
  final List<String> _graveyardCardIds;

  /// IDs des cartes au cimetière
  @override
  @JsonKey()
  List<String> get graveyardCardIds {
    if (_graveyardCardIds is EqualUnmodifiableListView)
      return _graveyardCardIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_graveyardCardIds);
  }

  /// IDs des cartes jouées ce tour
  final List<String> _playedCardIds;

  /// IDs des cartes jouées ce tour
  @override
  @JsonKey()
  List<String> get playedCardIds {
    if (_playedCardIds is EqualUnmodifiableListView) return _playedCardIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playedCardIds);
  }

  /// IDs des enchantements actifs
  final List<String> _activeEnchantmentIds;

  /// IDs des enchantements actifs
  @override
  @JsonKey()
  List<String> get activeEnchantmentIds {
    if (_activeEnchantmentIds is EqualUnmodifiableListView)
      return _activeEnchantmentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeEnchantmentIds);
  }

  /// Palier actif pour chaque enchantement (white/blue/yellow/red)
  final Map<String, String> _activeEnchantmentTiers;

  /// Palier actif pour chaque enchantement (white/blue/yellow/red)
  @override
  @JsonKey()
  Map<String, String> get activeEnchantmentTiers {
    if (_activeEnchantmentTiers is EqualUnmodifiableMapView)
      return _activeEnchantmentTiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_activeEnchantmentTiers);
  }

  /// Modificateurs persistants actifs (type -> liste d'enchantements)
  final Map<String, List<String>> _activeStatusModifiers;

  /// Modificateurs persistants actifs (type -> liste d'enchantements)
  @override
  @JsonKey()
  Map<String, List<String>> get activeStatusModifiers {
    if (_activeStatusModifiers is EqualUnmodifiableMapView)
      return _activeStatusModifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_activeStatusModifiers);
  }

  /// Le joueur est-il nu ? (important pour Ultima)
  @override
  @JsonKey()
  final bool isNaked;

  /// Niveau de progression des cartes (white/blue/yellow/red)
  @override
  @JsonKey()
  final CardLevel currentLevel;

  /// Le joueur est-il prêt ?
  @override
  @JsonKey()
  final bool isReady;

  /// Le joueur a-t-il déjà sacrifié une carte ce tour ?
  @override
  @JsonKey()
  final bool hasSacrificedThisTurn;

  /// Timestamp de connexion
  @override
  @JsonKey(includeIfNull: false)
  final DateTime? connectedAt;

  /// Timestamp de dernière activité (pour détecter déconnexion)
  @override
  @JsonKey(includeIfNull: false)
  final DateTime? lastActivityAt;

  @override
  String toString() {
    return 'PlayerData(playerId: $playerId, name: $name, gender: $gender, inhibitionPoints: $inhibitionPoints, tension: $tension, handCardIds: $handCardIds, deckCardIds: $deckCardIds, graveyardCardIds: $graveyardCardIds, playedCardIds: $playedCardIds, activeEnchantmentIds: $activeEnchantmentIds, activeEnchantmentTiers: $activeEnchantmentTiers, activeStatusModifiers: $activeStatusModifiers, isNaked: $isNaked, currentLevel: $currentLevel, isReady: $isReady, hasSacrificedThisTurn: $hasSacrificedThisTurn, connectedAt: $connectedAt, lastActivityAt: $lastActivityAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerDataImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.inhibitionPoints, inhibitionPoints) ||
                other.inhibitionPoints == inhibitionPoints) &&
            (identical(other.tension, tension) || other.tension == tension) &&
            const DeepCollectionEquality().equals(
              other._handCardIds,
              _handCardIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._deckCardIds,
              _deckCardIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._graveyardCardIds,
              _graveyardCardIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._playedCardIds,
              _playedCardIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._activeEnchantmentIds,
              _activeEnchantmentIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._activeEnchantmentTiers,
              _activeEnchantmentTiers,
            ) &&
            const DeepCollectionEquality().equals(
              other._activeStatusModifiers,
              _activeStatusModifiers,
            ) &&
            (identical(other.isNaked, isNaked) || other.isNaked == isNaked) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.hasSacrificedThisTurn, hasSacrificedThisTurn) ||
                other.hasSacrificedThisTurn == hasSacrificedThisTurn) &&
            (identical(other.connectedAt, connectedAt) ||
                other.connectedAt == connectedAt) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    playerId,
    name,
    gender,
    inhibitionPoints,
    tension,
    const DeepCollectionEquality().hash(_handCardIds),
    const DeepCollectionEquality().hash(_deckCardIds),
    const DeepCollectionEquality().hash(_graveyardCardIds),
    const DeepCollectionEquality().hash(_playedCardIds),
    const DeepCollectionEquality().hash(_activeEnchantmentIds),
    const DeepCollectionEquality().hash(_activeEnchantmentTiers),
    const DeepCollectionEquality().hash(_activeStatusModifiers),
    isNaked,
    currentLevel,
    isReady,
    hasSacrificedThisTurn,
    connectedAt,
    lastActivityAt,
  );

  /// Create a copy of PlayerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerDataImplCopyWith<_$PlayerDataImpl> get copyWith =>
      __$$PlayerDataImplCopyWithImpl<_$PlayerDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerDataImplToJson(this);
  }
}

abstract class _PlayerData implements PlayerData {
  const factory _PlayerData({
    required final String playerId,
    required final String name,
    required final PlayerGender gender,
    final int inhibitionPoints,
    final double tension,
    final List<String> handCardIds,
    final List<String> deckCardIds,
    final List<String> graveyardCardIds,
    final List<String> playedCardIds,
    final List<String> activeEnchantmentIds,
    final Map<String, String> activeEnchantmentTiers,
    final Map<String, List<String>> activeStatusModifiers,
    final bool isNaked,
    final CardLevel currentLevel,
    final bool isReady,
    final bool hasSacrificedThisTurn,
    @JsonKey(includeIfNull: false) final DateTime? connectedAt,
    @JsonKey(includeIfNull: false) final DateTime? lastActivityAt,
  }) = _$PlayerDataImpl;

  factory _PlayerData.fromJson(Map<String, dynamic> json) =
      _$PlayerDataImpl.fromJson;

  /// ID unique du joueur (Firebase Auth UID)
  @override
  String get playerId;

  /// Nom du joueur
  @override
  String get name;

  /// Sexe du joueur
  @override
  PlayerGender get gender;

  /// Points d'Inhibition (0-20)
  @override
  int get inhibitionPoints;

  /// Tension accumulée (0-100%)
  @override
  double get tension;

  /// IDs des cartes en main
  @override
  List<String> get handCardIds;

  /// IDs des cartes dans le deck
  @override
  List<String> get deckCardIds;

  /// IDs des cartes au cimetière
  @override
  List<String> get graveyardCardIds;

  /// IDs des cartes jouées ce tour
  @override
  List<String> get playedCardIds;

  /// IDs des enchantements actifs
  @override
  List<String> get activeEnchantmentIds;

  /// Palier actif pour chaque enchantement (white/blue/yellow/red)
  @override
  Map<String, String> get activeEnchantmentTiers;

  /// Modificateurs persistants actifs (type -> liste d'enchantements)
  @override
  Map<String, List<String>> get activeStatusModifiers;

  /// Le joueur est-il nu ? (important pour Ultima)
  @override
  bool get isNaked;

  /// Niveau de progression des cartes (white/blue/yellow/red)
  @override
  CardLevel get currentLevel;

  /// Le joueur est-il prêt ?
  @override
  bool get isReady;

  /// Le joueur a-t-il déjà sacrifié une carte ce tour ?
  @override
  bool get hasSacrificedThisTurn;

  /// Timestamp de connexion
  @override
  @JsonKey(includeIfNull: false)
  DateTime? get connectedAt;

  /// Timestamp de dernière activité (pour détecter déconnexion)
  @override
  @JsonKey(includeIfNull: false)
  DateTime? get lastActivityAt;

  /// Create a copy of PlayerData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerDataImplCopyWith<_$PlayerDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
