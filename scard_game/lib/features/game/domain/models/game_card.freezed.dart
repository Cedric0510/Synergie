// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameCard _$GameCardFromJson(Map<String, dynamic> json) {
  return _GameCard.fromJson(json);
}

/// @nodoc
mixin _$GameCard {
  /// ID unique de la carte
  String get id => throw _privateConstructorUsedError;

  /// Nom de la carte
  String get name => throw _privateConstructorUsedError;

  /// Type de carte (Instantané, Rituel, Enchantement)
  CardType get type => throw _privateConstructorUsedError;

  /// Couleur/Niveau de la carte
  CardColor get color => throw _privateConstructorUsedError;

  /// Description complète de la carte (optionnelle)
  String? get description =>
      throw _privateConstructorUsedError; // === COÛTS ET EFFETS ===
  /// Coût IRL pour le lanceur (ce que TU dois faire pour jouer la carte)
  /// Ex: "Aucun", "Enlever 2 vêtements", "Danse sensuelle 30 sec"
  String get launcherCost => throw _privateConstructorUsedError;

  /// Effet IRL sur la cible (ce que l'adversaire doit faire)
  /// Ex: "Enlever 1 vêtement", "Massage 1 minute", "Compliment sincère"
  /// Peut être null pour certaines cartes (ex: Pioche)
  String? get targetEffect => throw _privateConstructorUsedError;

  /// Dégâts infligés si la cible refuse l'effet IRL
  int get damageIfRefused => throw _privateConstructorUsedError;

  /// Description de l'effet en jeu (texte descriptif)
  /// Ex: "Piocher 2 cartes", "Détruire un enchantement ciblé"
  String get gameEffect =>
      throw _privateConstructorUsedError; // === EFFETS STRUCTURÉS (GAMEPLAY) ===
  /// Nombre de cartes à piocher immédiatement (0 = aucune)
  int get drawCards => throw _privateConstructorUsedError;

  /// Nombre de cartes a piocher par palier (cartes fusionnees)
  int get drawCardsWhite => throw _privateConstructorUsedError;
  int get drawCardsBlue => throw _privateConstructorUsedError;
  int get drawCardsYellow => throw _privateConstructorUsedError;
  int get drawCardsRed => throw _privateConstructorUsedError;

  /// Nombre de cartes à piocher par tour (enchantements uniquement)
  int get drawCardsPerTurn => throw _privateConstructorUsedError;

  /// Nombre de vêtements que le lanceur retire (0 = aucun)
  int get removeClothing => throw _privateConstructorUsedError;

  /// Nombre de vêtements que le lanceur remet (0 = aucun)
  int get addClothing => throw _privateConstructorUsedError;

  /// Nombre d'enchantements à détruire (0 = aucun)
  int get destroyEnchantment => throw _privateConstructorUsedError;

  /// Détruire tous les enchantements (false = non)
  bool get destroyAllEnchantments => throw _privateConstructorUsedError;

  /// Nombre d'enchantements à remplacer (0 = aucun)
  int get replaceEnchantment => throw _privateConstructorUsedError;

  /// Nombre de cartes à sacrifier (0 = aucune)
  int get sacrificeCard => throw _privateConstructorUsedError;

  /// Nombre de cartes à défausser (0 = aucune)
  int get discardCard => throw _privateConstructorUsedError;

  /// Nombre de cartes que l'adversaire pioche (0 = aucune)
  int get opponentDraw => throw _privateConstructorUsedError;

  /// Nombre de vêtements que l'adversaire retire par tour (enchantements)
  int get opponentRemoveClothing => throw _privateConstructorUsedError;

  /// Mélanger la main dans le deck (false = non)
  bool get shuffleHandIntoDeck => throw _privateConstructorUsedError;

  /// Dégâts PI à l'adversaire (0 = aucun)
  int get piDamageOpponent => throw _privateConstructorUsedError;

  /// Gain PI pour le lanceur (0 = aucun)
  int get piGainSelf => throw _privateConstructorUsedError;

  /// Augmentation de tension pour le lanceur (0 = aucune)
  int get tensionIncrease => throw _privateConstructorUsedError;

  /// Coût en PI pour lancer la carte (0 = gratuit)
  int get piCost => throw _privateConstructorUsedError;

  /// Est-ce un enchantement permanent qui reste en jeu
  bool get isEnchantment =>
      throw _privateConstructorUsedError; // === SPÉCIFIQUE AUX ENCHANTEMENTS ===
  /// Détermine qui doit voir/appliquer l'effet selon le palier (owner/opponent/both)
  Map<String, String> get enchantmentTargets =>
      throw _privateConstructorUsedError;

  /// Effets récurrents (ex: pioche +1 au début du tour)
  List<Map<String, dynamic>> get recurringEffects =>
      throw _privateConstructorUsedError;

  /// Modificateurs persistants (ex: PI bloqués)
  List<Map<String, dynamic>> get statusModifiers =>
      throw _privateConstructorUsedError;

  /// Gain de tension par tour pour le lanceur (null si pas un enchantement)
  /// Ex: 1, 3, 5, 7 ou null
  int? get tensionPerTurn => throw _privateConstructorUsedError; // === DECK ===
  /// Nombre maximum d'exemplaires dans le deck
  /// null = 4 exemplaires (défaut), 1 = unique (Ultima), 2 = limité
  int? get maxPerDeck =>
      throw _privateConstructorUsedError; // === MÉCANIQUES SPÉCIALES ===
  /// Liste des mécaniques spéciales de la carte
  /// Ex: sacrifice de carte, destruction d'enchantement, pioche conditionnelle, etc.
  List<CardMechanic> get mechanics =>
      throw _privateConstructorUsedError; // === UI ===
  /// URL de l'image de la carte
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Texte d'ambiance / flavor text
  String? get flavorText => throw _privateConstructorUsedError;

  /// Serializes this GameCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCardCopyWith<GameCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCardCopyWith<$Res> {
  factory $GameCardCopyWith(GameCard value, $Res Function(GameCard) then) =
      _$GameCardCopyWithImpl<$Res, GameCard>;
  @useResult
  $Res call({
    String id,
    String name,
    CardType type,
    CardColor color,
    String? description,
    String launcherCost,
    String? targetEffect,
    int damageIfRefused,
    String gameEffect,
    int drawCards,
    int drawCardsWhite,
    int drawCardsBlue,
    int drawCardsYellow,
    int drawCardsRed,
    int drawCardsPerTurn,
    int removeClothing,
    int addClothing,
    int destroyEnchantment,
    bool destroyAllEnchantments,
    int replaceEnchantment,
    int sacrificeCard,
    int discardCard,
    int opponentDraw,
    int opponentRemoveClothing,
    bool shuffleHandIntoDeck,
    int piDamageOpponent,
    int piGainSelf,
    int tensionIncrease,
    int piCost,
    bool isEnchantment,
    Map<String, String> enchantmentTargets,
    List<Map<String, dynamic>> recurringEffects,
    List<Map<String, dynamic>> statusModifiers,
    int? tensionPerTurn,
    int? maxPerDeck,
    List<CardMechanic> mechanics,
    String? imageUrl,
    String? flavorText,
  });
}

/// @nodoc
class _$GameCardCopyWithImpl<$Res, $Val extends GameCard>
    implements $GameCardCopyWith<$Res> {
  _$GameCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? color = null,
    Object? description = freezed,
    Object? launcherCost = null,
    Object? targetEffect = freezed,
    Object? damageIfRefused = null,
    Object? gameEffect = null,
    Object? drawCards = null,
    Object? drawCardsWhite = null,
    Object? drawCardsBlue = null,
    Object? drawCardsYellow = null,
    Object? drawCardsRed = null,
    Object? drawCardsPerTurn = null,
    Object? removeClothing = null,
    Object? addClothing = null,
    Object? destroyEnchantment = null,
    Object? destroyAllEnchantments = null,
    Object? replaceEnchantment = null,
    Object? sacrificeCard = null,
    Object? discardCard = null,
    Object? opponentDraw = null,
    Object? opponentRemoveClothing = null,
    Object? shuffleHandIntoDeck = null,
    Object? piDamageOpponent = null,
    Object? piGainSelf = null,
    Object? tensionIncrease = null,
    Object? piCost = null,
    Object? isEnchantment = null,
    Object? enchantmentTargets = null,
    Object? recurringEffects = null,
    Object? statusModifiers = null,
    Object? tensionPerTurn = freezed,
    Object? maxPerDeck = freezed,
    Object? mechanics = null,
    Object? imageUrl = freezed,
    Object? flavorText = freezed,
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
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as CardType,
            color:
                null == color
                    ? _value.color
                    : color // ignore: cast_nullable_to_non_nullable
                        as CardColor,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            launcherCost:
                null == launcherCost
                    ? _value.launcherCost
                    : launcherCost // ignore: cast_nullable_to_non_nullable
                        as String,
            targetEffect:
                freezed == targetEffect
                    ? _value.targetEffect
                    : targetEffect // ignore: cast_nullable_to_non_nullable
                        as String?,
            damageIfRefused:
                null == damageIfRefused
                    ? _value.damageIfRefused
                    : damageIfRefused // ignore: cast_nullable_to_non_nullable
                        as int,
            gameEffect:
                null == gameEffect
                    ? _value.gameEffect
                    : gameEffect // ignore: cast_nullable_to_non_nullable
                        as String,
            drawCards:
                null == drawCards
                    ? _value.drawCards
                    : drawCards // ignore: cast_nullable_to_non_nullable
                        as int,
            drawCardsWhite:
                null == drawCardsWhite
                    ? _value.drawCardsWhite
                    : drawCardsWhite // ignore: cast_nullable_to_non_nullable
                        as int,
            drawCardsBlue:
                null == drawCardsBlue
                    ? _value.drawCardsBlue
                    : drawCardsBlue // ignore: cast_nullable_to_non_nullable
                        as int,
            drawCardsYellow:
                null == drawCardsYellow
                    ? _value.drawCardsYellow
                    : drawCardsYellow // ignore: cast_nullable_to_non_nullable
                        as int,
            drawCardsRed:
                null == drawCardsRed
                    ? _value.drawCardsRed
                    : drawCardsRed // ignore: cast_nullable_to_non_nullable
                        as int,
            drawCardsPerTurn:
                null == drawCardsPerTurn
                    ? _value.drawCardsPerTurn
                    : drawCardsPerTurn // ignore: cast_nullable_to_non_nullable
                        as int,
            removeClothing:
                null == removeClothing
                    ? _value.removeClothing
                    : removeClothing // ignore: cast_nullable_to_non_nullable
                        as int,
            addClothing:
                null == addClothing
                    ? _value.addClothing
                    : addClothing // ignore: cast_nullable_to_non_nullable
                        as int,
            destroyEnchantment:
                null == destroyEnchantment
                    ? _value.destroyEnchantment
                    : destroyEnchantment // ignore: cast_nullable_to_non_nullable
                        as int,
            destroyAllEnchantments:
                null == destroyAllEnchantments
                    ? _value.destroyAllEnchantments
                    : destroyAllEnchantments // ignore: cast_nullable_to_non_nullable
                        as bool,
            replaceEnchantment:
                null == replaceEnchantment
                    ? _value.replaceEnchantment
                    : replaceEnchantment // ignore: cast_nullable_to_non_nullable
                        as int,
            sacrificeCard:
                null == sacrificeCard
                    ? _value.sacrificeCard
                    : sacrificeCard // ignore: cast_nullable_to_non_nullable
                        as int,
            discardCard:
                null == discardCard
                    ? _value.discardCard
                    : discardCard // ignore: cast_nullable_to_non_nullable
                        as int,
            opponentDraw:
                null == opponentDraw
                    ? _value.opponentDraw
                    : opponentDraw // ignore: cast_nullable_to_non_nullable
                        as int,
            opponentRemoveClothing:
                null == opponentRemoveClothing
                    ? _value.opponentRemoveClothing
                    : opponentRemoveClothing // ignore: cast_nullable_to_non_nullable
                        as int,
            shuffleHandIntoDeck:
                null == shuffleHandIntoDeck
                    ? _value.shuffleHandIntoDeck
                    : shuffleHandIntoDeck // ignore: cast_nullable_to_non_nullable
                        as bool,
            piDamageOpponent:
                null == piDamageOpponent
                    ? _value.piDamageOpponent
                    : piDamageOpponent // ignore: cast_nullable_to_non_nullable
                        as int,
            piGainSelf:
                null == piGainSelf
                    ? _value.piGainSelf
                    : piGainSelf // ignore: cast_nullable_to_non_nullable
                        as int,
            tensionIncrease:
                null == tensionIncrease
                    ? _value.tensionIncrease
                    : tensionIncrease // ignore: cast_nullable_to_non_nullable
                        as int,
            piCost:
                null == piCost
                    ? _value.piCost
                    : piCost // ignore: cast_nullable_to_non_nullable
                        as int,
            isEnchantment:
                null == isEnchantment
                    ? _value.isEnchantment
                    : isEnchantment // ignore: cast_nullable_to_non_nullable
                        as bool,
            enchantmentTargets:
                null == enchantmentTargets
                    ? _value.enchantmentTargets
                    : enchantmentTargets // ignore: cast_nullable_to_non_nullable
                        as Map<String, String>,
            recurringEffects:
                null == recurringEffects
                    ? _value.recurringEffects
                    : recurringEffects // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
            statusModifiers:
                null == statusModifiers
                    ? _value.statusModifiers
                    : statusModifiers // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
            tensionPerTurn:
                freezed == tensionPerTurn
                    ? _value.tensionPerTurn
                    : tensionPerTurn // ignore: cast_nullable_to_non_nullable
                        as int?,
            maxPerDeck:
                freezed == maxPerDeck
                    ? _value.maxPerDeck
                    : maxPerDeck // ignore: cast_nullable_to_non_nullable
                        as int?,
            mechanics:
                null == mechanics
                    ? _value.mechanics
                    : mechanics // ignore: cast_nullable_to_non_nullable
                        as List<CardMechanic>,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            flavorText:
                freezed == flavorText
                    ? _value.flavorText
                    : flavorText // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameCardImplCopyWith<$Res>
    implements $GameCardCopyWith<$Res> {
  factory _$$GameCardImplCopyWith(
    _$GameCardImpl value,
    $Res Function(_$GameCardImpl) then,
  ) = __$$GameCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    CardType type,
    CardColor color,
    String? description,
    String launcherCost,
    String? targetEffect,
    int damageIfRefused,
    String gameEffect,
    int drawCards,
    int drawCardsWhite,
    int drawCardsBlue,
    int drawCardsYellow,
    int drawCardsRed,
    int drawCardsPerTurn,
    int removeClothing,
    int addClothing,
    int destroyEnchantment,
    bool destroyAllEnchantments,
    int replaceEnchantment,
    int sacrificeCard,
    int discardCard,
    int opponentDraw,
    int opponentRemoveClothing,
    bool shuffleHandIntoDeck,
    int piDamageOpponent,
    int piGainSelf,
    int tensionIncrease,
    int piCost,
    bool isEnchantment,
    Map<String, String> enchantmentTargets,
    List<Map<String, dynamic>> recurringEffects,
    List<Map<String, dynamic>> statusModifiers,
    int? tensionPerTurn,
    int? maxPerDeck,
    List<CardMechanic> mechanics,
    String? imageUrl,
    String? flavorText,
  });
}

/// @nodoc
class __$$GameCardImplCopyWithImpl<$Res>
    extends _$GameCardCopyWithImpl<$Res, _$GameCardImpl>
    implements _$$GameCardImplCopyWith<$Res> {
  __$$GameCardImplCopyWithImpl(
    _$GameCardImpl _value,
    $Res Function(_$GameCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? color = null,
    Object? description = freezed,
    Object? launcherCost = null,
    Object? targetEffect = freezed,
    Object? damageIfRefused = null,
    Object? gameEffect = null,
    Object? drawCards = null,
    Object? drawCardsWhite = null,
    Object? drawCardsBlue = null,
    Object? drawCardsYellow = null,
    Object? drawCardsRed = null,
    Object? drawCardsPerTurn = null,
    Object? removeClothing = null,
    Object? addClothing = null,
    Object? destroyEnchantment = null,
    Object? destroyAllEnchantments = null,
    Object? replaceEnchantment = null,
    Object? sacrificeCard = null,
    Object? discardCard = null,
    Object? opponentDraw = null,
    Object? opponentRemoveClothing = null,
    Object? shuffleHandIntoDeck = null,
    Object? piDamageOpponent = null,
    Object? piGainSelf = null,
    Object? tensionIncrease = null,
    Object? piCost = null,
    Object? isEnchantment = null,
    Object? enchantmentTargets = null,
    Object? recurringEffects = null,
    Object? statusModifiers = null,
    Object? tensionPerTurn = freezed,
    Object? maxPerDeck = freezed,
    Object? mechanics = null,
    Object? imageUrl = freezed,
    Object? flavorText = freezed,
  }) {
    return _then(
      _$GameCardImpl(
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
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as CardType,
        color:
            null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                    as CardColor,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        launcherCost:
            null == launcherCost
                ? _value.launcherCost
                : launcherCost // ignore: cast_nullable_to_non_nullable
                    as String,
        targetEffect:
            freezed == targetEffect
                ? _value.targetEffect
                : targetEffect // ignore: cast_nullable_to_non_nullable
                    as String?,
        damageIfRefused:
            null == damageIfRefused
                ? _value.damageIfRefused
                : damageIfRefused // ignore: cast_nullable_to_non_nullable
                    as int,
        gameEffect:
            null == gameEffect
                ? _value.gameEffect
                : gameEffect // ignore: cast_nullable_to_non_nullable
                    as String,
        drawCards:
            null == drawCards
                ? _value.drawCards
                : drawCards // ignore: cast_nullable_to_non_nullable
                    as int,
        drawCardsWhite:
            null == drawCardsWhite
                ? _value.drawCardsWhite
                : drawCardsWhite // ignore: cast_nullable_to_non_nullable
                    as int,
        drawCardsBlue:
            null == drawCardsBlue
                ? _value.drawCardsBlue
                : drawCardsBlue // ignore: cast_nullable_to_non_nullable
                    as int,
        drawCardsYellow:
            null == drawCardsYellow
                ? _value.drawCardsYellow
                : drawCardsYellow // ignore: cast_nullable_to_non_nullable
                    as int,
        drawCardsRed:
            null == drawCardsRed
                ? _value.drawCardsRed
                : drawCardsRed // ignore: cast_nullable_to_non_nullable
                    as int,
        drawCardsPerTurn:
            null == drawCardsPerTurn
                ? _value.drawCardsPerTurn
                : drawCardsPerTurn // ignore: cast_nullable_to_non_nullable
                    as int,
        removeClothing:
            null == removeClothing
                ? _value.removeClothing
                : removeClothing // ignore: cast_nullable_to_non_nullable
                    as int,
        addClothing:
            null == addClothing
                ? _value.addClothing
                : addClothing // ignore: cast_nullable_to_non_nullable
                    as int,
        destroyEnchantment:
            null == destroyEnchantment
                ? _value.destroyEnchantment
                : destroyEnchantment // ignore: cast_nullable_to_non_nullable
                    as int,
        destroyAllEnchantments:
            null == destroyAllEnchantments
                ? _value.destroyAllEnchantments
                : destroyAllEnchantments // ignore: cast_nullable_to_non_nullable
                    as bool,
        replaceEnchantment:
            null == replaceEnchantment
                ? _value.replaceEnchantment
                : replaceEnchantment // ignore: cast_nullable_to_non_nullable
                    as int,
        sacrificeCard:
            null == sacrificeCard
                ? _value.sacrificeCard
                : sacrificeCard // ignore: cast_nullable_to_non_nullable
                    as int,
        discardCard:
            null == discardCard
                ? _value.discardCard
                : discardCard // ignore: cast_nullable_to_non_nullable
                    as int,
        opponentDraw:
            null == opponentDraw
                ? _value.opponentDraw
                : opponentDraw // ignore: cast_nullable_to_non_nullable
                    as int,
        opponentRemoveClothing:
            null == opponentRemoveClothing
                ? _value.opponentRemoveClothing
                : opponentRemoveClothing // ignore: cast_nullable_to_non_nullable
                    as int,
        shuffleHandIntoDeck:
            null == shuffleHandIntoDeck
                ? _value.shuffleHandIntoDeck
                : shuffleHandIntoDeck // ignore: cast_nullable_to_non_nullable
                    as bool,
        piDamageOpponent:
            null == piDamageOpponent
                ? _value.piDamageOpponent
                : piDamageOpponent // ignore: cast_nullable_to_non_nullable
                    as int,
        piGainSelf:
            null == piGainSelf
                ? _value.piGainSelf
                : piGainSelf // ignore: cast_nullable_to_non_nullable
                    as int,
        tensionIncrease:
            null == tensionIncrease
                ? _value.tensionIncrease
                : tensionIncrease // ignore: cast_nullable_to_non_nullable
                    as int,
        piCost:
            null == piCost
                ? _value.piCost
                : piCost // ignore: cast_nullable_to_non_nullable
                    as int,
        isEnchantment:
            null == isEnchantment
                ? _value.isEnchantment
                : isEnchantment // ignore: cast_nullable_to_non_nullable
                    as bool,
        enchantmentTargets:
            null == enchantmentTargets
                ? _value._enchantmentTargets
                : enchantmentTargets // ignore: cast_nullable_to_non_nullable
                    as Map<String, String>,
        recurringEffects:
            null == recurringEffects
                ? _value._recurringEffects
                : recurringEffects // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
        statusModifiers:
            null == statusModifiers
                ? _value._statusModifiers
                : statusModifiers // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
        tensionPerTurn:
            freezed == tensionPerTurn
                ? _value.tensionPerTurn
                : tensionPerTurn // ignore: cast_nullable_to_non_nullable
                    as int?,
        maxPerDeck:
            freezed == maxPerDeck
                ? _value.maxPerDeck
                : maxPerDeck // ignore: cast_nullable_to_non_nullable
                    as int?,
        mechanics:
            null == mechanics
                ? _value._mechanics
                : mechanics // ignore: cast_nullable_to_non_nullable
                    as List<CardMechanic>,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        flavorText:
            freezed == flavorText
                ? _value.flavorText
                : flavorText // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameCardImpl implements _GameCard {
  const _$GameCardImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    this.description,
    required this.launcherCost,
    this.targetEffect,
    this.damageIfRefused = 0,
    required this.gameEffect,
    this.drawCards = 0,
    this.drawCardsWhite = 0,
    this.drawCardsBlue = 0,
    this.drawCardsYellow = 0,
    this.drawCardsRed = 0,
    this.drawCardsPerTurn = 0,
    this.removeClothing = 0,
    this.addClothing = 0,
    this.destroyEnchantment = 0,
    this.destroyAllEnchantments = false,
    this.replaceEnchantment = 0,
    this.sacrificeCard = 0,
    this.discardCard = 0,
    this.opponentDraw = 0,
    this.opponentRemoveClothing = 0,
    this.shuffleHandIntoDeck = false,
    this.piDamageOpponent = 0,
    this.piGainSelf = 0,
    this.tensionIncrease = 0,
    this.piCost = 0,
    this.isEnchantment = false,
    final Map<String, String> enchantmentTargets = const {},
    final List<Map<String, dynamic>> recurringEffects = const [],
    final List<Map<String, dynamic>> statusModifiers = const [],
    this.tensionPerTurn,
    this.maxPerDeck,
    final List<CardMechanic> mechanics = const [],
    this.imageUrl,
    this.flavorText,
  }) : _enchantmentTargets = enchantmentTargets,
       _recurringEffects = recurringEffects,
       _statusModifiers = statusModifiers,
       _mechanics = mechanics;

  factory _$GameCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameCardImplFromJson(json);

  /// ID unique de la carte
  @override
  final String id;

  /// Nom de la carte
  @override
  final String name;

  /// Type de carte (Instantané, Rituel, Enchantement)
  @override
  final CardType type;

  /// Couleur/Niveau de la carte
  @override
  final CardColor color;

  /// Description complète de la carte (optionnelle)
  @override
  final String? description;
  // === COÛTS ET EFFETS ===
  /// Coût IRL pour le lanceur (ce que TU dois faire pour jouer la carte)
  /// Ex: "Aucun", "Enlever 2 vêtements", "Danse sensuelle 30 sec"
  @override
  final String launcherCost;

  /// Effet IRL sur la cible (ce que l'adversaire doit faire)
  /// Ex: "Enlever 1 vêtement", "Massage 1 minute", "Compliment sincère"
  /// Peut être null pour certaines cartes (ex: Pioche)
  @override
  final String? targetEffect;

  /// Dégâts infligés si la cible refuse l'effet IRL
  @override
  @JsonKey()
  final int damageIfRefused;

  /// Description de l'effet en jeu (texte descriptif)
  /// Ex: "Piocher 2 cartes", "Détruire un enchantement ciblé"
  @override
  final String gameEffect;
  // === EFFETS STRUCTURÉS (GAMEPLAY) ===
  /// Nombre de cartes à piocher immédiatement (0 = aucune)
  @override
  @JsonKey()
  final int drawCards;

  /// Nombre de cartes a piocher par palier (cartes fusionnees)
  @override
  @JsonKey()
  final int drawCardsWhite;
  @override
  @JsonKey()
  final int drawCardsBlue;
  @override
  @JsonKey()
  final int drawCardsYellow;
  @override
  @JsonKey()
  final int drawCardsRed;

  /// Nombre de cartes à piocher par tour (enchantements uniquement)
  @override
  @JsonKey()
  final int drawCardsPerTurn;

  /// Nombre de vêtements que le lanceur retire (0 = aucun)
  @override
  @JsonKey()
  final int removeClothing;

  /// Nombre de vêtements que le lanceur remet (0 = aucun)
  @override
  @JsonKey()
  final int addClothing;

  /// Nombre d'enchantements à détruire (0 = aucun)
  @override
  @JsonKey()
  final int destroyEnchantment;

  /// Détruire tous les enchantements (false = non)
  @override
  @JsonKey()
  final bool destroyAllEnchantments;

  /// Nombre d'enchantements à remplacer (0 = aucun)
  @override
  @JsonKey()
  final int replaceEnchantment;

  /// Nombre de cartes à sacrifier (0 = aucune)
  @override
  @JsonKey()
  final int sacrificeCard;

  /// Nombre de cartes à défausser (0 = aucune)
  @override
  @JsonKey()
  final int discardCard;

  /// Nombre de cartes que l'adversaire pioche (0 = aucune)
  @override
  @JsonKey()
  final int opponentDraw;

  /// Nombre de vêtements que l'adversaire retire par tour (enchantements)
  @override
  @JsonKey()
  final int opponentRemoveClothing;

  /// Mélanger la main dans le deck (false = non)
  @override
  @JsonKey()
  final bool shuffleHandIntoDeck;

  /// Dégâts PI à l'adversaire (0 = aucun)
  @override
  @JsonKey()
  final int piDamageOpponent;

  /// Gain PI pour le lanceur (0 = aucun)
  @override
  @JsonKey()
  final int piGainSelf;

  /// Augmentation de tension pour le lanceur (0 = aucune)
  @override
  @JsonKey()
  final int tensionIncrease;

  /// Coût en PI pour lancer la carte (0 = gratuit)
  @override
  @JsonKey()
  final int piCost;

  /// Est-ce un enchantement permanent qui reste en jeu
  @override
  @JsonKey()
  final bool isEnchantment;
  // === SPÉCIFIQUE AUX ENCHANTEMENTS ===
  /// Détermine qui doit voir/appliquer l'effet selon le palier (owner/opponent/both)
  final Map<String, String> _enchantmentTargets;
  // === SPÉCIFIQUE AUX ENCHANTEMENTS ===
  /// Détermine qui doit voir/appliquer l'effet selon le palier (owner/opponent/both)
  @override
  @JsonKey()
  Map<String, String> get enchantmentTargets {
    if (_enchantmentTargets is EqualUnmodifiableMapView)
      return _enchantmentTargets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_enchantmentTargets);
  }

  /// Effets récurrents (ex: pioche +1 au début du tour)
  final List<Map<String, dynamic>> _recurringEffects;

  /// Effets récurrents (ex: pioche +1 au début du tour)
  @override
  @JsonKey()
  List<Map<String, dynamic>> get recurringEffects {
    if (_recurringEffects is EqualUnmodifiableListView)
      return _recurringEffects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recurringEffects);
  }

  /// Modificateurs persistants (ex: PI bloqués)
  final List<Map<String, dynamic>> _statusModifiers;

  /// Modificateurs persistants (ex: PI bloqués)
  @override
  @JsonKey()
  List<Map<String, dynamic>> get statusModifiers {
    if (_statusModifiers is EqualUnmodifiableListView) return _statusModifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusModifiers);
  }

  /// Gain de tension par tour pour le lanceur (null si pas un enchantement)
  /// Ex: 1, 3, 5, 7 ou null
  @override
  final int? tensionPerTurn;
  // === DECK ===
  /// Nombre maximum d'exemplaires dans le deck
  /// null = 4 exemplaires (défaut), 1 = unique (Ultima), 2 = limité
  @override
  final int? maxPerDeck;
  // === MÉCANIQUES SPÉCIALES ===
  /// Liste des mécaniques spéciales de la carte
  /// Ex: sacrifice de carte, destruction d'enchantement, pioche conditionnelle, etc.
  final List<CardMechanic> _mechanics;
  // === MÉCANIQUES SPÉCIALES ===
  /// Liste des mécaniques spéciales de la carte
  /// Ex: sacrifice de carte, destruction d'enchantement, pioche conditionnelle, etc.
  @override
  @JsonKey()
  List<CardMechanic> get mechanics {
    if (_mechanics is EqualUnmodifiableListView) return _mechanics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mechanics);
  }

  // === UI ===
  /// URL de l'image de la carte
  @override
  final String? imageUrl;

  /// Texte d'ambiance / flavor text
  @override
  final String? flavorText;

  @override
  String toString() {
    return 'GameCard(id: $id, name: $name, type: $type, color: $color, description: $description, launcherCost: $launcherCost, targetEffect: $targetEffect, damageIfRefused: $damageIfRefused, gameEffect: $gameEffect, drawCards: $drawCards, drawCardsWhite: $drawCardsWhite, drawCardsBlue: $drawCardsBlue, drawCardsYellow: $drawCardsYellow, drawCardsRed: $drawCardsRed, drawCardsPerTurn: $drawCardsPerTurn, removeClothing: $removeClothing, addClothing: $addClothing, destroyEnchantment: $destroyEnchantment, destroyAllEnchantments: $destroyAllEnchantments, replaceEnchantment: $replaceEnchantment, sacrificeCard: $sacrificeCard, discardCard: $discardCard, opponentDraw: $opponentDraw, opponentRemoveClothing: $opponentRemoveClothing, shuffleHandIntoDeck: $shuffleHandIntoDeck, piDamageOpponent: $piDamageOpponent, piGainSelf: $piGainSelf, tensionIncrease: $tensionIncrease, piCost: $piCost, isEnchantment: $isEnchantment, enchantmentTargets: $enchantmentTargets, recurringEffects: $recurringEffects, statusModifiers: $statusModifiers, tensionPerTurn: $tensionPerTurn, maxPerDeck: $maxPerDeck, mechanics: $mechanics, imageUrl: $imageUrl, flavorText: $flavorText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.launcherCost, launcherCost) ||
                other.launcherCost == launcherCost) &&
            (identical(other.targetEffect, targetEffect) ||
                other.targetEffect == targetEffect) &&
            (identical(other.damageIfRefused, damageIfRefused) ||
                other.damageIfRefused == damageIfRefused) &&
            (identical(other.gameEffect, gameEffect) ||
                other.gameEffect == gameEffect) &&
            (identical(other.drawCards, drawCards) ||
                other.drawCards == drawCards) &&
            (identical(other.drawCardsWhite, drawCardsWhite) ||
                other.drawCardsWhite == drawCardsWhite) &&
            (identical(other.drawCardsBlue, drawCardsBlue) ||
                other.drawCardsBlue == drawCardsBlue) &&
            (identical(other.drawCardsYellow, drawCardsYellow) ||
                other.drawCardsYellow == drawCardsYellow) &&
            (identical(other.drawCardsRed, drawCardsRed) ||
                other.drawCardsRed == drawCardsRed) &&
            (identical(other.drawCardsPerTurn, drawCardsPerTurn) ||
                other.drawCardsPerTurn == drawCardsPerTurn) &&
            (identical(other.removeClothing, removeClothing) ||
                other.removeClothing == removeClothing) &&
            (identical(other.addClothing, addClothing) ||
                other.addClothing == addClothing) &&
            (identical(other.destroyEnchantment, destroyEnchantment) ||
                other.destroyEnchantment == destroyEnchantment) &&
            (identical(other.destroyAllEnchantments, destroyAllEnchantments) ||
                other.destroyAllEnchantments == destroyAllEnchantments) &&
            (identical(other.replaceEnchantment, replaceEnchantment) ||
                other.replaceEnchantment == replaceEnchantment) &&
            (identical(other.sacrificeCard, sacrificeCard) ||
                other.sacrificeCard == sacrificeCard) &&
            (identical(other.discardCard, discardCard) ||
                other.discardCard == discardCard) &&
            (identical(other.opponentDraw, opponentDraw) ||
                other.opponentDraw == opponentDraw) &&
            (identical(other.opponentRemoveClothing, opponentRemoveClothing) ||
                other.opponentRemoveClothing == opponentRemoveClothing) &&
            (identical(other.shuffleHandIntoDeck, shuffleHandIntoDeck) ||
                other.shuffleHandIntoDeck == shuffleHandIntoDeck) &&
            (identical(other.piDamageOpponent, piDamageOpponent) ||
                other.piDamageOpponent == piDamageOpponent) &&
            (identical(other.piGainSelf, piGainSelf) ||
                other.piGainSelf == piGainSelf) &&
            (identical(other.tensionIncrease, tensionIncrease) ||
                other.tensionIncrease == tensionIncrease) &&
            (identical(other.piCost, piCost) || other.piCost == piCost) &&
            (identical(other.isEnchantment, isEnchantment) ||
                other.isEnchantment == isEnchantment) &&
            const DeepCollectionEquality().equals(
              other._enchantmentTargets,
              _enchantmentTargets,
            ) &&
            const DeepCollectionEquality().equals(
              other._recurringEffects,
              _recurringEffects,
            ) &&
            const DeepCollectionEquality().equals(
              other._statusModifiers,
              _statusModifiers,
            ) &&
            (identical(other.tensionPerTurn, tensionPerTurn) ||
                other.tensionPerTurn == tensionPerTurn) &&
            (identical(other.maxPerDeck, maxPerDeck) ||
                other.maxPerDeck == maxPerDeck) &&
            const DeepCollectionEquality().equals(
              other._mechanics,
              _mechanics,
            ) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.flavorText, flavorText) ||
                other.flavorText == flavorText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    type,
    color,
    description,
    launcherCost,
    targetEffect,
    damageIfRefused,
    gameEffect,
    drawCards,
    drawCardsWhite,
    drawCardsBlue,
    drawCardsYellow,
    drawCardsRed,
    drawCardsPerTurn,
    removeClothing,
    addClothing,
    destroyEnchantment,
    destroyAllEnchantments,
    replaceEnchantment,
    sacrificeCard,
    discardCard,
    opponentDraw,
    opponentRemoveClothing,
    shuffleHandIntoDeck,
    piDamageOpponent,
    piGainSelf,
    tensionIncrease,
    piCost,
    isEnchantment,
    const DeepCollectionEquality().hash(_enchantmentTargets),
    const DeepCollectionEquality().hash(_recurringEffects),
    const DeepCollectionEquality().hash(_statusModifiers),
    tensionPerTurn,
    maxPerDeck,
    const DeepCollectionEquality().hash(_mechanics),
    imageUrl,
    flavorText,
  ]);

  /// Create a copy of GameCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameCardImplCopyWith<_$GameCardImpl> get copyWith =>
      __$$GameCardImplCopyWithImpl<_$GameCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameCardImplToJson(this);
  }
}

abstract class _GameCard implements GameCard {
  const factory _GameCard({
    required final String id,
    required final String name,
    required final CardType type,
    required final CardColor color,
    final String? description,
    required final String launcherCost,
    final String? targetEffect,
    final int damageIfRefused,
    required final String gameEffect,
    final int drawCards,
    final int drawCardsWhite,
    final int drawCardsBlue,
    final int drawCardsYellow,
    final int drawCardsRed,
    final int drawCardsPerTurn,
    final int removeClothing,
    final int addClothing,
    final int destroyEnchantment,
    final bool destroyAllEnchantments,
    final int replaceEnchantment,
    final int sacrificeCard,
    final int discardCard,
    final int opponentDraw,
    final int opponentRemoveClothing,
    final bool shuffleHandIntoDeck,
    final int piDamageOpponent,
    final int piGainSelf,
    final int tensionIncrease,
    final int piCost,
    final bool isEnchantment,
    final Map<String, String> enchantmentTargets,
    final List<Map<String, dynamic>> recurringEffects,
    final List<Map<String, dynamic>> statusModifiers,
    final int? tensionPerTurn,
    final int? maxPerDeck,
    final List<CardMechanic> mechanics,
    final String? imageUrl,
    final String? flavorText,
  }) = _$GameCardImpl;

  factory _GameCard.fromJson(Map<String, dynamic> json) =
      _$GameCardImpl.fromJson;

  /// ID unique de la carte
  @override
  String get id;

  /// Nom de la carte
  @override
  String get name;

  /// Type de carte (Instantané, Rituel, Enchantement)
  @override
  CardType get type;

  /// Couleur/Niveau de la carte
  @override
  CardColor get color;

  /// Description complète de la carte (optionnelle)
  @override
  String? get description; // === COÛTS ET EFFETS ===
  /// Coût IRL pour le lanceur (ce que TU dois faire pour jouer la carte)
  /// Ex: "Aucun", "Enlever 2 vêtements", "Danse sensuelle 30 sec"
  @override
  String get launcherCost;

  /// Effet IRL sur la cible (ce que l'adversaire doit faire)
  /// Ex: "Enlever 1 vêtement", "Massage 1 minute", "Compliment sincère"
  /// Peut être null pour certaines cartes (ex: Pioche)
  @override
  String? get targetEffect;

  /// Dégâts infligés si la cible refuse l'effet IRL
  @override
  int get damageIfRefused;

  /// Description de l'effet en jeu (texte descriptif)
  /// Ex: "Piocher 2 cartes", "Détruire un enchantement ciblé"
  @override
  String get gameEffect; // === EFFETS STRUCTURÉS (GAMEPLAY) ===
  /// Nombre de cartes à piocher immédiatement (0 = aucune)
  @override
  int get drawCards;

  /// Nombre de cartes a piocher par palier (cartes fusionnees)
  @override
  int get drawCardsWhite;
  @override
  int get drawCardsBlue;
  @override
  int get drawCardsYellow;
  @override
  int get drawCardsRed;

  /// Nombre de cartes à piocher par tour (enchantements uniquement)
  @override
  int get drawCardsPerTurn;

  /// Nombre de vêtements que le lanceur retire (0 = aucun)
  @override
  int get removeClothing;

  /// Nombre de vêtements que le lanceur remet (0 = aucun)
  @override
  int get addClothing;

  /// Nombre d'enchantements à détruire (0 = aucun)
  @override
  int get destroyEnchantment;

  /// Détruire tous les enchantements (false = non)
  @override
  bool get destroyAllEnchantments;

  /// Nombre d'enchantements à remplacer (0 = aucun)
  @override
  int get replaceEnchantment;

  /// Nombre de cartes à sacrifier (0 = aucune)
  @override
  int get sacrificeCard;

  /// Nombre de cartes à défausser (0 = aucune)
  @override
  int get discardCard;

  /// Nombre de cartes que l'adversaire pioche (0 = aucune)
  @override
  int get opponentDraw;

  /// Nombre de vêtements que l'adversaire retire par tour (enchantements)
  @override
  int get opponentRemoveClothing;

  /// Mélanger la main dans le deck (false = non)
  @override
  bool get shuffleHandIntoDeck;

  /// Dégâts PI à l'adversaire (0 = aucun)
  @override
  int get piDamageOpponent;

  /// Gain PI pour le lanceur (0 = aucun)
  @override
  int get piGainSelf;

  /// Augmentation de tension pour le lanceur (0 = aucune)
  @override
  int get tensionIncrease;

  /// Coût en PI pour lancer la carte (0 = gratuit)
  @override
  int get piCost;

  /// Est-ce un enchantement permanent qui reste en jeu
  @override
  bool get isEnchantment; // === SPÉCIFIQUE AUX ENCHANTEMENTS ===
  /// Détermine qui doit voir/appliquer l'effet selon le palier (owner/opponent/both)
  @override
  Map<String, String> get enchantmentTargets;

  /// Effets récurrents (ex: pioche +1 au début du tour)
  @override
  List<Map<String, dynamic>> get recurringEffects;

  /// Modificateurs persistants (ex: PI bloqués)
  @override
  List<Map<String, dynamic>> get statusModifiers;

  /// Gain de tension par tour pour le lanceur (null si pas un enchantement)
  /// Ex: 1, 3, 5, 7 ou null
  @override
  int? get tensionPerTurn; // === DECK ===
  /// Nombre maximum d'exemplaires dans le deck
  /// null = 4 exemplaires (défaut), 1 = unique (Ultima), 2 = limité
  @override
  int? get maxPerDeck; // === MÉCANIQUES SPÉCIALES ===
  /// Liste des mécaniques spéciales de la carte
  /// Ex: sacrifice de carte, destruction d'enchantement, pioche conditionnelle, etc.
  @override
  List<CardMechanic> get mechanics; // === UI ===
  /// URL de l'image de la carte
  @override
  String? get imageUrl;

  /// Texte d'ambiance / flavor text
  @override
  String? get flavorText;

  /// Create a copy of GameCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameCardImplCopyWith<_$GameCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
