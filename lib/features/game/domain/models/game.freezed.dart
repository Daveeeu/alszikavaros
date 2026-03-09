// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Game _$GameFromJson(Map<String, dynamic> json) {
  return _Game.fromJson(json);
}

/// @nodoc
mixin _$Game {
  String get id => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  GamePhase get phase => throw _privateConstructorUsedError;
  int get dayNumber => throw _privateConstructorUsedError;
  WinnerType get winner => throw _privateConstructorUsedError;
  List<String> get alivePlayerIds => throw _privateConstructorUsedError;

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCopyWith<Game> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) then) =
      _$GameCopyWithImpl<$Res, Game>;
  @useResult
  $Res call(
      {String id,
      String roomId,
      GamePhase phase,
      int dayNumber,
      WinnerType winner,
      List<String> alivePlayerIds});
}

/// @nodoc
class _$GameCopyWithImpl<$Res, $Val extends Game>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? phase = null,
    Object? dayNumber = null,
    Object? winner = null,
    Object? alivePlayerIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as GamePhase,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      winner: null == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as WinnerType,
      alivePlayerIds: null == alivePlayerIds
          ? _value.alivePlayerIds
          : alivePlayerIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameImplCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$$GameImplCopyWith(
          _$GameImpl value, $Res Function(_$GameImpl) then) =
      __$$GameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String roomId,
      GamePhase phase,
      int dayNumber,
      WinnerType winner,
      List<String> alivePlayerIds});
}

/// @nodoc
class __$$GameImplCopyWithImpl<$Res>
    extends _$GameCopyWithImpl<$Res, _$GameImpl>
    implements _$$GameImplCopyWith<$Res> {
  __$$GameImplCopyWithImpl(_$GameImpl _value, $Res Function(_$GameImpl) _then)
      : super(_value, _then);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? phase = null,
    Object? dayNumber = null,
    Object? winner = null,
    Object? alivePlayerIds = null,
  }) {
    return _then(_$GameImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as GamePhase,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      winner: null == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as WinnerType,
      alivePlayerIds: null == alivePlayerIds
          ? _value._alivePlayerIds
          : alivePlayerIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameImpl implements _Game {
  const _$GameImpl(
      {required this.id,
      required this.roomId,
      required this.phase,
      required this.dayNumber,
      required this.winner,
      required final List<String> alivePlayerIds})
      : _alivePlayerIds = alivePlayerIds;

  factory _$GameImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameImplFromJson(json);

  @override
  final String id;
  @override
  final String roomId;
  @override
  final GamePhase phase;
  @override
  final int dayNumber;
  @override
  final WinnerType winner;
  final List<String> _alivePlayerIds;
  @override
  List<String> get alivePlayerIds {
    if (_alivePlayerIds is EqualUnmodifiableListView) return _alivePlayerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alivePlayerIds);
  }

  @override
  String toString() {
    return 'Game(id: $id, roomId: $roomId, phase: $phase, dayNumber: $dayNumber, winner: $winner, alivePlayerIds: $alivePlayerIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.winner, winner) || other.winner == winner) &&
            const DeepCollectionEquality()
                .equals(other._alivePlayerIds, _alivePlayerIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, roomId, phase, dayNumber,
      winner, const DeepCollectionEquality().hash(_alivePlayerIds));

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      __$$GameImplCopyWithImpl<_$GameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameImplToJson(
      this,
    );
  }
}

abstract class _Game implements Game {
  const factory _Game(
      {required final String id,
      required final String roomId,
      required final GamePhase phase,
      required final int dayNumber,
      required final WinnerType winner,
      required final List<String> alivePlayerIds}) = _$GameImpl;

  factory _Game.fromJson(Map<String, dynamic> json) = _$GameImpl.fromJson;

  @override
  String get id;
  @override
  String get roomId;
  @override
  GamePhase get phase;
  @override
  int get dayNumber;
  @override
  WinnerType get winner;
  @override
  List<String> get alivePlayerIds;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
