// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerState {
  TimerStatus get status => throw _privateConstructorUsedError;
  int get remainingSeconds =>
      throw _privateConstructorUsedError; // Temps restant en secondes
  int get totalSeconds => throw _privateConstructorUsedError;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerStateCopyWith<TimerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateCopyWith<$Res> {
  factory $TimerStateCopyWith(
    TimerState value,
    $Res Function(TimerState) then,
  ) = _$TimerStateCopyWithImpl<$Res, TimerState>;
  @useResult
  $Res call({TimerStatus status, int remainingSeconds, int totalSeconds});
}

/// @nodoc
class _$TimerStateCopyWithImpl<$Res, $Val extends TimerState>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? remainingSeconds = null,
    Object? totalSeconds = null,
  }) {
    return _then(
      _value.copyWith(
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as TimerStatus,
            remainingSeconds:
                null == remainingSeconds
                    ? _value.remainingSeconds
                    : remainingSeconds // ignore: cast_nullable_to_non_nullable
                        as int,
            totalSeconds:
                null == totalSeconds
                    ? _value.totalSeconds
                    : totalSeconds // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimerStateImplCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$$TimerStateImplCopyWith(
    _$TimerStateImpl value,
    $Res Function(_$TimerStateImpl) then,
  ) = __$$TimerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TimerStatus status, int remainingSeconds, int totalSeconds});
}

/// @nodoc
class __$$TimerStateImplCopyWithImpl<$Res>
    extends _$TimerStateCopyWithImpl<$Res, _$TimerStateImpl>
    implements _$$TimerStateImplCopyWith<$Res> {
  __$$TimerStateImplCopyWithImpl(
    _$TimerStateImpl _value,
    $Res Function(_$TimerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? remainingSeconds = null,
    Object? totalSeconds = null,
  }) {
    return _then(
      _$TimerStateImpl(
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as TimerStatus,
        remainingSeconds:
            null == remainingSeconds
                ? _value.remainingSeconds
                : remainingSeconds // ignore: cast_nullable_to_non_nullable
                    as int,
        totalSeconds:
            null == totalSeconds
                ? _value.totalSeconds
                : totalSeconds // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

class _$TimerStateImpl extends _TimerState {
  const _$TimerStateImpl({
    this.status = TimerStatus.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
  }) : super._();

  @override
  @JsonKey()
  final TimerStatus status;
  @override
  @JsonKey()
  final int remainingSeconds;
  // Temps restant en secondes
  @override
  @JsonKey()
  final int totalSeconds;

  @override
  String toString() {
    return 'TimerState(status: $status, remainingSeconds: $remainingSeconds, totalSeconds: $totalSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.totalSeconds, totalSeconds) ||
                other.totalSeconds == totalSeconds));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, status, remainingSeconds, totalSeconds);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      __$$TimerStateImplCopyWithImpl<_$TimerStateImpl>(this, _$identity);
}

abstract class _TimerState extends TimerState {
  const factory _TimerState({
    final TimerStatus status,
    final int remainingSeconds,
    final int totalSeconds,
  }) = _$TimerStateImpl;
  const _TimerState._() : super._();

  @override
  TimerStatus get status;
  @override
  int get remainingSeconds; // Temps restant en secondes
  @override
  int get totalSeconds;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
