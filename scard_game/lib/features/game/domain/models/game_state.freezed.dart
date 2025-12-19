// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return _GameState.fromJson(json);
}

/// @nodoc
mixin _$GameState {
  /// ID unique de la partie
  String get gameId => throw _privateConstructorUsedError;

  /// Joueur 1
  Player get player1 => throw _privateConstructorUsedError;

  /// Joueur 2
  Player get player2 => throw _privateConstructorUsedError;

  /// Numéro du tour actuel
  int get turn => throw _privateConstructorUsedError;

  /// ID du joueur actif (dont c'est le tour)
  String get activePlayerId => throw _privateConstructorUsedError;

  /// Phase actuelle du jeu
  GamePhase get phase => throw _privateConstructorUsedError;

  /// Statut de la partie
  GameStatus get status => throw _privateConstructorUsedError;

  /// Deadline pour répondre (null si pas de timer actif)
  DateTime? get responseDeadline => throw _privateConstructorUsedError;

  /// ID du gagnant (null si partie pas terminée)
  String? get winnerId => throw _privateConstructorUsedError;

  /// Timestamp de création de la partie
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call({
    String gameId,
    Player player1,
    Player player2,
    int turn,
    String activePlayerId,
    GamePhase phase,
    GameStatus status,
    DateTime? responseDeadline,
    String? winnerId,
    DateTime? createdAt,
  });

  $PlayerCopyWith<$Res> get player1;
  $PlayerCopyWith<$Res> get player2;
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? player1 = null,
    Object? player2 = null,
    Object? turn = null,
    Object? activePlayerId = null,
    Object? phase = null,
    Object? status = null,
    Object? responseDeadline = freezed,
    Object? winnerId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            gameId:
                null == gameId
                    ? _value.gameId
                    : gameId // ignore: cast_nullable_to_non_nullable
                        as String,
            player1:
                null == player1
                    ? _value.player1
                    : player1 // ignore: cast_nullable_to_non_nullable
                        as Player,
            player2:
                null == player2
                    ? _value.player2
                    : player2 // ignore: cast_nullable_to_non_nullable
                        as Player,
            turn:
                null == turn
                    ? _value.turn
                    : turn // ignore: cast_nullable_to_non_nullable
                        as int,
            activePlayerId:
                null == activePlayerId
                    ? _value.activePlayerId
                    : activePlayerId // ignore: cast_nullable_to_non_nullable
                        as String,
            phase:
                null == phase
                    ? _value.phase
                    : phase // ignore: cast_nullable_to_non_nullable
                        as GamePhase,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as GameStatus,
            responseDeadline:
                freezed == responseDeadline
                    ? _value.responseDeadline
                    : responseDeadline // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            winnerId:
                freezed == winnerId
                    ? _value.winnerId
                    : winnerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerCopyWith<$Res> get player1 {
    return $PlayerCopyWith<$Res>(_value.player1, (value) {
      return _then(_value.copyWith(player1: value) as $Val);
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerCopyWith<$Res> get player2 {
    return $PlayerCopyWith<$Res>(_value.player2, (value) {
      return _then(_value.copyWith(player2: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
    _$GameStateImpl value,
    $Res Function(_$GameStateImpl) then,
  ) = __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String gameId,
    Player player1,
    Player player2,
    int turn,
    String activePlayerId,
    GamePhase phase,
    GameStatus status,
    DateTime? responseDeadline,
    String? winnerId,
    DateTime? createdAt,
  });

  @override
  $PlayerCopyWith<$Res> get player1;
  @override
  $PlayerCopyWith<$Res> get player2;
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
    _$GameStateImpl _value,
    $Res Function(_$GameStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? player1 = null,
    Object? player2 = null,
    Object? turn = null,
    Object? activePlayerId = null,
    Object? phase = null,
    Object? status = null,
    Object? responseDeadline = freezed,
    Object? winnerId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$GameStateImpl(
        gameId:
            null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                    as String,
        player1:
            null == player1
                ? _value.player1
                : player1 // ignore: cast_nullable_to_non_nullable
                    as Player,
        player2:
            null == player2
                ? _value.player2
                : player2 // ignore: cast_nullable_to_non_nullable
                    as Player,
        turn:
            null == turn
                ? _value.turn
                : turn // ignore: cast_nullable_to_non_nullable
                    as int,
        activePlayerId:
            null == activePlayerId
                ? _value.activePlayerId
                : activePlayerId // ignore: cast_nullable_to_non_nullable
                    as String,
        phase:
            null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                    as GamePhase,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as GameStatus,
        responseDeadline:
            freezed == responseDeadline
                ? _value.responseDeadline
                : responseDeadline // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        winnerId:
            freezed == winnerId
                ? _value.winnerId
                : winnerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStateImpl extends _GameState {
  const _$GameStateImpl({
    required this.gameId,
    required this.player1,
    required this.player2,
    this.turn = 1,
    required this.activePlayerId,
    this.phase = GamePhase.main,
    this.status = GameStatus.waiting,
    this.responseDeadline,
    this.winnerId,
    this.createdAt,
  }) : super._();

  factory _$GameStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStateImplFromJson(json);

  /// ID unique de la partie
  @override
  final String gameId;

  /// Joueur 1
  @override
  final Player player1;

  /// Joueur 2
  @override
  final Player player2;

  /// Numéro du tour actuel
  @override
  @JsonKey()
  final int turn;

  /// ID du joueur actif (dont c'est le tour)
  @override
  final String activePlayerId;

  /// Phase actuelle du jeu
  @override
  @JsonKey()
  final GamePhase phase;

  /// Statut de la partie
  @override
  @JsonKey()
  final GameStatus status;

  /// Deadline pour répondre (null si pas de timer actif)
  @override
  final DateTime? responseDeadline;

  /// ID du gagnant (null si partie pas terminée)
  @override
  final String? winnerId;

  /// Timestamp de création de la partie
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'GameState(gameId: $gameId, player1: $player1, player2: $player2, turn: $turn, activePlayerId: $activePlayerId, phase: $phase, status: $status, responseDeadline: $responseDeadline, winnerId: $winnerId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.player1, player1) || other.player1 == player1) &&
            (identical(other.player2, player2) || other.player2 == player2) &&
            (identical(other.turn, turn) || other.turn == turn) &&
            (identical(other.activePlayerId, activePlayerId) ||
                other.activePlayerId == activePlayerId) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.responseDeadline, responseDeadline) ||
                other.responseDeadline == responseDeadline) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gameId,
    player1,
    player2,
    turn,
    activePlayerId,
    phase,
    status,
    responseDeadline,
    winnerId,
    createdAt,
  );

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStateImplToJson(this);
  }
}

abstract class _GameState extends GameState {
  const factory _GameState({
    required final String gameId,
    required final Player player1,
    required final Player player2,
    final int turn,
    required final String activePlayerId,
    final GamePhase phase,
    final GameStatus status,
    final DateTime? responseDeadline,
    final String? winnerId,
    final DateTime? createdAt,
  }) = _$GameStateImpl;
  const _GameState._() : super._();

  factory _GameState.fromJson(Map<String, dynamic> json) =
      _$GameStateImpl.fromJson;

  /// ID unique de la partie
  @override
  String get gameId;

  /// Joueur 1
  @override
  Player get player1;

  /// Joueur 2
  @override
  Player get player2;

  /// Numéro du tour actuel
  @override
  int get turn;

  /// ID du joueur actif (dont c'est le tour)
  @override
  String get activePlayerId;

  /// Phase actuelle du jeu
  @override
  GamePhase get phase;

  /// Statut de la partie
  @override
  GameStatus get status;

  /// Deadline pour répondre (null si pas de timer actif)
  @override
  DateTime? get responseDeadline;

  /// ID du gagnant (null si partie pas terminée)
  @override
  String? get winnerId;

  /// Timestamp de création de la partie
  @override
  DateTime? get createdAt;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
