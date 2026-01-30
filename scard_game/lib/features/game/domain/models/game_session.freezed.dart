// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameSession _$GameSessionFromJson(Map<String, dynamic> json) {
  return _GameSession.fromJson(json);
}

/// @nodoc
mixin _$GameSession {
  /// ID unique de la session (code de partie)
  String get sessionId => throw _privateConstructorUsedError;

  /// ID du joueur 1
  String get player1Id => throw _privateConstructorUsedError;

  /// ID du joueur 2 (null si partie pas encore rejointe)
  String? get player2Id => throw _privateConstructorUsedError;

  /// Données du joueur 1
  PlayerData get player1Data => throw _privateConstructorUsedError;

  /// Données du joueur 2 (null si partie pas encore rejointe)
  PlayerData? get player2Data => throw _privateConstructorUsedError;

  /// ID du joueur actif (qui doit jouer)
  String? get currentPlayerId => throw _privateConstructorUsedError;

  /// Phase actuelle du jeu
  GamePhase get currentPhase => throw _privateConstructorUsedError;

  /// Statut de la partie
  GameStatus get status => throw _privateConstructorUsedError;

  /// Pile de résolution (IDs des cartes jouées ce tour)
  List<String> get resolutionStack => throw _privateConstructorUsedError;

  /// Palier choisi pour chaque carte jouée ce tour (white/blue/yellow/red)
  Map<String, String> get playedCardTiers => throw _privateConstructorUsedError;

  /// Actions pendantes du sort actif (à exécuter en Resolution si non contré)
  List<Map<String, dynamic>> get pendingSpellActions =>
      throw _privateConstructorUsedError;

  /// Pioche auto deja faite pour ce tour
  bool get drawDoneThisTurn => throw _privateConstructorUsedError;

  /// Effets d'enchantements déjà appliqués pour ce tour
  bool get enchantmentEffectsDoneThisTurn => throw _privateConstructorUsedError;

  /// === VALIDATION D'ACTIONS ===
  /// Effet de la carte de réponse jouée (null si pas de réponse)
  ResponseEffect? get responseEffect => throw _privateConstructorUsedError;

  /// ID de la carte dont l'action attend validation
  String? get cardAwaitingValidation => throw _privateConstructorUsedError;

  /// Liste des joueurs devant valider (IDs)
  List<String> get awaitingValidationFrom => throw _privateConstructorUsedError;

  /// Map des réponses de validation {playerId: actionCompleted}
  /// true = action effectuée, false = action refusée
  Map<String, bool> get validationResponses =>
      throw _privateConstructorUsedError;

  /// ID du gagnant (null si partie en cours)
  String? get winnerId => throw _privateConstructorUsedError;

  /// === COMPTEUR ULTIMA ===
  /// ID du joueur qui a le compteur Ultima actif (premier à avoir posé Ultima)
  String? get ultimaOwnerId => throw _privateConstructorUsedError;

  /// Nombre de tours écoulés depuis que Ultima est en jeu
  int get ultimaTurnCount => throw _privateConstructorUsedError;

  /// Timestamp de pose d'Ultima pour déterminer qui l'a posé en premier
  DateTime? get ultimaPlayedAt => throw _privateConstructorUsedError;

  /// Timestamp de création
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp de début de partie
  DateTime? get startedAt => throw _privateConstructorUsedError;

  /// Timestamp de fin de partie
  DateTime? get finishedAt => throw _privateConstructorUsedError;

  /// Timestamp de dernière mise à jour
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this GameSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSessionCopyWith<GameSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSessionCopyWith<$Res> {
  factory $GameSessionCopyWith(
    GameSession value,
    $Res Function(GameSession) then,
  ) = _$GameSessionCopyWithImpl<$Res, GameSession>;
  @useResult
  $Res call({
    String sessionId,
    String player1Id,
    String? player2Id,
    PlayerData player1Data,
    PlayerData? player2Data,
    String? currentPlayerId,
    GamePhase currentPhase,
    GameStatus status,
    List<String> resolutionStack,
    Map<String, String> playedCardTiers,
    List<Map<String, dynamic>> pendingSpellActions,
    bool drawDoneThisTurn,
    bool enchantmentEffectsDoneThisTurn,
    ResponseEffect? responseEffect,
    String? cardAwaitingValidation,
    List<String> awaitingValidationFrom,
    Map<String, bool> validationResponses,
    String? winnerId,
    String? ultimaOwnerId,
    int ultimaTurnCount,
    DateTime? ultimaPlayedAt,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime updatedAt,
  });

  $PlayerDataCopyWith<$Res> get player1Data;
  $PlayerDataCopyWith<$Res>? get player2Data;
}

/// @nodoc
class _$GameSessionCopyWithImpl<$Res, $Val extends GameSession>
    implements $GameSessionCopyWith<$Res> {
  _$GameSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? player1Id = null,
    Object? player2Id = freezed,
    Object? player1Data = null,
    Object? player2Data = freezed,
    Object? currentPlayerId = freezed,
    Object? currentPhase = null,
    Object? status = null,
    Object? resolutionStack = null,
    Object? playedCardTiers = null,
    Object? pendingSpellActions = null,
    Object? drawDoneThisTurn = null,
    Object? enchantmentEffectsDoneThisTurn = null,
    Object? responseEffect = freezed,
    Object? cardAwaitingValidation = freezed,
    Object? awaitingValidationFrom = null,
    Object? validationResponses = null,
    Object? winnerId = freezed,
    Object? ultimaOwnerId = freezed,
    Object? ultimaTurnCount = null,
    Object? ultimaPlayedAt = freezed,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId:
                null == sessionId
                    ? _value.sessionId
                    : sessionId // ignore: cast_nullable_to_non_nullable
                        as String,
            player1Id:
                null == player1Id
                    ? _value.player1Id
                    : player1Id // ignore: cast_nullable_to_non_nullable
                        as String,
            player2Id:
                freezed == player2Id
                    ? _value.player2Id
                    : player2Id // ignore: cast_nullable_to_non_nullable
                        as String?,
            player1Data:
                null == player1Data
                    ? _value.player1Data
                    : player1Data // ignore: cast_nullable_to_non_nullable
                        as PlayerData,
            player2Data:
                freezed == player2Data
                    ? _value.player2Data
                    : player2Data // ignore: cast_nullable_to_non_nullable
                        as PlayerData?,
            currentPlayerId:
                freezed == currentPlayerId
                    ? _value.currentPlayerId
                    : currentPlayerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            currentPhase:
                null == currentPhase
                    ? _value.currentPhase
                    : currentPhase // ignore: cast_nullable_to_non_nullable
                        as GamePhase,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as GameStatus,
            resolutionStack:
                null == resolutionStack
                    ? _value.resolutionStack
                    : resolutionStack // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            playedCardTiers:
                null == playedCardTiers
                    ? _value.playedCardTiers
                    : playedCardTiers // ignore: cast_nullable_to_non_nullable
                        as Map<String, String>,
            pendingSpellActions:
                null == pendingSpellActions
                    ? _value.pendingSpellActions
                    : pendingSpellActions // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
            drawDoneThisTurn:
                null == drawDoneThisTurn
                    ? _value.drawDoneThisTurn
                    : drawDoneThisTurn // ignore: cast_nullable_to_non_nullable
                        as bool,
            enchantmentEffectsDoneThisTurn:
                null == enchantmentEffectsDoneThisTurn
                    ? _value.enchantmentEffectsDoneThisTurn
                    : enchantmentEffectsDoneThisTurn // ignore: cast_nullable_to_non_nullable
                        as bool,
            responseEffect:
                freezed == responseEffect
                    ? _value.responseEffect
                    : responseEffect // ignore: cast_nullable_to_non_nullable
                        as ResponseEffect?,
            cardAwaitingValidation:
                freezed == cardAwaitingValidation
                    ? _value.cardAwaitingValidation
                    : cardAwaitingValidation // ignore: cast_nullable_to_non_nullable
                        as String?,
            awaitingValidationFrom:
                null == awaitingValidationFrom
                    ? _value.awaitingValidationFrom
                    : awaitingValidationFrom // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            validationResponses:
                null == validationResponses
                    ? _value.validationResponses
                    : validationResponses // ignore: cast_nullable_to_non_nullable
                        as Map<String, bool>,
            winnerId:
                freezed == winnerId
                    ? _value.winnerId
                    : winnerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            ultimaOwnerId:
                freezed == ultimaOwnerId
                    ? _value.ultimaOwnerId
                    : ultimaOwnerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            ultimaTurnCount:
                null == ultimaTurnCount
                    ? _value.ultimaTurnCount
                    : ultimaTurnCount // ignore: cast_nullable_to_non_nullable
                        as int,
            ultimaPlayedAt:
                freezed == ultimaPlayedAt
                    ? _value.ultimaPlayedAt
                    : ultimaPlayedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            startedAt:
                freezed == startedAt
                    ? _value.startedAt
                    : startedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            finishedAt:
                freezed == finishedAt
                    ? _value.finishedAt
                    : finishedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerDataCopyWith<$Res> get player1Data {
    return $PlayerDataCopyWith<$Res>(_value.player1Data, (value) {
      return _then(_value.copyWith(player1Data: value) as $Val);
    });
  }

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerDataCopyWith<$Res>? get player2Data {
    if (_value.player2Data == null) {
      return null;
    }

    return $PlayerDataCopyWith<$Res>(_value.player2Data!, (value) {
      return _then(_value.copyWith(player2Data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameSessionImplCopyWith<$Res>
    implements $GameSessionCopyWith<$Res> {
  factory _$$GameSessionImplCopyWith(
    _$GameSessionImpl value,
    $Res Function(_$GameSessionImpl) then,
  ) = __$$GameSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    String player1Id,
    String? player2Id,
    PlayerData player1Data,
    PlayerData? player2Data,
    String? currentPlayerId,
    GamePhase currentPhase,
    GameStatus status,
    List<String> resolutionStack,
    Map<String, String> playedCardTiers,
    List<Map<String, dynamic>> pendingSpellActions,
    bool drawDoneThisTurn,
    bool enchantmentEffectsDoneThisTurn,
    ResponseEffect? responseEffect,
    String? cardAwaitingValidation,
    List<String> awaitingValidationFrom,
    Map<String, bool> validationResponses,
    String? winnerId,
    String? ultimaOwnerId,
    int ultimaTurnCount,
    DateTime? ultimaPlayedAt,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime updatedAt,
  });

  @override
  $PlayerDataCopyWith<$Res> get player1Data;
  @override
  $PlayerDataCopyWith<$Res>? get player2Data;
}

/// @nodoc
class __$$GameSessionImplCopyWithImpl<$Res>
    extends _$GameSessionCopyWithImpl<$Res, _$GameSessionImpl>
    implements _$$GameSessionImplCopyWith<$Res> {
  __$$GameSessionImplCopyWithImpl(
    _$GameSessionImpl _value,
    $Res Function(_$GameSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? player1Id = null,
    Object? player2Id = freezed,
    Object? player1Data = null,
    Object? player2Data = freezed,
    Object? currentPlayerId = freezed,
    Object? currentPhase = null,
    Object? status = null,
    Object? resolutionStack = null,
    Object? playedCardTiers = null,
    Object? pendingSpellActions = null,
    Object? drawDoneThisTurn = null,
    Object? enchantmentEffectsDoneThisTurn = null,
    Object? responseEffect = freezed,
    Object? cardAwaitingValidation = freezed,
    Object? awaitingValidationFrom = null,
    Object? validationResponses = null,
    Object? winnerId = freezed,
    Object? ultimaOwnerId = freezed,
    Object? ultimaTurnCount = null,
    Object? ultimaPlayedAt = freezed,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _$GameSessionImpl(
        sessionId:
            null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                    as String,
        player1Id:
            null == player1Id
                ? _value.player1Id
                : player1Id // ignore: cast_nullable_to_non_nullable
                    as String,
        player2Id:
            freezed == player2Id
                ? _value.player2Id
                : player2Id // ignore: cast_nullable_to_non_nullable
                    as String?,
        player1Data:
            null == player1Data
                ? _value.player1Data
                : player1Data // ignore: cast_nullable_to_non_nullable
                    as PlayerData,
        player2Data:
            freezed == player2Data
                ? _value.player2Data
                : player2Data // ignore: cast_nullable_to_non_nullable
                    as PlayerData?,
        currentPlayerId:
            freezed == currentPlayerId
                ? _value.currentPlayerId
                : currentPlayerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        currentPhase:
            null == currentPhase
                ? _value.currentPhase
                : currentPhase // ignore: cast_nullable_to_non_nullable
                    as GamePhase,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as GameStatus,
        resolutionStack:
            null == resolutionStack
                ? _value._resolutionStack
                : resolutionStack // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        playedCardTiers:
            null == playedCardTiers
                ? _value._playedCardTiers
                : playedCardTiers // ignore: cast_nullable_to_non_nullable
                    as Map<String, String>,
        pendingSpellActions:
            null == pendingSpellActions
                ? _value._pendingSpellActions
                : pendingSpellActions // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
        drawDoneThisTurn:
            null == drawDoneThisTurn
                ? _value.drawDoneThisTurn
                : drawDoneThisTurn // ignore: cast_nullable_to_non_nullable
                    as bool,
        enchantmentEffectsDoneThisTurn:
            null == enchantmentEffectsDoneThisTurn
                ? _value.enchantmentEffectsDoneThisTurn
                : enchantmentEffectsDoneThisTurn // ignore: cast_nullable_to_non_nullable
                    as bool,
        responseEffect:
            freezed == responseEffect
                ? _value.responseEffect
                : responseEffect // ignore: cast_nullable_to_non_nullable
                    as ResponseEffect?,
        cardAwaitingValidation:
            freezed == cardAwaitingValidation
                ? _value.cardAwaitingValidation
                : cardAwaitingValidation // ignore: cast_nullable_to_non_nullable
                    as String?,
        awaitingValidationFrom:
            null == awaitingValidationFrom
                ? _value._awaitingValidationFrom
                : awaitingValidationFrom // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        validationResponses:
            null == validationResponses
                ? _value._validationResponses
                : validationResponses // ignore: cast_nullable_to_non_nullable
                    as Map<String, bool>,
        winnerId:
            freezed == winnerId
                ? _value.winnerId
                : winnerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        ultimaOwnerId:
            freezed == ultimaOwnerId
                ? _value.ultimaOwnerId
                : ultimaOwnerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        ultimaTurnCount:
            null == ultimaTurnCount
                ? _value.ultimaTurnCount
                : ultimaTurnCount // ignore: cast_nullable_to_non_nullable
                    as int,
        ultimaPlayedAt:
            freezed == ultimaPlayedAt
                ? _value.ultimaPlayedAt
                : ultimaPlayedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        startedAt:
            freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        finishedAt:
            freezed == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSessionImpl implements _GameSession {
  const _$GameSessionImpl({
    required this.sessionId,
    required this.player1Id,
    this.player2Id,
    required this.player1Data,
    this.player2Data,
    this.currentPlayerId,
    this.currentPhase = GamePhase.draw,
    this.status = GameStatus.waiting,
    final List<String> resolutionStack = const [],
    final Map<String, String> playedCardTiers = const {},
    final List<Map<String, dynamic>> pendingSpellActions = const [],
    this.drawDoneThisTurn = false,
    this.enchantmentEffectsDoneThisTurn = false,
    this.responseEffect,
    this.cardAwaitingValidation,
    final List<String> awaitingValidationFrom = const [],
    final Map<String, bool> validationResponses = const {},
    this.winnerId,
    this.ultimaOwnerId,
    this.ultimaTurnCount = 0,
    this.ultimaPlayedAt,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    required this.updatedAt,
  }) : _resolutionStack = resolutionStack,
       _playedCardTiers = playedCardTiers,
       _pendingSpellActions = pendingSpellActions,
       _awaitingValidationFrom = awaitingValidationFrom,
       _validationResponses = validationResponses;

  factory _$GameSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSessionImplFromJson(json);

  /// ID unique de la session (code de partie)
  @override
  final String sessionId;

  /// ID du joueur 1
  @override
  final String player1Id;

  /// ID du joueur 2 (null si partie pas encore rejointe)
  @override
  final String? player2Id;

  /// Données du joueur 1
  @override
  final PlayerData player1Data;

  /// Données du joueur 2 (null si partie pas encore rejointe)
  @override
  final PlayerData? player2Data;

  /// ID du joueur actif (qui doit jouer)
  @override
  final String? currentPlayerId;

  /// Phase actuelle du jeu
  @override
  @JsonKey()
  final GamePhase currentPhase;

  /// Statut de la partie
  @override
  @JsonKey()
  final GameStatus status;

  /// Pile de résolution (IDs des cartes jouées ce tour)
  final List<String> _resolutionStack;

  /// Pile de résolution (IDs des cartes jouées ce tour)
  @override
  @JsonKey()
  List<String> get resolutionStack {
    if (_resolutionStack is EqualUnmodifiableListView) return _resolutionStack;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_resolutionStack);
  }

  /// Palier choisi pour chaque carte jouée ce tour (white/blue/yellow/red)
  final Map<String, String> _playedCardTiers;

  /// Palier choisi pour chaque carte jouée ce tour (white/blue/yellow/red)
  @override
  @JsonKey()
  Map<String, String> get playedCardTiers {
    if (_playedCardTiers is EqualUnmodifiableMapView) return _playedCardTiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_playedCardTiers);
  }

  /// Actions pendantes du sort actif (à exécuter en Resolution si non contré)
  final List<Map<String, dynamic>> _pendingSpellActions;

  /// Actions pendantes du sort actif (à exécuter en Resolution si non contré)
  @override
  @JsonKey()
  List<Map<String, dynamic>> get pendingSpellActions {
    if (_pendingSpellActions is EqualUnmodifiableListView)
      return _pendingSpellActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingSpellActions);
  }

  /// Pioche auto deja faite pour ce tour
  @override
  @JsonKey()
  final bool drawDoneThisTurn;

  /// Effets d'enchantements déjà appliqués pour ce tour
  @override
  @JsonKey()
  final bool enchantmentEffectsDoneThisTurn;

  /// === VALIDATION D'ACTIONS ===
  /// Effet de la carte de réponse jouée (null si pas de réponse)
  @override
  final ResponseEffect? responseEffect;

  /// ID de la carte dont l'action attend validation
  @override
  final String? cardAwaitingValidation;

  /// Liste des joueurs devant valider (IDs)
  final List<String> _awaitingValidationFrom;

  /// Liste des joueurs devant valider (IDs)
  @override
  @JsonKey()
  List<String> get awaitingValidationFrom {
    if (_awaitingValidationFrom is EqualUnmodifiableListView)
      return _awaitingValidationFrom;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_awaitingValidationFrom);
  }

  /// Map des réponses de validation {playerId: actionCompleted}
  /// true = action effectuée, false = action refusée
  final Map<String, bool> _validationResponses;

  /// Map des réponses de validation {playerId: actionCompleted}
  /// true = action effectuée, false = action refusée
  @override
  @JsonKey()
  Map<String, bool> get validationResponses {
    if (_validationResponses is EqualUnmodifiableMapView)
      return _validationResponses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_validationResponses);
  }

  /// ID du gagnant (null si partie en cours)
  @override
  final String? winnerId;

  /// === COMPTEUR ULTIMA ===
  /// ID du joueur qui a le compteur Ultima actif (premier à avoir posé Ultima)
  @override
  final String? ultimaOwnerId;

  /// Nombre de tours écoulés depuis que Ultima est en jeu
  @override
  @JsonKey()
  final int ultimaTurnCount;

  /// Timestamp de pose d'Ultima pour déterminer qui l'a posé en premier
  @override
  final DateTime? ultimaPlayedAt;

  /// Timestamp de création
  @override
  final DateTime createdAt;

  /// Timestamp de début de partie
  @override
  final DateTime? startedAt;

  /// Timestamp de fin de partie
  @override
  final DateTime? finishedAt;

  /// Timestamp de dernière mise à jour
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'GameSession(sessionId: $sessionId, player1Id: $player1Id, player2Id: $player2Id, player1Data: $player1Data, player2Data: $player2Data, currentPlayerId: $currentPlayerId, currentPhase: $currentPhase, status: $status, resolutionStack: $resolutionStack, playedCardTiers: $playedCardTiers, pendingSpellActions: $pendingSpellActions, drawDoneThisTurn: $drawDoneThisTurn, enchantmentEffectsDoneThisTurn: $enchantmentEffectsDoneThisTurn, responseEffect: $responseEffect, cardAwaitingValidation: $cardAwaitingValidation, awaitingValidationFrom: $awaitingValidationFrom, validationResponses: $validationResponses, winnerId: $winnerId, ultimaOwnerId: $ultimaOwnerId, ultimaTurnCount: $ultimaTurnCount, ultimaPlayedAt: $ultimaPlayedAt, createdAt: $createdAt, startedAt: $startedAt, finishedAt: $finishedAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSessionImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.player1Id, player1Id) ||
                other.player1Id == player1Id) &&
            (identical(other.player2Id, player2Id) ||
                other.player2Id == player2Id) &&
            (identical(other.player1Data, player1Data) ||
                other.player1Data == player1Data) &&
            (identical(other.player2Data, player2Data) ||
                other.player2Data == player2Data) &&
            (identical(other.currentPlayerId, currentPlayerId) ||
                other.currentPlayerId == currentPlayerId) &&
            (identical(other.currentPhase, currentPhase) ||
                other.currentPhase == currentPhase) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._resolutionStack,
              _resolutionStack,
            ) &&
            const DeepCollectionEquality().equals(
              other._playedCardTiers,
              _playedCardTiers,
            ) &&
            const DeepCollectionEquality().equals(
              other._pendingSpellActions,
              _pendingSpellActions,
            ) &&
            (identical(other.drawDoneThisTurn, drawDoneThisTurn) ||
                other.drawDoneThisTurn == drawDoneThisTurn) &&
            (identical(
                  other.enchantmentEffectsDoneThisTurn,
                  enchantmentEffectsDoneThisTurn,
                ) ||
                other.enchantmentEffectsDoneThisTurn ==
                    enchantmentEffectsDoneThisTurn) &&
            (identical(other.responseEffect, responseEffect) ||
                other.responseEffect == responseEffect) &&
            (identical(other.cardAwaitingValidation, cardAwaitingValidation) ||
                other.cardAwaitingValidation == cardAwaitingValidation) &&
            const DeepCollectionEquality().equals(
              other._awaitingValidationFrom,
              _awaitingValidationFrom,
            ) &&
            const DeepCollectionEquality().equals(
              other._validationResponses,
              _validationResponses,
            ) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            (identical(other.ultimaOwnerId, ultimaOwnerId) ||
                other.ultimaOwnerId == ultimaOwnerId) &&
            (identical(other.ultimaTurnCount, ultimaTurnCount) ||
                other.ultimaTurnCount == ultimaTurnCount) &&
            (identical(other.ultimaPlayedAt, ultimaPlayedAt) ||
                other.ultimaPlayedAt == ultimaPlayedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    sessionId,
    player1Id,
    player2Id,
    player1Data,
    player2Data,
    currentPlayerId,
    currentPhase,
    status,
    const DeepCollectionEquality().hash(_resolutionStack),
    const DeepCollectionEquality().hash(_playedCardTiers),
    const DeepCollectionEquality().hash(_pendingSpellActions),
    drawDoneThisTurn,
    enchantmentEffectsDoneThisTurn,
    responseEffect,
    cardAwaitingValidation,
    const DeepCollectionEquality().hash(_awaitingValidationFrom),
    const DeepCollectionEquality().hash(_validationResponses),
    winnerId,
    ultimaOwnerId,
    ultimaTurnCount,
    ultimaPlayedAt,
    createdAt,
    startedAt,
    finishedAt,
    updatedAt,
  ]);

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSessionImplCopyWith<_$GameSessionImpl> get copyWith =>
      __$$GameSessionImplCopyWithImpl<_$GameSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSessionImplToJson(this);
  }
}

abstract class _GameSession implements GameSession {
  const factory _GameSession({
    required final String sessionId,
    required final String player1Id,
    final String? player2Id,
    required final PlayerData player1Data,
    final PlayerData? player2Data,
    final String? currentPlayerId,
    final GamePhase currentPhase,
    final GameStatus status,
    final List<String> resolutionStack,
    final Map<String, String> playedCardTiers,
    final List<Map<String, dynamic>> pendingSpellActions,
    final bool drawDoneThisTurn,
    final bool enchantmentEffectsDoneThisTurn,
    final ResponseEffect? responseEffect,
    final String? cardAwaitingValidation,
    final List<String> awaitingValidationFrom,
    final Map<String, bool> validationResponses,
    final String? winnerId,
    final String? ultimaOwnerId,
    final int ultimaTurnCount,
    final DateTime? ultimaPlayedAt,
    required final DateTime createdAt,
    final DateTime? startedAt,
    final DateTime? finishedAt,
    required final DateTime updatedAt,
  }) = _$GameSessionImpl;

  factory _GameSession.fromJson(Map<String, dynamic> json) =
      _$GameSessionImpl.fromJson;

  /// ID unique de la session (code de partie)
  @override
  String get sessionId;

  /// ID du joueur 1
  @override
  String get player1Id;

  /// ID du joueur 2 (null si partie pas encore rejointe)
  @override
  String? get player2Id;

  /// Données du joueur 1
  @override
  PlayerData get player1Data;

  /// Données du joueur 2 (null si partie pas encore rejointe)
  @override
  PlayerData? get player2Data;

  /// ID du joueur actif (qui doit jouer)
  @override
  String? get currentPlayerId;

  /// Phase actuelle du jeu
  @override
  GamePhase get currentPhase;

  /// Statut de la partie
  @override
  GameStatus get status;

  /// Pile de résolution (IDs des cartes jouées ce tour)
  @override
  List<String> get resolutionStack;

  /// Palier choisi pour chaque carte jouée ce tour (white/blue/yellow/red)
  @override
  Map<String, String> get playedCardTiers;

  /// Actions pendantes du sort actif (à exécuter en Resolution si non contré)
  @override
  List<Map<String, dynamic>> get pendingSpellActions;

  /// Pioche auto deja faite pour ce tour
  @override
  bool get drawDoneThisTurn;

  /// Effets d'enchantements déjà appliqués pour ce tour
  @override
  bool get enchantmentEffectsDoneThisTurn;

  /// === VALIDATION D'ACTIONS ===
  /// Effet de la carte de réponse jouée (null si pas de réponse)
  @override
  ResponseEffect? get responseEffect;

  /// ID de la carte dont l'action attend validation
  @override
  String? get cardAwaitingValidation;

  /// Liste des joueurs devant valider (IDs)
  @override
  List<String> get awaitingValidationFrom;

  /// Map des réponses de validation {playerId: actionCompleted}
  /// true = action effectuée, false = action refusée
  @override
  Map<String, bool> get validationResponses;

  /// ID du gagnant (null si partie en cours)
  @override
  String? get winnerId;

  /// === COMPTEUR ULTIMA ===
  /// ID du joueur qui a le compteur Ultima actif (premier à avoir posé Ultima)
  @override
  String? get ultimaOwnerId;

  /// Nombre de tours écoulés depuis que Ultima est en jeu
  @override
  int get ultimaTurnCount;

  /// Timestamp de pose d'Ultima pour déterminer qui l'a posé en premier
  @override
  DateTime? get ultimaPlayedAt;

  /// Timestamp de création
  @override
  DateTime get createdAt;

  /// Timestamp de début de partie
  @override
  DateTime? get startedAt;

  /// Timestamp de fin de partie
  @override
  DateTime? get finishedAt;

  /// Timestamp de dernière mise à jour
  @override
  DateTime get updatedAt;

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSessionImplCopyWith<_$GameSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
